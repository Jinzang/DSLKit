use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Main Class for a Domain Specific Language

package DSLMain;

use base qw(DSLCode);
use ScriptReader;
use LineReader;

#-----------------------------------------------------------------------
# Create a new dsl and initialize its state

sub new {
    my ($pkg, %config) = @_;

    my $self = DSLCode->new();
    while (my ($name, $value) = each %config) {
        my $var = DSLVar->new($self, $name);
        $var->set_value($value);
    }

    return bless($self, $pkg);
}

#----------------------------------------------------------------------
# Clean up by calling the teardown methods on all variables

sub cleanup {
    my ($self) = @_;

    my $errors = '';
    my $state = $self->{STATE};
    my @names = sort {$state->{$b}{SETUP} <=> $state->{$a}{SETUP}} keys %$state;

    foreach my $name (@names) {
        my $obj = $self->get($name);
        next unless ref $obj && $obj->{SETUP};

        eval {$obj->teardown()};
        $errors .= $@ if $@;
    }

    return $errors ;
}

#-----------------------------------------------------------------------
# Get a new file reader

sub get_reader {
    my ($self, @args) = @_;

    my $reader;
    if (@args) {
        $reader = ScriptReader->new(@args);
    } else {
        $reader = LineReader->new(["debug\n"]);
    }

    return $reader;
}

#-----------------------------------------------------------------------
# Setup the script and run it

sub main {
    my ($self, @args) = @_;

    eval {
        $self->setup(@args);
        my $reader = $self->get_reader(@args);
        $self->parse_some_lines($reader, $self, @args);

        $self->cleanup();
        $self->teardown();
    };

    my $errors = '';
    $errors .= $@ if $@;
    
    eval {$self->teardown()};
    $errors .= $@ if $@;

    return $errors;
}

1;
__END__
=head1 NAME

DSLMain -- Top level for DSL scripts

=head1 SYNOPSIS

    use DSLMain;
    my $script = shift @ARGV;
    my $demo = DSLMain->new();
    $errors = $demo->main($script, @ARGV);
    print $errors if $errors;

=head1 DESCRIPTION

DSL scripts are line delimeted lists of commands. Blanks lines and all
characters following a sharp character are ignored. Some commands are blocks
of lines, in which case the block is terminated by an end on its own line.
Lines can contain subcommands, which are enclosed in square brackets. These
subcommands are run first and the replaced by their return value.

Each command is implemented by a package whose name is the capitalized command
name followed by the word 'Command'. Commands are divided into core language
commands, which implement the method intereperet_some_lines (even if they are
single line commands)  and functional commands, which do the actual work of the
script and implement the execute or run method. The language commands are

=over

=item debug - Stop and accept new commands from terminal

=item eval - Evaluate a Perl expression

=item for - Loop over a block of commands

=item include - Include and execute the contents of another file

=item if - Execute a block of lines only if an expression is true

=item log - Write a message to log and mail log to user

=item macro - Define a block of commands as a macro

=item mock - A fake command for testing

=item new - Define parameters for a command and initialize it

=item show - Get the value of a variable field

=item var Initialize a command without setting parameters

=back

Commands are explained in more details in the files that implement them. New
commands should inherit from one of the base classes, all which begin with DSL.
These classes are:

=over

=item DSLVar - The base class for all commands and some single line commands

=item DSLCmd - The base class for most single line commands

=item DSLBlock - For multiple line commands whose following lines are data

=item DSLCode - For multiple line commands whose following lines are commands

=back

The documentation in these classes explain how to subclass them. I expect that
this code will not entirely meet your needs and you will need to modify it
before using it. This is especially true of this class, as it is the interface
that connects with the rest of your script.

=head1 METHODS

=head2 new

    my $obj = DSLMain->new(var1 => 'value1', var2 => 'value2')

The new method creates a new top level object. The top level object contains
all the named variables in the script, the log messages, and the script status.
The argument to the new method is a hash containing pre-defined variables that
your script will use.

=head2 main

    my $errors = $obj->main($filename, @args);

The main method should be called after creating the object with new. The first
argument is a filename of a script containing command lines to be interpreted.
The remaining arguments should be scalars. They can be accessed in the script
using numbered variables ($1, $2, ...) or as a whole with $*.

The main method returns a string containing all errors that occurred during
execution of the script, or an empty string if no errors occurred.
