#!/usr/bin/env perl

use strict;
use warnings;

{
    package TestApp;

    use Catalyst qw/
      FormValidator::Simple
      FormValidator::Simple::Auto
      /;

    __PACKAGE__->config(
        name => 'TestApp',
        validator => {
            profiles => {
                action1 => {
                    param1 => ['NOT_BLANK', 'ASCII'],
                },
            },
        },
    );
    __PACKAGE__->setup;

    sub action1 : Global {
        my ( $self, $c ) = @_;

        $c->res->body( $c->validator_profile );
    }

    sub action2 : Global {
        my ( $self, $c ) = @_;

        if ($c->req->method eq 'POST' ) {
            $c->forward('action1');
        }
    }
}

use Catalyst::Test 'TestApp';
use Test::More tests => 4;

use HTTP::Request::Common;

ok( my $res = request('/action1'), 'request ok' );
is( $res->content, 'action1', 'store profile ok (action based)');

ok( $res = request(POST '/action2'), 'request ok' );
is( $res->content, 'action1', 'store profile ok (forward based)');

