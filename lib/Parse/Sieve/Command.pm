package Parse::Sieve::Command;

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
use Carp;
use base qw(Parse::Sieve::Base);

use vars qw($VERSION);

$VERSION = '1.00';

__PACKAGE__->mk_accessors(qw(block requireblock priority));

my $ID = 1;
my @EMPTY = ();

sub new
{
    my $type = shift;
	my $requireblock = shift;
	my (undef, undef, undef, undef, @args) = @_;
    my $self = Parse::Sieve::Base->new(@_);
    return unless (defined $self);

    bless $self,$type;

	my %param = @args;

	$self->block($param{'block'});
	$self->requireblock($requireblock);

	if ($requireblock) {
		if ( ! defined $param{'block'} ) {
			warn $self->identifier 
				. " : must have a command block but does not have one.";
			return;
		}
	} else {
		if ( defined $param{'block'} ) {
			warn $self->identifier 
				. " : must not have a command block but does have one.";
			return;
		}
	}

	$self->priority($param{'priority'}
					? $param{'priority'}
					: $self->id()*10 );

    return $self;
}

sub clone
{
    my $self = shift;
    my $clone = $self->Parse::Sieve::Base::clone();
    bless $clone,'Parse::Sieve::Command';
	$clone->requireblock($self->requireblock);
	$clone->block($self->block->clone) if ($self->block);
	$clone->priority($self->priority);
    return $clone;
}

sub parse
{
	my $self = shift;

	if ($self->requireblock) {
		if ( ! scalar $self->block->commands ) {
			warn $self->identifier 
				. " : must have a command block but does not have one.";
			return;
		}
	} else {
		if ( scalar $self->block->commands  ) {
			warn $self->identifier 
				. " : must not have a command block but does have one.";
			return;
		}
	}

	return $self->Parse::Sieve::Base::parse(@_);
}

sub toString
{
	my $self = shift;
	my $indent = shift;

	# Special case for require because we handle it elsewhere...
	return q{} if (lc($self->identifier) eq 'require');

	my $line = $self->Parse::Sieve::Base::toString($indent,@_);
	
	return $self->Parse::Sieve::Base::toString($indent,@_)
			. ';' unless ($self->requireblock);
	return $self->Parse::Sieve::Base::toString($indent,@_)
			. $self->block()->toString($indent,@_) ;
}

sub sieverequire
{
	my $self = shift;
	my @req = $self->Parse::Sieve::Base::sieverequire();
	if ($self->block) {
		push @req, $self->block->sieverequire();
	}
	return @req;
}

1;
