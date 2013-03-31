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
$j $i
end
end
EOQ

my $block = DSLMock->main($source);
my $j = $block->get_var('j')->get_value();
is_deeply($j, [1], "If block"); # test 2
