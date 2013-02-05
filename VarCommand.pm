use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Create new object with no parameters

package VarCommand;

use base qw(DSLVar);

#-----------------------------------------------------------------------
# Check arguments to new

sub check {
    my ($self, @args) = @_;

    my $cmd = shift @args;
    die "No command name for var\n" unless defined $cmd && ! ref $cmd;

    my $var = shift @args;
    die "No variable for new\n" unless defined $var && ref $var;

    die "The var command takes two arguments\n" if @args;
    return ($cmd, $var);
}

#-----------------------------------------------------------------------
# Create and set the state of a new variable

sub interpret_some_lines {
    my ($self, $lines, $context, @args) = @_;

    my ($cmd, $var) = $self->check(@args);

    my $name = $var->get_name();
    my $parent = $self->{PARENT} || $self;
    my $obj = $parent->get_pkg($cmd, $name);

    $obj->increment_setup();
    $obj->setup();

    return $self;
}

#-----------------------------------------------------------------------
# Check the status

sub status {
    my ($self) = @_;

    return 1;
}

1;
__END__
=head1 NAME

VarCommand -- Define the type of a variable

=head1 SYNOPSIS

    var command $var

=head1 DESCRIPTION

The var command set the type of a variable and marks it as initialized

=head1 ARGUMENTS

The command takes two arguments:

=over

=item command

The type of the variable to be initialized. Each variable is associated with
a command, which is run when the variable is at the start of the line.

=item $var

The variable to be initialized.

=back
