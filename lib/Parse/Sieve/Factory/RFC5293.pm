package Parse::Sieve::Factory::RFC5293;

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
use Parse::Sieve::Argument::String;
use Parse::Sieve::Argument::OptionalStringList;
use Parse::Sieve::Argument::Numeric;
use Parse::Sieve::Argument::Comparator;
use Parse::Sieve::Argument::MatchType;

# 4. Action addheader
# "addheader" [":last"] <field-name: string> <value: string>

# 5. Action deleteheader
# "deleteheader" [":index" <fieldno: number> [":last"]]
#                   [COMPARATOR] [MATCH-TYPE]
#                   <field-name: string>
#                   [<value-patterns: string-list>]

# XXX Ergh, An optional positional argument, this conflicts with RFC5228!

my @EMPTY = ();

{
my $index = new Parse::Sieve::Argument::Numeric (
		name => 'value',
		tag => ':index',
		type => 'optional'
	);
my $fieldname = new Parse::Sieve::Argument::String (
		name => 'field-name',
		type => 'positional'
	);
my $value = new Parse::Sieve::Argument::String (
		name => 'value',
		type => 'positional'
	);
my $comparator = new Parse::Sieve::Argument::Comparator (
		name => 'comparator'
	);
my $match = new Parse::Sieve::Argument::MatchType (
		name => 'match-type'
	);
my $patterns = new Parse::Sieve::Argument::OptionalStringList (
		name => 'value-patterns',
		type => 'positional'
	);
my $lastArg = new Parse::Sieve::Argument (
        name => 'last',
        tag => ':last',
        type => 'optional'
    );
Parse::Sieve::Factory::registerCommandArguments(
		'addheader', ($lastArg, $fieldname, $value));
Parse::Sieve::Factory::registerCommandRequires(
		'addheader', 'editheader');
Parse::Sieve::Factory::registerCommandArguments(
		'deleteheader', ($index, $lastArg, $comparator,
						$match, $fieldname, $patterns ));
Parse::Sieve::Factory::registerCommandRequires(
		'deleteheader', 'editheader');
}

1;
