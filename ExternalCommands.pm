use strict;
use warnings;
use integer;

#----------------------------------------------------------------------
# One stop shopping for all external commands

package ExternalCommands;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(get_external_command run_external_command);

our %command_list;

use constant COMMAND_LIST => [
                                '/usr/local/bin/convert',
                                '/usr/texbin/dvipdfm',
                                '/usr/lib/sendmail -oi -t',
                                '/usr/texbin/latex',
                                '/bin/uname -n',
                              ];

#----------------------------------------------------------------------
# Run an external command, capture errors

sub get_external_command {
    my ($cmd) = @_;
    
    initialize_external_command() unless %command_list;
    $cmd = $command_list{$cmd} or die "Command not found: $cmd\n";
    return $cmd;
}

#----------------------------------------------------------------------
# Initialize the hash of commands

sub initialize_external_command {

    my $command_list = COMMAND_LIST;
    foreach my $command (@$command_list) {
        my ($path) = split(' ', $command);
        my ($cmd) = $path =~ /([^\/]*)$/;
        
        $command_list{$cmd} = $command;
    }
    
    return;
}

#----------------------------------------------------------------------
# Run an external command, capture errors

sub run_external_command {
    my ($cmd, @args) = @_;

    foreach (@args) {
        $_ = "'$_'" if /\s/;
    }

    my $full_command = get_external_command($cmd);
    my $command_line = join (' ', $full_command, @args, '2>&1');
    my $log = "$command_line\n" . `$command_line`;

    if ($?) {
        my $error = $? >> 8;
        die "$log\nExecution error: $error";
    }

    return;
}

1;
__END__
=head1 NAME

Commands

=head1 DESCRIPTION

This class hides the different paths that Unix commands might have on different
systems. Commands are fetched or run based only on the last part of their paths.