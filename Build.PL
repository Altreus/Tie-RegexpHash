use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'Tie::RegexpHash',
     license => 'perl',
     requires => {
       'perl'                       => '5.005',
       'Carp'                       => 0,
     },
     recommends => {
     },
     build_requires => {
       'Test'                       => 0,
     },
     create_makefile_pl => 'traditional',
     dist_author        => 'Robert Rothenberg <rrwo at cpan.org>',
     sign => 1,
);

$build->create_build_script;
