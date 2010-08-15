#!/usr/bin/perl -w
#
# Test the behaviour of The actual RecDescent Parser
#

use strict;

use Test::More tests => 80;

use_ok('Parse::Sieve');

use Parse::Sieve;

my $parser = Parse::Sieve->new();
ok($parser ,'Parse::Sieve created');

# Grab direct access to the parser/Grammar, this should not normally be done
# but allows us to test functionallity of some of the more, low level parts
# of the grammar/tokeniser
$parser = $parser->{'parser'};
ok($parser, 'Parser extracted');

# Identifier
# identifier = (ALPHA / "_") *(ALPHA DIGIT "_")

# -- valid tokens --
my $id = '_token42';
my $parsed = $parser->identifier($id);
is ($parsed, $id ,"Identifier: $id");
$id = 'tok_en';
$parsed = $parser->identifier($id);
is ($parsed, $id, "Identifier: $id");
$id = 'token';
$parsed = $parser->identifier($id);
is ($parsed, $id, "Identifier: $id");
# -- invalid tokens --
my $bad_id = '43_token';
$parsed = $parser->identifier($bad_id);
ok (! $parsed, "Bad Identifier: $bad_id");
$bad_id = '$wibble';
$parsed = $parser->identifier($bad_id);
ok (! $parsed, "Bad Identifier: $bad_id");


# Tag
# tag = ":" identifier

# -- valid tokens --
my $tag = ':_token42';
$parsed = $parser->tag($tag);
is ($parsed, $tag ,"Tag: $tag");
$tag = ':tok_en';
$parsed = $parser->tag($tag);
is ($parsed, $tag, "Tag: $tag");
$tag = ':token';
$parsed = $parser->tag($tag);
is ($parsed, $tag, "Tag: $tag");
# -- invalid tokens --
my $bad_tag = '43_token';
$parsed = $parser->tag($bad_tag);
ok (!$parsed, "Bad Tag: $bad_tag");
$bad_tag = '$wibble';
$parsed = $parser->tag($bad_tag);
ok (!$parsed, "Bad Tag: $bad_tag");
$bad_tag = ':43_token';
$parsed = $parser->tag($bad_tag);
ok (!$parsed, "Bad Tag: $bad_tag");
$bad_tag = ':$wibble';
$parsed = $parser->tag($bad_tag);
ok (!$parsed, "Bad Tag: $bad_tag");


# Quantifier
# QUANTIFIER = "K" / "M" / "G"

# -- valid tokens --
my $quantifier = 'K';
$parsed = $parser->QUANTIFIER($quantifier);
is ($parsed, $quantifier ,"Quantifier: $quantifier");
# -- invalid tokens --
my $bad_quantifier = 'F';
$parsed = $parser->QUANTIFIER($bad_quantifier);
ok (!$parsed, "Bad Quantifier: $bad_quantifier");


# Number
# number = 1*DIGIT [QUANTIFIER]
# -- valid tokens --
my $number = '2';
$parsed = $parser->number($number);
is ($parsed, $number ,"Number: $number");
$number = ' 2';
$parsed = $parser->number($number);
is ($parsed, '2' ,"Number: $number");
$number = '2 ';
$parsed = $parser->number($number);
is ($parsed, '2' ,"Number: $number");
$number = '100M';
$parsed = $parser->number($number);
is ($parsed, $number ,"Number: $number");
# -- invalid tokens --
my $bad_number = 'K';
$parsed = $parser->number($bad_number);
ok (!$parsed, "Bad Number: $bad_number");
$bad_number = 'L';
$parsed = $parser->number($bad_number);
ok (!$parsed, "Bad Number: $bad_number");


# Quoted Strings
# quoted-string = DQUOTE *CHAR DQUOTE
my $text = '"wibble"';
$parsed = $parser->quoted_string($text);
is ($parsed, 'wibble' ,"Quoted String: $text");
$text = '"wibb;le"';
$parsed = $parser->quoted_string($text);
is ($parsed, 'wibb;le' ,"Quoted String: $text");
$text = '" wibble"';
$parsed = $parser->quoted_string($text);
is ($parsed, ' wibble' ,"Quoted String: $text");
$text = '"wibble "';
$parsed = $parser->quoted_string($text);
is ($parsed, 'wibble ' ,"Quoted String: $text");
$text = '" wi bble "';
$parsed = $parser->quoted_string($text);
is ($parsed, ' wi bble ' ,"Quoted String: $text");
# -- invalid tokens --
my $bad_text = '"wibble';
$parsed = $parser->quoted_string($bad_text);
ok (!$parsed, "Bad Quoted String: $bad_text");
$bad_text = 'wibble';
$parsed = $parser->quoted_string($bad_text);
ok (!$parsed, "Bad Quoted String: $bad_text");
$bad_text = 'wibb"le';
$parsed = $parser->quoted_string($bad_text);
ok (!$parsed, "Bad Quoted String: $bad_text");

# Multiline Strings
# multi-line        = "text:" *(SP / HTAB) (hash-comment / CRLF)
#   *(multi-line-literal / multi-line-dotstuff)
#   "." CRLF

$text = 'text:
Some text
.
';
$parsed = $parser->multi_line($text);
is ($parsed, "Some text\n" ,'Multiline String: (simple)');
# Double dot is the escape...
$text = 'text:
..
.
';
$parsed = $parser->multi_line($text);
is ($parsed, ".\n" ,'Multiline String: (..)');
# .Some things is valid (only a "\n.\n" ends the token)
$text = 'text:
.Some text
.
';
$parsed = $parser->multi_line($text);
is ($parsed, ".Some text\n" ,'Multiline String: (.Text)');
# Hash comments are valid after the "text:" as is "\t" and " "
$text = "text: \t #Some comment
Some text
.
";
$parsed = $parser->multi_line($text);
is ($parsed, "Some text\n" ,'Multiline String: (comments)');
# Make sure we don't swallow whitespace that we shouldn't swallow
$text = 'text: 

  Some text

.
';
$parsed = $parser->multi_line($text);
is ($parsed, "\n  Some text\n\n" ,'Multiline String: (whitespace)');


# -- invalid tokens --
$bad_text = '"wibble"';
$parsed = $parser->multi_line($bad_text);
ok (!$parsed, 'Bad Multiline String: (string)');
$bad_text = 'text: wibble
Some text
.';
$parsed = $parser->multi_line($bad_text);
ok (!$parsed, 'Bad Multiline String: (Non-comment after text:)');
$bad_text = 'text:
Some text
';
$parsed = $parser->multi_line($bad_text);
ok (!$parsed, 'Bad Multiline String: (no EOF)');


# Strings (Simple ones)
# string = quoted-string / multi-line

# Simple string
$text = '"wibble"';
$parsed = $parser->string($text);
is ($parsed, 'wibble' ,'String: (quoted-string)');
$text = 'text:
Some text
.
';
$parsed = $parser->string($text);
is ($parsed, "Some text\n" ,'String: (multiline)');


# Lists of strings
# string-list = "[" string *("," string) "]" / string
#
# ONE OF ...
#
# Simple string
$text = '"wibble"';
$parsed = $parser->string_list($text);
ok ($parsed, 'StringList: (single quoted)');
is (ref $parsed, 'ARRAY', 'StringList: (single quoted)');
is (scalar @{$parsed}, 1, 'StringList: (single quoted)');
is ($parsed->[0], 'wibble' ,'StringList: (single quoted)');
# Simple multiline string
$text = 'text:
Some text
.
';
$parsed = $parser->string_list($text);
ok ($parsed, 'StringList: (single multiline)');
is (ref $parsed, 'ARRAY', 'StringList: (single multiline)');
is (scalar @{$parsed}, 1, 'StringList: (single multiline)');
is ($parsed->[0], "Some text\n" ,'String: (single multiline)');
#
# ONE OF ...
#
# Simple string
$text = ' [ "wibble" ] ';
$parsed = $parser->string_list($text);
ok ($parsed, 'StringList: (single bracketed quoted)');
is (ref $parsed, 'ARRAY', 'StringList: (single bracketed quoted)');
is (scalar @{$parsed}, 1, 'StringList: (single bracketed quoted)');
is ($parsed->[0], 'wibble' ,'StringList: (single bracketed quoted)');
# Simple multiline string
$text = '[ text:
Some text
.
]';
$parsed = $parser->string_list($text);
ok ($parsed, 'StringList: (single bracketed multiline)');
is (ref $parsed, 'ARRAY', 'StringList: (single bracketed multiline)');
is (scalar @{$parsed}, 1, 'StringList: (single bracketed multiline)');
is ($parsed->[0], "Some text\n" ,'String: (single bracketed multiline)');
#
# Two OF ...
#
# Simple string
$text = ' [ "wibble" , "wobble" ] ';
$parsed = $parser->string_list($text);
ok ($parsed, 'StringList: (double quoted)');
is (ref $parsed, 'ARRAY', 'StringList: (double quoted)');
is (scalar @{$parsed}, 2, 'StringList: (double quoted)');
is ($parsed->[0], 'wibble' ,'StringList: (double quoted)');
is ($parsed->[1], 'wobble' ,'StringList: (double quoted)');
# Simple multiline string
$text = '[ text:
Some text
.
, text:
Some other text
.
]';
$parsed = $parser->string_list($text);
ok ($parsed, 'StringList: (double multiline)');
is (ref $parsed, 'ARRAY', 'StringList: (double multiline)');
is (scalar @{$parsed}, 2, 'StringList: (double multiline)');
is ($parsed->[0], "Some text\n" ,'String: (double multiline)');
is ($parsed->[1], "Some other text\n" ,'String: (double multiline)');
# One of each
$text = '[ text:
Some text
.
, "wibble"
]';
$parsed = $parser->string_list($text);
ok ($parsed, 'StringList: (double multiline and quoted)');
is (ref $parsed, 'ARRAY', 'StringList: (double multiline and quoted)');
is (scalar @{$parsed}, 2, 'StringList: (double multiline and quoted)');
is ($parsed->[0], "Some text\n" ,'String: (double multiline and quoted)');
is ($parsed->[1], "wibble" ,'String: (double multiline and quoted)');

# argument = string_list / number / tag
# We check further up for these all behaving properly
my $number_val = $parser->argument('42');
my $string = $parser->argument('"hello world"');
my $string_list = $parser->argument('["hello world","goodbye world"]');
my $mytag = $parser->argument(":mytag");

ok ($number_val, 'Argument: Number');
ok ($string, 'Argument: String');
ok ($string_list, 'Argument: Stringlist');
ok ($mytag, 'Argument: Tag');

is_deeply($number_val, { 'number' => '42'}, 'Argument: Number - value');
is_deeply($string, { 'stringlist' => ['hello world']}, 
							'Argument: String - value');
is_deeply($string_list, { 'stringlist' => ['hello world', 'goodbye world'] }, 
							'Argument: StringList - value');
is_deeply($mytag, { 'tag' => ':mytag'}, 'Argument: Tag - value');
