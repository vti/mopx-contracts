package mopx::contracts;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw(expected ensured);

our $VERSION = '0.01';

require Carp;

use mop;
use mopx::contracts::metaclass;

$Carp::Internal{(__PACKAGE__)}++;
$Carp::Internal{'mop::internals::observable'}++;
$Carp::Internal{'mop::attribute'}++;
$Carp::Internal{'mop::class'}++;

sub expected {
    if ($_[0]->isa('mop::attribute')) {
        my ($attr, $type) = @_;
        $attr->bind(
            'before:STORE_DATA' => sub {
                my $error = $type->validate(${$_[2]});
                Carp::croak($attr->name . ' type failed: ' . $error)
                  if defined $error;
            }
        );
    }
    elsif ($_[0]->isa('mop::method')) {
        my ($meth, @types) = @_;

        mop::apply_metaclass($meth, 'mopx::contracts::metaclass');

        $meth->associated_meta->bind(
            'before:FINALIZE' => sub {
                my ($meta) = @_;

                my $parent_types = _superclass_expected_types($meth, $meta);
                return unless @$parent_types;

                if (@$parent_types > @types) {
                    Carp::croak('preconditions cannot be stronger: '
                          . 'wrong number of arguments');
                }

                for (my $i = 0; $i < @$parent_types; $i++) {
                    if (!$types[$i]->is_a_type_of($parent_types->[$i])) {
                        Carp::croak('preconditions cannot be stronger: '
                              . $types[$i]->name
                              . ' is not a subtype of '
                              . $parent_types->[$i]->name);
                    }
                }
            }
        );

        $meth->expected_arg_types(\@types);
    }
}

sub ensured {
    if ($_[0]->isa('mop::method')) {
        my ($meth, @types) = @_;
        mop::apply_metaclass($meth, 'mopx::contracts::metaclass');

        $meth->associated_meta->bind(
            'before:FINALIZE' => sub {
                my ($meta) = @_;

                my $parent_types = _superclass_ensured_types($meth, $meta);
                return unless @$parent_types;

                if (@$parent_types != @types) {
                    Carp::croak('postconditions cannot be weaker: '
                          . 'wrong number of arguments');
                }

                for (my $i = 0; $i < @$parent_types; $i++) {
                    if (!$parent_types->[$i]->is_a_type_of($types[$i])) {
                        Carp::croak('postconditions cannot be weaker: '
                              . $parent_types->[$i]->name
                              . ' is not a subtype of '
                              . $types[$i]->name);
                    }
                }
            }
        );

        $meth->ensured_arg_types(\@types);
    }
}

sub _superclass_expected_types {
    my ($meth, $meta) = @_;

    if (my $superclass = $meta->superclass) {
        if (my $superclass_meta = mop::meta($superclass)) {
            if (my $method = $superclass_meta->get_method($meth->name)) {
                return $method->expected_arg_types;
            }
        }
    }

    return [];
}

sub _superclass_ensured_types {
    my ($meth, $meta) = @_;

    if (my $superclass = $meta->superclass) {
        if (my $superclass_meta = mop::meta($superclass)) {
            if (my $method = $superclass_meta->get_method($meth->name)) {
                return $method->ensured_arg_types;
            }
        }
    }

    return [];
}

1;
__END__

=pod

=head1 NAME

mopx::contracts - contracts for mop

=head1 SYNOPSIS

    use mop;
    use mopx::contracts;

    use Types::Standard -types;

    class Foo {
        has $!bar is rw, expected(Int);

        method add_numbers($a, $b) is expected(Int, Int), ensured(Int) {
            $a + $b
        };
    }

=head1 DESCRIPTION

Type checking for L<mop>. The type checking is done via L<Type::Tiny>.

=head2 Exported functions

=head3 C<expected>

    ensured(Str, Int, ...)

Check the arguments.

=head3 C<ensured>

    ensured(Str, ...)

Check the return value.

=head2 Inheritance

Types are inherited. No need for duplication. Useful for describing abstract
classes or interfaces.

    class MyAbstractClass is abstract {
        method do ($a, $b, $c) is expected(Str, Int, Int), ensured(Str)
    }

    class MyClass extends MyAbstractClass {}

=head1 AUTHOR

Viacheslav Tykhanovskyi

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
