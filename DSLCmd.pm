use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Base class for all commands

package DSLCmd;

use IO::File;
use base qw(DSLVar);

#-----------------------------------------------------------------------
# Clear the log messages

sub clear_log {
    my ($self) = @_;

    my $top = $self->get_top();
    $top->{LOG} = '';
    return;
}

#-----------------------------------------------------------------------
# Get a state value

sub get {
    my ($self, $name) = @_;

    # Check initialization for user commands

    if (! $self->{SETUP}) {
        my $str = ref $self;
        $str =~ s/Command$//;
        $str = lc($str);
        die "$str was not declared\n";
    }

    return $self->SUPER::get($name);
}

#-----------------------------------------------------------------------
# Get the log messages

sub get_log {
    my ($self) = @_;

    my $top = $self->get_top();
    return $top->{LOG};
}

#-----------------------------------------------------------------------
# Get the status of the entire script

sub get_script_status {
    my ($self) = @_;

    my $top = $self->get_top();
    return $top->{STATUS};
}

#-----------------------------------------------------------------------
# Interperet the command and log the results

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    eval {
        $self->SUPER::interpret_some_lines($reader, $context, @args);
        $self->log(@args);
    };

    if ($@) {
        $self->set_script_status(2);
        die $@;
    } else {
        my $status = $self->status() == 0 ? 0 : 1;
        $self->set_script_status($status);
    }

    return $self;
}

#-----------------------------------------------------------------------
# Log a command to be executed

sub log {
    my ($self, @args) = @_;

    my $msg;
    foreach my $arg ($self, @args) {
        my $ref = ref $arg;

        if ($ref) {
            my $str = $arg->get_name();
            if (defined $str) {
                $str = '$' . $str;
            } else {
                # TODO: replace with get_command
                $str = $ref;
                $str =~ s/Command$//;
                $str = lc($str);
            }
            $msg .= $str;

        } elsif ($arg =~ /[\s\$\[\]\'\"]/) {
            my $str = $arg;
            $str =~ s/'/\\'/g;
            $msg .= "'$str'";

        } else {
            $msg .= $arg;
        }

        $msg .= ' ';
    }

    my $status = $self->status();
    $msg .= "($status)";
    $msg .= "\n";

    $self->put_log($msg);
    return;
}

#-----------------------------------------------------------------------
# Put a message to the log file

sub put_log {
    my ($self, $msg) = @_;

    my $top = $self->get_top();
    $top->{LOG} = '' unless exists $top->{LOG};
    $top->{LOG} .= $msg;

    return;
}

#-----------------------------------------------------------------------
# Set the status

sub set_script_status {
    my ($self, $value) = @_;

    my $top = $self->get_top();
    $top->{STATUS} = $value;
    return;
}

#-----------------------------------------------------------------------
# Check the status

sub status {
    my ($self) = @_;

    return scalar @{$self->get_value()};
}

1;
__END__
=head1 NAME

DSLCmd -- Base class for logged commands

=head1 SYNOPSIS

    my $value = $obj->run(@args);
    my $status = $obj->status();

    # Script syntax
    # Initialize the state of the command
    new var $var
    field1: value1
    field2: value2
    end
    # Run it and assign the result to another variable
    $result [$var arg1 arg2]

=head1 SYNOPSIS

This class is used as the base class for most single line commands.
It writes a message to the log file with the command line and status after
a command is run. Unlike DSLVar, which always sets its status to 1, it sets its
status to the number of results it generates. If there are no results, the
containing method that invokes it will end early.

=head1 METHODS

The class supports all the methods of DSLVar, which are defined there. It also
supports methods to handle log messages and the script status

=head2 get_script_status set_script_status

    my $code = $var->get_script_status();
    $var->set_script_status($code);

The status of the script is accessed through the get_script_status and
set_script_status fields. The numeric codes are early exit=0 normal exit=1
error exit=2.

=head2 get_log put_log clear_log

    my $msg = $var->get_log();
    $var->put_log();
    $var->clear_log();

The get_log method retrieves all the log messages. The put_log method appends
a message to the log. The clear_log method removes any messages. Any messages in
the log are printed when the script exits.

When subclassing DSLVar, you will overload one or more of the following
methods.

