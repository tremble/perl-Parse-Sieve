package Parse::Sieve::Argument::String;

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

sub popvalue
{
	my $self = shift;
	my $value = $self->Parse::Sieve::Argument::StringList::popvalue(@_);
	return if (! ( ref $value eq 'ARRAY' ) );
	$value = $value->[0];
	$self->value($value);
	return $value;
}

sub clone
{
	my $self = shift;
	my $clone = $self->Parse::Sieve::Argument::StringList::clone(@_);
	bless $clone,'Parse::Sieve::Argument::String';
	return $clone;
}

sub isValidValue
{
	my $self = shift;
	return 0 if (! $self->Parse::Sieve::Argument::StringList::isValidValue(@_));
	my $value = shift;
	return ( scalar(@{$value->{'stringlist'}}) == 1 );
}

sub toString
{
	my $self = shift;
	my $value = $self->value;
	return q{} if (!$value);

	$value = $self->toStringSingle($value);

	return $self->Parse::Sieve::Argument::StringList::_toString($value, @_);
}


1;
