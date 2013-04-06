#!/usr/bin/env perl
use strict;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 3;

BEGIN {use_ok("ReturnCommand");} # test 1

my $return = ReturnCommand->new();
is(ref $return, 'ReturnCommand', "Right type"); # test 2

my $source = <<'EOQ';
macro $double
return [eval 2*$1]
set $double 0
end
$a [$double 5]
EOQ

my $mock = DSLMock->main($source);
my $a = $mock->get_var('a')->get_value();

is_deeply($a, [10], "Return from macro"); # test 3
