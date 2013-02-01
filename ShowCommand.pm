use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Show contents of a variable

package ShowCommand;

use base qw(DSLVar);

#-----------------------------------------------------------------------
# Parse the arguments passed to this command

sub check {
    my ($self, $var, @fields) = @_;

    if (! defined $var) {
        $var = $self->get_top();

    } elsif (! ref $var) {
        if ($var eq '^') {
            my $name = $self->get('name');
            $var = defined $name ? $self->get_var($name) : $self->get_top();

            my $old_fields = $self->get('fields');
            unshift(@fields, @$old_fields) if defined $old_fields;

        } else {
            unshift(@fields, $var);
            $var = $self->get_top();
        }
    }

    return ($var, @fields);
}

#-----------------------------------------------------------------------
# Find the requested data, if any

sub find_data {
    my ($self, $var, @fields) = @_;

    my $data = $var;
    foreach my $field (@fields) {
        return unless defined $data;

        if ($data =~ /ARRAY/) {
            return unless $field =~ /^\d+$/;
            $data = $data->[$field];

        } elsif ($data =~ /HASH/) {
            return unless exists $data->{$field};
            $data = $data->{$field};

        } else {
            return;
        }
    }

    return $data;
}

#-----------------------------------------------------------------------
# Get one level of the data

sub get_data {
    my ($self, $data) = @_;

    my @values;
    if ($data =~ /ARRAY/) {
        foreach my $item (@$data) {
            my $value = ref $item ? ref $item : $item;
            push(@values, $value);
        }

    } elsif ($data =~ /HASH/) {
        @values = sort keys %$data;

    } else {
        push(@values, $data);
    }

    return \@values;
}

#-----------------------------------------------------------------------
# Show one level of the contents of a variable

sub run {
    my ($self, $var, @fields) = @_;

    my $data = $self->find_data($var, @fields);

    my $values;
    if (defined $data) {
        my $name = $var->get_name();
        $self->set('var', $name);
        $self->set('fields', \@fields);

        $values = $self->get_data($data);
    }

    return $values;
}

1;

__END__
=head1 NAME

ShowCommand -- Display the fields of an object (variable)

=head1 SYNOPSIS

    show LOG
    show $db STATE
    show ^ Database

=head1 DESCRIPTION

The show command displays specified fields of a variable. It is most often used
interactively, following the debug command.

=head1 ARGUMENTS

This command takes two arguments. The first is the variable whose fields are to
be displayed and the remaining parameters are the field names in order of the
hierarchy in the variable. If the variable is omitted, fields of the topmost
variable, which represents the script, are displayed. If the first field is a
caret (^), the variable and fields of the most recent show command are re-used,
followed by the fields on the current line.

=over

=item $variable

The variable whose fields are to be displayed

=item field

One or more field names, specifying which data is to be displayed.

=back

=head1 PARAMETERS

This command does not use any parameters
