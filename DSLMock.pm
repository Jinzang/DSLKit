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
    my @lines = map {"$_\n"} split(/\n/, $code);
    my $reader = LineReader->new(\@lines);

    $self->increment_setup();
    return $self->parse_some_lines($reader, $self, @args);
}

1;
