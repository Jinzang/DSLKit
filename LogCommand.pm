use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Log a message

package LogCommand;

use base qw(DSLCmd);

use IO::File;
use ExternalCommands;

#-----------------------------------------------------------------------
# Check and convert arguments

sub check {
    my ($self, @args) = @_;

    my @new_args;
    foreach my $arg (@args) {
        if (ref $arg) {
            push(@new_args, $arg->stringify($arg));
        } else {
            push(@new_args, $arg);
        }
    }

    return @new_args;
}

#-----------------------------------------------------------------------
# Write a log message

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    @args = $self->check(@args);
    my $result = $self->run(@args);
    $self->set_value($result);

    return $self;
}

#----------------------------------------------------------------------
# Generate mail header

sub mail_header {
    my ($self) = @_;

    my $header = '';

    my $admin = $self->get('admin') || 'nobody';
    my %default = (To => $admin, From => $admin, Subject => 'No Subject');

    foreach my $field (qw (To From Subject)) {
        my $value = $self->get($field) || $default{$field};
        $header .= "$field: $value\n";
    }

    $header .= "\n";
    return $header;
}

#----------------------------------------------------------------------
# Send a mail message with the log messages

sub mail_message {
    my ($self) = @_;

    # Open filehandle for mail

    my $mailcmd = get_external_command('sendmail');
    return unless $mailcmd;

    my $mail = IO::File->new( "|$mailcmd");

    if ($mail) {
        my $header = $self->mail_header();
        print $mail $header;

    } else {
        $mail = IO::File->new(">-");
    }

    print $mail $self->get_log();

    my $ok = close($mail);
    if ($ok) {
        $self->clear_log();

    } else {
        die $! ? "Error closing mail pipe: $!"
               : "Exit status $? from sendmail";
    }

    return;
}

#----------------------------------------------------------------------
# Add a message to the log

sub run {
    my ($self, @args) = @_;    

    my $msg = join(' ', $self->check(@args)) . "\n";
    $self->put_log("$msg");

    return $msg;
}

#----------------------------------------------------------------------
# Mail the log file if it exceeds the reporting level

sub teardown {
    my ($self) = @_;

    my $status = $self->get_script_status();
    my $level = $self->get('Level') || 0;

    if ($level <= $status) {
        $self->mail_message();
    } else {
        $self->clear_log();
    }

   return;
}

1;
__END__
=head1 NAME

LogCommand -- Write a message to the log file

=head1 SYNOPSIS

    log The following data was uploaded
    log $data

=head1 USAGE

The log command writes a message to the log file. The log file is emailed
after thhe completion of the script. Any class which is subclassed from
DSLCmd sends the script line the invoked it to the log file, followed
by the return status.

If a reference is passed to the run method, it is converted to a string and
printed on multiple lines.

=head1 ARGUMENTS

The command takes a variable number of arguments. Each is printed. If an
argument is a variable, its string form is printed.

=head1 PARAMETERS

This command uses the following parameters in its set block:

=item From

The person the email is from. The default value is 'nobody'
parameter.

=item Level

The script only send an email if the return value is greater or equal to the
value of this parameter. The return values of the script have the following
meanings:

    0: Incomplete. The script ended because a command returned a zero status
    1: Complete. The script ran to completion
    2: Error. The script died before completing.

To always get ouput, set Level to 0. This is the default value. To never get
output, set level to 3.

=item Subject

The subject line of the email message. The default value is "No Subject"

=item To

A comma separated list of the people to email. The default value is 'nobody'.

=back
