#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec::Functions qw(rel2abs);
use IO::File;

use FindBin qw($Bin);
use lib "$Bin/..";

use Test::More tests => 4;

#----------------------------------------------------------------------
# Initialize test directories

my %params = (
                base_dir => '/tmp',
              );

my $script_dir = "$params{base_dir}/scripts";
system("/bin/rm -rf $script_dir");
mkdir $script_dir;

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("DSLMain");} # test 1

my $main = DSLMain->new(%params);
isa_ok($main, "DSLMain"); # test 2

#----------------------------------------------------------------------
# Read script

my $script = <<'EOQ';
$x 1
$y 2
$z [eval $x + $y]
$a [eval $base_dir =~ /tmp/]
EOQ

my $script_name = "$script_dir/script.cmd";
my $fd = IO::File->new($script_name, 'w');
print $fd $script;
$fd->close;

#----------------------------------------------------------------------
# Run

$main = DSLMain->new(%params);
$main->main($script_name);

my $z = $main->get_var('z')->get_value();
is_deeply($z, [3], "read and run commands"); # test 3

my $a = $main->get_var('a')->get_value();
is_deeply($a, [1], "use input variables"); # test 4
