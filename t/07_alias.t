use strict;
use warnings;

{
    package TestApp;

    use Catalyst qw/
      FormValidator::Simple
      FormValidator::Simple::Auto
      /;

    use FindBin;
    use File::Spec;

    __PACKAGE__->config(
        name => 'TestApp',
        validator => {
            profiles => File::Spec->catfile($FindBin::Bin, '07_alias.yaml'),
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
