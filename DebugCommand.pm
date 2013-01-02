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
# Get the next input line

sub get_line {
    my ($self, $reader, $context) = @_;

    $reader->set_prompt(FIRST_PROMPT);
    return $self->SUPER::get_line($reader, $context);
}

#-----------------------------------------------------------------------
# Interpret lines read from the terminal

sub interpret_some_lines {
    my ($self, $reader, $context, $cmd, @args) = @_;

    my $obj;
    $reader = InputReader->new();

    while (defined (my $line = $self->get_line($reader, $context))) {       
        eval {
            $reader->set_prompt(SECOND_PROMPT);
            $obj = $self->interpret_a_line($reader, $line, $context);
            my $val = $obj->stringify();
            print "$val\n" if $val;
        };

        print "Error: $@\n" if $@;
    }
    
    return $obj;
}

#-----------------------------------------------------------------------
# Set the terminator for interactive debugging

sub terminator {
    my ($self) = @_;
    return 'quit';
}

1;