package Parse::Sieve::Test;

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
use base qw(Parse::Sieve::Base);

use vars qw($VERSION);

$VERSION = '1.00';

__PACKAGE__->mk_accessors(qw(not));

my $ID = 1;
my @EMPTY = ();

sub new
{
    my $type = shift;
	my (undef, undef, undef, $arguments, @args) = @_;

	my (%param) = @args;

	# We make a special case for not, because it gets messy otherwise.
	if (lc($param{'identifier'}) eq 'not') {
		return if (ref($param{'arguments'}) ne 'HASH');
		return if (ref($param{'arguments'}->{'tests'}) ne 'ARRAY');
		my $test = $param{'arguments'}->{'tests'}->[0];
		if (defined $test->not && $test->not eq 'not') {
			$test->set('not',undef);
		} else {
			$test->not('not');
		}

		return $test;
	}

    my $self = Parse::Sieve::Base->new(@_);
    return unless (defined $self);

    bless $self,$type;

    return $self;
}

sub clone
{
    my $self = shift;
    my $clone = $self->Parse::Sieve::Base::clone();
    bless $clone,'Parse::Sieve::Test';
	$clone->not($self->not);
    return $clone;
}

sub toString
{
	my $self = shift;
	my $line = q{};
	$line .= 'not ' if ($self->not());

	return $line . $self->Parse::Sieve::Base::toString(@_);
}

1;
