#!/usr/bin/env perl
use strict;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 4;

BEGIN {use_ok("SetCommand");} # test 1

my $set = SetCommand->new();
is(ref $set, 'SetCommand', "Right type"); # test 2

my $source = <<'EOQ';
set $a 5
set $b 10 20 30
EOQ

my $mock = DSLMock->main($source);
my $a = $mock->get_var('a')->get_value();
my $b = $mock->get_var('b')->get_value();

is_deeply($a, [5], "Scalar assignment"); # test 3
is_deeply($b, [10, 20, 30], "Array expression"); # test 4
