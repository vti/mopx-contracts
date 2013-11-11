use strict;
use warnings;
use mop;
use mopx::contracts;

use Types::Standard -types;

class PreconditionsWrongNumberOfArguments extends Foo {
    method numbers($a) is expected(Int), ensured(Str, Str) {
    }
}

1;
