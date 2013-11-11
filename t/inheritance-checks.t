#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use lib 't/lib';

subtest 'throw when preconditions are stronger: wrong number of arguments' => sub {
    my $e = exception { require 't/lib/PreconditionsWrongNumberOfArguments.pm' };
    like $e, qr/preconditions cannot be stronger: wrong number of arguments/;
};

subtest 'throw when preconditions are stronger: wrong types of arguments' => sub {
    my $e = exception { require 't/lib/PreconditionsWrongTypesOfArguments.pm' };
    like $e, qr/preconditions cannot be stronger: Str is not a subtype of Int/;
};

subtest 'throw when postconditions are weaker wrong number of arguments' => sub {
    my $e = exception { require 't/lib/PostconditionsWrongNumberOfArguments.pm' };
    like $e, qr/postconditions cannot be weaker: wrong number of arguments/;
};

subtest 'throw when postconditions are weaker wrong types of arguments' => sub {
    my $e = exception { require 't/lib/PostconditionsWrongTypesOfArguments.pm' };
    like $e, qr/postconditions cannot be weaker: Str is not a subtype of ArrayRef/;
};

done_testing;
