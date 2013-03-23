#!/usr/bin/env perl
use strict;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 6;

BEGIN {use_ok("EvalCommand");} # test 1

my $eval = EvalCommand->new();
is(ref $eval, 'EvalCommand', "Right type"); # test 2

my $source = <<'EOQ';
$a 5
$b 10 20 30
$x [eval $a < 10]
$y [eval @b == 3]
$z [eval 1/$1]
$sum 0
for $i 1 2 3 4 5 6 7 8 9 10
$sum [eval $sum+$i]
end
EOQ

my $mock = DSLMock->main($source, 2);
my $x = $mock->get_var('x')->get_value();
my $y = $mock->get_var('y')->get_value();
my $z = $mock->get_var('z')->get_value();
my $sum = $mock->get_var('sum')->get_value();

is_deeply($x, [1], "Simple scalar expression"); # test 3
is_deeply($y, [1], "Simple array expression"); # test 4
is_deeply($z, [0.5], "Expression with number variable"); #test 5
is_deeply($sum, [55], "Eval inside of loop"); # test 6
