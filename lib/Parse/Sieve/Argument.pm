package Parse::Sieve::Argument;

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
use base qw(Class::Accessor::Fast);

use vars qw($VERSION);

$VERSION = '1.00';

__PACKAGE__->mk_accessors(qw(name value comparators addressparts matchtypes tag requires hasvalue id));
__PACKAGE__->mk_ro_accessors(qw(type));

my @EMPTY = ();
my $ID = 1;

sub new
{
	my $class = shift;
	my %param =();
	%param = @_;

	my $self = bless ({}, ref ($class) || $class);

	# tagged, optional, positional
	$self->set ( 'type', lc($param{'type'}) );
	$self->name ( lc($param{'name'}) );
	$self->tag ( lc($param{'tag'}) );
	$self->requires ( lc($param{'requires'}) );
	$self->hasvalue( defined $param{'hasvalue'}
						? $param{'hasvalue'}
						: 0 );
	$self->set('value', undef);
	
	$self->{'applies'} = $param{'applies'};

	return unless ( 0
		|| ($self->type eq 'tagged')
		|| ($self->type eq 'optional')
		|| ($self->type eq 'positional') );

	$self->id($ID++);

	return $self;
}

sub clone
{
	my $self = shift;
	my $clone = new Parse::Sieve::Argument(
			type =>  $self->type || undef ,
			name =>  $self->name || undef ,
			tag =>  $self->tag || undef ,
			requires => $self->requires || undef,
			applies =>  $self->{'applies'},
		);
	$clone->set('comparators', $self->comparators);
	$clone->set('addressparts', $self->addressparts);
	$clone->set('matchtypes', $self->matchtypes);
	$clone->set('value', $self->value);
	$clone->set('hasvalue', $self->hasvalue);
	return $clone;
}

sub applies
{
	my $self = shift;
	my %param =();
	%param = @_;
	if ($self->type eq 'tagged') {
	} elsif ($self->type eq 'optional') {
	} elsif ($self->type eq 'positional') {
	}
	return;
}

sub isValidTag {
	my $self = shift;
	my $tag = shift;
	return 0 if (! $self->tag) ;
	return 1 if (lc($self->tag) eq lc($tag));
	return 0;
}

sub isValidValue {
	my $self = shift;
	return 1;
}

sub popvalue
{
	my $self = shift;
	my $args = shift;
	return if (! ( ref $args eq 'ARRAY' ) ) ;
	if ($self->type eq 'positional') {
		my $popped = $args->[-1];
		return if (! defined $popped);
		return if (ref($popped) ne 'HASH');
		return if (! $self->isValidValue($popped) );
		pop @{$args};
		# argument     = string-list / number / tag
		if (defined $popped->{'stringlist'}) {
			$popped = $popped->{'stringlist'};
		} elsif (defined $popped->{'number'}) {
			$popped = $popped->{'number'};
		} elsif (defined $popped->{'tests'}) {
			# Strictly only valid as the last positional argument
			$popped = $popped->{'tests'};
		}
		$self->value($popped);
		return $popped;
	} else {
		return $self->popvalues($args, @_) if ($self->hasvalue());
		# tagged/optional without values;
		return if (! ( ref $args eq 'ARRAY' ) ) ;
		return if ( scalar @{$args} < 1);
	
		foreach my $index (0..($#{$args})) {
			my $element = $args->[$index];
			next if (ref($element) ne 'HASH');
			next if (! defined $element->{'tag'});
			if ( $self->isValidTag($element->{'tag'})) {
				my $value = $element->{'tag'};
				next if (! $self->isValidValue($value) );
				$self->value($value);
				delete $args->[$index];
				return $value;
			}
		}
	}
	return;
}

# tagged with values
sub popvalues
{
	my $self = shift;
	my $args = shift;
	return if (! ( ref $args eq 'ARRAY' ) ) ;
	return if scalar @{$args} < 2;

	foreach my $index (0..($#{$args}-1)) {
		my $element = $args->[$index];
		next if (ref($element) ne 'HASH');
		next if (! defined $element->{'tag'});
		if ( $self->isValidTag($element->{'tag'})) {
			my $value = $args->[$index+1];
			next if (! $self->isValidValue($value) );
			delete $args->[$index+1];
			delete $args->[$index];
			# argument     = string-list / number / tag
			if (defined $value->{'stringlist'}) {
				$value = $value->{'stringlist'};
			} elsif (defined $value->{'number'}) {
				$value = $value->{'number'};
			}
			$self->value($value);
			return $value;
		}
	}
	return;
}

sub toString
{
	my $self = shift;
	return $self->_toString($self->value,@_);
}

sub _toString
{
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		if ($self->type ne 'positional' && $self->hasvalue) {
			return $self->tag . q{ } . $value;
		}
		return $value;
	}
	return q{};
}

1;
