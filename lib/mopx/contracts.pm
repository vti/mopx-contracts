package mopx::contracts;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw(expected ensured);

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
