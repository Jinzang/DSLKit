use strict;
use warnings;
use integer;

package IncludeCommand;

use base qw(DSLCode);
use ScriptReader;

#-----------------------------------------------------------------------
# Check arguments to run

sub check {
    my ($self, @args) = @_;

    my $file = shift @args;
    die "No filename on include\n" unless defined $file && ! ref $file;
    die "Too many arguments for include\n" if @args;     

    return $file;
}

#----------------------------------------------------------------------
# Interpret lines from file

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    my $file = $self->check(@args);
    my $script_dir = $self->get_string_value('script_dir');
    $reader = ScriptReader->new("$script_dir/$file");

    my $parent = $self->{PARENT} || $self;
    return $parent->parse_some_lines($reader, $self, @$context);
}

#-----------------------------------------------------------------------
# Read the rest of the block (no op for single line commands)

sub read_some_lines {
    my ($self, $lines) = @_;
    return ();
}

1;
__END__
=head1 NAME

IncludeCommand -- Interpret lines in a file

=head1 SYNOPSIS

    include somefile.inc

=head1 USAGE

This command reads lines from a file passed as its argument and interprets them.

=head1 ARGUMENTS

This command takes a single argument: the name of the file. 

=item filename

A string containing the filename. The file is in the script directory.

=head1 PARAMETERS

This command does not use any parameters.
