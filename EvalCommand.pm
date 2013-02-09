use strict;
use warnings;
use integer;

#-----------------------------------------------------------------------
# Show contents of a variable

package EvalCommand;

use base qw(DSLVar);

#-----------------------------------------------------------------------
# Evaluate an expression as perl

sub interpret_some_lines {
    my ($self, $reader, $context, $expr) = @_;
    
    my $fun = $self->make_fun($context, $expr);

    my $prefix = '{&$fun';
    my $suffix ='}';
    
    $expr =~ s/([\$\@\%])(\w+)/$1$prefix('$2')$suffix/g;
    
    my $result = eval $expr;
    die "Syntax error in expr: $expr\n" if $@;
    
    $self->set_value($result);
    return $self;
}

#-----------------------------------------------------------------------
# Make the function that returns a reference to a variable

sub make_fun {
    my ($self, $context, $expr) = @_;

    my $fun = sub {
        my ($name) = @_;

        my $var;
        if ($name =~ /^(\d+)$/) {
            # Numeric variable: get from context
            $var = $context->[$name];

        } else {
            # Named variable: look up or create
            $var = $self->get_var($name) || DSLVar->new();
        }

        my $val = $var->dereferenced_value();
        my $ptr = ref $val ? $val : \$val;

        return $ptr;
    };

    return $fun;    
}

#-----------------------------------------------------------------------
# Return the whole line as a single argument

sub next_arg {
    my ($self, $line, $context) = @_;

    return (undef, $line);
}

1;

__END__
=head1 NAME

EvalCommand -- Evaluate line as a Perl expression

=head1 SYNOPSIS

    eval $x > 5
    
=head1 DESCRIPTION

This command evaluates the rest of the line as a perl expression and returns
its value

=head1 ARGUMENTS

This command evaluates the rest of the line as an expression. The expression
should be valid Perl and not have side effects. It is mostly intended to
support tests for the if command.

=head1 PARAMETERS

This command does not use any parameters
