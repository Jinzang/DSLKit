#!/usr/bin/env perl
use strict;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 4;

BEGIN {use_ok("EvalCommand");} # test 1

my $eval = EvalCommand->new();
is(ref $eval, 'EvalCommand', "Right type"); # test 2

my $source = <<'EOQ';
$a 5
$b 10 20 30
$x [eval $a < 10]
$y [eval @b == 3]
EOQ

my $mock = DSLMock->main($source);
my $x = $mock->get_var('x')->get_value();
my $y = $mock->get_var('y')->get_value();

is_deeply($x, [1], "Simple scalar expression"); # test 3
is_deeply($y, [1], "Simple array expression"); # test 4