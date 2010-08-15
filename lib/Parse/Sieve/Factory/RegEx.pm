package Parse::Sieve::Factory::RegEx;

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
use Parse::Sieve::Test::MatchType;

# 2. Capability Identifier
# The capability string associated with the extension defined in this
# document is "regex".

# 3.  Regex Match Type
# MATCH-TYPE  =/  ":regex"

{
	my $regex = new Parse::Sieve::Test::MatchType (
		name => ':regex',
		requires => 'regex'
	);
Parse::Sieve::Factory::registerMatchType(
		$regex);
}

1;
