use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# A code containing object

package DSLCode;

use base qw(DSLBlock);

#-----------------------------------------------------------------------
# Parse a set of lines

sub parse_some_lines {
    my ($self, $reader, @context) = @_;

    while (defined (my $line = $self->get_line($reader, \@context))) {
        my $obj = $self->interpret_a_line($reader, $line, \@context);

        if ($obj->status() == 0) {
            $self->set_script_status(0);
            last;
        }
    }

    return $self;
}

#-----------------------------------------------------------------------
# Read the next block of lines

sub read_some_lines {
    my ($self, $reader, @context) = @_;

    my @lines;
    while (defined (my $line = $self->get_line($reader, \@context))) {
        push(@lines, $line);

        my ($new_line, $cmd) = $self->next_arg($line, \@context);
        my $obj = $self->get_pkg($cmd);

        push(@lines, $obj->read_some_lines($reader, @context));
    }

    my $terminator = $self->terminator();
    push(@lines, "$terminator\n");

    return @lines;
}

1;
__END__
=head1 NAME

DSLBlock -- Base class for commands with multi-line data

=head1 SYNOPSIS

    my $obj = $obj->interpret_some_lines($reader, $context, @args);

    # Script syntax
    cmd $arg1 $arg2
    subcmd1 arg1 arg2
    subcmd2 $arg3
    end

=head1 SYNOPSIS

This class should be used as the base class for multiple line commands where the
lines after the first contains other commands. The can be recursive. Some of
these lines may also be multi-line commands. Two examples of classes based on
this class are ForCommand, which loops over a set of lines, and MacroCommand,
which saves a set of lines in a variable to be executed later.

=head1 METHODS

All the methods of DSLBlock are supported, mostly with the same meaning.

=head2 interpret_some_lines

    $obj = $obj->interpret_some_lines($reader, $context, @args);

This method is called after the command is parsed. The parsed line is placed
into $cmd (the first argument) and @args (the reamining arguments). $context
contains the parsed argument list of the containing object. $reader has the
next_line method, which is used to get the following lines of the multi-line
command.

=head2 parse_some_lines

    $obj2 = $obj->parse_some_lines($reader, @context);

This method is used to parse the following lines of a multi-line command, up
to the terminating line. The following lines are interpreted, and the result of
the last command is returned from the method. $reader has the next_line method,
which is used to get the following lines. @context contains the parsed
arguments from the first line of the multi-line command.

=head2 read_some_lines

    @lines = $obj->read_some_lines($reader, @context);

This method reads the follwing lines of a command without processing them. The
arguments are the same as parse_some_lines.

=head2 terminator

    $str = $obj->terminator();

The method returns the string used to end the block of lines. Each line is
parsed into arguments and when the first argument matches the terminator,
the command is done.
