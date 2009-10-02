use 5.008001;
use ExtUtils::MakeMaker;
exit 0 if $ENV{AUTOMATED_TESTING};

print <<END;
More tests will be added in the near future.  This is an experimental release 
that is _NOT_ ready for production quite yet.
END

WriteMakefile(
    NAME              => 'WWW::Salesforce',
    VERSION_FROM      => 'lib/WWW/Salesforce.pm', # finds $VERSION
    PREREQ_PM         => {
		'Moose'			=> 0.86,
		'Moose::Util::TypeConstraints' => 0.86,
        'Crypt::SSLeay' => 0.56,
        'SOAP::Lite'    => 0.68,
    }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM => 'lib/WWW/Salesforce.pm',
    AUTHOR => 'Chase Whitener <cwhitener@gmail.com>',
    LICENSE => 'perl',
);
