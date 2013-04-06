use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Base code for witing a Domain Specific Language

package ReturnCommand;

use base qw(DSLVar);

#-----------------------------------------------------------------------
# Set the value of the parent and stop execution

sub run {
    my ($self, $value) = @_;

    my $var = $self->{PARENT} || $self;
    $var->set_value($value);
    
    return $value;
}

#-----------------------------------------------------------------------
# Stop execution of macro

sub status {
    my ($self) = @_;

    return 0;
}

1;

__END__
=head1 NAME

ReturnCommand -- Set value of a macro and stop its execution
=head1 SYNOPSIS

    return $a

=head1 DESCRIPTION

The return command sets the value its parent and stops execution of it by
setting the status to zero.

=head1 ARGUMENTS

The script takes a list of arguments that are flattend into a single value and assigned
to its parent.

=head1 PARAMETERS

This command does not take any parameters.
