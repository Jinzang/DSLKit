#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 4;

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("ForCommand");} # test 1

#----------------------------------------------------------------------
# Test methods

my $source = <<'EOQ';
$j ''
for $i one two three four
$j "$j$i "
end
EOQ

my $block = DSLMock->main($source);
my $j = $block->get_var('j')->get_value();
is_deeply($j, ['one two three four '], "Single loop"); # test 2

$source = <<'EOQ';
$k ''
for $i red blue
for $j car boat
$k "$k$i $j,"
end
end
EOQ

$block = DSLMock->main($source);
my $k = $block->get_var('k')->get_value();
is_deeply($k, ["red car,red boat,blue car,blue boat,"],
          "Double loop"); # test 3

$source = <<'EOQ';
$k ''
for $i red blue
for $j car boat
$k "$k$1 $i $j,"
end
end
EOQ

$block = DSLMock->main($source, 'big');
$k = $block->get_var('k')->get_value();
is_deeply($k, ["big red car,big red boat,big blue car,big blue boat,"],
          "Double loop with varuable"); # test 4
