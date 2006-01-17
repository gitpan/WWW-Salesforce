use strict;
use warnings;
use Data::Dumper;
use Carp;

use WWW::Salesforce;


#test 1, connection!
print "test 1, new object/connection...\n   ";
my $sforce = WWW::Salesforce->new(
    username => 'chase.whitener@infotechfl.com',
    password => 'PaidFor',
);
print $sforce?1:0;
print "\n";

#test 2, get server time
print "test 2, time on server...\n   ";
my $res = $sforce->getServerTimestamp();
my $val = $res->valueof( '//getServerTimestampResponse/result/timestamp' );
print defined $val?1:0;
print "\n";

#test 3, get describeGlobal
print "test 3, describeGlobal...\n   ";
$res = $sforce->describeGlobal();
if ( !$res->fault() and defined $res->valueof('//describeGlobalResponse/result/types') ) {
    print 1;
}
else {
    print 0;
}
print "\n";

#test 4, query
print "test 4, query...\n   ";
$res = $sforce->query(
    'query' => 'select id, firstname, lastname from lead',
    'limit' => 5
);
if ( !$res->fault() and defined $res->valueof('//queryResponse/result/records') ) {
    print 1;
}
else {
    print 0;
}
print "\n";

#test 5, queryMore
print "test 5, queryMore...\n   ";
my $locator = $res->valueof('//queryResponse/result/queryLocator');
$res = $sforce->queryMore('queryLocator' => $locator,'limit' => 5);
if ( !$res->fault() and defined $res->valueof('//queryMoreResponse/result/records') ) {
    print 1;
}
else {
    print 0;
}
print "\n";

#test 6, getUserinfo
print "test 6, getUserInfo...\n   ";
$res = $sforce->getUserInfo();
if ( !$res->fault() and defined $res->valueof('//getUserInfoResponse/result') ) {
    print 1;
}
else {
    print 0;
}
print "\n";

#test 7, describeSObject
print "test 7, describeSObject...\n   ";
$res = $sforce->describeSObject( 'type' => 'Account' );
if ( !$res->fault() and defined $res->valueof('//describeSObjectResponse/result/fields') ) {
    print 1;
}
else {
    print 0;
}
print "\n";
