use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Class for reading a set of lines as if from a file

package LineReader;

#-----------------------------------------------------------------------
# Create a new object

sub new {
    my ($pkg, $lines) = @_;

    my $self = {};
    my @lines = @$lines; 
    $self->{lines} = \@lines;
    
    return bless($self, $pkg);
}

#-----------------------------------------------------------------------
# Read next line

sub next_line {
    my ($self) = @_;

    return shift @{$self->{lines}};
}

1;