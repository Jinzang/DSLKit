use strict;
use warnings;
use integer;

#----------------------------------------------------------------------
# One stop shopping for all external commands

package ExternalCommands;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(CONVERT_COMMAND DVIPDF_COMMAND LATEX_COMMAND
                 MAIL_COMMAND NAME_COMMAND);

#use constant CONVERT_COMMAND => '/usr/bin/convert';
use constant CONVERT_COMMAND => '/usr/local/bin/convert';

#use constant DVIPDF_COMMAND => '/usr/bin/dvipdfm';
use constant DVIPDF_COMMAND => '/usr/texbin/dvipdfm';

#use constant LATEX_COMMAND => '/usr/bin/latex';
use constant LATEX_COMMAND => '/usr/texbin/latex';

#use constant MAIL_COMMAND => '/usr/lib/sendmail -oi -t';
use constant MAILCMD => '';

use constant NAME_COMMAND => '/bin/uname -n';
#use constant NAME_COMMAND => '/usr/bin/uname -n';

1;
__END__
=head1 NAME

Commands

=head1 DESCRIPTION

This package contains the constants for the paths of external commands, which
may differ between systems.
