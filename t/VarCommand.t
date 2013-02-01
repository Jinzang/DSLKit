#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 4;

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("VarCommand");} # test 1
my $var = VarCommand->new('new');
isa_ok($var, "VarCommand"); # test 2

#----------------------------------------------------------------------
# Test methods

my $source = <<'EOQ';
var mock $test
$test
EOQ

my $block = DSLMock->main($source);

my $test = $block->get_var('test');
my $type = ref $test;
is($type, 'MockCommand', "set type"); # test 3
ok($test->{SETUP} > 0, "test setup"); # test 4
