#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";
use DSLMock;

use Test::More tests => 16;

#----------------------------------------------------------------------
# Create object

BEGIN {use_ok("ShowCommand");} # test 1
my $show = ShowCommand->new();
isa_ok($show, "ShowCommand"); # test 2

my $a = DSLVar->new($show, 'a');

#----------------------------------------------------------------------
# Test parsing

my ($var, @fields) = $show->parse_args();
is($var, $show, "Parse var with no args"); # test 3
is_deeply(\@fields, [], "Parse fields with no args"); # test 4

($var, @fields) = $show->parse_args('STATE');
is($var, $show, "Parse var with no var"); # test 5
is_deeply(\@fields, ['STATE'], "Parse fields with no var"); # test 6

$show->set('fields', ['SETUP']);
($var, @fields) = $show->parse_args('^');
is($var, $show, "Parse var with caret"); # test 7
is_deeply(\@fields, ['SETUP'], "Parse fields with caret"); # test 8

($var, @fields) = $show->parse_args($a, 'PARENT');
is($var, $a, "Parse var with variable"); # test 9
is_deeply(\@fields, ['PARENT'], "Parse fields with variable"); # test 10

#----------------------------------------------------------------------
# Find data

$a->set_value([1, 2]);
my $data = $show->find_data($show, qw(STATE a VALUE 1));
is($data, 2, "Find data"); # test 11

$data = $show->find_data($show, qw(STATE b VALUE));
is($data, undef, "Find data when no data"); # test 12

#----------------------------------------------------------------------
# Get data

my $value = $show->get_data($a->{VALUE}[0]);
is_deeply($value, [1], "Get scalar data"); # test 13

$value = $show->get_data($a->{VALUE});
is_deeply($value, [1, 2], "Get array data"); # test 14

$value = $show->get_data($show);
is_deeply($value, [qw(SETUP STATE VALUE)], "Get hash data"); # test 15

#----------------------------------------------------------------------
# Execute

my $code = <<'EOQ';
$a 1 2
$b [show $a VALUE 1]
EOQ

my $mock = DSLMock->main($code);
my $b = $mock->get_var('b');
$value = $b->get_value();
is_deeply($value, [2], "Execute"); # test 16
