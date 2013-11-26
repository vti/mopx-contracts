use strict;
use warnings;

require Carp;

use mop;

$Carp::Internal{(__PACKAGE__)}++;
$Carp::Internal{'mop::internals::observable'}++;
$Carp::Internal{'mop::attribute'}++;
$Carp::Internal{'mop::class'}++;
$Carp::Internal{'mop::role'}++;

role mopx::contracts::metaclass::role {
    has $!expected_arg_types is lazy, rw = $_->_build_expected_arg_types;
    has $!ensured_arg_types is lazy,  rw = $_->_build_ensured_arg_types;

    method execute ($invocant, $args) {
        if (defined $!expected_arg_types) {
            if (@$args != @{$!expected_arg_types}) {
                Carp::croak('wrong number of arguments');
            }

            for my $i (0..$#$args) {
                my $type = $!expected_arg_types->[$i];
                next unless $type;

                my $error = $type->validate($args->[$i]);
                Carp::croak('arg[' . $i . '] type failed: ' . $error)
                  if defined $error;
            }
        }

        my @retval = $self->next::method($invocant, $args);

        if (defined $!ensured_arg_types) {
            my $got      = scalar @retval;
            my $expected = scalar @{$! ensured_arg_types};
            if ($got != $expected) {
                Carp::croak('wrong number of return values: '
                      . "got $got, expected $expected");
            }

            for my $i (0..$#retval) {
                my $type = $!ensured_arg_types->[$i];
                next unless $type;

                my $error = $type->validate($retval[$i]);
                Carp::croak('return[' . $i . '] type failed: ' . $error)
                  if defined $error;
            }
        }

        return wantarray ? @retval : $retval[0];
    }

    method _build_expected_arg_types {
        my $class = $self->associated_meta;

        my ($next, $method) = ($class);
        do {
            return unless $next->superclass;
            $next = mop::meta($next->superclass);
        } while ($next && !($method = $next->get_method($self->name)));

        return unless $method->does(__ROLE__);

        return $method->expected_arg_types;
    }

    method _build_ensured_arg_types {
        my $class = $self->associated_meta;

        my ($next, $method) = ($class);
        do {
            return unless $next->superclass;
            $next = mop::meta($next->superclass);
        } while ($next && !($method = $next->get_method($self->name)));

        return unless $method->does(__ROLE__);

        return $method->ensured_arg_types;
    }
}

class mopx::contracts::metaclass extends mop::method with mopx::contracts::metaclass::role { }

1;
