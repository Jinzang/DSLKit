#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 4;

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("NewCommand");} # test 1
my $new = NewCommand->new('new');
isa_ok($new, "NewCommand"); # test 2

#----------------------------------------------------------------------
# Test methods

my $source = <<'EOQ';
new mock $test
Constant: value
First: 1
Second: 2
Third: 3
Description: This is a
multiline parameter.
end
$test
EOQ

my $block = DSLMock->main($source);

my $test = $block->get_var('test');
my $result = $test->{STATE};

my $result_ok = {First => 1,
                 Second => 2,
                 Third => 3,
                 Constant => 'value',
                 Description => "This is a\nmultiline parameter."
                 };

is_deeply($result, $result_ok, "Test parsing"); # test 3
ok($test->{SETUP} > 0, "Test setup"); # test 4
