package Parse::Sieve::Argument::OptionalStringList;

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
use base qw(Parse::Sieve::Argument::StringList);

use vars qw($VERSION);

$VERSION = '1.00';

sub new
{
	my $type = shift;
	my %param =();
	%param = @_;
	my $self = Parse::Sieve::Argument::StringList->new(@_);
	return unless (defined $self);

	bless $self,$type;

	return $self;
}

sub clone
{
	my $self = shift;
	my $clone = $self->Parse::Sieve::Argument::StringList::clone(@_);
	$clone->{'options'} = $self->{'options'};
	bless $clone,'Parse::Sieve::Argument::OptionalStringList';
	return $clone;
}

sub popvalue
{
	my $self = shift;
	my $args = shift;
	my $value = $self->Parse::Sieve::Argument::StringList::popvalue($args,@_);
	return $value || 1;
}

1;
