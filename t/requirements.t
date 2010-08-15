#!/usr/bin/perl -w
#
# Test that all the modules we require are available.
#

use Test::More tests => 5;

use_ok( 'Class::Accessor::Fast' );
use_ok( 'Exporter' );
use_ok( 'Carp' );
use_ok( 'Data::Dumper' );
use_ok( 'Parse::RecDescent' );
