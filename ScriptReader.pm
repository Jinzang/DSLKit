use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Class for reading a script

package ScriptReader;

#-----------------------------------------------------------------------
# Create a new object

sub new {
    my ($pkg, $script) = @_;
    die "No script name\n" unless defined $script;
    
    my $self = {};  
    $self->{fd} = IO::File->new($script, 'r');
    die "Couldn't read $script" unless $self->{fd};

    return bless($self, $pkg);
}

#-----------------------------------------------------------------------
# Read next line

sub next_line {
    my ($self) = @_;

    my $line;
    if (exists $self->{fd}) {
        my $fd = $self->{fd};
        $line = <$fd>;

        if (! defined $line) {
            delete $self->{fd};
            close($fd);
            return;
        }
    }

    return $line;
}

1;