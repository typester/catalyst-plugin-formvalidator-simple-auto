package TestApp06::Controller::Root;

use base qw(Catalyst::Controller);

__PACKAGE__->config(namespace => '');

sub action_a : Local {
    my ($self, $c) = @_;

    if ($c->form->has_error) {
        $c->forward('action_b');
    } else {
        $c->res->body('a');
    }

    if (($c->req->params->{restore} || '') eq 'a') {
        $c->res->body($c->form_messages->{input}->[0]);
    }
}

sub action_b : Local {
    my ($self, $c) = @_;

    if ($c->form->has_error) {
        $c->forward('action_c');
    } else {
        $c->res->body('b');
    }

    if (($c->req->params->{restore} || '') eq 'b') {
        $c->res->body(
            $c->form->field_messages($c->validator_profile)->{input}[0]);
    }
}

sub action_c : Local {
    my ($self, $c) = @_;

    if ($c->form->has_error) {
        $c->res->body('error');
    } else {
        $c->res->body('c');
    }
}

sub no_validate_action : Local {
    my ($self, $c) = @_;

    $c->forward('action_a');
    $c->res->body($c->form_messages->{input}->[0]);
}

1;
