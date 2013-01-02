#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;
use DSLMain;

my $base_dir = $Bin;

if (@ARGV) {
    my $script = "$base_dir/scripts/" . shift(@ARGV);
    unshift(@ARGV, $script);
}

my $demo = DSLMain->new(stage_dir => "$base_dir/stage");
$demo->main(@ARGV);
