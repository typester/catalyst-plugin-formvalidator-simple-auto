package Catalyst::Plugin::FormValidator::Simple::Auto;
use strict;
use warnings;

use Catalyst::Exception;
use UNIVERSAL::isa;
use YAML;

our $VERSION = '0.02';

=head1 NAME

Catalyst::Plugin::FormValidator::Simple::Auto - Smart validation with FormValidator::Simple

=head1 SYNOPSIS

    use Catalyst qw/
      FormValidator::Simple
      FormValidator::Simple::Auto
      /;
    
    __PACKAGE__->config(
        validator => {
            messages => 'messages.yml',
            profiles => 'profiles.yml',
            # and other FormValidator::Simple config
        },
    );
    
    
    # profiles.yml
    action1:
      param1:
        - NOT_BLANK
        - ASCII
        - [ 'LENGTH', 4, 10 ]
      param2:
        - NOT_BLANK
    
    
    # then your action
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

=head1 EXTENDED METHODS

=head2 setup

=cut

sub setup {
    my $c = shift;

    Catalyst::Exception->throw( message =>
          __PACKAGE__ . qq/: You need to load "Catalyst::Plugin::FormValidator::Simple"/ )
      unless $c->isa('Catalyst::Plugin::FormValidator::Simple');

    Catalyst::Exception->throw(
        message => __PACKAGE__ . qq/: You must set validator profiles/ )
      unless $c->config->{validator}->{profiles};

    if ( ref $c->config->{validator}->{profiles} ne 'HASH' ) {
        my $profiles = eval {
            YAML::LoadFile( $c->path_to( $c->config->{validator}->{profiles} ) );
        };
        Catalyst::Exception->throw( message => __PACKAGE__ . qq/: $@/ ) if $@;

        $c->config->{validator}->{profiles} = $profiles;
    }

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

    if ( my $profile = $c->config->{validator}{profiles}{ $c->action->name } ) {
        $c->form(%$profile);
    }

    $c
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
