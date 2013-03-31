#!/usr/bin/env perl
use strict;

use Test::More tests => 7;

BEGIN {use_ok("LogCommand");} # test 1

my $log = LogCommand->new();
is_deeply($log, {SETUP => 0, STATE => {}, VALUE => []}, "New log"); # test 2
is(ref $log, 'LogCommand', "Right type"); # test 3

$log->run('a', 'message');
my $msg = $log->get_log();
is($msg, "a message\n", "Simple log msg"); # test 4

my $obj = DSLVar->new($log, "test");
$obj->set_value("ok");
$log->clear_log();
my @args = $log->check('is', $obj);
$log->run(@args);
$msg = $log->get_log();
my $msg_ok = <<'EOQ';
is ok
EOQ
is($msg, $msg_ok, "Log message with string variable"); # test 5

$log->clear_log();
$obj->set_value(['one', 'two']);
@args = $log->check($obj);
$log->run(@args);
$msg = $log->get_log();
$msg_ok = <<'EOQ';
one
two
EOQ
is($msg, $msg_ok, "Log message with list variable"); # test 6

$log->clear_log();
$obj->set_value({'one' => 1, 'two' => 2});
@args = $log->check($obj);
$log->run(@args);
$msg = $log->get_log();
$msg_ok = <<'EOQ';
one: 1
two: 2
EOQ
is($msg, $msg_ok, "Log message with hash variable"); # test 7
