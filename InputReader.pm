use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Class for reading from STDIN

package InputReader;

#-----------------------------------------------------------------------
# Create a new object

sub new {
    my ($pkg) = @_;

    my $self = {};  
    $self->{prompt} = '> ';

    return bless($self, $pkg);
}

#-----------------------------------------------------------------------
# Read next line

sub next_line {
    my ($self) = @_;

    print $self->{prompt};
    my $line = <STDIN>;

    return $line;
}

#-----------------------------------------------------------------------
# Set the input prompt

sub set_prompt {
    my ($self, $prompt) = @_;
    
    $self->{prompt} = $prompt;
    return;
}

1;