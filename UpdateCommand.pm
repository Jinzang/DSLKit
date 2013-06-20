use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Update the value of a field in a variable

package UpdateCommand;

use base qw(DSLVar);

#-----------------------------------------------------------------------
# Check arguments to run

sub check {
    my ($self, @args) = @_;

    my $var = shift(@args);
    die "First argument to update must be a variable\n" unless ref $var;

    my $field = shift(@args);
    die "Second argument to update must be a string\n" if ref $field;

    my @value = $self->flatten(@args);
    return($var, $field, \@value);
}

#-----------------------------------------------------------------------
# Update the field in a variable

sub run {
    my ($self, $var, $field, $value) = @_;

    if (@$value == 1) {
        $var->set($field, $value->[0]);

    } else {
        $var->set($field, $value);
    }

    return $var;
}

1;

__END__
=head1 NAME

UpdateCommand -- Update the value of a field in a variable

=head1 SYNOPSIS

    update $var field 45

=head1 DESCRIPTION

The update command update the value of a field in a variable.

=head1 ARGUMENTS

The script takes two or more arguments. The first is the variable that is being
updated. The second is the name of the field that is being changed. The
remaining arguments are flattened into a list and assigned to the field.

=head1 PARAMETERS

This command does not take any parameters.
