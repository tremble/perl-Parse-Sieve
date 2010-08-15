package Parse::Sieve::Argument::Numeric;

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

$VERSION = '1.00';

sub new
{
	my $type = shift;
	my %param =();
	%param = @_;
	my $self = Parse::Sieve::Argument->new(@_);
	return if (!defined $self);

	bless $self,$type;

	return $self;
}

sub isValidValue
{
	my $self = shift;
	return 0 if (! $self->Parse::Sieve::Argument::isValidValue(@_));
	my $value = shift;
	return 0 if (ref ($value) ne 'HASH');
	return 0 if (! defined ($value->{'number'}));
	return 1;
}

sub clone
{
	my $self = shift;
	my $clone = $self->Parse::Sieve::Argument::clone(@_);
	$clone->{'options'} = $self->{'options'};
	bless $clone,'Parse::Sieve::Argument::Numeric';
	return $clone;
}

1;
