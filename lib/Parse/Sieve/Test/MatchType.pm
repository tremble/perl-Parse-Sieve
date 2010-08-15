package Parse::Sieve::Test::MatchType;

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

__PACKAGE__->mk_accessors(qw(name requires));

my @EMPTY = ();

sub new
{
	my $class = shift;
	my %param =();
	%param = @_;

	my $self = bless ({}, ref ($class) || $class);

	$self->name( lc($param{'name'}) );
	$self->{'applies'} = $param{'applies'};
	$self->requires($param{'requires'});

	return $self;
}

sub applies
{
	my $self = shift;
	my %param =();
	%param = @_;
	return;
}

1;
