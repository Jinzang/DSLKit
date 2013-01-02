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

    my $line;
    do {
        $line = $reader->next_line();
        return unless defined $line;
        
        my $comment;
        ($line, $comment) = split(/\#/, $line);
    } until $line =~ /\S/;
    
    my ($new_line, $arg) = $self->next_arg($line, $context);
    return if $arg eq $self->terminator();
        
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