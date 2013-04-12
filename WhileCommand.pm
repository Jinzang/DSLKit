use strict;
use warnings;
use integer;

package WhileCommand;

use base qw(DSLCode);

#-----------------------------------------------------------------------
# Check arguments

sub check {
    my ($self, @args) = @_;

    my $arg = shift @args;
    die "No test on while\n" unless defined $arg;
    die "Too many args on while\n" if @args;
    
    return $arg;
}

#----------------------------------------------------------------------
# Evaluate while expression test

sub do_again {
    my ($self, $subline, $context) = @_;

    my $reader = NoReader->new;
    my ($obj, @args) = $self->parse_a_line($subline, $context);
    my $arg = $obj->interpret_some_lines($reader, $context, @args);

    my $test = ref $arg ? $arg->dereferenced_value() : $arg;
    return $test;
}

#----------------------------------------------------------------------
# Loop over a block of lines while condition is true

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    my $subline = $self->check(@args);
    my @while_lines = $self->read_some_lines($reader, @$context);

    my @result;
    while ($self->do_again($subline, $context)) {
        my $reader = LineReader->new(\@while_lines);
        my $obj = $self->parse_some_lines($reader, @$context);

        push(@result, $obj);
    }

    $self->set_value($self->flatten(@result));
    return $self;
}

#----------------------------------------------------------------------
# Return a bracketed expression without interpreting it

sub interpret_subline {
    my ($self, $subline, $context) = @_;

    return $subline;
}

1;
__END__
=head1 NAME

WhileCommand -- Loop over a goup of commands conditionally

=head1 SYNOPSIS

    macro $factorial
    $i $1
    set $factorial 1
    while [$i]
    set $factorial [eval $factorial * $i]
    $i [eval $i - 1]
    end while
    end macro

=head1 USAGE

This command treats the rest of the line as a test and executes the commands
in the block repeatedly while test is Perl true.

=head1 ARGUMENTS

This command takes the rest of the line as a command and evaluates it each
time the loop starts

=head1 PARAMETERS

This command does not use any parameters.

=back
