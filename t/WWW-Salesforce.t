# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WWW-Salesforce.t'
#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use strict;
use warnings;
use SOAP::Lite;
use Test::More tests => 2;

#test -- can we find the module?
BEGIN { use_ok( 'WWW::Salesforce' ) };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

#test -- new object/connection...
my $sforce = WWW::Salesforce->new();
ok( $sforce, "New object creation test" );
