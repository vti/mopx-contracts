# NAME

mopx::contracts - contracts for mop

# SYNOPSIS

    use mop;
    use mopx::contracts;

    use Types::Standard -types;

    class Foo {
        has $!bar is rw, expected(Int);

        method add_numbers($a, $b) is expected(Int, Int), ensured(Int) {
            $a + $b
        };
    }

# DESCRIPTION

Type checking for [mop](http://search.cpan.org/perldoc?mop). The type checking is done via [Type::Tiny](http://search.cpan.org/perldoc?Type::Tiny).

## Exported functions

### `expected`

    ensured(Str, Int, ...)

Check the arguments.

### `ensured`

    ensured(Str, ...)

Check the return value.

## Inheritance

Types are inherited. No need for duplication. Useful for describing abstract
classes or interfaces.

    class MyAbstractClass is abstract {
        method do ($a, $b, $c) is expected(Str, Int, Int), ensured(Str)
    }

    class MyClass extends MyAbstractClass {}

# AUTHOR

Viacheslav Tykhanovskyi

# COPYRIGHT AND LICENSE

Copyright (C) 2013, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.
