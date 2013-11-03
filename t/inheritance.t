#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use mop;
use mopx::contracts;

use Types::Standard -types;

class AbstractClass {
    method add_numbers ($a, $b) is expected(Int, Int), ensured(Int) {
        ...
    }
}

class Foo extends AbstractClass {
    method add_numbers ($a, $b) {
        $a + $b
    }
};

subtest 'check method signatures' => sub {
    my $foo = Foo->new;

    my $result = $foo->add_numbers(100, 100);
    is($result, 200);

    like(
        exception { $foo->add_numbers([], 20) },
        qr/did not pass type constraint/
    );
};

done_testing;
