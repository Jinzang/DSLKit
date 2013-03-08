#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec::Functions qw(rel2abs);
use IO::File;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 4;

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

BEGIN {use_ok("IncludeCommand");} # test 1

my $inc = IncludeCommand->new();
isa_ok($inc, "IncludeCommand"); # test 2

#----------------------------------------------------------------------
# Write script

my $script = <<'EOQ';
$a 1
$b 2
EOQ

my $script_name = "$params{script_dir}/file.inc";
my $fd = IO::File->new($script_name, 'w');
print $fd $script;
$fd->close;

#----------------------------------------------------------------------
# Run

my $source = <<"EOQ";
\$script_dir $params{script_dir}
include file.inc
EOQ

my $mock = DSLMock->main($source);

my $a = $mock->get_var('a')->get_value();
my $b = $mock->get_var('b')->get_value();

is_deeply($a, [1], "Read first var"); # test 3
is_deeply($b, [2], "Read second var"); # test 4
