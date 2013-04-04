use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Mock the main class

package DSLMock;

use base qw(DSLCode);
use LineReader;

#-----------------------------------------------------------------------
# Main procedure

sub main {
    my ($pkg, $code, @args) = @_;

    my $self = $pkg->new();
    my @lines = $self->split_lines($code);
    my $reader = LineReader->new(\@lines);

    return $self->parse_some_lines($reader, $self, @args);
}

#-----------------------------------------------------------------------
# Split code into lines

sub split_lines {
    my ($self, $code) = @_;
    
    return map {"$_\n"} split(/\n/, $code);
}

1;
