# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WWW-Salesforce.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use SOAP::Lite;
use vars qw($user $pass);
require 't/sfdc.cfg';

use Test::More tests => 8;

#test 1, can we find the module?
BEGIN { use_ok('WWW::Salesforce') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $res;


#test 2, new object/connection...
my $sforce = WWW::Salesforce->new( 'username' => $user,'password' => $pass );
ok( ($sforce)? 1 : 0 );


#test 3, get server time
$res = $sforce->getServerTimestamp();
my $val = $res->valueof( '//getServerTimestampResponse/result/timestamp' );
ok( (defined $val)? 1 : 0 );

#test 4, get describeGlobal
$res = $sforce->describeGlobal();
if ( !$res->fault() and defined $res->valueof('//describeGlobalResponse/result/types') ) {
    ok(1);
}
else {
    ok(0);
}

#test 5, query
$res = $sforce->query(
    'query' => 'select id, firstname, lastname from lead',
    'limit' => 5
);
if ( !$res->fault() and defined $res->valueof('//queryResponse/result/records') ) {
    ok(1);
}
else {
    ok(0);
}

#test 6, queryMore
my $locator = $res->valueof('//queryResponse/result/queryLocator');
$res = $sforce->queryMore('queryLocator' => $locator,'limit' => 5);
if ( !$res->fault() and defined $res->valueof('//queryMoreResponse/result/records') ) {
    ok(1);
}
else {
    ok(0);
}

#test 7, getUserinfo
$res = $sforce->getUserInfo();
if ( !$res->fault() and defined $res->valueof('//getUserInfoResponse/result') ) {
    ok(1);
}
else {
    ok(0);
}

#test 8, describeSObject
$res = $sforce->describeSObject( 'type' => 'Account' );
if ( !$res->fault() and defined $res->valueof('//describeSObjectResponse/result/fields') ) {
    ok(1);
}
else {
    ok(0);
}
