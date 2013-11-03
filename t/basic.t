#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use mop;
use mopx::contracts;

use Types::Standard -types;

class Foo {
    has $!bar is rw, expected(Int);

    method set_bar($val) {
        $!bar = $val;
    };

    method add_numbers($a, $b) is expected(Int, Int), ensured(Int) {
        $a + $b
    };
}

subtest 'check attribute type during construction' => sub {
    my $foo = Foo->new;

    ok! exception { $foo->bar(10) };
    is($foo->bar, 10);

    like(
        exception { $foo->bar([]) },
        qr/did not pass type constraint/
    );
};

subtest 'check attribute type during assignment' => sub {
    my $foo = Foo->new;

    ok !exception { $foo->set_bar(100) };
    is($foo->bar, 100);

    like(exception { $foo->set_bar([]) }, qr/did not pass type constraint/);
    is($foo->bar, 100);
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

subtest 'apply correct traits' => sub {
    my @traits = mop::traits::util::applied_traits(
        mop::meta('Foo')->get_attribute('$!bar')
    );

    is($traits[0]->{'trait'}, \&rw);
    is($traits[1]->{'trait'}, \&expected);
    is_deeply($traits[1]->{'args'}, ['Int']);
};

done_testing;
