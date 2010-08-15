#!/usr/bin/perl -w
#
# Test the behaviour of MatchTypes and the MatchType Arguments
#

use Test::More tests => 25;

use_ok('Parse::Sieve::Test::MatchType');
use_ok('Parse::Sieve::Argument::MatchType');

use Parse::Sieve::Test::MatchType;
use Parse::Sieve::Argument::MatchType;

my $matchtype = Parse::Sieve::Test::MatchType->new(name => ':mymatch', requires => 'matchcapability');
ok($matchtype);
is($matchtype->name, ':mymatch');
is($matchtype->requires, 'matchcapability');

my $matchtypeB = Parse::Sieve::Test::MatchType->new(name => ':other');

# MatchType should set all the defaults we need...
my $arg = Parse::Sieve::Argument::MatchType->new(name => 'match-type');
ok($arg);
is($arg->name, 'match-type');
is($arg->requires, undef);

my %types = ( $matchtype->name => $matchtype,
				$matchtypeB->name => $matchtypeB );

$arg->matchtypes( \%types );

is_deeply ($arg->matchtypes, \%types, 'MatchType Argument - Setting MatchTypes');

my @argsA = ( { tag => ':mymatch' } , { number => '42' } );
my @argsB = ( { stringlist => ['41', '42'] } , { tag => ':mymatch' } );
my @argsC = ( { tag => ':other' } );
my @argsD = ( { stringlist => ['41'] } );
my @args;

$arg = Parse::Sieve::Argument::MatchType->new(name => 'match-type');
$arg->matchtypes( \%types );
@args = @argsA;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,':mymatch');
is($arg->requires,'matchcapability');
is($arg->toString,':mymatch');
is_deeply (\@args, [ { number => '42' } ]);

$arg = Parse::Sieve::Argument::MatchType->new(name => 'match-type');
$arg->matchtypes( \%types );
@args = @argsB;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,':mymatch');
is($arg->requires,'matchcapability');
is($arg->toString,':mymatch');
is_deeply (\@args, [ {stringlist => ['41','42']} ]);

$arg = Parse::Sieve::Argument::MatchType->new(name => 'match-type');
$arg->matchtypes( \%types );
@args = @argsC;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,':other');
is($arg->requires,undef);
is($arg->toString,':other');
is(scalar @args, 0);

$arg = Parse::Sieve::Argument::MatchType->new(name => 'match-type');
$arg->matchtypes( \%types );
@args = @argsD;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,':is');
is($arg->requires,undef);
is($arg->toString,'');
is_deeply (\@args, [ {stringlist => ['41']} ]);
