package Parse::Sieve::Factory::RFC5233;

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
use Parse::Sieve::Test::AddressPart;

# 3. Capability Identifier
#  The capability string associated with the extension defined in this
#  document is "subaddress"

# 4. Subaddress Comparisons
#    ADDRESS-PART  =/  ":user" / ":detail"

{
	my $user = new Parse::Sieve::Test::AddressPart (
		name => ':user',
		requires => 'subaddress'
	);
	my $detail = new Parse::Sieve::Test::AddressPart (
		name => ':detail',
		requires => 'subaddress'
	);
Parse::Sieve::Factory::registerAddressPart(
		$user);
Parse::Sieve::Factory::registerAddressPart(
		$detail);
}

1;
