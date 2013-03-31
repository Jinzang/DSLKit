#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 3;

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("MacroCommand");} # test 1

#----------------------------------------------------------------------
# Test methods

my $source = <<'EOQ';
macro $sum
set $sum 0
for $i $*
set $sum [eval $sum+$i]
end
end
$x [$sum 10 20 30]
EOQ

my $block = DSLMock->main($source);
my $sum = $block->get_var('sum');
my $code = $sum->get('code');
my $code_ok = [
"set \$sum 0\n",
"for \$i \$*\n",
"set \$sum [eval \$sum+\$i]\n",
"end\n",
"end\n",
];

is_deeply($code, $code_ok, "Macro code"); # test 2

my $x = $sum->get_value();
is_deeply($x, [60], "Macro result"); # test 3
