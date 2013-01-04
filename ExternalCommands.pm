use strict;
use warnings;
use integer;

#----------------------------------------------------------------------
# One stop shopping for all external commands

package ExternalCommands;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(MAIL_COMMAND NAME_COMMAND);

use constant MAIL_COMMAND => '/usr/lib/sendmail -oi -t';
use constant NAME_COMMAND => '/bin/uname -n';

1;
__END__
=head1 NAME

Commands

=head1 DESCRIPTION

This package contains the constants for the paths of external commands, which
may differ between systems. 
