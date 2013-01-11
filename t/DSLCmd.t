#!/usr/bin/env perl
use strict;

use File::Spec::Functions qw(rel2abs);
use FindBin qw($Bin);
use lib "$Bin/..";

use Test::More tests => 6;

BEGIN {use_ok("DSLCmd");} # test 1
use MockCommand;

my $cmd = DSLCmd->new();
is_deeply($cmd, {SETUP => 0, STATE => {}, VALUE => []}, "New command"); # test 2
is(ref $cmd, 'DSLCmd', "Right type"); # test 3

my $mock = MockCommand->new();
$mock->log('foobar');
my $log = $mock->get_log();
is($log, "mock foobar (0)\n", "Simple log msg"); # test 4

$mock->clear_log();
$mock->log('a string');
$log = $mock->get_log();
is($log, "mock 'a string' (0)\n", "Quoted string log msg"); # test 5

my $obj = DSLVar->new($cmd, "test");
$mock->clear_log();
$mock->log($obj);
$log = $mock->get_log();
is($log, "mock \$test (0)\n", "Log message with variable"); # test 6
