#!/usr/bin/env perl 
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use Test::More tests => 35;

BEGIN {use_ok("DSLVar");} # test 1

my $obj = DSLVar->new();
is_deeply($obj, {SETUP => 0, STATE => {}, VALUE => []}, "New object"); # test 2
is(ref $obj, 'DSLVar', "Right type"); # test 3

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

$val = 0;
$obj->set_value($val);
$val = $obj->status();
is($val, 1, "Status"); # test 11

$ok = {};
$obj->set_var('ok', $ok);
$val = $obj->get_var('ok');
is_deeply($val, $ok, "Get_var/set_var"); # test 12

my $top = DSLVar->new();
$obj = DSLVar->new($top, 'ok');
$val = $obj->get_var('ok');
is_deeply($val, $obj, "Create named var"); # test 13

$val = $obj->get_var('not');
is($val, undef, "Non-existent var"); # test 14

$ok = 'test';
$obj->set_value($ok);
my $test = $obj->if_string();
is($test, $ok, "if string"); # test 15

$obj->set_value(['one', 'two']);
$test = $obj->stringify();
is($test, "one\ntwo", "Stringify list variable"); # test 16

$obj->set_value({'one' => 1, 'two' => 2});
$test = $obj->stringify();
is($test, "one: 1 two: 2", "Stringify hash variable"); # test 17

my $lines = [];
my $one = DSLVar->new($top, 'one');
my $two = DSLVar->new($top, 'two');
$one->set_value(1);
$ok = $one->get_value();
$two->interpret_some_lines($lines, [], $two, $one);
$val = $two->get_value();
is_deeply($val, $ok, "run with scalar value"); # test 18

$one->set_value('one');
$two->set_value('two');
$two->interpret_some_lines($lines, [], $two, $one, $two);
$val = $two->get_value();
is_deeply($val, ['one', 'two'], "run with multiple args"); # test 19

$obj = DSLVar->new($top, 'ok');
$obj->set_value('test');

my $context = ['foo', 'bar'];
$test = $top->interpolate_var('ok', $context);
is($test, 'test', "Interpolate named variable"); # test 20

$test = $top->interpolate_var('1', $context);
is($test, 'bar', "Interpolate numbered string"); # test 21

$context = ['foo', $obj];
$test = $top->interpolate_var('1', $context);
is($test, 'test', "Interpolate numbered variable"); # test 22

$context = [];
my ($line, $arg) = $top->next_arg("\n", $context);
is($line, '', "Parse empty line"); # test 23
is($arg, undef, "Parse no argument"); # test 24

($line, $arg) = $top->next_arg('"don\'t care"', $context);
is($arg, 'don\'t care', "Parse simple double quoted string"); # test 25

($line, $arg) = $top->next_arg("'don\\'t care'", $context);
is($arg, 'don\'t care', "Single quoted string with escape"); # test 26

($line, $arg) = $top->next_arg("\"\\\$ok\"", $context);
is($arg, '$ok',"Double quoted string with escape"); # test 27
 
$context = ['mock', 'bar'];
($line, $arg) = $top->next_arg("\"foo\$1\"", $context);
is($arg, 'foobar', "Double quoted string with context variable"); # test 28

($line, $arg) = $top->next_arg("\"fair \$ok\"", $context);
is($arg, 'fair test', "Double quoted string with named variable"); # test 29

my @args;
my $mock = DSLVar->new($top, 'mock');
($line, @args) = $top->parse_a_line("\$mock one two three\n", $context);
is($line, '', "Completely parse simple line"); # test 30
is_deeply(\@args, [$mock, 'one', 'two', 'three'],
          "Parse simple strings"); # test 29

($line, @args) = $top->parse_a_line("\$mock 'one two' three\n", $context);
is_deeply(\@args, [$mock, 'one two', 'three'],
          "Parse simple single quoted string"); # test 32

($line, @args) = $top->parse_a_line("\$mock \$*\n", $context);
$val = $args[1]->get_value();
is_deeply($val, ['bar'], "Parse starred variable"); # test 33

($line, @args) = $top->parse_a_line("\$mock \$1\n", $context);
is_deeply(\@args, [$mock, 'bar'], "Parse numbered variable"); # test 34

my $a = DSLVar->new($top,'a');
my $b = DSLVar->new($top, 'b');
($line, @args) = $top->parse_a_line('$a [$b 3]', $context);
is_deeply(\@args, [$a, $b], "Parse bracketed expression"); # test 35

