package Parse::Sieve::Argument::Tests;

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

use base qw(Parse::Sieve::Argument);
use vars qw($VERSION);

use Parse::Sieve::Block;

$VERSION = '1.00';

sub new
{
	my $type = shift;
	my %param =();
	%param = @_;
	my $self = Parse::Sieve::Argument->new(@_);
	return unless (defined $self);

	bless $self,$type;

	return $self;
}

sub clone
{
	my $self = shift;
	my $clone = $self->Parse::Sieve::Argument::clone(@_);
	$clone->{'options'} = $self->{'options'};
	bless $clone,'Parse::Sieve::Argument::Tests';
	return $clone;
}

sub isValidValue
{
	my $self = shift;
	return 0 if (! $self->Parse::Sieve::Argument::isValidValue(@_));
	my $value = shift;
	return 0 if (ref($value) ne 'HASH');
	return ref($value->{'tests'}) eq 'ARRAY';
}

sub toString
{
	my $self = shift;
	my $indent = shift;
	my $indentation = Parse::Sieve::Block::getIndentation();
	my $value = $self->value;
	return q{} unless ($value);
	# Brackets not *needed* for single tests
	if (scalar(@{$value}) == 1) {
		return $value->[0]->toString($indent,@_);
	}
	my $string = q{};
	foreach my $val (@{$value}) {
		$string .= ', ' unless ($string eq q{});
		$string .= $val ;
	}
	my $in = q{};
	foreach (0..$indent) {
		$in .= $indentation;
	};
	return '(' . join (",\n$in", map {$_->toString($indent,@_)} @{$value}) .')';
}

sub deleteTest
{
	my $self = shift;
	my $id = shift;
	if (ref($id) && $id->can('id')) {
		$id = $id->id;
	}
	my $deleted = undef;
	my @tests =  @{$self->value};
	
	for my $testindex (0..$#tests) {
		my $test = $tests[$testindex];
		my $next=$testindex+1;
		if ($test->id == $id){
			$deleted = $tests[$testindex];
			delete $tests[$testindex];
		}
	}
	@tests = grep { $_ } @tests;
	$self->set('value',\@tests) if ($deleted);
	
	return $deleted;
}

1;
