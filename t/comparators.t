#!/usr/bin/perl -w
#
# Test the behaviour of Comparators and the Comparator Arguments
#

use Test::More tests => 24;

use_ok('Parse::Sieve::Test::Comparator');
use_ok('Parse::Sieve::Argument::Comparator');

use Parse::Sieve::Test::Comparator;
use Parse::Sieve::Argument::Comparator;

my $comparator = Parse::Sieve::Test::Comparator->new(name => 'elbonia' );
ok($comparator);
is($comparator->name, 'elbonia');

my $comparatorB = Parse::Sieve::Test::Comparator->new(name => 'i;octet');

# Comparator should set all the defaults we need...
my $arg = Parse::Sieve::Argument::Comparator->new(name => '');
ok($arg);
is($arg->name, '');
is($arg->requires, undef);

my %comps = ( $comparator->name => $comparator,
				$comparatorB->name => $comparatorB );

$arg->comparators( \%comps );

is_deeply ($arg->comparators, \%comps, 'Comparator Argument - Setting Comparators');

my @argsA = ( { tag => ':comparator' } , { number => '42' } );
my @argsB = ( { tag => ':comparator'} , { stringlist => ['i;octet'] } );
my @argsC = ( { tag => ':comparator'} , { stringlist => ['elbonia'] } );
my @argsD = ( { stringlist => ['41'] } );
my @args;

$arg = Parse::Sieve::Argument::Comparator->new(name => '');
$arg->comparators( \%comps );
@args = @argsA;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,'i;ascii-casemap');
is($arg->requires,undef);
is($arg->toString,q{});
is_deeply (\@args, \@argsA);

$arg = Parse::Sieve::Argument::Comparator->new(name => '');
$arg->comparators( \%comps );
@args = @argsB;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,'i;octet');
is($arg->requires,undef);
is($arg->toString,':comparator "i;octet"');
is (scalar @args, 0);

$arg = Parse::Sieve::Argument::Comparator->new(name => '');
$arg->comparators( \%comps );
@args = @argsC;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,'elbonia');
is($arg->requires,'comparator-elbonia');
is($arg->toString,':comparator "elbonia"');
is(scalar @args, 0);

$arg = Parse::Sieve::Argument::Comparator->new(name => '');
$arg->comparators( \%comps );
@args = @argsD;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,'i;ascii-casemap');
is($arg->requires,undef);
is($arg->toString,q{});
is_deeply (\@args, [ {stringlist => ['41']} ]);
