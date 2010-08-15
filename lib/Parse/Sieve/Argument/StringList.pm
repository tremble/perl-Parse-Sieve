package Parse::Sieve::Argument::StringList;

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

	return $self;
}

sub clone
{
	my $self = shift;
	my $clone = $self->Parse::Sieve::Argument::clone(@_);
	bless $clone,'Parse::Sieve::Argument::StringList';
	return $clone;
}

sub isValidValue
{
	my $self = shift;
	return 0 if (! $self->Parse::Sieve::Argument::isValidValue(@_) );
	my $value = shift;
	return 0 if (ref $value ne 'HASH');
	return 0 if (ref $value->{'stringlist'} ne 'ARRAY');
	return 1;
}

sub toStringSingle
{
	my $self = shift;
	my $val = shift;
	if ($val && $val =~ /[\n]/mx) {
			# This won't happen as a result of the parser, 
			# but who knows what people will try...
		$val .= "\n" if (! $val =~ /[\n]$/mx);
		$val =~ s/^\./../mx;
		$val = "text:\n$val.\n";
	} elsif ($val) {
		$val =~ s/"//g;
		$val = '"' . $val . '"' ;
	}
	return $val;
}

sub toString
{
	my $self = shift;
	return q{} if (ref($self->value) ne 'ARRAY');
	my @value = @{$self->value};

	return q{} if (@value == 0);

	foreach my $val (@value) {
		$val = $self->toStringSingle($val);
	}
	my $values = '[' . join (', ', @value) .']';
	$values = $value[0] if (@value == 1);
	return $self->Parse::Sieve::Argument::_toString($values, @_);
}

1;
