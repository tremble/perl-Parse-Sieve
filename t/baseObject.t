#!/usr/bin/perl -w
#
# Test the behaviour of the Primary Base object
#
# This is then used by Command and Test
#

use Test::More tests => 30;
use Test::Deep;

use_ok('Parse::Sieve::Base');

# Some simple arguments for us to play with
use Parse::Sieve::Base;
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
my $object = new Parse::Sieve::Base(
		\%a, \%m, \%c, 
		\@EMPTY ) ;

# At the very least none of these should Error!
ok ($object , 'Bare minimum Base object');
is ($object->identifier , undef );
is ($object->requires , undef );
ok ($object->id );
is ($object->toString , q{} );
is ($object->deleteTest(1) , undef );
is ($object->getArgument('someArg') , undef );
my @tmp = $object->tests;
is_deeply (\@tmp , \@EMPTY );
@tmp = $object->sieverequire;
is_deeply (\@tmp , \@EMPTY );

# Very simple, positional string list.
my $headers = new Parse::Sieve::Argument::StringList (
		name => 'header-names',
		requires => 'headernames',
		type => 'positional'
	);
my @valid = ( { stringlist => ['X-Spam-Flag'] } );
my @invalidTag = ( { tag => ':something' } );

$headers->addressparts(\%a);
$headers->matchtypes(\%m);
$headers->comparators(\%c);

$object = new Parse::Sieve::Base(
		\%a, \%m, \%c, 
		[ $headers ] ) ;
cmp_deeply (	{ %{$object->getArgument('header-names')} } , 
				{%$headers , id => ignore() } );
ok ( ! $object->getArgument('other-arg') ); 

# Again shouldn't break, although should send warning messages
{
	local $@;
	my @warnings = ();
	$SIG{__WARN__} = sub {
		push @warnings, @_;
	}; 
	$object = new Parse::Sieve::Base(
		\%a, \%m, \%c, 
		[ $headers ], ( identifier => 'exists',
						requires => 'somecap' ) ) ;
	is (scalar @warnings, 1);
	is ($object->requires , 'somecap' );
	is ($object->identifier , 'exists' );
	# XXX This is an invalid script, the question is what should we return...
	# (We're missing a positional argument)
	is ($object->toString , 'exists');
}

{
	local $@;
	my @warnings = ();
	$SIG{__WARN__} = sub {
		push @warnings, @_;
	}; 
	$object = new Parse::Sieve::Base(
		\%a, \%m, \%c, 
		[ $headers ], ( identifier => 'exists',
						requires => 'somecap',
						arguments => { arguments => \@invalidTag } ) ) ;
	is (scalar @warnings, 2);
	# XXX This is an invalid script, the question is what should we return...
	# (We're missing a positional argument)
	is ($object->toString , 'exists');
}

{
	local $@;
	my @warnings = ();
	$SIG{__WARN__} = sub {
		push @warnings, @_;
	}; 
	$object = new Parse::Sieve::Base(
		\%a, \%m, \%c, 
		[ $headers ], ( identifier => 'exists',
						requires => 'somecap',
						arguments => { arguments => \@valid } ) ) ;
	is (scalar @warnings, 0);
	ok ($object->getArgument('header-names'));
	is_deeply ($object->getArgument('header-names')->value , ['X-Spam-Flag'] );
	is ($object->toString , 'exists "X-Spam-Flag"');
	my @requirements = $object->sieverequire();
	cmp_deeply(\@requirements, bag('somecap','headernames'));

	my $clone = $object->clone();
	is ($object->requires , 'somecap' );
	is ($object->identifier , 'exists' );
	cmp_deeply (	{ %{$object->getArgument('header-names')} } , 
					{%$headers , id => ignore(), value => ignore() } );
	is_deeply ($object->getArgument('header-names')->value , ['X-Spam-Flag'] );
	is ($object->toString , 'exists "X-Spam-Flag"');
	@requirements = $object->sieverequire();
	cmp_deeply(\@requirements, bag('somecap','headernames'));

}

TODO: {
	fail(" XXX Write me Test the tests and deleteTest methods");
}
