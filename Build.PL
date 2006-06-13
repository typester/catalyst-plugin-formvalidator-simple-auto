use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name => 'Catalyst::Plugin::FormValidator::Simple::Auto',
    license     => 'perl',
    requires    => {
        'Catalyst'                                => '5.30',
        'Catalyst::Plugin::FormValidator::Simple' => 0,
        'UNIVERSAL::isa'                          => 0,
        'YAML'                                    => 0,
    },
)->create_build_script;
