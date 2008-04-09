use strict;
use warnings;

{
    package TestApp;

    use Catalyst qw/
      FormValidator::Simple
      FormValidator::Simple::Auto
      /;

    use YAML;

    my $conf = <<'_YAML_';
action1:
    param1: &param1
        - rule: NOT_BLANK
          message: blank

action2:
    param1: *param1

_YAML_

    __PACKAGE__->config(
        name => 'TestApp',
        validator => {
            profiles => YAML::Load($conf),
        },
    );
    __PACKAGE__->setup;

    sub action1 : Global {
        my ( $self, $c ) = @_;

        $c->res->body( @{ $c->form_messages('param1') } );
    }

    sub action2 : Global {
        my ( $self, $c ) = @_;
        $c->res->body( @{ $c->form_messages('param1') } );
    }
}

use Catalyst::Test 'TestApp';
use Test::More tests => 4;

ok( my $res = request('/action1'), 'request ok' );
is( $res->content, 'blank', 'action1 errors ok');

ok( $res = request('/action2'), 'request ok' );
is( $res->content, 'blank', 'action2 errors ok');
