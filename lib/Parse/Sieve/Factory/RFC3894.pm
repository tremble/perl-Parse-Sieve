package Parse::Sieve::Factory::RFC3894;

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

# 5. IANA Considerations
#   Capability name: copy
#   Capability keyword: copy

# 3. ":copy" extension to the "fileinto" and "redirect" commands
# Syntax: "fileinto" [":copy"] <folder: string>
#         "redirect" [":copy"] <address: string>

{
	my $copy = new Parse::Sieve::Argument(
		name => 'copy',
		tag => ':copy',
		type => 'optional',
		requires => 'copy'
	);
Parse::Sieve::Factory::registerCommandArguments(
		'fileinto', ( $copy ));
Parse::Sieve::Factory::registerCommandArguments(
		'redirect', ( $copy ));
}

1;
