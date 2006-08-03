# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WWW-Salesforce.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use SOAP::Lite;
use vars qw($user $pass);
require 't/sfdc.cfg';

use Test::More tests => 9;

#test 1, can we find the module?
BEGIN { use_ok('WWW::Salesforce') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $res;

#test 2, new object/connection...
my $sforce = WWW::Salesforce->login( 'username' => $user,'password' => $pass );
if ( $sforce ) {
    ok(1);
}
else {
    print "$!\n";
    ok(0);
}

#test 3, get server time
$res = $sforce->getServerTimestamp();
if ( $res ) {
    ok(1);
}
else {
    print "$!\n";
    ok(0);
}

#test 4, get describeGlobal
$res = $sforce->describeGlobal();
if ( $res ) {
    ok(1);
}
else {
    print "$!\n";
    ok(0);
}

#test 5, query
$res = $sforce->query(
    'query' => 'select id, firstname, lastname from lead',
    'limit' => 5
);
if ( $res ) {
    ok(1);
}
else {
    print "$!\n";
    ok(0);
}

#test 6, queryMore
my $locator = $res->valueof('//queryResponse/result/queryLocator');
$res = $sforce->queryMore('queryLocator' => $locator,'limit' => 5);
if ( $res ) {
    ok(1);
}
else {
    print "$!\n";
    ok(0);
}

#test 7, getUserinfo
$res = $sforce->getUserInfo();
if ( $res ) {
    ok(1);
}
else {
    print "$!\n";
    ok(0);
}

#test 8, describeSObject
$res = $sforce->describeSObject( 'type' => 'Account' );
if ( $res ) {
    ok(1);
}
else {
    print "$!\n";
    ok(0);
}

#test 9, describeLayout
$res = $sforce->describeLayout( 'type' => 'Account' );
if ( $res ) {
    ok(1);
}
else {
    print "$!\n";
    ok(0);
}
