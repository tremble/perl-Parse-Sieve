package Parse::Sieve::Factory::Reject;

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

my @EMPTY = ();

{
my $message = new Parse::Sieve::Argument::String (
		name => 'message',
		type => 'positional'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'ereject', ($message));
Parse::Sieve::Factory::registerCommandRequires(
		'ereject', 'ereject');
Parse::Sieve::Factory::registerCommandArguments(
		'reject', ($message));
Parse::Sieve::Factory::registerCommandRequires(
		'reject', 'reject');
}

1;
