use strict;
use warnings;


use Test::More tests => 3;

#----------------------------------------------------------------------
# Tests

BEGIN {use_ok("ExternalCommands");} # test 1

my $command = get_external_command('uname');
ok($command =~ /\/uname/, "get external command"); # test 2

my $msg = run_external_command('uname');
ok($msg, "run external command"); # test 3