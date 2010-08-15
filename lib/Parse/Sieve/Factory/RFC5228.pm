package Parse::Sieve::Factory::RFC5228;

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
use vars qw($VERSION);

$VERSION = '1.00';

use Parse::Sieve::Factory;
use Parse::Sieve::Argument::Numeric;
use Parse::Sieve::Argument::AlternateTag;
use Parse::Sieve::Argument::StringList;
use Parse::Sieve::Argument::String;
use Parse::Sieve::Argument::Tests;
use Parse::Sieve::Argument::Comparator;
use Parse::Sieve::Argument::MatchType;
use Parse::Sieve::Argument::AddressPart;
use Parse::Sieve::Test::AddressPart;
use Parse::Sieve::Test::Comparator;
use Parse::Sieve::Test::MatchType;

my @EMPTY = ();

# 2.7.1. Match Type
# ... The three match types in this specification are
#  ":contains", ":is", and ":matches". ...

{
	my $contain = new Parse::Sieve::Test::MatchType (
			name => ':contains');
	my $is = new Parse::Sieve::Test::MatchType (
			name => ':is');
	my $matches = new Parse::Sieve::Test::MatchType (
			name => ':matches');

	Parse::Sieve::Factory::registerMatchType($contain);
	Parse::Sieve::Factory::registerMatchType($is);
	Parse::Sieve::Factory::registerMatchType($matches);
}

# 2.7.3. Comparators
# ... All implementations MUST support the "i;octet" comparator
# and the "i;ascii-casemap" comparator ..

{
	my $octet = new Parse::Sieve::Test::Comparator (
			name => '"i;octet"');
	my $ascii = new Parse::Sieve::Test::Comparator (
			name => '"i;ascii-casemap"');

	Parse::Sieve::Factory::registerComparator($octet);
	Parse::Sieve::Factory::registerComparator($ascii);
}

# 2.7.4. Comparisons against Addresses
# ... These optional arguments are ":localpart", ":domain", and ":all"...

{
	my $local = new Parse::Sieve::Test::AddressPart (
			name => ':localpart');
	my $domain = new Parse::Sieve::Test::AddressPart (
			name => ':domain');
	my $all = new Parse::Sieve::Test::AddressPart (
			name => ':all');

	Parse::Sieve::Factory::registerAddressPart($local);
	Parse::Sieve::Factory::registerAddressPart($domain);
	Parse::Sieve::Factory::registerAddressPart($all);
}

# 5.1. Test address
# address [COMPARATOR] [ADDRESS-PART] [MATCH-TYPE]
#		 <header-list: string-list> <key-list: string-list>
{
my $headers = new Parse::Sieve::Argument::StringList (
		name => 'header-list',
		type => 'positional'
	);
my $keys = new Parse::Sieve::Argument::StringList (
		name => 'key-list',
		type => 'positional'
	);
my $comparator = new Parse::Sieve::Argument::Comparator (
		name => 'comparator'
	);
my $match = new Parse::Sieve::Argument::MatchType (
		name => 'match-type'
	);
my $address = new Parse::Sieve::Argument::AddressPart (
		name => 'address-part'
	);

Parse::Sieve::Factory::registerTestArguments(
		'address', ($comparator,$address,$match,$headers,$keys));
}

# 5.2. Test allof
# 5.3. Test anyof
# allof <tests: test-list>
# anyof <tests: test-list>
{
my $tests = new Parse::Sieve::Argument::Tests (
		name => 'test-list',
		type => 'positional'
	);
Parse::Sieve::Factory::registerTestArguments(
		'anyof', ($tests));
Parse::Sieve::Factory::registerTestArguments(
		'allof', ($tests));
}

# 5.4. Test envelope
# envelope [COMPARATOR] [ADDRESS-PART] [MATCH-TYPE]
#		 <envelope-part: string-list> <key-list: string-list>
{
my $envelope = new Parse::Sieve::Argument::StringList (
		name => 'envelope-part',
		type => 'positional'
	);
my $keys = new Parse::Sieve::Argument::StringList (
		name => 'key-list',
		type => 'positional'
	);
my $comparator = new Parse::Sieve::Argument::Comparator (
		name => 'comparator'
	);
my $match = new Parse::Sieve::Argument::MatchType (
		name => 'match-type'
	);
my $address = new Parse::Sieve::Argument::AddressPart (
		name => 'address-part'
	);

Parse::Sieve::Factory::registerTestArguments(
		'envelope', ($comparator,$address,$match,$envelope,$keys));
Parse::Sieve::Factory::registerTestRequires(
		'envelope', 'envelope');

}


# 5.5. Test exists
# exists <header-names: string-list>
{
my $headers = new Parse::Sieve::Argument::StringList (
		name => 'header-names',
		type => 'positional'
	);

Parse::Sieve::Factory::registerTestArguments(
		'exists', ($headers));
}

# 5.6. Test false
# false
Parse::Sieve::Factory::registerTestArguments(
		'false');

# 5.7 Test header
# header [COMPARATOR] [MATCH-TYPE] 
#		<header-names: string-list> <key-list: string-list>
{
my $headers = new Parse::Sieve::Argument::StringList (
		name => 'header-names',
		type => 'positional'
	);
my $keys = new Parse::Sieve::Argument::StringList (
		name => 'key-list',
		type => 'positional'
	);
my $comparator = new Parse::Sieve::Argument::Comparator (
		name => 'comparator'
	);
my $match = new Parse::Sieve::Argument::MatchType (
		name => 'match-type'
	);

Parse::Sieve::Factory::registerTestArguments(
		'header', ($comparator,$match,$headers,$keys));
}


# 5.8 Not - delt with in Parse::Sieve::Test as a special case

# 5.9. Test size
# size <":over" / ":under"> <limit: number>
{
	my @tmp = qw(:over :under);
my $operator = new Parse::Sieve::Argument::AlternateTag (
		name => 'operator',
		type => 'tagged',
		options => \@tmp
	);
my $size = new Parse::Sieve::Argument::Numeric (
		name => 'limit',
		type => 'positional'
	);

Parse::Sieve::Factory::registerTestArguments(
		'size', ($operator, $size));
}

# 5.10. Test true
# true
Parse::Sieve::Factory::registerTestArguments(
		'true');

# 3.1. Control if
#    if    <test1: test> <block1: block>
#    elsif <test2: test> <block2: block>
#    else  <block3: block>
{
my $testa = new Parse::Sieve::Argument::Tests (
		name => 'test1',
		type => 'positional'
	);
my $testb = new Parse::Sieve::Argument::Tests (
		name => 'test2',
		type => 'positional'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'if', $testa);
Parse::Sieve::Factory::registerCommandRequiresBlock(
		'if',1);
Parse::Sieve::Factory::registerCommandArguments(
		'elsif', $testb);
Parse::Sieve::Factory::registerCommandRequiresBlock(
		'elsif',1);
Parse::Sieve::Factory::registerCommandArguments(
		'else');
Parse::Sieve::Factory::registerCommandRequiresBlock(
		'else',1);
}

# 3.2. Control require
#    require <capabilities: string-list>
{
my $capabilities = new Parse::Sieve::Argument::StringList (
		name => 'capabilities',
		type => 'positional'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'require', $capabilities);
}

# 3.3. Control stop
#    stop
Parse::Sieve::Factory::registerCommandArguments(
		'stop');

# 4.1. Action fileinto
#    fileinto <mailbox: string>
{
my $mailbox = new Parse::Sieve::Argument::String (
		name => 'mailbox',
		type => 'positional'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'fileinto', ($mailbox));
Parse::Sieve::Factory::registerCommandRequires(
		'fileinto', 'fileinto');
}

# 4.2. Action redirect
#    redirect <address: string>
{
my $address = new Parse::Sieve::Argument::String (
		name => 'address',
		type => 'positional'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'redirect', ($address));
}

# 4.3. Action keep
#    keep
Parse::Sieve::Factory::registerCommandArguments(
		'keep');

# 4.4. Action discard
#    discard
Parse::Sieve::Factory::registerCommandArguments(
		'discard');

1;
