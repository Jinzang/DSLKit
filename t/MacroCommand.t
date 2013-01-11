#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 2;

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("MacroCommand");} # test 1

#----------------------------------------------------------------------
# Test methods

my $source = <<'EOQ';
macro $test
for $i 1 2 3
log $1 $i
end for
end macro
$test count
EOQ

my $block = DSLMock->main($source);
my $test = $block->get_var('test');
my $code = $test->get('code');
my $code_ok = [
"for \$i 1 2 3\n",
"log \$1 \$i\n",
"end\n",
"end\n"
];

is_deeply($code, $code_ok, "Macro code"); # test 2
