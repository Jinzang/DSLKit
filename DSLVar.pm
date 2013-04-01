use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Base code for witing a Domain Specific Language

package DSLVar;

use NoReader;
use Data::Dumper;

use constant DEFAULT_TERMINATOR => 'end';

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
    return $self->flatten(@args);
}

#-----------------------------------------------------------------------
# Check for hash argument

sub check_hash_arg {
    my ($self, $arg) = @_;

    return unless defined $arg;
    return unless ref $arg;

    my $value = $arg->get_value();
    return if @$value && ref $value->[0] ne 'HASH';

    return $value;
}

#-----------------------------------------------------------------------
# Check for list argument

sub check_list_arg {
    my ($self, $arg) = @_;

    return unless defined $arg;
    return unless ref $arg;

    my $value = $arg->get_value();
    return if @$value && ref $value->[0];

    return $value;
}

#-----------------------------------------------------------------------
# Check for string argument

sub check_string_arg {
    my ($self, $arg) = @_;

    return unless defined $arg;

    my $value;
    if (ref $arg) {
        $value = $arg->dereferenced_value();
        return if ref $value;

    } else {
        $value = $arg;
    }

    return $value;
}

#-----------------------------------------------------------------------
# Dereferenced value of a variable if it is a scalar

sub dereferenced_value {
    my ($self) = @_;

    my $value = $self->get_value();
    if (@$value == 0) {
        return;

    } elsif (@$value == 1) {
        return $value->[0];

    } else {
        return $value;
    }
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
        # TODO use $self->{PATH} to find package
        my $pkg =  ucfirst(lc($cmd)) . 'Command';
        eval "require $pkg" or die "Command not found: $cmd\n";
        $obj = $pkg->new($self, $name);
    }

    return $obj;
}

#-----------------------------------------------------------------------
# Get the value of a string valued variable

sub get_string_value {
    my ($self, $name, $context) = @_;

    my $obj;
    if (! defined $name) {
        $obj = $self;

    } elsif (defined $context && $name =~ /^(\d+)$/) {
        return unless $name < @$context;
        $obj = $context->[$1];

    } else {
        $obj = $self->get_var($name);
        return unless defined $obj;
    }

    my $value;
    if (ref $obj) {
        $value = $obj->dereferenced_value();
        return if ref $value;

    } else {
        $value = $obj;
    }

    return $value;
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
# Get the current setup count and increment it

sub increment_setup {
    my ($self) = @_;

    my $top = $self->get_top();
    $self->{SETUP} ||= ++ $top->{SETUP};

    return;
}

#-----------------------------------------------------------------------
# Set up one line command to call run

sub interpret_some_lines {
    my ($self, $reader, $context, @args) = @_;

    @args = $self->check(@args);
    my $result = $self->run(@args);
    $self->set_value($result);

    return $self;
}

#-----------------------------------------------------------------------
# Return the next argument from a line

sub next_arg {
    my ($self, $line, $context) = @_;

    my $arg;
    while (! defined $arg) {
        if ($line =~ /^\[/) {
            # Bracketed expression, replace with interpreted result
            my $subline;
            my $reader = NoReader->new;
            ($subline, $line) = $self->subline($line);
            my ($obj, @args) = $self->parse_a_line($subline, $context);
            $arg = $obj->interpret_some_lines($reader, $context, @args);

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
            $arg =~ s/(?<!\\)\$(\w+)/$self->get_string_value($1, $context)/eg;
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

    return @args;
}

#-----------------------------------------------------------------------
# Parse the next block of lines to initialize the state

sub parse_some_lines {
    my ($self, $reader, @context) = @_;

    my %hash;
    my $name;
    while (defined (my $line = $self->read_a_line($reader, \@context))) {
        chomp $line;

        if ($line =~ /^\w+:/) {
            my $value;
            ($name, $value) = split(/:\s*/, $line, 2);
            $hash{$name} = $value;

        } else {
            die "Undefined field name\n" . substr($line, 0, 20) . "\n"
                unless defined $name;

            $hash{$name} .= "\n$line";
        }
    }

    return \%hash;
}

#-----------------------------------------------------------------------
# Read the next input line

sub read_a_line {
    my ($self, $reader, $context) = @_;

    my $line = $reader->next_line();
    return unless defined $line;

    my ($new_line, $arg) = $self->next_arg($line, $context);
    return if defined $arg && $arg eq $self->terminator();

    return $line;
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

    my $value = $self->dereferenced_value();
    return $self->value_to_string($value, 1);
}

#-----------------------------------------------------------------------
# Extract a bracket delimeted subline from a line

sub subline {
    my ($self, $line) = @_;

    my $pos = 1;
    my $depth = 1;
    while ($depth > 0) {
        my $lpos = index($line, '[', $pos) + 1;
        my $rpos = index($line, ']', $pos) + 1;

        if ($lpos && ($rpos == 0 || $lpos < $rpos)) {
            $pos = $lpos;
            $depth ++;

        } elsif ($rpos && ($lpos == 0 || $rpos < $lpos)) {
            $pos = $rpos;
            $depth --;

        } else {
            die "Unbalaced brackets on line: $line";
        }
    }

    my $subline = substr($line, 1, $pos-2);
    $line = substr($line, $pos);

    return ($subline, $line);
}

#-----------------------------------------------------------------------
# Clean up before deleting object

sub teardown {
    my ($self) = @_;
    return ();
}

#-----------------------------------------------------------------------
# Get the string which terminates a block of commands

sub terminator {
    my ($self) = @_;
    return DEFAULT_TERMINATOR;
}

#-----------------------------------------------------------------------
# Return a value converted into a string

sub value_to_string {
    my ($self, $value, $multiline) = @_;
    $multiline = 0 unless defined $multiline;

    my $str;
    my $ref = ref $value;
    my $separator = $multiline ? "\n" : ',';

    if ($ref && $multiline < 0) {
        $str = '...';
        
    } elsif ($ref eq 'ARRAY') {
        $str = '';
        foreach my $item (@$value) {
            $str .= $separator if $str;
            $str .= $self->value_to_string($item, $multiline-1);
        }

    } elsif ($ref eq 'HASH') {
        $str = '';
        foreach my $name (sort keys %$value) {
            my $item = $self->value_to_string($value->{$name}, $multiline-1);
            $str .= $separator if $str;
            $str .= "$name:$item";
        }

    } else {
        $str = $value;
    }
    
    return $str;
}

1;

__END__
=head1 NAME

DSLVar -- Base class for DSL objects

=head1 SYNOPSIS

    # Examples of variable use in Perl
    my $var = DSLVar->new($self, 'name');
    $var->set_value('foobar');
    my $value = $var->get_value();
    my $name = $var->get_name();

    # Syntax examples of variable use in scripts
    $x value
    $y multiple values
    $z 'a single value'
    $a "interpolated $x"
    # Assignment of command result to variable
    $b [cmd arg1 arg2]

=head1 SYNOPSIS

This class implements the most basic type of object, a variable. One feature of
the DSL code is that every command is an class and each use of a command is an
object which is an instance of that class and has both a value and a runtime
method. This class implements simple variables whose runtime method is assignment.

Each variable has three fields: VALUE, an array reference which contains the
value of the object, STATE, a hash reference which contains the object state
that is used when the object is run, and SETUP, a scalar which flags if the
setup method has been called so the teardown method can be called. It optionally
has two other fields: NAME, the name of the variable, and PARENT, a reference to
the containing object.

=head1 METHODS

=head2 new

    $var = DSLVar->new($parent, 'name');

New variables are automatically created in a script whenever it parses a word
preceded by a dollar sign. You create a variable in code by calling new. The
first argument is the container object, usually the object whose method is
calling new. The second argument is the name of the variable, which can be used
to retrieve it later. New can be called without any arguments, in which case
it creates an anonymous variable.

This class also supports a number of getters and setters for its fields

=head2 get set

   $var->get('name');
   $var->set('name', $value);

Get and set a field in the STATE of the variable. Simple variables do not use
their state.

=head2 get_value set_value

    my $value = $var->get_value();
    $var->set_value($value);

The value returned by get_value is an array reference. If set_value is called
with an argument that is not an array reference, it is enclosed in an array
when it is stored.

=head2 get_name

    my $name = $var->get_name();

Get the name of a variable. Returns undef if it has none.

=head2 get_top

    my $top = $var->get_top();

Return the topmost variable, which is found by tracing up the PARENT refernces.
The topmost variable has several extra fields, which can be retrieved from any
variable by several other methods.

=head2 interpret_some_lines

    $var = $var->interpret_some_lines($reader, $context, @args);

The most general way to invoke a variable is with this method. The first
argument, $reader, is an object with a next_line method, which gets the next
line of the script. Context is a reference to the argument list that the
containing object was invoked with. The remaining arguments are interpreted by
the method.

This method would be used by classes subclassing DSLVar if they have multiple
lines or need to use the arguments of the object invoking it.

=head2 setup

    $var->setup();

The setup method is called on an object after its state in initialized. It is
not used by simple variables, but may be used by your class.

=head2 check

    @new_args = $var->check(@args);

Check unmarsalls the data from the arguments passed to a command and checks that
they are the correct number and type. The unmarshalled data is passed to run.

=head2 chack_hash_arg check_list_arg check_string_arg

    $value = $self->check_hash_arg($arg);
    $value = $self->check_list_arg($arg);
    $value = $self->check_string_arg($arg);

These methods check a command line argument to see if it has the correct type.
If it does, it unmarshalls the data contained in the argument. If not, it
returns undef.

=head2 run

    my $value = $var->run(@args);

The run method implements your command. For simple variables, it returns a list
containing the values of the arguments passed to it, or the value of the
variable if called with no arguments.

=head2 teardown

    $var->teardown();

The teardown method is called at the end of the script on each object where
the setup method was called. It is not used by simple variables.

=head2 parse_some_lines

    $data = $obj->parse_some_lines($reader, @context);

This method is used to parse the following lines of a multi-line command, up
to the terminating line. The following lines are converted into $data, which
is returned from the method. $reader has the next_line method, which is used
to get the following lines. @context contains the parsed arguments from the
first line of the multi-line command.

=head2 terminator

    $str = $obj->terminator();

The method returns the string used to end a multi line command. Each line is
parsed into arguments and when the first argument matches the terminator,
the command is done.

