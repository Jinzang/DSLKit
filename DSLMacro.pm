use strict;
use warnings;
use integer;

package DSLMacro;

use base qw(DSLCode);
use LineReader;

#----------------------------------------------------------------------
# Store the text of a macro

sub interpret_some_lines {
    my ($self, $lines, $context, $cmd, @args) = @_;

    my $code = $cmd->get('code');
    my $reader = LineReader->new($code);
    return $cmd->parse_some_lines($reader, $cmd, @args);
}

#-----------------------------------------------------------------------
# Read the rest of the block (no op for single line commands)

sub read_some_lines {
    my ($self, $lines) = @_;
    return ();
}

1;
