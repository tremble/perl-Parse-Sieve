#!/usr/bin/perl -w
#
# Test the behaviour of The actual RecDescent Parser
#

use strict;

use Test::More tests => 48;
use Test::Deep;

use_ok('Parse::Sieve');

use Parse::Sieve;
use Parse::Sieve::Factory;
use Parse::Sieve::Factory::RFC5228;

Parse::Sieve::Factory::setStrict(0);

my $parser = Parse::Sieve->new();
ok($parser ,'Parse::Sieve created');

# Grab direct access to the parser/Grammar, this should not normally be done
# but allows us to test functionallity of some of the more, low level parts
# of the grammar/tokeniser
$parser = $parser->{'parser'};
ok($parser, 'Parser extracted');

# Start Simply....  And yes, some of these definitions are recursive
# At this point we may as well use the RFC5228 arguments rather than start
# building and registering our own.

# test = identifier arguments
my $fragment = 'size :under 100M';
my $test = $parser->test($fragment);
ok ($test);
is ($test->toString, 'size :under 100M');
$fragment = 'exists "X-Spam-Flag"';
my $testb = $parser->test($fragment);
ok ($testb);
is ($testb->toString, 'exists "X-Spam-Flag"');

# test-list = "(" test *("," test) ")"
$fragment = '( size :under 100M )';
my $tests = $parser->test_list($fragment);
ok ($tests);
ok (ref($tests) eq 'ARRAY');
is (scalar(@{$tests}),1 );
cmp_deeply( { %{$tests->[0]} },  { %$test, id => ignore(), _args=> ignore() } );
is ($tests->[0]->toString, 'size :under 100M');
$fragment = '( size :under 100M , exists "X-Spam-Flag" )';
$tests = $parser->test_list($fragment);
ok ($tests);
ok (ref($tests) eq 'ARRAY');
is (scalar(@{$tests}),2 );
cmp_deeply( { %{$tests->[0]} },  
			{ %$test, id => ignore(), _args=> ignore() } );
is ($tests->[0]->toString, 'size :under 100M');
cmp_deeply( { %{$tests->[1]} },  
			{ %$testb, id => ignore(), _args=> ignore() } );
is ($tests->[1]->toString, 'exists "X-Spam-Flag"');

# arguments : argument(s?) (test | test_list)(?)
$fragment = '42 ["lumberjack", "shirt"] :tag "monkey" size :under 100M ';
my $arguments = $parser->arguments($fragment);
ok ($arguments);
cmp_deeply ($arguments,
			{ arguments => [ 
					{ number => 42 } ,
					{ stringlist => ['lumberjack', 'shirt'] } ,
					{ tag => ':tag' } , { stringlist => ['monkey'] } 
				] ,
				tests => [ ignore() ] }
			 );
cmp_deeply( { %{$arguments->{'tests'}->[0]} },  
				{ %$test, id => ignore(), _args=> ignore() } );
is ( $arguments->{'tests'}->[0]->toString, $test->toString );

$fragment = '42 ( size :under 100M )';
$arguments = $parser->arguments($fragment);
ok ($arguments);
cmp_deeply ($arguments,
			{ arguments => [ { number => 42 } , ] ,
				tests => [ ignore() ] }
			 );
cmp_deeply( { %{$arguments->{'tests'}->[0]} },  
				{ %$test, id => ignore(), _args=> ignore() } );
is ( $arguments->{'tests'}->[0]->toString, $test->toString );

$fragment = '42 ( size :under 100M, exists "X-Spam-Flag" )';
$arguments = $parser->arguments($fragment);
ok ($arguments);
cmp_deeply ($arguments,
			{ arguments => [ { number => 42 } , ] ,
				tests => [ ignore(), ignore() ] }
			 );
cmp_deeply( { %{$arguments->{'tests'}->[0]} },  
				{ %$test, id => ignore(), _args=> ignore() } );
cmp_deeply( { %{$arguments->{'tests'}->[1]} },  
				{ %$testb, id => ignore(), _args=> ignore() } );
is ( $arguments->{'tests'}->[0]->toString, $test->toString );
is ( $arguments->{'tests'}->[1]->toString, $testb->toString );

$fragment = '"I\'m a lumberjack and I\'m ok"';
$arguments = $parser->arguments($fragment);
ok ($arguments);
cmp_deeply ($arguments,
			{ arguments => [ 
					{ stringlist => ['I\'m a lumberjack and I\'m ok'] } ,
				] }
			 );

# command = identifier arguments ( ";" / block )
$fragment = 'fileinto "INBOX"';
my $command = $parser->command($fragment);
ok (! defined $command);
$fragment = 'fileinto "INBOX" ;';
$command = $parser->command($fragment);
ok ($command);
$fragment = 'if true { fileinto "INBOX" ; } ';
$command = $parser->command($fragment);
ok ($command);
{
	local $@;
	my @warnings = ();
	$SIG{__WARN__} = sub {
		push @warnings, @_;
	};
		# Note the missing quotes
	$fragment = 'if true { fileinto INBOX ; stop ; } ';
	$command = $parser->command($fragment);
	ok ($command);
	is (scalar @warnings, 3);
}

# commands = *command
$fragment = 'fileinto "INBOX" ; stop ;';
my $commands = $parser->commands($fragment);
ok ($commands);
ok (ref($commands) eq 'ARRAY');
is ($commands->[0]->toString(), 'fileinto "INBOX";');
is ($commands->[1]->toString(), 'stop;');

# block = "{" commands "}"

$fragment = 'fileinto "INBOX" ; stop ;';
my $block = $parser->block($fragment);
ok (! defined $block);

$fragment = '{ fileinto "INBOX" ; stop ; }';
$block = $parser->block($fragment);
ok ($block);
my @commands = $block->commands;
is ($commands[0]->toString(), 'fileinto "INBOX";');
is ($commands[1]->toString(), 'stop;');
