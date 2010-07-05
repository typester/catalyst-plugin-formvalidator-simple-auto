package TestApp05::Controller::Root;

use base qw(Catalyst::Controller);

__PACKAGE__->config(namespace => '');

sub action1 : Global {
    my ($self, $c) = @_;

    if ($c->form->has_error) {
        if (($c->req->params->{as} || '') eq 'hash') {
            $c->res->body($c->form_messages->{param1}->[0]);
        } else {
            $c->res->body($c->form_messages('param1')->[0]);
        }
    } else {
        $c->res->body('no errors');
    }
}

1;
