# Note: this file was auto-generated by Module::Build::Compat version 0.03
use ExtUtils::MakeMaker;
WriteMakefile
(
    NAME => 'Tie::RegexpHash',
    VERSION_FROM => 'lib/Tie/RegexpHash.pm',
    PREREQ_PM => {
        'Carp' => '0',
    },
    TEST_REQUIRES => {
        'Test::More' => '0'
    },
    INSTALLDIRS => 'site',
    EXE_FILES => [],
    PL_FILES => {},
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                url => 'git://github.com/Altreus/Tie-RegexpHash',
                web => 'https://github.com/Altreus/Tie-RegexpHash',
                type => 'git',
            },
        },
    },
)
;
