package Parse::Sieve::Argument::AddressPart;

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
			options => \@EMPTY,
			type => 'optional',
			@_);
	return unless (defined $self);
	
	bless $self,$type;

	# RFC 5228
	# 2.7.3. Comparisons against Addresses
	# ... If an optional address-part is omitted, the default is ":all".  ...
	$self->value(':all');

	return $self;
}

sub clone
{
	my $self = shift;
	my $clone = $self->Parse::Sieve::Argument::AlternateTag::clone(@_);
	bless $clone,'Parse::Sieve::Argument::AddressPart';
	return $clone;
}

sub isValidTag
{
	my $self = shift;
	my $parts = $self->addressparts;
	my @keys = keys(%{$parts});
	$self->{'options'} = \@keys;
	return $self->Parse::Sieve::Argument::AlternateTag::isValidTag(@_);
}

sub toString
{
	my $self = shift;
	return q{} if ($self->value eq ':all');
	return $self->Parse::Sieve::Argument::AlternateTag::toString(@_);
}

sub requires
{
	my $self = shift;
	return if ($self->value eq ':all');
	return if (! $self->addressparts );
	return if (! $self->addressparts->{$self->value} );
	return $self->addressparts->{$self->value}->requires;
}

1;
