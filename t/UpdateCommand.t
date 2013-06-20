#!/usr/bin/env perl
use strict;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 4;

BEGIN {use_ok("UpdateCommand");} # test 1

my $update = UpdateCommand->new();
is(ref $update, 'UpdateCommand', "Right type"); # test 2

my $source = <<'EOQ';
new mock $mock
foo: 0
end

$a [show $mock STATE foo]
update $mock foo 1
$b [show $mock STATE foo]
EOQ

my $mock = DSLMock->main($source);
my $a = $mock->get_var('a')->get_value();
my $b = $mock->get_var('b')->get_value();

is_deeply($a, [0], "Before update"); # test 3
is_deeply($b, [1], "After update"); # test 4
