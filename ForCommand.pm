use strict;
use warnings;
use integer;

package ForCommand;

use base qw(DSLCode);

#-----------------------------------------------------------------------
# Check arguments to run

sub check {
    my ($self, @args) = @_;

    my $var = shift @args;
    die "No variable on for" unless defined $var && ref $var;
    
    @args = $self->flatten(@args);
    return ($var, @args);
}

#----------------------------------------------------------------------
# Loop over block of lines

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    my $var;
    ($var, @args) = $self->check(@args);
    my @for_lines = $self->read_some_lines($reader, @$context);

    my @result;
    foreach my $arg (@args) {
        $var->set_value($arg);

        my $reader = LineReader->new(\@for_lines);
        my $obj = $self->parse_some_lines($reader, @$context);

        push(@result, $obj);
    }

    $self->set_value($self->flatten(@result));
    return $self;
}


1;
__END__
=head1 NAME

ForCommand -- Loop over block of commands

=head1 SYNOPSIS

    $say ''
    for $countdown three two one blastoff
    $say "$say$countdown..."
    end

=head1 USAGE

This command loops over a block of commands, setting its first argument to
the values of the subsequent arguments in turn.

=head1 ARGUMENTS

This command takes the following arguments:

=item $var

The variable that recieves the value during each iteration of the
loop.

=item fields

One or more arguments. The loop will be run once for each field and the
loop variable will receive the value of the field.

=head1 PARAMETERS

This command does not use any parameters.
