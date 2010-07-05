package TestApp03::Controller::Root;

use base qw(Catalyst::Controller);

__PACKAGE__->config(namespace => '');

sub action1 : Global {
    my ($self, $c) = @_;

    $c->res->body($c->validator_profile);
}

sub action2 : Global {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        $c->forward('action1');
    }
}

sub action3 : Global {
    my ($self, $c) = @_;
    $c->forward('action1');
    $c->res->body($c->validator_profile);
}

1;
