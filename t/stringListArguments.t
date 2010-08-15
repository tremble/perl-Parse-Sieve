#!/usr/bin/perl -w
#
# Test the basic behaviour of Arguments
#

use Test::More tests => 106;
use strict;

use_ok('Parse::Sieve::Argument::StringList');

use Parse::Sieve::Argument::StringList;

# Absolute minimum Args
my $argument = Parse::Sieve::Argument::StringList->new(type => 'positional');
ok($argument, 'New Argument Creation (min args)');

# Check everything actually gets set when passed in...
$argument = Parse::Sieve::Argument::StringList->new(
		type => 'tagged',
		name => 'myname', 
		tag => ':sometag', 
		requires => 'aRequirement',
		hasvalue => 42 ) ;
ok($argument, 'New Argument Creation');
ok(! defined $argument->value, 'New Argument Value');

my $value = ["Somestring", "Some other String"];
my $valueString = '["Somestring", "Some other String"]';

$argument = Parse::Sieve::Argument::StringList->new(
		type => 'tagged',
		tag => ':sometag', # Not actually any use...
		hasvalue => 42 ) ;
$argument->value($value);

$argument->hasvalue('1');
is ($argument->toString(), ":sometag $valueString" , 'toString multiple (TAGGED has value)');
# Technically an invalid combination...
$argument->hasvalue(0);
is ($argument->toString(), $valueString , 'toString multiple (TAGGED has novalue)');

$argument = Parse::Sieve::Argument::StringList->new(
		type => 'positional',
		tag => ':sometag', # Not actually any use...
		hasvalue => 42 ) ;
$argument->value($value);
is ($argument->toString(), $valueString , 'toString multiple (POSITIONAL has value)');
$argument->hasvalue(0);
is ($argument->toString(), $valueString , 'toString multiple (POSITIONAL has novalue)');

$argument = Parse::Sieve::Argument::StringList->new(
		type => 'optional',
		tag => ':sometag',
		hasvalue => 42 ) ;
$argument->value($value);
is ($argument->toString(), ":sometag $valueString" , 'toString multiple (OPTIONAL has value)');
# Technically an invalid combination...
$argument->hasvalue(0);
is ($argument->toString(), $valueString , 'toString multiple (OPTIONAL has novalue)');

$value = ["Somestring"];
$valueString = '"Somestring"';

$argument = Parse::Sieve::Argument::StringList->new(
		type => 'tagged',
		tag => ':sometag',
		hasvalue => 42 ) ;
$argument->value($value);

$argument->hasvalue('1');
is ($argument->toString(), ":sometag $valueString" , 'toString singular (TAGGED has value)');
# Technically an invalid combination...
$argument->hasvalue(0);
is ($argument->toString(), $valueString , 'toString singular (TAGGED has novalue)');

$argument = Parse::Sieve::Argument::StringList->new(
		type => 'positional',
		tag => ':sometag', # Not actually any use...
		hasvalue => 42 ) ;
$argument->value($value);
is ($argument->toString(), $valueString , 'toString singular (POSITIONAL has value)');
$argument->hasvalue(0);
is ($argument->toString(), $valueString , 'toString singular (POSITIONAL has novalue)');

$argument = Parse::Sieve::Argument::StringList->new(
		type => 'optional',
		tag => ':sometag', 
		hasvalue => 42 ) ;
$argument->value($value);
is ($argument->toString(), ":sometag $valueString" , 'toString singular (OPTIONAL has value)');
# Technically an invalid combination...
$argument->hasvalue(0);
is ($argument->toString(), $valueString , 'toString singular (OPTIONAL has novalue)');

my @numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
my @stringParams = ( { tag => ':mytag' } , 
					{ 'stringlist' => [ '42' ] } );
my @otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
my @noTagParams = ( { 'other' => [ '42' ] } );
my @justTagParams = ( { tag => ':mytag' } );
my @justNumericParams = ( { number => '42' } );
my @justStringParams = ( { stringlist => ['42'] } );

# Pop
my $tagged = Parse::Sieve::Argument::StringList->new(
		type => 'tagged',
		tag => ':mytag',
		hasvalue => '0');

my @tmp = @numericParams;
$tagged->set('value', undef);
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Tag Numeric - return');
is ($tagged->value, undef, 'Pop Tag Numeric - value');
is_deeply (\@tmp, \@numericParams, 'Pop Tag Numeric - arguments');

@tmp = @stringParams;
$tagged->set('value', undef);
$value = undef;
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Tag String - return');
is ($tagged->value, undef, 'Pop Tag String - value');
is_deeply (\@tmp, \@stringParams, 'Pop Tag String - arguments');

@tmp = @otherParams;
$value = undef;
$tagged->set('value', undef);
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Tag Other - return');
is ($tagged->value, undef, 'Pop Tag Other - value');
is_deeply (\@tmp, \@otherParams, 'Pop Tag Other - arguments');

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
is ($value, undef, 'Pop Tag JustTag - return');
is ($tagged->value, undef, 'Pop Tag JustTag - value');
is_deeply (\@tmp, \@justTagParams, 'Pop Tag JustTag - arguments');

@numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
@stringParams = ( { tag => ':mytag' } , { 'stringlist' => [ '42' ] } );
@otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
@justTagParams = ( { tag => ':mytag' } );
@noTagParams = ( { 'other' => [ '42' ] } );

my $positional = Parse::Sieve::Argument::StringList->new(
		type => 'positional',
		tag => '',
		hasvalue => '0');

@tmp = @numericParams;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Positional Numeric - return');
is ($positional->value, undef, 'Pop Positional Numeric - value');
is_deeply (\@tmp, \@numericParams, 
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
is ($value, undef, 'Pop Positional Other - value');
is ($positional->value, undef, 'Pop Positional Other - return');
is_deeply (\@tmp, \@otherParams, 
				'Pop Positional Other - arguments');


@tmp = @noTagParams;
$positional->set('value', undef);
$value = undef;
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is($value, undef, 'Pop Positional NoTag - value');
is($positional->value, undef, 'Pop Positional NoTag - return');
is_deeply (\@tmp, \@noTagParams, 'Pop Positional NoTag - arguments');

@tmp = @justTagParams;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is($value, undef, 'Pop Positional JustTag - value');
is($positional->value, undef, 'Pop Positional JustTag - return');
is_deeply (\@tmp, \@justTagParams, 'Pop Positional JustTag - arguments');


@numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
@stringParams = ( { tag => ':mytag' } , { 'stringlist' => [ '42' ] } );
@otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
@noTagParams = ( { 'other' => [ '42' ] } );
@justTagParams = ( { tag => ':mytag' } );

my $optional = Parse::Sieve::Argument::StringList->new(
		type => 'optional',
		tag => ':mytag',
		hasvalue => '0');

@tmp = @numericParams;
$optional->set('value', undef);
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Optional Numeric - return');
is ($optional->value, undef, 'Pop Optional Numeric - value');
is_deeply (\@tmp, \@numericParams, 'Pop Optional Numeric - arguments');

@tmp = @stringParams;
$optional->set('value', undef);
$value = undef;
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Optional String - return');
is ($optional->value, undef, 'Pop Optional String - value');
is_deeply (\@tmp, \@stringParams, 'Pop Optional String - arguments');

@tmp = @otherParams;
$value = undef;
$optional->set('value', undef);
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Optional Other - return');
is ($optional->value, undef, 'Pop Optional Other - value');
is_deeply (\@tmp, \@otherParams, 'Pop Optional Other - arguments');

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
is ($value, undef, 'Pop Optional JustTag - return');
is ($optional->value, undef, 'Pop Optional JustTag - value');
is_deeply (\@tmp, \@justTagParams, 'Pop Optional JustTag - arguments');

@numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
@stringParams = ( { tag => ':mytag' } , { 'stringlist' => [ '42' ] } );
@otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
@noTagParams = ( { 'other' => [ '42' ] } );
@justTagParams = ( { tag => ':mytag' } );

# Pop
$tagged = Parse::Sieve::Argument::StringList->new(
		type => 'tagged',
		tag => ':mytag',
		hasvalue => '1');

@tmp = @numericParams;
$tagged->set('value', undef);
$value = $tagged->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Tag Numeric (hasvalue) - return');
is ($tagged->value, undef, 'Pop Tag Numeric (hasvalue) - value');
is_deeply (\@tmp, \@numericParams, 'Pop Tag Numeric (hasvalue) - arguments');

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
is ($value, undef, 'Pop Tag Other (hasvalue) - return');
is ($tagged->value, undef, 'Pop Tag Other (hasvalue) - value');
is_deeply (\@tmp, \@otherParams, 'Pop Tag Other (hasvalue) - arguments');

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
$positional = Parse::Sieve::Argument::StringList->new(
		type => 'positional',
		tag => '',
		hasvalue => '1');

@tmp = @numericParams;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Positional Numeric (hasvalue) - return');
is ($positional->value, undef, 
				'Pop Positional Numeric (hasvalue) - value');
is_deeply (\@tmp, \@numericParams, 
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
is ($value, undef, 
				'Pop Positional Other (hasvalue) - value');
is ($positional->value, undef, 
				'Pop Positional Other (hasvalue) - return');
is_deeply (\@tmp, \@otherParams, 
				'Pop Positional Other (hasvalue) - arguments');


@tmp = @noTagParams;
$positional->set('value', undef);
$value = undef;
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef,
				'Pop Positional NoTag (hasvalue) - value');
is ($positional->value, undef,
				'Pop Positional NoTag (hasvalue) - return');
is_deeply (\@tmp, \@noTagParams, 'Pop Positional NoTag (hasvalue) - arguments');


@tmp = @justTagParams;
$positional->set('value', undef);
$value = $positional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Positional JustTag (hasvalue) - value');
is ($positional->value, undef, 'Pop Positional JustTag (hasvalue) - return');
is_deeply (\@tmp, \@justTagParams, 
					'Pop Positional JustTag (hasvalue) - arguments');


@numericParams = ( { tag => ':mytag' } , { 'number' => '42' } );
@stringParams = ( { tag => ':mytag' } , { 'stringlist' => [ '42' ] } );
@otherParams = ( { tag => ':mytag' } , { 'other' => [ '42' ] } );
@noTagParams = ( { 'other' => [ '42' ] } );
@justTagParams = ( { tag => ':mytag' } );

$optional = Parse::Sieve::Argument::StringList->new(
		type => 'optional',
		tag => ':mytag',
		hasvalue => '1');

@tmp = @numericParams;
$optional->set('value', undef);
$value = $optional->popvalue(\@tmp);
@tmp = grep {$_} @tmp;
is ($value, undef, 'Pop Optional Numeric (hasvalue) - return');
is ($optional->value, undef, 'Pop Optional Numeric (hasvalue) - value');
is_deeply (\@tmp, \@numericParams, 
					'Pop Optional Numeric (hasvalue) - arguments');

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
is($value, undef, 'Pop Optional Other (hasvalue) - return');
is($optional->value, undef , 'Pop Optional Other (hasvalue) - value');
is_deeply (\@tmp, \@otherParams, 'Pop Optional Other (hasvalue) - arguments');

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
