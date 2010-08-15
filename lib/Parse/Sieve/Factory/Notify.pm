package Parse::Sieve::Factory::Notify;

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
use Parse::Sieve::Argument::StringList;
use Parse::Sieve::Argument::String;

# 2. Capability Identifier
#  The capability string associated with the extension defined in this
#  document is "enotify".
#
# 3.  Notify Action
#  Usage:  notify [":from" string]
#          [":importance" <"1" / "2" / "3">]
#          [":options" string-list]
#          [":message" string]
#          <method: string>

# XXX This needs limiting to "1"/"2"/"3"
my $importance = new Parse::Sieve::Argument::String (
		name => 'importance',
		tag => ':importance',
		type => 'optional',
		hasvalue => 1
	);

my $message = new Parse::Sieve::Argument::String (
		name => 'message',
		tag => ':message',
		type => 'optional',
		hasvalue => 1
	);

my $from = new Parse::Sieve::Argument::String (
		name => 'from',
		tag => ':from',
		type => 'optional',
		hasvalue => 1
	);

my $options = new Parse::Sieve::Argument::StringList (
		name => 'options',
		tag => ':options',
		type => 'optional',
		hasvalue => 1
	);

my $method = new Parse::Sieve::Argument::String (
		name => 'method',
		type => 'positional'
	);

Parse::Sieve::Factory::registerCommandArguments(
		'notify', ($from, $importance, $options, $message,
					$method));
Parse::Sieve::Factory::registerCommandRequires(
		'notify','enotify');

1;
