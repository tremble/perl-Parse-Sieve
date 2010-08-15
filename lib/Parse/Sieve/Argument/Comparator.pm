package Parse::Sieve::Argument::Comparator;

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
use base qw(Parse::Sieve::Argument::String);

use vars qw($VERSION);

$VERSION = '1.00';

sub new
{
	my $type = shift;
	my %param =();
	%param = @_;
	my $self = Parse::Sieve::Argument::String->new(
					hasvalue => 1,
					type => 'optional',
					@_);
	return if (! defined $self);
	# RFC 5228 
	# 2.7.3. Comparators
	# ":comparator" <comparator-name: string>
	# ... If left unspecified, the default is "i;ascii-casemap" ...
	$self->tag(':comparator');
	$self->value('i;ascii-casemap');

	bless $self,$type;

	return $self;
}

sub clone
{
	my $self = shift;
	my $clone = $self->Parse::Sieve::Argument::String::clone(@_);
	$clone->{'options'} = $self->{'options'};
	bless $clone,'Parse::Sieve::Argument::Comparator';
	return $clone;
}

sub isValidValue
{
	my $self = shift;
	# String gets to worry about the being a string an only one value
	return 0 if (! $self->Parse::Sieve::Argument::String::isValidValue(@_));
	my $value = shift;
	my $comps = $self->comparators;
	$value = $value->{'stringlist'}->[0];
	if (grep /^$value$/mix, keys %$comps ) {
		$self->value(lc($value));
		return 1 ;
	}
	return 0;
}

sub requires
{
	my $self = shift;
# RFC 5228
# 6.1 Capability String
#  ...
#   comparator- The string "comparator-elbonia" is provided if the
#               implementation supports the "elbonia" comparator.
#               Therefore, all implementations have at least the
#               "comparator-i;octet" and "comparator-i;ascii-casemap"
#               capabilities.  However, these comparators may be used
#               without being declared with require.
# ...
	my $value = $self->value;
	# So we ignore i;ascii-casemap and i;octet
	return if (! defined $value);
	return if ($value eq 'i;ascii-casemap');
	return if ($value eq 'i;octet');
	return "comparator-$value";
}

sub toString
{
	my $self = shift;
	return q{} if (! defined $self->value);
	return q{} if ($self->value eq 'i;ascii-casemap');
	return $self->Parse::Sieve::Argument::String::toString();
}

1;
