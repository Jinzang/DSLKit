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

    my $stage_dir = $self->get_string('stage_dir');
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

    my $stage_dir = $self->get_string('stage_dir');
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
# Get a variable as a string

sub get_string {
    my ($self, $name) = @_;

    my $var = $self->get_var($name);
    return unless $var;

    return $var->if_string();
}

#-----------------------------------------------------------------------
# Setup the script and run it

sub main {
    my ($self, @args) = @_;

    eval {
        $self->setup(@args);
        my $reader = $self->get_reader(@args);
        $self->parse_some_lines($reader, @args);
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
    
    my $cmd = NAME_COMMAND;
    my $uname = `$cmd`;
    chomp($uname);

    my $text = 'Script was run at ' . localtime() . " on $uname\n";
    $self->put_log($text);
    
    return; 
}

#----------------------------------------------------------------------
# Call the teardown methods on all variables

sub teardown {
    my ($self) = @_;

    my $state = $self->{STATE};
    my @names = sort {$state->{$b}{SETUP} <=> $state->{$a}{SETUP}} keys %$state;

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

=head1 USAGE

DSL scripts are line delimeted lists of commands. Blanks lines and all
characters following a sharp character are ignored. Some commands are blocks
of lines, in which case the block is terminated by an end on its own line.
Each command is implemented by a package whose name is the capitalized command
name followed by the word 'Command'. Commands are divided into core language
commands, which implement the method intereperet_some_lines (even if they are
single line commands)  and functional commands, which do the actual work of the
script and implement the execute or run method. The language commands are

=over

=item for - Loop over a block of commands

=item log - Write a message to log

=item macro - Define a block of commands as a macro

=item new - define parameters for a command and initialize it

=back

Commands are explained in more details in the files that implement them.
