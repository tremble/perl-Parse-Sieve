package Parse::Sieve::Argument::AlternateTag;

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
	return unless (defined $self);
	
	bless $self,$type;

	$self->{'options'} = $param{'options'};
	return unless (ref($param{'options'}) eq 'ARRAY');

	return $self;
}

sub clone
{
	my $self = shift;
	my $clone = $self->Parse::Sieve::Argument::clone(@_);
	$clone->{'options'} = $self->{'options'};
	bless $clone,'Parse::Sieve::Argument::AlternateTag';
	return $clone;
}

sub isValidTag
{
	my $self = shift;
	my $tag = shift;
	return 1 if (grep /^$tag$/mix , @{$self->{'options'}} );
	return 0;
}

1;
