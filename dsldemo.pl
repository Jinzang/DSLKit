#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;

use DSLMain;

my $base_dir = $Bin;
my $script;

##if (@ARGV) {
##    $script = shift @ARGV or die "No script on command line\n";
##    $script = "$base_dir/scripts/$script";
##    unshift(@ARGV, $script);
##}

my $demo = DSLMain->new(stage_dir => "$base_dir/stage");
$demo->main(@ARGV);
