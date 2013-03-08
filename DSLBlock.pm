use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Main Class for a Domain Specific Language

package DSLBlock;

use base qw(DSLVar);

#-----------------------------------------------------------------------
# Read the next block of lines

sub read_some_lines {
    my ($self, $reader, @context) = @_;

    # One trick that makes this code work is that read_a_line does not
    # return the terminating line and this method appends it. This
    # prevents the terminating line from being interpreted.

    my @lines;
    while (defined (my $line = $self->read_a_line($reader, \@context))) {
        push(@lines, $line);
    }

    my $terminator = $self->terminator();
    push(@lines, "$terminator\n");
    return @lines;
}

#-----------------------------------------------------------------------
# Check the status

sub status {
    my ($self) = @_;

    return 1;
}

1;
__END__
=head1 NAME

DSLBlock -- Base class for commands with multi-line data

=head1 SYNOPSIS

    my $obj = $obj->interpret_some_lines($reader, $context, @args);

    # Script syntax
    cmd $arg1 $arg2
    field1: value1
    field2: value2
    end

=head1 SYNOPSIS

This class should be used as the base class for multiple line commands where the
lines after the first contain data and not other commands. An example is
NewCommand, which creates a variable and intitializes its state.

=head1 METHODS

All the methods of DSLVar are supported. The method read_some_lines is
over-ridden so that it returns a block of lines, up to the terminating line.
The method status is over-ridden so that a block does not end interpretation.

=head2 read_some_lines

    @lines = $obj->read_some_lines($reader, @context);

This method reads the follwing lines of a command without processing them. The
arguments are the same as parse_some_lines.

