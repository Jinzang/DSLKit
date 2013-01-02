use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Base class for all commands

package DSLCmd;

use base qw(DSLVar);

#-----------------------------------------------------------------------
# Interperet the command and log the results

sub interpret_some_lines {
    my ($self, $lines, $context, @args) = @_;

    $self->execute(@args);
    $self->log(@args);

    return $self;
}

#-----------------------------------------------------------------------
# Log a command to be executed

sub log {
    my ($self, @args) = @_;
    
    my $msg;
    foreach my $arg (@args) {        
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
