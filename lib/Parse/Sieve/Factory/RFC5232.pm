package Parse::Sieve::Factory::RFC5232;

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
use Parse::Sieve::Argument::OptionalStringList;
use Parse::Sieve::Argument::StringList;
use Parse::Sieve::Argument::Comparator;
use Parse::Sieve::Argument::MatchType;

#8. IANA Considerations
# ...
#   Capability name: imap4flags

#3.1. Action setflag
#   setflag [<variablename: string>]
#            <list-of-flags: string-list>
{
	my $variable = new Parse::Sieve::Argument::OptionalStringList(
		name => 'variable-name',
		type => 'positional'
	);
	my $list = new Parse::Sieve::Argument::StringList(
		name => 'list-of-flags',
		type => 'positional'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'setflag', ( $variable, $list ));
Parse::Sieve::Factory::registerCommandRequires(
		'setflag','imap4flags');

}

#3.2. Action addflag
#   addflag [<variablename: string>]
#            <list-of-flags: string-list>
{
	my $variable = new Parse::Sieve::Argument::OptionalStringList(
		name => 'variable-name',
		type => 'positional'
	);
	my $list = new Parse::Sieve::Argument::StringList(
		name => 'list-of-flags',
		type => 'positional'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'addflag', ( $variable, $list ));
Parse::Sieve::Factory::registerCommandRequires(
		'addflag','imap4flags');

}


#3.3. Action removeflag
#   removeflag [<variablename: string>]
#            <list-of-flags: string-list>
{
	my $variable = new Parse::Sieve::Argument::OptionalStringList(
		name => 'variable-name',
		type => 'positional'
	);
	my $list = new Parse::Sieve::Argument::StringList(
		name => 'list-of-flags',
		type => 'positional'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'removeflag', ( $variable, $list ));
Parse::Sieve::Factory::registerCommandRequires(
		'removeflag','imap4flags');

}


#4. Test hasflag
#   hasflag [MATCH-TYPE] [COMPARATOR]
#          [<variable-list: string-list>]
#          <list-of-flags: string-list>
{
	my $match = new Parse::Sieve::Argument::MatchType(
		name => 'match-type'
	);
	my $comparator = new Parse::Sieve::Argument::Comparator(
		name => 'comparator'
	);
	my $variable = new Parse::Sieve::Argument::OptionalStringList(
		name => 'variable-name',
		type => 'positional'
	);
	my $list = new Parse::Sieve::Argument::StringList(
		name => 'list-of-flags',
		type => 'positional'
	);
Parse::Sieve::Factory::registerTestArguments(
		'hasflag', ( $match, $comparator, $variable, $list ));
Parse::Sieve::Factory::registerTestRequires(
		'hasflag','imap4flags');

}


#5. Tagged Argument :flags
#
#   This specification adds a new optional tagged argument ":flags" that
#   alters the behavior of actions "keep" and "fileinto".
#
#   Usage:   ":flags" <list-of-flags: string-list>
#     fileinto :flags "\\Deleted" "INBOX.From Boss";
{
	my $flag = new Parse::Sieve::Argument::StringList(
		name => 'list-of-flags',
		tag => ':flags',
		hasvalue => 1,
		type => 'optional',
		requires => 'imap4flags'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'fileinto', ( $flag ));
Parse::Sieve::Factory::registerCommandArguments(
		'keep', ( $flag ));

}

1;
