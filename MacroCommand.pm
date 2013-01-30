use strict;
use warnings;
use integer;

package MacroCommand;

use base qw(DSLCode);
use DSLMacro;

#----------------------------------------------------------------------
# Get the signature of a macro

sub check {
	my ($self, @args) = @_;

    my $var = shift(@args);
    die "No variable passed to macro\n" unless defined $var && ref $var;
    die "Macro command only takes one argument\n" if @args;
    
	return $var;
}

#----------------------------------------------------------------------
# Store the text of a macro

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    my $var = $self->check(@args);
    my $name = $var->get_name();

    my @lines = $self->read_some_lines($reader);
    my $parent = $self->{PARENT} || $self;
    my $obj = DSLMacro->new($parent, $name);
    $obj->set('code', \@lines);
    $obj->increment_setup();
    
    return $self;
}

1;

__END__
=head1 NAME

MacroCommand -- Save a block of commands to be run later

=head1 SYNOPSIS

    macro $hello
    log Hello $1
    end
    $hello World!

=head1 USAGE

Macros create a new command that can be invoked later. The following lines, up
to and including the end line, are saved under a new command name and may be
invoked by the macro name. Macros can contain numbered variables, which are
replaced by the corresponding argument passed on the command line.
