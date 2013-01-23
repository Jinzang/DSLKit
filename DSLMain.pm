use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Main Class for a Domain Specific Language

package DSLMain;

use base qw(DSLCode);
use ExternalCommands;
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
# Create an empty staging directory

sub create_stage_dir {
    my ($self) = @_;

    my $stage_dir = $self->get_string_value('stage_dir');
    return unless defined $stage_dir;

    $self->delete_stage_dir() if -e $stage_dir;

    mkdir($stage_dir) or die "Couldn't make staging directory: $!";
    chdir($stage_dir) or die "Couldn't cd to staging directory: $!";

    return;
}

#----------------------------------------------------------------------
# Delete the directory used for staged files

sub delete_stage_dir {
    my ($self) = @_;

    my $stage_dir = $self->get_string_value('stage_dir');
    return unless defined $stage_dir;
    my $base_dir = $ENV{HOME} || '';

    chdir($base_dir);
    system("rm -rf '$stage_dir'") ==  0
        or die "Deleting stage dir failed: $?";

    return;
}

#-----------------------------------------------------------------------
# Log error and change status

sub error {
    my ($self, $error) = @_;

    $self->put_log($error);
    $self->set_script_status(2);

    return;
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
    };

    $self->error($@) if $@;
    $self->teardown();

    return;
}

#----------------------------------------------------------------------
# Set up the script

sub setup {
    my ($self, $script_name, @args) = @_;

    $self->set_script_status(1);
    $self->put_log("This script is $script_name\n") if $script_name;

    my $text = 'Script was run at ' . localtime();

    my $cmd = get_external_command('uname');
    if ($cmd) {
        my $uname = `$cmd`;
        $text .= " on $uname";
    } else {
        $text .= "\n";
    }

    $self->put_log($text);
    $self->create_stage_dir();

    return;
}

#----------------------------------------------------------------------
# Call the teardown methods on all variables

sub teardown {
    my ($self) = @_;

    my $state = $self->{STATE};
    my @names = grep {ref $state->{$_}} keys %$state;
    @names = sort {$state->{$b}{SETUP} <=> $state->{$a}{SETUP}} @names;

    foreach my $name (@names) {
        my $obj = $self->get($name);
        next unless ref $obj && $obj->{SETUP};

        eval {$obj->teardown()};
        $self->error($@) if $@;
    }

    eval {$self->delete_stage_dir()};
    $self->error($@) if $@;

    my $msg = $self->get_log();
    print $msg if $msg;

    return;
}

1;
__END__
=head1 NAME

DSLMain -- Top level for DSL scripts

=head1 SYNOPSIS

    use DSLMain;
    my $script = shift @ARGV;
    my $demo = DSLMain->new(stage_dir => "/tmp");
    $demo->main($script, @ARGV);

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

=item for - Loop over a block of commands

=item log - Write a message to log and mail log to user

=item macro - Define a block of commands as a macro

=item mock - A fake command for testing

=item new - Define parameters for a command and initialize it

=item show - Get the value of a variable field

=back

Commands are explained in more details in the files that implement them. New
commands should inherit from one of the base classes, all which begin with DSL.
These classes are:

=over

=item DSLVar - For single line commands and the base class for all commands

=item DSLCmd - For single line commands that log a message when they run

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
your script will use. The DSLMain method as written expects the variable
stage_dir, which is used to create a directory to hold temporary files used by
the script. If it is not present, the directory will not be created.

=head2 main

    $obj->main($filename, @args);

The main method should be called after creating the object with new. The first
argument is a filename of a script containing command lines to be interpreted.
The remaining arguments should be scalars. They can be accessed in the script
using numbered variables ($1, $2, ...) or as a whole with $*.
