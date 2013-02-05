#!/usr/bin/env perl
use strict;

use FindBin qw($Bin);
use lib "$Bin/..";

use Test::More tests => 9;
use LineReader;

BEGIN {use_ok("DSLBlock");} # test 1

my $block = DSLBlock->new();
is_deeply($block, {SETUP => 0, STATE => {}, VALUE => []}, "New block"); # test 2
is(ref $block, 'DSLBlock', "Right type"); # test 3

my $first = <<EOQ;
first line
not the end
neither is this
end
EOQ
my @first = map {"$_\n"} split(/\n/, $first);

my $second = <<EOQ;
please don't read this
end
EOQ
my @second = map {"$_\n"} split(/\n/, $second);

my $third = <<EOQ;
the next to last
the last line
EOQ
my @third = map {"$_\n"} split(/\n/, $third);

my @lines;
push(@lines, @first, @second, @third);
my $reader = LineReader->new(\@lines);

my $context = [];
my $test = $block->read_a_line($reader, $context);
my $ok = shift(@first);
is($test, $ok, "More lines"); # test 4

my @block = $block->read_some_lines($reader, $context);
is_deeply(\@block, \@first, "Read first block"); # test 5

@block = $block->read_some_lines($reader, $context);
is_deeply(\@block, \@second, "Read second block"); # test 6

@block = $block->read_some_lines($reader, $context);
my $line = pop(@block);

is($line, "end\n", "Add end to last line"); # test 7
is_deeply(\@block, \@third, "Read third block"); # test 8

$test = $block->read_a_line($reader, $context);
is($test, undef, "No more lines"); # test 9
