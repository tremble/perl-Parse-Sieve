#!/usr/bin/perl -w
#
# Test the behaviour of AddressPart and the AddressPart Arguments
#

use Test::More tests => 25;

use_ok('Parse::Sieve::Test::AddressPart');
use_ok('Parse::Sieve::Argument::AddressPart');

use Parse::Sieve::Test::AddressPart;
use Parse::Sieve::Argument::AddressPart;

my $addresspart = Parse::Sieve::Test::AddressPart->new(name => ':mypart', requires => 'addresscapability');
ok($addresspart);
is($addresspart->name, ':mypart');
is($addresspart->requires, 'addresscapability');

my $addresspartB = Parse::Sieve::Test::AddressPart->new(name => ':other');

# AddressPart should set all the defaults we need...
my $arg = Parse::Sieve::Argument::AddressPart->new(name => 'address-part');
ok($arg);
is($arg->name, 'address-part');
is($arg->requires, undef);

my %types = ( $addresspart->name => $addresspart,
				$addresspartB->name => $addresspartB );

$arg->addressparts( \%types );

is_deeply ($arg->addressparts, \%types, 'AddressPart Argument - Setting AddressPart');

my @argsA = ( { tag => ':mypart' } , { number => '42' } );
my @argsB = ( { stringlist => ['41', '42'] } , { tag => ':mypart' } );
my @argsC = ( { tag => ':other' } );
my @argsD = ( { stringlist => ['41'] } );
my @args;

$arg = Parse::Sieve::Argument::AddressPart->new(name => 'address-part');
$arg->addressparts( \%types );
@args = @argsA;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,':mypart');
is($arg->requires,'addresscapability');
is($arg->toString,':mypart');
is_deeply (\@args, [ { number => '42' } ]);

$arg = Parse::Sieve::Argument::AddressPart->new(name => 'address-part');
$arg->addressparts( \%types );
@args = @argsB;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,':mypart');
is($arg->requires,'addresscapability');
is($arg->toString,':mypart');
is_deeply (\@args, [ {stringlist => ['41','42']} ]);

$arg = Parse::Sieve::Argument::AddressPart->new(name => 'address-part');
$arg->addressparts( \%types );
@args = @argsC;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,':other');
is($arg->requires,undef);
is($arg->toString,':other');
is(scalar @args, 0);

$arg = Parse::Sieve::Argument::AddressPart->new(name => 'address-part');
$arg->addressparts( \%types );
@args = @argsD;
$arg->popvalue(\@args);
@args = grep {$_} @args;
is($arg->value,':all');
is($arg->requires,undef);
is($arg->toString,'');
is_deeply (\@args, [ {stringlist => ['41']} ]);
