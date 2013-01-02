#!/usr/bin/env perl 
use strict;

use Test::More tests => 6;

BEGIN {use_ok("DSLCmd");} # test 1

my $cmd = DSLCmd->new();
is_deeply($cmd, {SETUP => 0, STATE => {}, VALUE => []}, "New command"); # test 2
is(ref $cmd, 'DSLCmd', "Right type"); # test 3

$cmd->log('mock');
my $log = $cmd->get_log();
is($log, "mock (0)\n", "Simple log msg"); # test 4

$cmd->clear_log();
$cmd->log('mock', 'a string');
$log = $cmd->get_log();
is($log, "mock 'a string' (0)\n", "Quoted string log msg"); # test 5

my $obj = DSLVar->new($cmd, "test");
$cmd->clear_log();
$cmd->log('mock', $obj);
$log = $cmd->get_log();
is($log, "mock \$test (0)\n", "Log message with variable"); # test 6
