package mopx::contracts;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw(expected ensured);

use mop;
use mopx::contracts::metaclass;

sub expected {
    if ($_[0]->isa('mop::attribute')) {
        my ($attr, $type) = @_;
        $attr->bind('before:STORE_DATA' => sub { $type->assert_valid(${$_[2]}) });
    }
    elsif ($_[0]->isa('mop::method')) {
        my ($meth, @types) = @_;
        mop::apply_metaclass($meth, 'mopx::contracts::metaclass');
        $meth->expected_arg_types(\@types);
    }
}

sub ensured {
    if ($_[0]->isa('mop::method')) {
        my ($meth, @types) = @_;
        mop::apply_metaclass($meth, 'mopx::contracts::metaclass');
        $meth->ensured_arg_types(\@types);
    }
}

1;
