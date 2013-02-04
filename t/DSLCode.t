#!/usr/bin/env perl
use strict;

use FindBin qw($Bin);
use lib "$Bin/..";

use Test::More tests => 7;
use LineReader;

BEGIN {use_ok("DSLCode");} # test 1

my $code = DSLCode->new();
is_deeply($code, {SETUP => 0, STATE => {}, VALUE => []}, "New code"); # test 2
is(ref $code, 'DSLCode', "Right type"); # test 3

my $lines = <<'EOQ';
$abe 1
$bob 2
$chris $abe
$dave [$bob 3]
$edgar [$abe 4] 5
EOQ

my @lines = map {"$_\n"} split(/\n/, $lines);
my @input = @lines;
my $reader = LineReader->new(\@input);

$code->setup();
my @output = $code->read_some_lines($reader);
my $end = pop(@output);

is_deeply(\@output, \@lines, "Read lines"); # test 4
is($end, "end\n", "Added end"); # test 5

@input = @lines;
$reader = LineReader->new(\@input);

my $context = [];
my $line = $reader->next_line();
my ($obj, @args) = $code->parse_a_line($line, $context);
$obj->interpret_some_lines($reader, $context, @args);

my $val = $obj->get_value();
is_deeply($val, [1], "Interpret some lines value"); # test 6

$obj = $code->get_var('abe');
$val = $obj->get_value();
is_deeply($val, [1], "Interpret some lines variable"); # test 7
