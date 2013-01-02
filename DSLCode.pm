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
    
    my $obj;
    while (defined (my $line = $self->get_line($reader, \@context))) {       
        $obj = $self->interpret_a_line($reader, $line, \@context);

        if ($obj->status() == 0) {
            $self->set_script_status(0);
            last;
        }
    }

    return $obj;
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