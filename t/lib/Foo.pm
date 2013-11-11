use strict;
use warnings;
use mop;
use mopx::contracts;

use Types::Standard -types;

class Foo {
    method numbers($a, $b) is expected(Int, Int), ensured(Str, Str) {}
}

1;
