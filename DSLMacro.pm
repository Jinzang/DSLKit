use strict;
use warnings;
use integer;

package DSLMacro;

use base qw(DSLCode);
use LineReader;

#----------------------------------------------------------------------
# Store the text of a macro

sub interpret_some_lines {
    my ($self, $lines, $context, @args) = @_;

    my $code = $self->get('code');
    my $reader = LineReader->new($code);
    return $self->parse_some_lines($reader, $self, @args);
}

#-----------------------------------------------------------------------
# Read the rest of the block (no op for single line commands)

sub read_some_lines {
    my ($self, $lines) = @_;
    return ();
}

1;
__END__
=head1 NAME

MacroCommand -- Save a block of commands to be run later

=head1 SYNOPSIS

    macro $hello
    log Hello $1
    end
    $hello World!

=head1 DESCRIPTION

Macros create a new command that can be invoked later. The following lines, up
to and including the end line, are saved into a varuable and may be
invoked by the variable. Macros can contain numbered variables, which are
replaced by the corresponding argument passed on the command line.

=head1 ARGUMENTS

The command takes one argument, the variable which holds the macro and is used
to call it.

=head1 PARAMETERS

This command does not use any parameters.
