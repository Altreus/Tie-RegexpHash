use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Tie::RegexpHash',
    'VERSION_FROM'	=> 'RegexpHash.pm', # finds $VERSION
    'PREREQ_PM'		=> {
      'warnings::register' => 0,
      'Carp'               => 0,
    },
);
