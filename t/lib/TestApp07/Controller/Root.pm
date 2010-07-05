package TestApp07::Controller::Root;

use base qw(Catalyst::Controller);

__PACKAGE__->config(namespace => '');

sub action1 : Global {
    my ($self, $c) = @_;

    $c->res->body(@{$c->form_messages('param1')});
}

sub action2 : Global {
    my ($self, $c) = @_;
    $c->res->body(@{$c->form_messages('param1')});
}


1;
