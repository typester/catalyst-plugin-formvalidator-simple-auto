package Catalyst::Plugin::FormValidator::Simple::Auto;
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;

use Catalyst::Exception;
use UNIVERSAL::isa;
use YAML;
use FormValidator::Simple;

our $VERSION = '0.12';

__PACKAGE__->mk_accessors(qw/validator_profile/);

=head1 NAME

Catalyst::Plugin::FormValidator::Simple::Auto - Smart validation with FormValidator::Simple

=head1 SYNOPSIS

Loading:

    use Catalyst qw/
      ConfigLoader
      FormValidator::Simple
      FormValidator::Simple::Auto
      /;

myapp.yml:

    validator:
      profiles: __path_to(profiles.yml)__
      messages: __path_to(messages.yml)__
      message_format: <span class="error">%s</span>
      # and other FormValidator::Simple config

profiles.yml:

    # profiles.yml
    action1:
      param1:
        - NOT_BLANK
        - ASCII
        - [ 'LENGTH', 4, 10 ]
      param2:
        - NOT_BLANK

Then, using in your action:

    sub action1 : Global {
        my ($self, $c) = @_;
    
        # $c->form($profile) already executed!
        unless ($c->form->has_error) {
            ...
        }
    }

=head1 DESCRIPTION

This plugin provide auto validation to Plugin::FormValidator::Simple.

You can define validation profiles into config or YAML file, and no longer have to write it in actions.

=head1 BUNDLING ERROR MESSAGES

With 0.08 or earlier version, you need define validator profiles and error messages in separately.

So, you had to write two settings like this:

    # profiles.yml
    action1:
      param1:
        - NOT_BLANK
    
    # messages.yml
    action1:
      param1:
        NOT_BLANK: param1 is required!

It's bothered!

Since 0.09, you can place error messages in profiles config.

Above two configs is equals to:

    # profiles.yml
    action1:
      param1:
        - rule: NOT_BLANK
          message: param1 is required!

=head1 METHODS

=head2 validator_profile

An accessor for current profile name

=head2 form_messages

=head2 form_messages( 'key' );

Return error messages about current validator profile.

If the key isn't presented, return all messages as hash.

=cut

sub form_messages {
    my ($c, $key) = @_;
    my $messages = $c->form->field_messages( $c->validator_profile );

    $key ? $messages->{$key} : $messages;
}

=head1 EXTENDED METHODS

=head2 setup

=cut

sub setup {
    my $c = shift;
    my $config = $c->config->{validator};

    Catalyst::Exception->throw( message =>
          __PACKAGE__ . qq/: You need to load "Catalyst::Plugin::FormValidator::Simple"/ )
      unless $c->isa('Catalyst::Plugin::FormValidator::Simple');

    $c->log->warn( __PACKAGE__ . qq/: You must set validator profiles/ )
      unless $config->{profiles};

    if ( $config->{profiles} and ref $config->{profiles} ne 'HASH' ) {
        my $profiles = eval {
            YAML::LoadFile( $config->{profiles} );
        };
        Catalyst::Exception->throw( message => __PACKAGE__ . qq/: $@/ ) if $@;

        $config->{profiles} = $profiles;
    }

    my $messages;
    my $profiles = $config->{profiles};
    for my $action ( keys %{ $profiles || {} } ) {
        my $profile = $profiles->{$action} || {};

        for my $param ( keys %$profile ) {
            my $rules = $profile->{$param} || [];

            for my $rule (@$rules) {
                if ( ref $rule eq 'HASH' and defined $rule->{rule} ) {
                    my $rule_name = ref $rule->{rule} eq 'ARRAY' ? $rule->{rule}[0] : $rule->{rule};
                    $messages->{$action}{$param} ||= {};
                    $messages->{$action}{$param}{ $rule_name } = $rule->{message} if defined $rule->{message};
                    $rule = $rule->{rule};
                }
            }
        }
    }

    # XXX: replace messages. ponder about hash merging
    $config->{messages} = $messages if $messages;

    # fix plugin order
    {
        no strict 'refs';
        my $pkg = __PACKAGE__;
        @{"$c\::ISA"} = ( $pkg, grep !/^$pkg$/, @{"$c\::ISA"} );
    }

    $c->NEXT::setup(@_);
}

=head2 prepare

=cut

sub prepare {
    my $c = shift->NEXT::prepare(@_);

    if ( my $profile = $c->config->{validator}{profiles}{ $c->action->reverse } ) {
        $c->validator_profile( $c->action->reverse );
        $c->form(%$profile);
    }

    $c
}

=head2 forward

=cut

sub forward {
    my $c = shift;
    my $action = $c->dispatcher->_invoke_as_path($c, @_);

    local $NEXT::NEXT{ $c, 'forward' };

    my $res;
    if ( my $profile = $c->config->{validator}{profiles}{ $action } ) {
        # We only need to create a new validator if there is a new profile
        local $c->{validator} = FormValidator::Simple->new;
        local $c->{validator_profile} = $action;

        $c->form(%$profile);
        $res = $c->NEXT::forward(@_);
    }
    else {
        $res = $c->NEXT::forward(@_);
    }

    $res;
}

=head1 ORIGINAL IDEA

Daisuke Maki <dmaki@cpan.org>

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
