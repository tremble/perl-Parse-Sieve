#!/usr/bin/perl -w
#
# Test that all Factory behaves as we expect
#

use Test::More tests => 1;

use_ok('Parse::Sieve::Factory');
use Parse::Sieve::Factory;

#Parse::Sieve::Factory::registerAddressPart;
#getAddressParts
#registerMatchType
#getMatchTypes
#registerComparator
#getComparators
#registerTestArguments
#getTestArguments
#registerTestRequires
#getTestRequires
#registerCommandArguments
#getCommandArguments
#registerCommandRequires
#getCommandRequires
#registerCommandRequiresBlock
#getCommandRequiresBlock
#createTest
#createCommand
