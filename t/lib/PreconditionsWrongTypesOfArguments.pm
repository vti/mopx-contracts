use strict;
use warnings;
use mop;
use mopx::contracts;

use Types::Standard -types;

class PreconditionsWrongTypesOfArguments extends Foo {
    method numbers($a, $b) is expected(Int, Str), ensured(Str, Str) {
    }
}

1;
