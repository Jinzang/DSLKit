#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use Test::More tests => 37;

BEGIN {use_ok("DSLVar");} # test 1

my $obj = DSLVar->new();
is_deeply($obj, {SETUP => 0, STATE => {}, STATUS => 1, VALUE => []},
          "New object"); # test 2

is(ref $obj, 'DSLVar', "Right type"); # test 3

$obj->setup();
$obj->set('one', 1);
my $val = $obj->get('one');
is($val, 1, "Get/set"); # test 4
$val = $obj->get('two');
is($val, undef, "Get non-existent value"); # test 5

my $ok = [qw(one two)];
$obj->set_value($ok);
$val = $obj->get_value();
is_deeply($val, $ok, "Get_value/set_value"); # test 6

$ok = 3;
$obj->set_value($ok);
$val = $obj->get_value();
is_deeply($val, [$ok], "Set_value array coercion"); # test 7

my @list = $obj->flatten();
is_deeply(\@list, [], "Flatten with no args"); # test 8

@list = $obj->flatten('one');
is_deeply(\@list, ['one'], "Flatten with one arg"); # test 9

$obj->set_value(['one', 'two']);
@list = $obj->flatten($obj, 'three');
is_deeply(\@list, ['one', 'two', 'three'], "Flatten with mixed args"); # test 10

$obj->set_status(42);
$val = $obj->get_status();
is($val, 42, "Status"); # test 11

$ok = {};
$obj->set_var('ok', $ok);
$val = $obj->get_var('ok');
is_deeply($val, $ok, "Get_var/set_var"); # test 12

my $top = DSLVar->new();
$top->setup();

$obj = DSLVar->new($top, 'ok');
$val = $obj->get_var('ok');
is_deeply($val, $obj, "Create named var"); # test 13

$val = $obj->get_var('not');
is($val, undef, "Non-existent var"); # test 14

$obj->set_value(['one', 'two']);
my $test = $obj->stringify();
my $test_ok = <<'EOQ';
one
two
EOQ
chomp$test_ok;
is($test, $test_ok, "Stringify list variable"); # test 15

$obj->set_value({'one' => 1, 'two' => 2});
$test = $obj->stringify();
$test_ok = <<'EOQ';
one:1
two:2
EOQ
chomp $test_ok;
is($test, $test_ok, "Stringify hash variable"); # test 16

my $lines = [];
my $one = DSLVar->new($top, 'one');
my $two = DSLVar->new($top, 'two');
$one->set_value(1);
$ok = $one->get_value();
$two->interpret_some_lines($lines, [],  $one);
$val = $two->get_value();
is_deeply($val, $ok, "run with scalar value"); # test 17

$one->set_value('one');
$two->set_value('two');
$two->interpret_some_lines($lines, [], $one, $two);
$val = $two->get_value();
is_deeply($val, ['one', 'two'], "run with multiple args"); # test 18

$obj = DSLVar->new($top, 'ok');
$obj->set_value('test');

$ok = 'test';
$obj->set_value($ok);
$test = $obj->get_string_value();
is($test, $ok, "Get string value, no args"); # test 19

my $context = ['foo', 'bar'];
$test = $top->get_string_value('ok',);
is($test, 'test', "Get string value, one arg"); # test 20

$test = $top->get_string_value('1', $context);
is($test, 'bar', "Get string value, two args"); # test 21

$context = ['foo', $obj];
$test = $top->get_string_value('1', $context);
is($test, 'test', "Interpolate numbered variable"); # test 22

my ($first, $rest) = $top->subline('[the [first][second] third]word');
is($first, 'the [first][second] third', "extract subline"); # test 23
is($rest, 'word', "remaining subline"); # test 24

$context = [];
my ($line, $arg) = $top->next_arg("\n", $context);
is($line, '', "Parse empty line"); # test 24
is($arg, undef, "Parse no argument"); # test 25

($line, $arg) = $top->next_arg('"don\'t care"', $context);
is($arg, 'don\'t care', "Parse simple double quoted string"); # test 26

($line, $arg) = $top->next_arg("'don\\'t care'", $context);
is($arg, 'don\'t care', "Single quoted string with escape"); # test 27

($line, $arg) = $top->next_arg("\"\\\$ok\"", $context);
is($arg, '$ok',"Double quoted string with escape"); # test 28

$context = ['mock', 'bar'];
($line, $arg) = $top->next_arg("\"foo\$1\"", $context);
is($arg, 'foobar', "Double quoted string with context variable"); # test 29

($line, $arg) = $top->next_arg("\"fair \$ok\"", $context);
is($arg, 'fair test', "Double quoted string with named variable"); # test 30

my @args;
my $mock = DSLVar->new($top, 'mock');
@args = $top->parse_a_line("\$mock one two three\n", $context);
is($line, '', "Completely parse simple line"); # test 31
is_deeply(\@args, [$mock, 'one', 'two', 'three'],
          "Parse simple strings"); # test 32

@args = $top->parse_a_line("\$mock 'one two' three\n", $context);
is_deeply(\@args, [$mock, 'one two', 'three'],
          "Parse simple single quoted string"); # test 33

@args = $top->parse_a_line("\$mock \$*\n", $context);
$val = $args[1]->get_value();
is_deeply($val, ['bar'], "Parse starred variable"); # test 34

@args = $top->parse_a_line("\$mock \$1\n", $context);
is_deeply(\@args, [$mock, 'bar'], "Parse numbered variable"); # test 35

my $a = DSLVar->new($top,'a');
my $b = DSLVar->new($top, 'b');
@args = $top->parse_a_line('$a [$b 3]', $context);
is_deeply(\@args, [$a, $b], "Parse bracketed expression"); # test 36
