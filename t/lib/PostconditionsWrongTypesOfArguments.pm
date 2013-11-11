use strict;
use warnings;
use mop;
use mopx::contracts;

use Types::Standard -types;

class PostconditionsWrongTypesOfArguments extends Foo {
    method numbers($a, $b) is expected(Int, Int), ensured(ArrayRef, Str) {
    }
}

1;
