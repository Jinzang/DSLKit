use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Base code for witing a Domain Specific Language

package DSLVar;

#-----------------------------------------------------------------------
# Create a new object

sub new {
    my ($pkg, $parent, $name) = @_;

    my $self = {SETUP => 0, STATE => {}, VALUE => []};
    $self =  bless($self, $pkg);

    $self->{PARENT} = $parent if defined $parent;
    
    if (defined $name) {
        $self->{NAME} = $name;
        $parent->set_var($name, $self);
    }

    return $self;
}

#-----------------------------------------------------------------------
# Check arguments to run

sub check {
    my ($self, @args) = @_;  
    return;
}

#-----------------------------------------------------------------------
# Clear the log messages

sub clear_log {
    my ($self) = @_;

    my $top = $self->get_top();
    $top->{LOG} = '';
    return;
}

#-----------------------------------------------------------------------
# Standard interface for executing commands

sub execute {
    my ($self, $cmd, @args) = @_;

    @args = $self->flatten(@args);
    my $result = $self->run(@args);
    $self->set_value($result);

    return $self;
}

#-----------------------------------------------------------------------
# Convert a list of arrays to one long array

sub flatten {
    my ($self, @args) = @_;
    
    my @list;
    foreach my $arg (@args) {
        if (ref $arg) {
            my $val = $arg->get_value();
            push(@list, @$val);

        } else {
            push(@list, $arg);
        }
    }
    
    return @list;
}

#-----------------------------------------------------------------------
# Get a state value

sub get {
    my ($self, $name) = @_;

    return unless exists $self->{STATE}{$name};
    return $self->{STATE}{$name};
}

#-----------------------------------------------------------------------
# Get the log messages

sub get_log {
    my ($self) = @_;

    my $top = $self->get_top();
    return $top->{LOG}; 
}

#-----------------------------------------------------------------------
# Get the name of a variable

sub get_name {
    my ($self) = @_;
    
    return exists $self->{NAME} ? $self->{NAME} : undef;
}

#-----------------------------------------------------------------------
# Convert a command to package name, load the package, and create an object

sub get_pkg {
    my ($self, $cmd, $name) = @_;    

    my $obj;
    if (ref $cmd) {
        $obj = $cmd;

    } else {
        my $pkg =  ucfirst(lc($cmd)) . 'Command';
        eval "require $pkg" or die "Command not found: $cmd\n";
        $obj = $pkg->new($self, $name);
    }

    return $obj;
}

#-----------------------------------------------------------------------
# Get the status of the entire script

sub get_script_status {
    my ($self) = @_;

    my $top = $self->get_top();
    return $top->{STATUS}; 
}

#-----------------------------------------------------------------------
# Get the topmost variable via the prent chain

sub get_top {
    my ($self) = @_;

    my $parent = $self;
    $parent = $parent->{PARENT} while exists $parent->{PARENT};
    return $parent;    
}

#-----------------------------------------------------------------------
# Get the value of a variable

sub get_value {
    my ($self) = @_;
    return $self->{VALUE};
}

#-----------------------------------------------------------------------
# Add the name of a variable to the main object

sub get_var {
    my ($self, $name) = @_;

    my $top = $self->get_top();
    return $top->get($name);
}

#-----------------------------------------------------------------------
# Get a string value if it is a string

sub if_string {
    my ($self) = @_;
    
    my $val = $self->get_value();
    my $name = $self->get_name();
    
    die "$name has no value\n" unless @$val;
    die "$name is not a string\n" if @$val > 1 || ref $val->[0];

    return $val->[0];
}

#-----------------------------------------------------------------------
# Interpolate a variable value into a string

sub interpolate_var {
    my ($self, $name, $context) = @_;

    my $obj;
    if ($name =~ /^(\d+)$/) {
        die "Undefined variable: \$$name\n" unless $name < @$context;
        $obj = $context->[$1];

    } else {
        $obj = $self->get_var($name);
        die "Undefined variable: \$$name\n" unless defined $obj;
    } 
    
    return ref $obj ? $obj->if_string() : $obj;
}

#-----------------------------------------------------------------------
# Run the interpreter

sub interpret_a_line {
    my ($self, $reader, $line, $context) = @_;

    my @args;
    ($line, @args) = $self->parse_a_line($line, $context);
    die "Unmatched bracket: $line\n" if $line;
    
    my $obj = shift(@args);
    return $obj->interpret_some_lines($reader, $context, $obj, @args);
}

#-----------------------------------------------------------------------
# One line commands have nothing to do besides call execute

sub interpret_some_lines {
    my ($self, $reader, $context, $cmd, @args) = @_;

    return $self->execute($cmd, @args);
}

#-----------------------------------------------------------------------
# Return the next argument from a line

sub next_arg {
    my ($self, $line, $context) = @_;

    my $arg;
    while (! defined $arg) {
        if ($line =~ s/^\[//) {
            # Start of bracketed expression: collect args and interpret
            my @args;
            ($line, @args) = $self->parse_a_line($line, $context);
            my $obj = shift(@args);
            $arg = $obj->interpret_some_lines([], $context, $obj, @args);
            
        } elsif ($line =~ s/^\]//) {
            # End of bracketed expression: return           
            last;

        } elsif ($line =~ s/^\$\*//) {
            # Star variable, replace with context
            $arg = DSLVar->new();
            my @context = @$context;
            shift(@context);
            $arg->set_value(\@context);

        } elsif ($line =~ s/^\$(\d+)//) {
            # Numeric variable: get from context
            $arg = $context->[$1];

        } elsif ($line =~ s/^\$(\w+)//) {
            # Named variable: look up or create
            $arg = $self->get_var($1);
            $arg = DSLVar->new($self, $1) unless defined $arg;

        } elsif ($line =~ s/^"([^"\\]*(?:\\.[^"\\]*)*)("?)//) {
            # Double quoted string: interpolate any variables in it
            die "Missing quote: $line\n" unless $2;
            $arg = $1;
            $arg =~ s/(?<!\\)\$(\w+)/$self->interpolate_var($1, $context)/eg;
            $arg =~ s/(?<!\\)\\//g;
            $arg =~ s/\\\\/\\/g;

        } elsif ($line =~ s/^'([^'\\]*(?:\\.[^'\\]*)*)('?)//) {
            # Single quoted string
            die "Missing quote: $line\n" unless $2;
            $arg = $1;
            $arg =~ s/(?<!\\)\\//g;
            $arg =~ s/\\\\/\\/g;

        } elsif ($line =~ s/^([^\s\$\[\]"']+)//) {
            # Unquoted string
            $arg = $1;

        } elsif ($line =~ s/^\s+//) {
            # White space: ignore
            ;

        } else {
            last;
        }
    }
    
    return ($line, $arg);
}

#-----------------------------------------------------------------------
# Parse and interpret a single line

sub parse_a_line {
    my ($self, $line, $context) = @_;

    my $cmd;
    ($line, $cmd) = $self->next_arg($line, $context);

    die "Empty brackets: $line\n" unless defined $cmd;
    my $obj = $self->get_pkg($cmd);
    
    my ($arg, @args);
    push(@args, $obj);

    for (;;) {
        ($line, $arg) = $obj->next_arg($line, $context);
        last unless defined $arg;

        push(@args, $arg);
    }
    
    return ($line, @args);
}

#-----------------------------------------------------------------------
# Put a message to the log file

sub put_log {
    my ($self, $msg) = @_;

    my $top = $self->get_top();    
    $top->{LOG} = '' unless exists $top->{LOG};
    $top->{LOG} .= $msg;
    
    return;
}

#-----------------------------------------------------------------------
# Read the rest of the block (no op for single line commands)

sub read_some_lines {
    my ($self, $lines) = @_;
    return ();
}

#-----------------------------------------------------------------------
# The default method copies the value from one var to another

sub run {
    my ($self, @args) = @_;

    return @args ? \@args : $self->get_value();
}

#-----------------------------------------------------------------------
# Set the state

sub set {
    my ($self, $name, $value) = @_;

    $self->{STATE}{$name} = $value;
    return;    
}

#-----------------------------------------------------------------------
# Initialize an object after its state has been set (stub)

sub setup {
    my ($self) = @_;
    return;
}

#-----------------------------------------------------------------------
# Set the status

sub set_script_status {
    my ($self, $value) = @_;

    my $top = $self->get_top();
    $top->{STATUS} = $value;
    return;    
}

#-----------------------------------------------------------------------
# Set the value

sub set_value {
    my ($self, $value) = @_;

    if (! defined $value) {
        $value = [];
    } elsif (ref $value ne 'ARRAY') {
        $value = [$value];
    }

    $self->{VALUE} = $value;

    return;    
}

#-----------------------------------------------------------------------
# Add the name of a variable to the main object

sub set_var {
    my ($self, $name, $obj) = @_;

    my $top = $self->get_top();
    $top->set($name, $obj);

    return;    
}

#-----------------------------------------------------------------------
# Check the status

sub status {
    my ($self) = @_;
    
    return 1;
}

#-----------------------------------------------------------------------
# Return string version of value

sub stringify {
    my ($self) = @_;
    
    my $val = $self->get_value();
    $val = $self->to_string($val);
    
    return $val;
}

#-----------------------------------------------------------------------
# Clean up before deleting object

sub teardown {
    my ($self) = @_;
    return ();
}

#-----------------------------------------------------------------------
# Get the string which terminates a block of commands (stub)

sub terminator {
    my ($self) = @_;
    return;
}

#-----------------------------------------------------------------------
# Convert an element of a value to a string

sub to_string {
    my ($self, $val) = @_;
    
    my $str;
    my $ref = ref $val;

    if ($ref eq 'ARRAY') {
        $str = '';
        foreach my $subval (@$val) {
            $str .= "\n" if $str;
            $str .= ref $subval eq 'ARRAY' ? '...' : $self->to_string($subval);
        }

    } elsif ($ref eq 'HASH') {
        $str = '';
        foreach my $key (sort keys %$val) {
            $str .= ' ' if $str;
            $str .= "$key: ";
            $str .=  ref $val->{$key} ? '...' : $val->{$key};
        }

    } else {
        $str = "$val";
    }

    return $str;
}

1;

__END__
=head1 NAME

DSLVar -- Base class for DSL objects

=head1 SYNOPSIS

    # Syntax examples
    $x value
    $y multiple values
    $z 'a single value'
    $a "interpolated $x"
    # Assignment of command result to variable
    $b [cmd args]

=head1 USAGE

This class implements parsing for Domain Specific Languages (DSLs) and
implements the most basic type of objects, variable. One feature of this code
is that every command is an class and each use of a command is a variable which
is an instance of that class. The base class implements simple variables whose
method is assignment. In addition to the method that the variables runs, there
are also methods to parse the command line that the variable is used on. Each
class inherits the parsing code and can override it.

=head1 SYNTAX

The syntax of a DSL script is line oriented. Each command is implemented as a
line or block of lines. Lines are divided into arguments, which are either
strings or variables. Variables are prefaced with a dollar sign ($), strings
are not. If a string contains blanks or other characters with special meaning,
it should be surrounded by single quotes. If double quotes are used, variables
can be interpolated, just as in Perl. A backslash turns off the special meaning
of the following character. Parts of a line inside square brackets are
interpreted as a command and replaced by the command's results. This is how
the result of a command is assigned to a variable.

The the class of the first argument on a line specifies how the line is parsed
and what code is run with the remaining arguments. If the first argument is a
string, an unnamed variable of that class is created and then that variable's
code is run. For example, if the string is log, an unnamed variable of the
LogCommand class is created.

=head1 FIELDS

Each variable has the fields:

=over

=item STATE

A hash which contains the state of a variable, which holds the persistent
information about the the object. For simple variables the state is unused.
The state is accessed by the methods get and set.

=item VALUE

An array containing the value or values of the variable. The values are
accessed by the methods get_value and set_value.

=item SETUP

A field indicating the the class's setup method has been called. This is not
used by simple variables.

=back

A variable optionally has these fields. They are sepcified when creating the
object with the new method and not changed afterwards.

=over

=item PARENT

The object containing the variable, usually the object creating it. The topmost
object and unnamed objects have no PARENT field.

=item NAME

The name of the variable.

=back

The topmost variable represents the script. It is found by tracing up the parent
chain. It can be accessed by calling the get_top method. The STATE hash of the
topmost variable contains references to all the variables keyed by their names.
They are accessed by the get_var and set_var methods. Additional information is
stored on the following fields:

=over
 
=item LOG

This field contains all the log messages generated by the script. It is accessed
by the methods get_log and put_log.

=item STATUS

This field contains a numeric code representing the status of the script. It is
accessed through the get_script_status and set_script_status fields. The numeric
codes are early exit=0 normal exit=1 error exit=2.

=back
