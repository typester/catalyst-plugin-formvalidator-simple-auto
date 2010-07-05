package TestApp03;

use Catalyst qw/
    FormValidator::Simple
    FormValidator::Simple::Auto
    /;

__PACKAGE__->config(
    name => 'TestApp',
    validator =>
        {profiles => {action1 => {param1 => ['NOT_BLANK', 'ASCII'],},},},
);
__PACKAGE__->setup;

1;

