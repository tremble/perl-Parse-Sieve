package Parse::Sieve;

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

use Parse::RecDescent;
use Parse::Sieve::Factory qw(createCommand createTest);
use Parse::Sieve::Factory::RFC5228;
use Parse::Sieve::Command;
use Parse::Sieve::Block;
use Parse::Sieve::Test;
use Parse::Sieve::Script;
use Parse::Sieve::Grammar;

use strict;
use warnings;
use vars qw($VERSION);

$VERSION = '1.00';

sub new
{
	my ($class, $param) = @_;
	my $self = bless ({}, ref ($class) || $class);

	$self->{'parser'} = new Parse::Sieve::Grammar ();

	return $self;
}

sub parse {
	my $self = shift;
	my $script = shift;
	return $self->{'parser'}->start($script);
}

sub commands {
	my $self = shift;
	my $script = shift;
	my @commands = $self->{'parser'}->commands($script);
	return @{$commands[0]};
}

sub block {
	my $self = shift;
	my $script = shift;
	return $self->{'parser'}->block($script);
}

sub test {
	my $self = shift;
	my $script = shift;
	return $self->{'parser'}->test($script);
}

sub string {
	my $self = shift;
	my $script = shift;
	return $self->{'parser'}->string($script);
}

1;
