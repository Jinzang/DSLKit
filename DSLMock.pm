use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Mock the main class

package DSLMock;

use base qw(DSLCode);
use LineReader;

#-----------------------------------------------------------------------
# Evaluate passed code

sub evaluate {
    my ($self, $code, @args) = @_;

    my @lines = $self->split_lines($code);
    my $reader = LineReader->new(\@lines);

    return $self->parse_some_lines($reader, $self, @args);
}

#-----------------------------------------------------------------------
# Main procedure

sub main {
    my ($pkg, $code, @args) = @_;

    my $self = $pkg->new();
    return $self->evaluate($code, @args);
}

#-----------------------------------------------------------------------
# Split code into lines

sub split_lines {
    my ($self, $code) = @_;

    return map {"$_\n"} split(/\n/, $code);
}

1;
