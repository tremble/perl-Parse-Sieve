package Parse::Sieve::Factory::RFC5230;

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

use Parse::Sieve::Argument;
use Parse::Sieve::Argument::Numeric;
use Parse::Sieve::Argument::StringList;
use Parse::Sieve::Argument::String;

#3. Capability Identifier
#   Sieve implementations that implement vacation have an identifier of
#   "vacation" for use with the capability mechanism.
#
#4. Vacation Action
#   Usage:   vacation [":days" number] [":subject" string]
#                     [":from" string] [":addresses" string-list]
#                     [":mime"] [":handle" string] <reason: string>

my $days = new Parse::Sieve::Argument::Numeric (
		name => 'days',
		tag => ':days',
		type => 'optional',
		hasvalue => 1

	);

my $subject = new Parse::Sieve::Argument::String (
		name => 'subject',
		tag => ':subject',
		type => 'optional',
		hasvalue => 1
	);

my $from = new Parse::Sieve::Argument::String (
		name => 'from',
		tag => ':from',
		type => 'optional',
		hasvalue => 1
	);

my $addresses = new Parse::Sieve::Argument::StringList (
		name => 'addresses',
		tag => ':addresses',
		type => 'optional',
		hasvalue => 1
	);

my $mime = new Parse::Sieve::Argument (
		name => 'mime',
		tag => ':mime',
		type => 'optional'
	);

my $handle = new Parse::Sieve::Argument::String (
		name => 'handle',
		tag => ':handle',
		type => 'optional',
		hasvalue => 1
	);

my $reason = new Parse::Sieve::Argument::String (
		name => 'reason',
		type => 'positional'
	);

Parse::Sieve::Factory::registerCommandArguments(
		'vacation', ($days, $subject, $from, $addresses,
					$mime, $handle, $reason));
Parse::Sieve::Factory::registerCommandRequires(
		'vacation','vacation');

1;
