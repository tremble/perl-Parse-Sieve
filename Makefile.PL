#!/usr/bin/perl

use strict;
use inc::Module::Install;

name            'Parse-Sieve';
perl_version    '5.006';
author          'Mark Chappell <tremble@tremble.org.uk>';
license         'perl';
all_from        'lib/Parse/Sieve.pm';
version_from    'lib/Parse/Sieve.pm';

requires 'Class::Accessor::Fast' => 0.30;
requires 'Parse::RecDescent' => 0.30;

build_requires  'Pod::Coverage';
build_requires  'Test::More';
build_requires  'Test::Deep';

auto_install;

tests('t/*.t');

# Make::Install overrides the default of running all of them
makemaker_args('PL_FILES' => { 
			'MakeGrammar.PL' => 'blib/lib/Parse/Sieve/Grammar.pm' }  );

WriteAll;
