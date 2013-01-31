use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Base class for all commands

package DSLCmd;

use IO::File;
use base qw(DSLVar);

#-----------------------------------------------------------------------
# Check for hash argument

sub check_hash_arg {
    my ($self, $arg) = @_;

    return unless defined $arg;
    return unless ref $arg;
    
    my $value = $arg->get_value();
    return if @$value && ref $value->[0] ne 'HASH';

    return $value;
}

#-----------------------------------------------------------------------
# Check for list argument

sub check_list_arg {
    my ($self, $arg) = @_;

    return unless defined $arg;
    return unless ref $arg;
    
    my $value = $arg->get_value();
    return if @$value && ref $value->[0];

    return $value;
}

#-----------------------------------------------------------------------
# Check for string argument

sub check_string_arg {
    my ($self, $arg) = @_;

    return unless defined $arg;
    
    my $value;
    if (ref $arg) {
        my $list = $arg->get_value();
        return unless @$list == 1;
        $value = $list->[0];

    } else {
        $value = $arg;
    }
    
    return $value;
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
        die "$str was not initialized by new\n";
    }
    
    return $self->SUPER::get($name);
}

#-----------------------------------------------------------------------
# Interperet the command and log the results

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    $self->SUPER::interpret_some_lines($reader, $context, @args);
    $self->log(@args);

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

This class should be used as the base class for most single line commands.
It writes a message to the log file with the command line and status after
a command is run. Unlike DSLVar, which always sets its status to 1, it sets its
status to the number of results it generates. If there are no results, the
containing method that invokes it will end early.

=head1 METHODS

The class supports all the methods of DSLVar, which are defined there. It also
supports three helper methods for check

    $value = $self->check_hash_arg($arg);
    $value = $self->check_list_arg($arg);
    $value = $self->check_string_arg($arg);
    
These methods check a command line argument to see if it has the correct type.
If it does, it unmarshalls the data contained in the argument. If not, it
returns undef.
