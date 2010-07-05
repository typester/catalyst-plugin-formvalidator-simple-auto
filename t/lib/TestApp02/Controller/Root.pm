package TestApp02::Controller::Root;

use base qw(Catalyst::Controller);

__PACKAGE__->config(namespace => '');

sub action1 : Global {
    my ($self, $c) = @_;

    if ($c->form->has_error) {
        $c->res->body($c->form->error('param1'));
    } else {
        $c->res->body('no errors');
    }
}

sub action2 : Global {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        $c->forward('action2_submit');
    } else {
        $c->res->body('no $c->form executed');
    }
}

sub action2_submit : Private {
    my ($self, $c) = @_;

    if ($c->form->has_error) {
        $c->res->body($c->form->error('param1'));
    } else {
        $c->res->body('no errors');
    }
}

1;
