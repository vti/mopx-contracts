package mopx::contracts::metaclass;

use mop;

role mopx::contracts::metaclass::role {
    has $!expected_arg_types is lazy, rw = $_->_build_expected_arg_types;
    has $!ensured_arg_types is lazy,  rw = $_->_build_ensured_arg_types;

    method execute ($invocant, $args) {
        for my $i (0..$#$args) {
            $!ensured_arg_types->[$i]->assert_valid($args->[$i])
                if $!ensured_arg_types->[$i];
        }
        $self->next::method($invocant, $args);
    }

    method _build_expected_arg_types {
        my $class = $self->associated_meta;

        my ($next, $method);
        do {
            return [] unless $class->superclass;
            $next = mop::meta($class->superclass);
        } while ($next && !($method = $next->get_method($self->name)));

        return [] unless $method->does(__ROLE__);

        return $method->expected_arg_types;
    }

    method _build_ensured_arg_types {
        my $class = $self->associated_meta;

        my ($next, $method);
        do {
            return [] unless $class->superclass;
            $next = mop::meta($class->superclass);
        } while ($next && !($method = $next->get_method($self->name)));

        return [] unless $method->does(__ROLE__);

        return $method->ensured_arg_types;
    }
}

class mopx::contracts::metaclass extends mop::method with mopx::contracts::metaclass::role { }

1;
