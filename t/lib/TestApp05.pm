package TestApp05;

use Catalyst qw/
    FormValidator::Simple
    FormValidator::Simple::Auto
    /;

__PACKAGE__->config(
    name      => 'TestApp',
    validator => {
        profiles => {
            action1 => {
                param1 => [
                    {rule => 'NOT_BLANK', message => 'NOT_BLANK!!!'},
                    {rule => 'ASCII',     message => 'ASCII!!!'},
                ],
            },
        },
    },
);
__PACKAGE__->setup;

1;

