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
        name      => 'TestApp',
        validator => {
            profiles => {
                action1 => {
                    param1 => [
                        { rule => 'NOT_BLANK', message => 'NOT_BLANK!!!' },
                        { rule => 'ASCII',     message => 'ASCII!!!' },
                    ],
                },
                action2_submit => { param1 => [ 'NOT_BLANK', 'ASCII' ], },
            },
        },
    );
    __PACKAGE__->setup;

    sub action1 : Global {
        my ( $self, $c ) = @_;

        if ($c->form->has_error) {
            $c->res->body( $c->form->message->get( $c->validator_profile, 'param1', $c->form->error('param1') ) );
        }
        else {
            $c->res->body('no errors');
        }
    }

    sub action2 : Global {
        my ( $self, $c ) = @_;

        if ($c->req->method eq 'POST') {
            $c->forward('action2_submit');
        }
        else {
            $c->res->body('no $c->form executed');
        }
    }

    sub action2_submit : Private {
        my ( $self, $c ) = @_;

        if ($c->form->has_error) {
            $c->res->body( $c->form->error('param1') );
        }
        else {
            $c->res->body('no errors');
        }
    }
}

use Catalyst::Test 'TestApp';
use Test::Base;

plan tests => 14;

use HTTP::Request::Common;

# action driven validation
ok( my $res = request('/action1'), 'request ok' );
is( $res->content, 'NOT_BLANK!!!', 'is NOT_BLANK error');

ok( $res = request('/action1?param1=aaa bbb'), 'request ok' );
is( $res->content, 'ASCII!!!', 'is ASCII error');

ok( $res = request('/action1?param1=aaa'), 'request ok' );
is( $res->content, 'no errors', 'is no errors');


# forward driven validation
ok( $res = request(POST '/action2', [ param1 => '' ]), 'request ok' );
is( $res->content, 'NOT_BLANK', 'is NOT_BLANK error');

ok( $res = request(POST '/action2', [ param1 => 'aaa bbb' ]), 'request ok' );
is( $res->content, 'ASCII', 'is ASCII error');

ok( $res = request(POST '/action2', [ param1 => 'ab' ]), 'request ok' );
is( $res->content, 'no errors', 'is no errors');

ok( $res = request('/action2'), 'request ok' );
is( $res->content, 'no $c->form executed', 'is no $c->form executed');

