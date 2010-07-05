package TestApp07;

use Catalyst qw/
    FormValidator::Simple
    FormValidator::Simple::Auto
    /;

use FindBin;
use File::Spec;

__PACKAGE__->config(
    name => 'TestApp',
    validator =>
        {profiles => File::Spec->catfile($FindBin::Bin, '07_alias.yaml'),},
);
__PACKAGE__->setup;

1;
