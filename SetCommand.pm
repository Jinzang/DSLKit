use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Base code for witing a Domain Specific Language

package SetCommand;

use base qw(DSLVar);

#-----------------------------------------------------------------------
# Check arguments to run

sub check {
    my ($self, @args) = @_;

    my $var = shift(@args);
    die "First argument to set must be a variable\n" unless ref $var;
    
    my @value = $self->flatten(@args);
    return($var, \@value);
}

#-----------------------------------------------------------------------
# The default method copies the value from one var to another

sub run {
    my ($self, $var, $value) = @_;

    $var->set_value($value);
    return $value;
}

1;

__END__
=head1 NAME

SetCommand -- Set the value of a variable

=head1 SYNOPSIS

    set $var 45

=head1 DESCRIPTION

The set command sets the value of a variable. The command may seem redundant,
but because variables call the run method when they are at the head of a line
variables, you must use the set command to set a non-simple variable in
a script.

=head1 ARGUMENTS

The script takes one or more arguments. The first is the variable that is being
assigned to. The remaining arguments are flattened into a list and assigned to
the variable.

=head1 PARAMETERS

This command does not take any parameters.
