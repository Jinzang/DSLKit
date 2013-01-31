#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec::Functions qw(rel2abs);
use IO::File;

use FindBin qw($Bin);
use lib "$Bin/..";

use Test::More tests => 7;

#----------------------------------------------------------------------
# Initialize test directories

my %params = (
                base_dir => '/tmp',
                script_dir => '/tmp/scripts',
                stage_dir => '/tmp/test',
              );

foreach my $dir ($params{stage_dir}, $params{script_dir}) {
    system("/bin/rm -rf $dir");
    mkdir $dir;
}

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("DSLMain");} # test 1

my $main = DSLMain->new(%params);
isa_ok($main, "DSLMain"); # test 2

#----------------------------------------------------------------------
# Test for staging directory

$main->create_stage_dir();
ok(-e $params{stage_dir}, "Create stage dir"); # test 3

$main->delete_stage_dir();
ok(! -e $params{stage_dir}, "Delete stage dir"); # test 4

#----------------------------------------------------------------------
# Read script

my $script = <<'EOQ';
macro $test
log Testing $1
end
$test one
$test two
EOQ

my $script_name = "$params{script_dir}/script.cmd";
my $fd = IO::File->new($script_name, 'w');
print $fd $script;
$fd->close;

#----------------------------------------------------------------------
# Run

$main = DSLMain->new(%params);
$main->main($script_name);

my $msg = $main->get_log();
my @msg = split(/\n/, $msg);

is($msg[0], "This script is $script_name", "Starting run message"); # test 5
is($msg[2], "Testing one", "First macro call"); # test 6
is($msg[3], "Testing two", "Second macro call"); # test 7
