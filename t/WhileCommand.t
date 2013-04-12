#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 3;

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("WhileCommand");} # test 1

#----------------------------------------------------------------------
# Test methods

my $source = <<'EOQ';
macro $factorial
$i $1
set $factorial 1
while [$i]
set $factorial [eval $factorial * $i]
$i [eval $i - 1]
end while
end macro
$j [$factorial 5]
EOQ

my $block = DSLMock->main($source);
my $i = $block->get_var('i')->get_value();
is_deeply($i, [0], "While block variable"); # test 2

my $j = $block->get_var('j')->get_value();
is_deeply($j, [120], "While block result"); # test 3
