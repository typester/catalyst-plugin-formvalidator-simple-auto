package TestApp06;

use Catalyst qw/
    FormValidator::Simple
    FormValidator::Simple::Auto
    /;

__PACKAGE__->config(
    name      => 'TestApp',
    validator => {
        profiles => {
            action_a => {
                input => [{rule => 'NOT_BLANK', message => 'error a'}, 'INT']
            },
            action_b => {
                input =>
                    [{rule => 'NOT_BLANK', message => 'error b'}, 'ASCII']
            },
            action_c => {input => []},
        },
    },
);
__PACKAGE__->setup;

1;

