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
for $i one two three four
log $i
end
EOQ

my $block = DSLMock->main($source);
my $msg = $block->get_log();
my $msg_ok = <<'EOQ';
       'one'
       'two'
       'three'
       'four'
EOQ
is($msg, $msg_ok, "Single loop"); # test 2

$source = <<'EOQ';
for $i red blue
for $j car boat
log $i $j
end
end
EOQ


$block = DSLMock->main($source);
$msg = $block->get_log();
$msg_ok = <<'EOQ';
       'red'        'car'
       'red'        'boat'
       'blue'        'car'
       'blue'        'boat'
EOQ
is($msg, $msg_ok, "Double loop"); # test 3

$source = <<'EOQ';
for $i red blue
for $j car boat
log $1 $i $j
end
end
EOQ

$block = DSLMock->main($source, 'big');
$msg = $block->get_log();
$msg_ok = <<'EOQ';
big        'red'        'car'
big        'red'        'boat'
big        'blue'        'car'
big        'blue'        'boat'
EOQ
is($msg, $msg_ok, "Double loop with varuable"); # test 4
