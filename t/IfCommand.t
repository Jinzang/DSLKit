#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 2;

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("IfCommand");} # test 1

#----------------------------------------------------------------------
# Test methods

my $source = <<'EOQ';
for $i 0 1
if $i
log $i
end
end
EOQ

my $block = DSLMock->main($source);
my $msg = $block->get_log();
my $msg_ok = <<'EOQ';
       '1'
EOQ

is($msg, $msg_ok, "If Command"); # test 2
