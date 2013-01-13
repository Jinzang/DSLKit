use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Create new object

package NewCommand;

use base qw(DSLBlock);

#-----------------------------------------------------------------------
# Check arguments to new

sub check {
    my ($self, $cmd, $var) = @_;

    die "No command name for new\n" unless defined $cmd && ! ref $cmd;
    die "No variable for new\n" unless defined $var && ref $var;

    return;
}

#-------- ---------------------------------------------------------------
# Create and set the state of a new variable

sub interpret_some_lines {
    my ($self, $lines, $context, @args) = @_;

    $self->check(@args);

    my $kmd = shift(@args);
    my $var = shift(@args);
    my $name = $var->get_name();
    my $parent = $self->{PARENT} || $self;
    my $obj = $parent->get_pkg($kmd, $name);

    my @lines = $self->read_some_lines($lines);
    my $reader = LineReader->new(\@lines);

    $obj->{STATE} = $self->parse_some_lines($reader, $self, @args);

    $obj->setup();
    my $setup = $parent->get('setup') || 0;
    $setup ++;

    $parent->set('setup', $setup);
    $obj->{SETUP} = $setup;

    return $self;
}

1;
__END__
=head1 NAME

NewCommand -- Set parameters for other commands

=head1 SYNOPSIS

    new command $var
    Field1: First Value
    Field2: Second value
    Field3: This is
    a multi-line field
    end

=head1 DESCRIPTION

The new command creates and initializes the state of a variable

=head1 ARGUMENTS

The command takes two arguments:

=over

=item command

The type of the variable to be initialized. Each variable is associated with
a command, which is run when the variable is at the start of the line.

=item $var

The variable to be initialized.

=back

=head1 PARAMETERS

None. That would be too recursive for my brain to handle.

=back
