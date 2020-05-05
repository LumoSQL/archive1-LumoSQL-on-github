use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Notfork',
    VERSION       => '0.0',
    PMLIBDIRS     => [ 'lib' ],
    EXE_FILES     => [ 'bin/not-fork' ],
);

