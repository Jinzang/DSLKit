use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Base class for all commands

package DSLCmd;

use IO::File;
use base qw(DSLVar);

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

All the methods of DSLVar are supported and there are no new methods. But any
single line methods subclassing it should implement the following
methods, but not both.

=head2 run

    $value = $obj->run(@args);

Run is the simpler of the two methods. The values of all of the script
arguments are flattened into a single list. The run method should return its
result either as a scalar or a reference to an array. This result will be saved
as the object's value.
