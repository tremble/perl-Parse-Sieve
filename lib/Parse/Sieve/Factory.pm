package Parse::Sieve::Factory;

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

use Exporter ();
use Carp qw(cluck croak);
use Parse::Sieve::Test;
use Parse::Sieve::Command;
use Data::Dumper;

use vars qw($VERSION @EXPORT_OK);
use base qw(Exporter);

$VERSION = '1.00';

my $strict = 1;
my $warnings = 1;

my %tests = ();
my %testrequires = ();
my %commands = ();
my %commandrequires = ();
my %commandblock = ();
my %addressparts = ();
my %matchtypes = ();
my %comparators = ();
my @EMPTY = ();

@EXPORT_OK = qw( createTest createCommand );

sub registerAddressPart {
	my ($apart) = @_;
	my $id = $apart->name;
	my $arg = $apart;
	$id= lc($id);
	if ($addressparts{$id}) {
		croak "Attempted to override Address-Part '$id'" if ($strict);
		cluck "Address-Part: '$id' Overriden!" if ($warnings);
	}
	$addressparts{$id} = $apart ;
	return;
}

sub getAddressParts {
	my %parts = %addressparts;
	return %parts;
}

sub registerMatchType {
	my ($match) = @_;
	my $id = $match->name;
	my $arg = $match;
	$id= lc($id);
	if ($matchtypes{$id}) {
		croak "Attempted to override Match-Type '$id'" if ($strict);
		cluck "Match-Type: '$id' Overriden!" if ($warnings);
	}
	$matchtypes{$id} = $match ;
	return;
}

sub getMatchTypes {
	my %types = %matchtypes;
	return %types;
}

sub registerComparator {
	my ($comp) = @_;
	my $id = $comp->name;
	my $arg = $comp;
	$id= lc($id);
	if ($comparators{$id}) {
		croak "Attempted to override Comparator '$id'" if ($strict);
		cluck "Comparator: '$id' Overriden!" if ($warnings);
	}
	$comparators{$id} = $comp ;
	return;
}

sub getComparators {
	my %comps = %comparators;
	return %comps;
}

sub registerTestArguments {
	my ($identifier, @arguments) = @_;
	$identifier = lc($identifier);

	if ($tests{$identifier}) {
		@arguments = ( @arguments, @{$tests{$identifier}}) ;
	}
	$tests{$identifier} = \@arguments ;
	return;
}

sub getTestArguments {
	my $identifier = shift;
	return if ( ! defined $tests{$identifier} );
	my @args = @{$tests{$identifier}};
	return @args;
}

sub registerTestRequires {
	my ($identifier, $requires) = @_;
	$identifier = lc($identifier);

	if ($testrequires{$identifier}) {
		croak "Attempted to override Test '$identifier' Requires" if ($strict);
		cluck "Test '$identifier' Requires overridden " if ($warnings);
	}
	$testrequires{$identifier} = $requires ;
	return;
}

sub getTestRequires {
	my $identifier = shift;
	my $req = $testrequires{$identifier};
	return $req;
}

sub registerCommandArguments {
	my ($identifier, @arguments) = @_;
	$identifier = lc($identifier);

	if ($commands{$identifier}) {
		@arguments = ( @arguments, @{$commands{$identifier}}) ;
	}
	$commands{$identifier} = \@arguments ;
	return;
}

sub getCommandArguments {
	my $identifier = shift;
	return if ( ! defined $commands{$identifier} );
	my @args = @{$commands{$identifier}};
	return @args;
}

sub registerCommandRequires {
	my ($identifier, $requires) = @_;
	$identifier = lc($identifier);

	if ($commandrequires{$identifier}) {
		croak "Attempted to override Command '$identifier' Requires" if ($strict);
		cluck "Command '$identifier' Requires overridden " if ($warnings);
	}
	$commandrequires{$identifier} = $requires ;
	return;
}

sub getCommandRequires {
	my $identifier = shift;
	my $req = $commandrequires{$identifier};
	return $req;
}

sub registerCommandRequiresBlock {
	my ($identifier, $requires) = @_;
	$identifier = lc($identifier);

	if ($commandblock{$identifier}) {
		croak "Attempted to override Command '$identifier' Block Requirements" if ($strict);
		cluck "Command '$identifier' Block Requirements overridden " if ($warnings);
	}
	$commandblock{$identifier} = $requires ;
	return;
}

sub getCommandRequiresBlock {
	my $identifier = shift;
	my $req = $commandblock{$identifier};
	return $req;
}

# @Magic
sub _getParserContext {
	my $i = 1;
	package DB;
	while (my @call =  caller ($i ++)) {
		if ($call[3] =~ /^Parse::RecDescent::.*::command$/mx){
			return $DB::args[1] ;
		}
	}
	return;
}

sub createTest
{
	my (%param) = @_;
	my $id = lc($param{'identifier'});
	my @arguments = getTestArguments($id);
	my $test;
	my %a = getAddressParts();
	my %m = getMatchTypes();
	my %c = getComparators();

	unless (defined getTestArguments($id) || $id eq 'not') {
 		my $parseContext = _getParserContext();
		if ($parseContext) {
			$parseContext = ' : near \'' . substr($parseContext,0,25) . '\'';
		} else {	
			$parseContext = q{};
		}
		warn "Unknown Test '$id'$parseContext\n"; 
	};
	$test = new Parse::Sieve::Test(\%a,\%m,\%c, \@arguments, %param );
	if (getTestRequires($id)) {
		$test->requires(getTestRequires($id));
	}
	return $test;
}

sub createCommand
{
	my (%param) = @_;
	my $id = lc($param{'identifier'});
	my @arguments = getCommandArguments($id);
	my $command;
	my %a = getAddressParts();
	my %m = getMatchTypes();
	my %c = getComparators();
	unless (defined getCommandArguments($id)) {
 		my $parseContext = _getParserContext();
		if ($parseContext) {
			$parseContext = ' : near \'' . substr($parseContext,0,15) . '\'';
		} else {	
			$parseContext = q{};
		}
		warn "Unknown Command '$id'$parseContext\n"; 
	};
	$command = new Parse::Sieve::Command(
					$commandblock{$id}, \%a,\%m,\%c, \@arguments, %param);
	if (getCommandRequires($id)) {
		$command->requires(getCommandRequires($id));
	}

	return $command;
}

sub setWarnings {
	$warnings = shift;
	return $warnings;
}

sub getWarnings {
	return $warnings;
}

sub setStrict {
	$strict = shift;
	return $strict;
}

sub getStrict {
	return $strict;
}

1;
