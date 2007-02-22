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
            },
        },
    );
    __PACKAGE__->setup;

    sub action1 : Global {
        my ( $self, $c ) = @_;

        if ($c->form->has_error) {
            if (($c->req->params->{as} || '') eq 'hash') {
                $c->res->body( $c->form_messages->{param1}->[0] );
            }
            else {
                $c->res->body( $c->form_messages('param1')->[0] );
            }
        }
        else {
            $c->res->body('no errors');
        }
    }
}

use Catalyst::Test 'TestApp';
use Test::Base;

plan tests => 8;

ok( my $res = request('/action1'), 'request ok' );
is( $res->content, 'NOT_BLANK!!!', 'is NOT_BLANK error');

ok( $res = request('/action1?as=hash'), 'request ok' );
is( $res->content, 'NOT_BLANK!!!', 'is NOT_BLANK error (test as hash)');


ok( $res = request('/action1?param1=aaa bbb'), 'request ok' );
is( $res->content, 'ASCII!!!', 'is ASCII error');

ok( $res = request('/action1?param1=aaa bbb&as=hash'), 'request ok' );
is( $res->content, 'ASCII!!!', 'is ASCII error (test as hash)');
