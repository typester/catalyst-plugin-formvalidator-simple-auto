package TestApp04::Controller::Root;

use base qw(Catalyst::Controller);

__PACKAGE__->config(namespace => '');

sub action1 : Global {
    my ($self, $c) = @_;

    if ($c->form->has_error) {
        $c->res->body(
            $c->form->message->get(
                $c->validator_profile, 'param1', $c->form->error('param1')
            )
        );
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

sub action3 : Global {
    my ($self, $c) = @_;

    $c->set_invalid_form(param1 => 'SELF');
    $c->res->body($c->form_messages('param1')->[0]);
}


1;
