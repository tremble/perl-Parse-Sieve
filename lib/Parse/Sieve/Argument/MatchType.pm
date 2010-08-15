package Parse::Sieve::Argument::MatchType;

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
use base qw(Parse::Sieve::Argument::AlternateTag);

use vars qw($VERSION);

$VERSION = '1.00';

sub new
{
	my $type = shift;
	my @EMPTY = ();
	my $self = Parse::Sieve::Argument::AlternateTag->new(
			type => 'optional',
			hasvalue => 0,
			options => \@EMPTY,
			@_);
	return unless (defined $self);
	
	bless $self,$type;

	# RFC 5228
	# 2.7.1. Match Type
	# ... Commands default to using ":is" matching if no match type argument 	
	# is supplied. ...
	$self->value(':is');

	return $self;
}

sub clone
{
	my $self = shift;
	my $clone = $self->Parse::Sieve::Argument::AlternateTag::clone(@_);
	bless $clone,'Parse::Sieve::Argument::MatchType';
	return $clone;
}

sub isValidTag
{
	my $self = shift;
	my $matches = $self->matchtypes;
	my @keys = keys(%{$matches});
	$self->{'options'} = \@keys;
	return $self->Parse::Sieve::Argument::AlternateTag::isValidTag(@_);
}

sub toString
{
	my $self = shift;
	return q{} if ($self->value eq ':is');
	return $self->Parse::Sieve::Argument::AlternateTag::toString(@_);
}

sub requires
{
	my $self = shift;
	return if ($self->value eq ':is');
	return if (! $self->matchtypes );
	return if (! $self->matchtypes->{$self->value} );
	return $self->matchtypes->{$self->value}->requires;
}

1;
