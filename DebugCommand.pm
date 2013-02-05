use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Command to support debugging a script

package DebugCommand;

use base qw(DSLCode);
use InputReader;

use constant FIRST_PROMPT => '> ';
use constant SECOND_PROMPT => '>> ';

#-----------------------------------------------------------------------
# Interpret lines read from the terminal

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    $reader = InputReader->new();
    while (defined (my $line = $self->read_a_line($reader, $context))) {
        eval {
            $reader->set_prompt(SECOND_PROMPT);
            my ($obj, @args) = $self->parse_a_line($line, $context);
            $obj->interpret_some_lines($reader, $context, @args);

            my $val = $obj->stringify();
            print "$val\n" if $val;
        };

        print "Error: $@\n" if $@;
    }

    return $self;
}

#-----------------------------------------------------------------------
# Read the next input line

sub read_a_line {
    my ($self, $reader, $context) = @_;

    $reader->set_prompt(FIRST_PROMPT);
    return $self->SUPER::read_a_line($reader, $context);
}

#-----------------------------------------------------------------------
# Set the terminator for interactive debugging

sub terminator {
    my ($self) = @_;
    return 'quit';
}

1;
__END__
=head1 NAME

DebugCommand -- Stop and interpret commands interactively

=head1 SYNOPSIS

    debug
    > show LOG
    > quit

=head1 DESCRIPTION

This command stops the interpretation of the script and prompts the user for
input. The user enters commands, which are interpreted. When the user types
quit, interpretation of the script continues with the next line.

=head1 ARGUMENTS

This command does not take any arguments.

=head1 PARAMETERS

This command does not use any parameters
