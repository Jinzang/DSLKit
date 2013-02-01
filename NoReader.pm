use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Class that throws an error when a read is attempted

package NoReader;

#-----------------------------------------------------------------------
# Create a new object

sub new {
    my ($pkg) = @_;

    my $self = {};
    return bless($self, $pkg);
}

#-----------------------------------------------------------------------
# Read next line

sub next_line {
    my ($self) = @_;

    die "Cannot use a block command here\n";
    return;
}

1;
