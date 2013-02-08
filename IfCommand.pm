use strict;
use warnings;
use integer;

package IfCommand;

use base qw(DSLCode);

#-----------------------------------------------------------------------
# Check arguments to run

sub check {
    my ($self, @args) = @_;

    my $arg = shift @args;
    die "No test on if\n" unless defined $arg;
    die "Too many args on if\n" if @args;
    
    return $arg;
}

#----------------------------------------------------------------------
# Execute a block of lines conditionally

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    my $arg = $self->check(@args);
    my @if_lines = $self->read_some_lines($reader, @$context);
    my $test = ref $arg ? $arg->dereferenced_value() : $arg;

    if ($test) {
        my $reader = LineReader->new(\@if_lines);
        $self->parse_some_lines($reader, @$context);
    }

    return $self;
}

1;
__END__
=head1 NAME

IfCommand -- Test whether to execute a block of commands

=head1 SYNOPSIS

    if [eval -e 'filename.txt']
    cat filename.txt
    end

=head1 USAGE

This command the value of its argument and executes the commands in the block
if the expression is Perl true.

=head1 ARGUMENTS

This command takes one argument, a value to test

=head1 PARAMETERS

This command does not use any parameters.

=back
