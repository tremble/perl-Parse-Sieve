package Parse::Sieve::Base;

# $URL$
# $Rev$
# $Date$
# $Id$
#
# Copyright 2010 Mark Chappell - <tremble@tremble.org.uk>
#
# This program is free software; you can redistribute
# it and/or modify it under the same terms as Perl itself.
# 
# The full text of the license can be found in the
# LICENSE file included with this module.
#

use strict;
use warnings;
use Data::Dumper;
use base qw(Class::Accessor::Fast);

use vars qw($VERSION);

$VERSION = '1.00';

__PACKAGE__->mk_accessors(qw(identifier id requires));

my $ID = 1;
my @EMPTY = ();

sub new
{
	my ($class, $addressparts, $matchtypes, $comparators,
		$arguments, @params) = @_;

	my $self = bless ({}, ref ($class) || $class);
	$self->{'addressparts'} = $addressparts;
	$self->{'matchtypes'} = $matchtypes;
	$self->{'comparators'} = $comparators;
	
	{
		my @tagged = ();
		$self->{'_args'}{'tagged'} = \@tagged;
		my @optional = ();
		$self->{'_args'}{'optional'} = \@optional;
		my @positional = ();
		$self->{'_args'}{'positional'} = \@positional;
	}
	foreach my $arg (@{$arguments}) {
		my $tmp = $self->{'_args'}{$arg->type};
		my $clone = $arg->clone;
		$clone->addressparts($addressparts);
		$clone->matchtypes($matchtypes);
		$clone->comparators($comparators);
		push @{$tmp}, $clone;
	}

	$self->id($ID++);

	return $self unless (@params);

	my (%param) = @params;

	# See RFC 5228
	# $param{'identifier'} - Name of the object
	# $param{'requires'} - Capability Requirements
	# $param{'arguments'} - "*argument"
	# $param{'tests'} - test / test-list following "*argument"

	$self->identifier($param{'identifier'});
	$self->requires($param{'requires'});

	my $args = $param{'arguments'};
	my @instanceargs = ();
	if (ref($args) eq 'HASH' && ref($args->{'arguments'}) eq 'ARRAY') {
		@instanceargs = @{$args->{'arguments'}};
	}

	# RFC 5228 
	# 8.2. Grammar
	# arguments	= *argument [ test / test-list ]
	# Tests always come last...
	if ($args->{'tests'}) {
			my %t = ('tests' => $args->{'tests'});
			push @instanceargs, \%t;
	}
	$self->parse(\@instanceargs);
	return $self;
}

sub parse {
	my $self = shift;
	my $instanceargs = shift;

	# First we remove the required args, in reverse order
	foreach my $positional ( reverse ( @{ $self->{'_args'}{'positional'} } ) ) {
		my $value = $positional->popvalue($instanceargs);
		if (! $value) {
			warn $self->identifier . ' : ' 
				. 'Unable to find valid value for Positional Argument ' 
				. $positional->name . "\n";
		}
	}
	# Next we deal with the tagged args
	foreach my $tagged ( @{ $self->{'_args'}{'tagged'} } ) {
		my $value = $tagged->popvalue($instanceargs);
		if (! $value) {
			warn $self->identifier . ' : '
				. 'Unable to find valid value for Tagged Argument ' 
				. $tagged->name . "\n";
		}
	}
	# Finally we deal with the optional args
	foreach my $optional ( @{ $self->{'_args'}{'optional'} } ) {
		next if (! scalar @{$instanceargs});
		$optional->popvalue($instanceargs);
	}
	
	my @iargs = grep {$_} @{$instanceargs};

	if (scalar @iargs) {
		warn $self->identifier . " : Unknown extra arguments\n";
	}

	return $self;
}

sub clone
{
	my $self = shift;

	my $addressparts = $self->{'addressparts'};
	my $matchtypes = $self->{'matchtypes'};
	my $comparators = $self->{'comparators'};
	my @arguments = ();
	foreach my $arg ( reverse ( @{ $self->{'_args'}{'tagged'} } ) ) {
		push @arguments, $arg->clone();
	}
	foreach my $arg ( reverse ( @{ $self->{'_args'}{'optional'} } ) ) {
		push @arguments, $arg->clone();
	}
	foreach my $arg ( reverse ( @{ $self->{'_args'}{'positional'} } ) ) {
		push @arguments, $arg->clone();
	}

	my $clone = new Parse::Sieve::Base(
		$addressparts, $matchtypes, $comparators,
		\@arguments);
	
	$clone->identifier($self->identifier);
	$clone->requires($self->requires);

	return $clone;
}

sub toString
{
	my $self = shift;
	my $line = q{} . ( $self->identifier() || q{} );

	foreach my $arg (@{$self->{'_args'}{'tagged'}}) {
		my $text = $arg->toString(@_);
		$line .= q{ } . $text unless ($text eq q{});
	}
	foreach my $arg (@{$self->{'_args'}{'optional'}}) {
		my $text = $arg->toString(@_);
		$line .= q{ } . $text unless ($text eq q{});
	}
	foreach my $arg (@{$self->{'_args'}{'positional'}}) {
		my $text = $arg->toString(@_);
		$line .= q{ } . $text unless ($text eq q{});
	}

	return $line;
}

sub getArgument
{
	my $self = shift;
	my $argname = shift;
	return unless ($argname);
	$argname = lc($argname);

	foreach my $arg (@{$self->{'_args'}{'tagged'}}) {
		return $arg if (lc($arg->name) eq $argname);
	}
	foreach my $arg (@{$self->{'_args'}{'optional'}}) {
		return $arg if (lc($arg->name) eq $argname);
	}
	foreach my $arg (@{$self->{'_args'}{'positional'}}) {
		return $arg if (lc($arg->name) eq $argname);
	}

	return;
}

# According to the grammar this can happen with any set of arguments
# This occurs with things like anyof,allof,not
#
# This is simply a getter!
sub tests
{
	my $self = shift;
	my @positional = @{$self->{'_args'}{'positional'}};
	my @tmp = ();
	my $arg = $positional[-1];
	return @tmp if (! $arg);
	return @tmp if (ref($arg->value) ne 'ARRAY');
	foreach my $test (@{$arg->value}) {
		return @tmp if (! ref $test);
		return @tmp if (! $test->isa('Parse::Sieve::Test'));
	}
	@tmp = @{$arg->value};
	return @tmp;
}

sub deleteTest
{
	my $self = shift;
	my $id = shift;
	if (ref($id) && $id->can('id')) {
		$id = $id->id;
	}
	my $deleted = undef;

	foreach my $positional ( reverse ( @{ $self->{'_args'}{'positional'} } ) ) {
		if (ref($positional) && $positional->can('deleteTest')){
			my $d = $positional->deleteTest($id) ;
			$deleted = $d if ($d);
		}
	}
	foreach my $tagged ( @{ $self->{'_args'}{'tagged'} } ) {
		if (ref($tagged) && $tagged->can('deleteTest')){
			my $d = $tagged->deleteTest($id) ;
			$deleted = $d if ($d);
		}
	}
	foreach my $optional ( @{ $self->{'_args'}{'optional'} } ) {
		if (ref($optional) && $optional->can('deleteTest')){
			my $d = $optional->deleteTest($id) ;
			$deleted = $d if ($d);
		}
	}
	
	return $deleted;
}

sub sieverequire {
	my $self = shift;
	my @reqs = ();
	push @reqs, $self->requires if ($self->requires);
	foreach my $positional ( reverse ( @{ $self->{'_args'}{'positional'} } ) ) {
		push @reqs, $positional->requires()
			if ($positional->requires() && defined $positional->value);
	}
	foreach my $tagged ( @{ $self->{'_args'}{'tagged'} } ) {
		push @reqs, $tagged->requires()
			if ($tagged->requires() && defined $tagged->value);
	}
	foreach my $optional ( @{ $self->{'_args'}{'optional'} } ) {
		push @reqs, $optional->requires()
			if ($optional->requires() && defined $optional->value );
	}
	foreach my $test ( $self->tests ) {
		push @reqs, $test->requires() if ($test->requires());
	}
	return (@reqs);
}

1;
