# Test the basic behaviour of Arguments
#

use Test::More tests => 124;
use strict;

use_ok('Parse::Sieve::Argument');

use Parse::Sieve::Argument;

# Absolute minimum Args
my $argument = Parse::Sieve::Argument->new(type => 'positional');
ok($argument, 'New Argument Creation (min args)');
is(lc($argument->type), lc('positional'), 'New Argument Creation (min args)');
is($argument->name, q{}, 'New Argument Creation (min args - defaults)');
is($argument->tag, q{}, 'New Argument Creation (min args - defaults)');
is($argument->requires, q{}, 'New Argument Creation (min args - defaults)');
is($argument->hasvalue, 0, 'New Argument Creation (min args - defaults)');
is($argument->value, undef, 'New Argument Creation (min args - defaults)');

# Check everything actually gets set when passed in...
$argument = Parse::Sieve::Argument->new(
		type => 'tagged',
		name => 'myname', 
		tag => ':sometag', 
		requires => 'aRequirement',
		hasvalue => 42 ) ;
ok($argument, 'New Argument Creation');
# We make no garauntees about case on these
is(lc($argument->type), 'tagged' , 'New Argument Type');
is(lc($argument->name), 'myname' , 'New Argument Name');
is(lc($argument->tag), ':sometag', 'New Argument Tag');
is(lc($argument->requires), 'arequirement', 'New Argument Requires');
is($argument->hasvalue, 42, 'New Argument HasValue');
ok(! defined $argument->value, 'New Argument Value');

# Test setters
my $value = '42 is the Meaning of life';
$argument->value($value);
$argument->name('someNewName');
$argument->tag(':meaning');
$argument->requires('life');
$argument->hasvalue(0);
is(lc($argument->name), 'somenewname' , 'Argument Name');
is(lc($argument->tag), ':meaning', 'Argument Tag');
is(lc($argument->requires), 'life', 'Argument Requires');
# We don't change the case of values
is($argument->value, $value, 'Argument Value');
# We only garauntee true/false (1/0)
ok( ! $argument->hasvalue, 'New Argument HasValue');
# This should bomb out...
{
	local $@;
	eval {
		local $SIG{__DIE__};
		$argument->type('positional');
	} ;
	ok($@ , 'Argument Type (readonly)');
}

# Test the basic functionality of clone
my $clone = $argument->clone;
ok($clone, 'Argument Cloning');
is(lc($clone->type), 'tagged' , 'Clone Type (read only)');
is(lc($clone->name), 'somenewname' , 'Clone Name');
is(lc($clone->tag), ':meaning', 'Clone Tag');
is(lc($clone->requires), 'life', 'Clone Requires');
# We don't change the case of values
is($clone->value, $value, 'Clone Value');
ok( ! $clone->hasvalue, 'Clone HasValue');

$clone->hasvalue('1');
is ($clone->toString(), ":meaning $value" , 
						'toString (TAGGED has value)');
is ($argument->toString(), $value , 'toString (TAGGED has novalue)');

$argument = Parse::Sieve::Argument->new(
		type => 'positional',
		tag => ':sometag', # Not actually any use...
		hasvalue => 42 ) ;
$argument->value($value);
is ($argument->toString(), $value , 'toString (POSITIONAL has value)');
$argument->hasvalue(0);
is ($argument->toString(), $value , 'toString (POSITIONAL has novalue)');

$argument = Parse::Sieve::Argument->new(
		type => 'optional',
		tag => ':sometag', 
		hasvalue => 42 ) ;
$argument->value($value);
is ($argument->toString(), ":sometag $value" , 
						'toString (OPTIONAL has value)');
$argument->hasvalue(0);
is ($argument->toString(), $value , 
						'toString (OPTIONAL has novalue)');

my @numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
my @stringParams = ( { tag => ':mytag' } , 
					{ 'stringlist' => [ '42' ] } );
my @otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
my @noTagParams = ( { 'other' => [ '42' ] } );
my @justTagParams = ( { tag => ':mytag' } );
my @justNumericParams = ( { number => '42' } );
my @justStringParams = ( { stringlist => ['42'] } );

# Pop
my $tagged = Parse::Sieve::Argument->new(
		type => 'tagged',
		tag => ':mytag',
		hasvalue => '0');

my @tmp = @numericParams;
$tagged->set('value', undef);
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, ':mytag', 'Pop Tag Numeric - return');
is ($tagged->value, ':mytag', 'Pop Tag Numeric - value');
is_deeply (\@tmp, \@justNumericParams, 'Pop Tag Numeric - arguments');

@tmp = @stringParams;
$tagged->set('value', undef);
$value = undef;
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, ':mytag', 'Pop Tag String - return');
is ($tagged->value, ':mytag', 'Pop Tag String - value');
is_deeply (\@tmp, \@justStringParams, 'Pop Tag String - arguments');

@tmp = @otherParams;
$value = undef;
$tagged->set('value', undef);
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, ':mytag', 'Pop Tag Other - return');
is ($tagged->value, ':mytag', 'Pop Tag Other - value');
is_deeply (\@tmp, \@noTagParams, 'Pop Tag Other - arguments');

@tmp = @noTagParams;
$tagged->set('value', undef);
$value = undef;
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Tag NoTag - return');
is ($tagged->value, undef, 'Pop Tag NoTag - value');
is_deeply (\@tmp, \@noTagParams, 'Pop Tag NoTag - arguments');

@tmp = @justTagParams;
$tagged->set('value', undef);
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, ':mytag', 'Pop Tag JustTag - return');
is ($tagged->value, ':mytag', 'Pop Tag JustTag - value');
is (scalar(@tmp), 0, 'Pop Tag JustTag - arguments');

@numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
@stringParams = ( { tag => ':mytag' } , { 'stringlist' => [ '42' ] } );
@otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
@justTagParams = ( { tag => ':mytag' } );
@noTagParams = ( { 'other' => [ '42' ] } );

my $positional = Parse::Sieve::Argument->new(
		type => 'positional',
		tag => '',
		hasvalue => '0');

@tmp = @numericParams;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, '42', 'Pop Positional Numeric - return');
is ($positional->value, '42', 'Pop Positional Numeric - value');
is_deeply (\@tmp, \@justTagParams, 
						'Pop Positional Numeric - arguments');

@tmp = @stringParams;
$positional->set('value', undef);
$value = undef;
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, ['42'], 
				'Pop Positional String - value');
is_deeply ($positional->value, ['42'], 
				'Pop Positional String - return');
is_deeply (\@tmp, \@justTagParams, 
				'Pop Positional String - arguments');

@tmp = @otherParams;
$value = undef;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, $noTagParams[0], 
				'Pop Positional Other - value');
is_deeply ($positional->value, $noTagParams[0], 
				'Pop Positional Other - return');
is_deeply (\@tmp, \@justTagParams, 
				'Pop Positional Other - arguments');


@tmp = @noTagParams;
$positional->set('value', undef);
$value = undef;
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, $noTagParams[0], 
				'Pop Positional NoTag - value');
is_deeply ($positional->value, $noTagParams[0], 
				'Pop Positional NoTag - return');
is (scalar(@tmp), 0, 'Pop Positional NoTag - arguments');


@tmp = @justTagParams;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, $justTagParams[0], 
				'Pop Positional JustTag - value');
is_deeply ($positional->value, $justTagParams[0], 
				'Pop Positional JustTag - return');
is (scalar(@tmp), 0, 'Pop Positional JustTag - arguments');


@numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
@stringParams = ( { tag => ':mytag' } , { 'stringlist' => [ '42' ] } );
@otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
@noTagParams = ( { 'other' => [ '42' ] } );
@justTagParams = ( { tag => ':mytag' } );

my $optional = Parse::Sieve::Argument->new(
		type => 'optional',
		tag => ':mytag',
		hasvalue => '0');

@tmp = @numericParams;
$optional->set('value', undef);
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, ':mytag', 'Pop Optional Numeric - return');
is ($optional->value, ':mytag', 'Pop Optional Numeric - value');
is_deeply (\@tmp, \@justNumericParams, 'Pop Optional Numeric - arguments');

@tmp = @stringParams;
$optional->set('value', undef);
$value = undef;
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, ':mytag', 'Pop Optional String - return');
is ($optional->value, ':mytag', 'Pop Optional String - value');
is_deeply (\@tmp, \@justStringParams, 'Pop Optional String - arguments');

@tmp = @otherParams;
$value = undef;
$optional->set('value', undef);
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, ':mytag', 'Pop Optional Other - return');
is ($optional->value, ':mytag', 'Pop Optional Other - value');
is_deeply (\@tmp, \@noTagParams, 'Pop Optional Other - arguments');

@tmp = @noTagParams;
$optional->set('value', undef);
$value = undef;
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Optional NoTag - return');
is ($optional->value, undef, 'Pop Optional NoTag - value');
is_deeply (\@tmp, \@noTagParams, 'Pop Optional NoTag - arguments');

@tmp = @justTagParams;
$optional->set('value', undef);
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, ':mytag', 'Pop Optional JustTag - return');
is ($optional->value, ':mytag', 'Pop Optional JustTag - value');
is (scalar(@tmp), 0, 'Pop Optional JustTag - arguments');

@numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
@stringParams = ( { tag => ':mytag' } , { 'stringlist' => [ '42' ] } );
@otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
@noTagParams = ( { 'other' => [ '42' ] } );
@justTagParams = ( { tag => ':mytag' } );

# Pop
$tagged = Parse::Sieve::Argument->new(
		type => 'tagged',
		tag => ':mytag',
		hasvalue => '1');

@tmp = @numericParams;
$tagged->set('value', undef);
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, '42', 'Pop Tag Numeric (hasvalue) - return');
is ($tagged->value, '42', 'Pop Tag Numeric (hasvalue) - value');
is (scalar(@tmp), 0, 'Pop Tag Numeric (hasvalue) - arguments');

@tmp = @stringParams;
$tagged->set('value', undef);
$value = undef;
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, ['42'] , 
				'Pop Tag String (hasvalue) - return');
is_deeply ($tagged->value, ['42'] , 
				'Pop Tag String (hasvalue) - value');
is (scalar(@tmp), 0, 'Pop Tag String (hasvalue) - arguments');

@tmp = @otherParams;
$value = undef;
$tagged->set('value', undef);
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, $noTagParams[0] , 
				'Pop Tag Other (hasvalue) - return');
is_deeply ($tagged->value, $noTagParams[0] , 
				'Pop Tag Other (hasvalue) - value');
is (scalar(@tmp), 0, 'Pop Tag Other (hasvalue) - arguments');

@tmp = @noTagParams;
$tagged->set('value', undef);
$value = undef;
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Tag NoTag (hasvalue) - return');
is ($tagged->value, undef, 'Pop Tag NoTag (hasvalue) - value');
is_deeply (\@tmp, \@noTagParams , 
				'Pop Tag NoTag (hasvalue) - arguments');

@tmp = @justTagParams;
$tagged->set('value', undef);
$value = undef;
$value = $tagged->popvalue(\@tmp);
is ($value, undef, 'Pop Tag JustTag (hasvalue) - return');
is ($tagged->value, undef, 'Pop Tag JustTag (hasvalue) - value');
is_deeply (\@tmp, \@justTagParams , 
				'Pop Tag JustTag (hasvalue) - arguments');


@numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
@stringParams = ( { tag => ':mytag' } , { 'stringlist' => [ '42' ] } );
@otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
@noTagParams = ( { 'other' => [ '42' ] } );
@justTagParams = ( { tag => ':mytag' } );

# Should behave IDENTICALLY with or without hasvalue
$positional = Parse::Sieve::Argument->new(
		type => 'positional',
		tag => '',
		hasvalue => '1');

@tmp = @numericParams;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, '42', 'Pop Positional Numeric (hasvalue) - return');
is ($positional->value, '42', 
				'Pop Positional Numeric (hasvalue) - value');
is_deeply (\@tmp, \@justTagParams, 
				'Pop Positional Numeric (hasvalue) - arguments');

@tmp = @stringParams;
$positional->set('value', undef);
$value = undef;
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, ['42'], 
				'Pop Positional String (hasvalue) - value');
is_deeply ($positional->value, ['42'], 
				'Pop Positional String (hasvalue) - return');
is_deeply (\@tmp, \@justTagParams, 
				'Pop Positional String (hasvalue) - arguments');

@tmp = @otherParams;
$value = undef;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, $noTagParams[0], 
				'Pop Positional Other (hasvalue) - value');
is_deeply ($positional->value, $noTagParams[0], 
				'Pop Positional Other (hasvalue) - return');
is_deeply (\@tmp, \@justTagParams, 
				'Pop Positional Other (hasvalue) - arguments');


@tmp = @noTagParams;
$positional->set('value', undef);
$value = undef;
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, $noTagParams[0], 
				'Pop Positional NoTag (hasvalue) - value');
is_deeply ($positional->value, $noTagParams[0], 
				'Pop Positional NoTag (hasvalue) - return');
is (scalar(@tmp), 0, 'Pop Positional NoTag (hasvalue) - arguments');


@tmp = @justTagParams;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, $justTagParams[0], 
				'Pop Positional JustTag (hasvalue) - value');
is_deeply ($positional->value, $justTagParams[0], 
				'Pop Positional JustTag (hasvalue) - return');
is (scalar(@tmp), 0, 'Pop Positional JustTag (hasvalue) - arguments');


@numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
@stringParams = ( { tag => ':mytag' } , { 'stringlist' => [ '42' ] } );
@otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
@noTagParams = ( { 'other' => [ '42' ] } );
@justTagParams = ( { tag => ':mytag' } );

$optional = Parse::Sieve::Argument->new(
		type => 'optional',
		tag => ':mytag',
		hasvalue => '1');

@tmp = @numericParams;
$optional->set('value', undef);
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, '42', 'Pop Optional Numeric (hasvalue) - return');
is ($optional->value, '42', 'Pop Optional Numeric (hasvalue) - value');
is (scalar(@tmp), 0, 'Pop Optional Numeric (hasvalue) - arguments');

@tmp = @stringParams;
$optional->set('value', undef);
$value = undef;
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, ['42'] , 
						'Pop Optional String (hasvalue) - return');
is_deeply ($optional->value, ['42'] , 
						'Pop Optional String (hasvalue) - value');
is (scalar(@tmp), 0, 'Pop Optional String (hasvalue) - arguments');

@tmp = @otherParams;
$value = undef;
$optional->set('value', undef);
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is_deeply ($value, $noTagParams[0] , 
						'Pop Optional Other (hasvalue) - return');
is_deeply ($optional->value, $noTagParams[0] , 
						'Pop Optional Other (hasvalue) - value');
is (scalar(@tmp), 0, 'Pop Optional Other (hasvalue) - arguments');

@tmp = @noTagParams;
$optional->set('value', undef);
$value = undef;
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Optional NoTag (hasvalue) - return');
is ($optional->value, undef, 'Pop Optional NoTag (hasvalue) - value');
is_deeply (\@tmp, \@noTagParams , 
						'Pop Optional NoTag (hasvalue) - arguments');

@tmp = @justTagParams;
$optional->set('value', undef);
$value = undef;
$value = $optional->popvalue(\@tmp);
is ($value, undef, 'Pop Optional JustTag (hasvalue) - return');
is ($optional->value, undef, 'Pop Optional JustTag (hasvalue) - value');
is_deeply (\@tmp, \@justTagParams , 
						'Pop Optional JustTag (hasvalue) - arguments');

