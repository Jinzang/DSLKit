use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Main Class for a Domain Specific Language

package DSLBlock;

use base qw(DSLVar);
use constant DEFAULT_TERMINATOR => 'end';

#-----------------------------------------------------------------------
# Get the next input line

sub get_line {
    my ($self, $reader, $context) = @_;

    my $line = $reader->next_line();
    return unless defined $line;

    my ($new_line, $arg) = $self->next_arg($line, $context);
    return if defined $arg && $arg eq $self->terminator();

    return $line;
}

#-----------------------------------------------------------------------
# Parse the next block of lines to initialize the state

sub parse_some_lines {
    my ($self, $reader, @context) = @_;

    my %hash;
    my $name;
    while (defined (my $line = $self->get_line($reader, \@context))) {
        chomp $line;

        if ($line =~ /^\w+:/) {
            my $value;
            ($name, $value) = split(/:\s*/, $line, 2);
            $hash{$name} = $value;

        } else {
            die "Undefined field name\n" . substr($line, 20) . "\n"
                unless defined $name;

            $hash{$name} .= "\n$line";
        }
    }

    return \%hash;
}

#-----------------------------------------------------------------------
# Read the next block of lines

sub read_some_lines {
    my ($self, $reader, @context) = @_;

    # One trick that makes this code work is that get_line does not
    # return the terminating line and this method appends it. This
    # prevents the terminating line from being interpreted.

    my @lines;
    while (defined (my $line = $self->get_line($reader, \@context))) {
        push(@lines, $line);
    }

    my $terminator = $self->terminator();
    push(@lines, "$terminator\n");
    return @lines;
}

#-----------------------------------------------------------------------
# Get the string which terminates a block of commands

sub terminator {
    my ($self) = @_;
    return DEFAULT_TERMINATOR;
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

All the methods of DSLVar are supported. In addition, several new methods
support interpreting multiline commands.

=head2 interpret_some_lines

    $obj = $obj->interpret_some_lines($reader, $context, @args);

This method is called after the command is parsed. The parsed line is placed
into $cmd (the first argument) and @args (the reamining arguments). $context
contains the parsed argument list of the containing object. $reader has the
next_line method, which is used to get the following lines of the multi-line
command.

=head2 parse_some_lines

    $data = $obj->parse_some_lines($reader, @context);

This method is used to parse the following lines of a multi-line command, up
to the terminating line. The following lines are converted into $data, which
is returned from the method. $reader has the next_line method, which is used
to get the following lines. @context contains the parsed arguments from the
first line of the multi-line command.

=head2 read_some_lines

    @lines = $obj->read_some_lines($reader, @context);

This method reads the follwing lines of a command without processing them. The
arguments are the same as parse_some_lines.

=head2 terminator

    $str = $obj->terminator();

The method returns the string used to end the block of lines. Each line is
parsed into arguments and when the first argument matches the terminator,
the command is done.
