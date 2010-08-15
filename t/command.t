#!/usr/bin/perl -w
#
# Test the behaviour of the Command object
#

use Test::More tests => 24;
use Test::Deep;

use_ok('Parse::Sieve::Base');

# Some simple arguments for us to play with
use Parse::Sieve::Command;
use Parse::Sieve::Argument;
use Parse::Sieve::Argument::StringList;
use Parse::Sieve::Argument::String;
use Parse::Sieve::Argument::Numeric;

# No point testing anything too fancy we do that elsewhere.
my %c = ();
my %a = ();
my %m = ();
my @EMPTY = ();

# Bare Minimum of arguments
my $object = new Parse::Sieve::Command( 0,
		\%a, \%m, \%c, 
		\@EMPTY ) ;

# At the very least none of these should Error!
ok ($object , 'Bare minimum Command object');
is ($object->identifier , undef );
is ($object->requires , undef );
ok ($object->id );
is ($object->toString , ';' );
is ($object->deleteTest(1) , undef );
is ($object->getArgument('someArg') , undef );
my @tmp = $object->tests;
is_deeply (\@tmp , \@EMPTY );
@tmp = $object->sieverequire;
is_deeply (\@tmp , \@EMPTY );

# Very simple, positional string list.
my $fileinto = new Parse::Sieve::Argument::String (
		name => 'mailbox',
		requires => 'somecap',
		type => 'positional'
	);
my @valid = ( { stringlist => ['INBOX'] } );
my @invalidTag = ( { tag => ':something' } );

$fileinto->addressparts(\%a);
$fileinto->matchtypes(\%m);
$fileinto->comparators(\%c);

$object = new Parse::Sieve::Command( 0,
		\%a, \%m, \%c, 
		[ $fileinto ] ) ;
cmp_deeply (	{ %{$object->getArgument('mailbox')} } , 
				{%$fileinto , id => ignore() } );
ok ( ! $object->getArgument('other-arg') ); 

{
	local $@;
	my @warnings = ();
	$SIG{__WARN__} = sub {
		push @warnings, @_;
	}; 
	$object = new Parse::Sieve::Command(0,
		\%a, \%m, \%c, 
		[ $fileinto ], ( identifier => 'fileinto',
						requires => 'fileintocap',
						arguments => { arguments => \@valid } ) ) ;
	is (scalar @warnings, 0);
	ok ($object->getArgument('mailbox'));
	is_deeply ($object->getArgument('mailbox')->value , 'INBOX' );
	is ($object->toString , 'fileinto "INBOX";');
	my @requirements = $object->sieverequire();
	cmp_deeply(\@requirements, bag('somecap','fileintocap'));

	my $clone = $object->clone();
	is ($object->requires , 'fileintocap' );
	is ($object->identifier , 'fileinto' );
	cmp_deeply (	{ %{$object->getArgument('mailbox')} } , 
					{%$fileinto , id => ignore(), value => ignore() } );
	is_deeply ($object->getArgument('mailbox')->value , 'INBOX' );
	is ($object->toString , 'fileinto "INBOX";');
	@requirements = $object->sieverequire();
	cmp_deeply(\@requirements, bag('somecap','fileintocap'));
}

fail ('XXX Write some tests for the Command Blocks');
