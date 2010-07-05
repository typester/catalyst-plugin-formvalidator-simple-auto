package TestApp04;

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
            action2_submit => {param1 => ['NOT_BLANK', 'ASCII'],},
            action3 =>
                {param1 => [{self_rule => 'SELF', message => 'SELF!!',},],},
        },
    },
);
__PACKAGE__->setup;

1;

