#!/usr/bin/perl
use Parse::RecDescent;

my $target = $ARGV[0];

open GRAMMAR_FILE, "grammar" or die;
local $/;
my $grammar = <GRAMMAR_FILE>;

$target =~ s/\/[^\/]*$//;

chdir $target;

Parse::RecDescent->Precompile($grammar, "Parse::Sieve::Grammar");
