package WWW::Salesforce::LeadConvertResult;
use 5.008001;
use Moose; #turns on strict and warnings

use WWW::Salesforce::Error;
extends 'WWW::Salesforce::SObject';

use Carp qw(croak carp confess);

use vars qw( $VERSION );
$VERSION = '0.001'; # note: should be x.xxx (three decimal places)

has 'leadId' => ( is => 'rw', isa => 'SF::ID', default => undef, );
has 'accountId' => ( is => 'rw', isa => 'SF::ID', default => undef, );
has 'contactId' => ( is => 'rw', isa => 'SF::ID', default => undef, );
has 'opportunityId' => ( is => 'rw', isa => 'SF::ID', default => undef, );
has 'success' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'errors' => (
    is => 'rw',
    isa => 'SF::ErrorArray',
    default => sub { [WWW::Salesforce::Error->new(),] },
    auto_deref => 1,
    coerce => 1,
);


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=pod

=head1 NAME

WWW::Salesforce::LeadConvertResult - A class to hold the return values of the L<WWW::Salesforce/convertLead> method

=head1 DESCRIPTION

WWW::Salesforce::LeadConvertResult is a subclass of L<WWW::Salesforce::SObject|WWW::Salesforce::SObject>. This is one of the complex types Salesforce returns from a method call.

=head1 SYNOPSIS

 use WWW::Salesforce;
 use WWW::Salesforce::LeadConvert;
 my $sforce = WWW::Salesforce->new();
 my $uinfo = $sforce->login( 'USER','PASS' ) or die $sforce->errstr;

 my $lc = WWW::Salesforce::LeadConvert->new(
    leadId => '0FQ30000009gBn8',
    convertedStatus => 'Closed - Converted',
 );

 my @lcrs = $sforce->convertLead( $lc, $lc, $lc, $lc ) or die $sforce->errstr();

 #loop through the LeadConvertResults
 for my $lcr ( @lcrs ) {
    print "convertLead for ", ($lcr->leadId()?$lcr->leadId():"invalid id"), " ";
    if ( $lcr->success() ) {
        print "passed!\n";
    }
    else {
        print "FAILED!\n";
        for my $err ( @{$lcr->errors()} ) {
            print $err->statusCode(), " ";
            print $err->message(), "\nOn Fields: ";
            print join ', ', @{$err->fields()};
        }
        print "\n";
    }
 }

=head1 METHODS

=over 4

=item new HASH

X<new>
Creates a new WWW::Salesforce::LeadConvertResult object.  You shouldn't ever have to create this object on your own.

 my $lc = WWW::Salesforce::LeadConvertResult->new();

The following are the accepted input parameters:

=over 4

=item leadId

REQUIRED - IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item opportunityId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item accountId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item contactId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item errors

String of errors

=item success

Boolean (1) true, (0) false

=back


=item leadId  ID

=item leadId

X<leadId>
ID of the converted lead. IDs are valid if they pass ^[a-zA-Z0-9]{15,18}$

 $lc->leadId( 'D0000123anc00000CF' );
 print $lc->leadId();

=item opportunityId ID

=item opportunityId

X<opportunityId>
ID of the new Opportunity, if one was created when L<WWW::Salesforce/convertLead> was invoked.  IDs are valid if they pass ^[a-zA-Z0-9]{15,18}$

 $lc->opportunityId( 'D0000000anc00000CF' );
 print $lc->opportunityId();

=item accountId ID

=item accountId

X<accountId>
ID of the new Account (if a new account was specified) or the ID of the account specified when L<WWW::Salesforce/convertLead> was invoked. IDs are valid if they pass ^[a-zA-Z0-9]{15,18}$

 $lc->accountId( 'D0000002anc00000CF' );
 print $lc->accountId();

=item contactId ID

=item contactId

X<contactId>
ID of the new Contact (if a new contact was specified) or the ID of the contact specified when L<WWW::Salesforce/convertLead> was invoked. IDs are valid if they pass ^[a-zA-Z0-9]{15,18}$

 $lc->contactId( 'D0000002anc00000CF' );
 print $lc->contactId();

=item success BOOLEAN

=item success

X<success>
Indicates whether the L<WWW::Salesforce/convertLead> call succeeded (true - 1) or not (false - 0) for this object.

 $lc->success( 1 );
 print $lc->success();

=item errors STATUS

=item errors

X<errors>
If an error occurred during the create() call, an array of one or more Error objects providing the error code and description.

 Select Id, MasterLabel from LeadStatus where IsConverted=true

 $lc->convertedStatus( 'Some status value' );
 print $lc->convertedStatus();

=item doNotCreateOpportunity BOOLEAN

=item doNotCreateOpportunity

X<doNotCreateOpportunity>
Specifies whether to create an Opportunity during lead conversion (0, the default) or not (1). Set this flag to true (1) only if you do not want to create an opportunity from the lead. An opportunity is created by default.

 $lc->doNotCreateOpportunity( 1 );
 print $lc->doNotCreateOpportunity();

=item overwriteLeadSource BOOLEAN

=item overwriteLeadSource

X<overwriteLeadSource>
Specifies whether to overwrite the LeadSource field on the target Contact object with the contents of the LeadSource field in the source Lead object (1), or not (0, the default). To set this field to true (1), the client application must specify a contactId for the target contact.

 $lc->overwriteLeadSource( 1 );
 print $lc->overwriteLeadSource();

=item sendNotificationEmail  BOOLEAN

=item sendNotificationEmail

X<sendNotificationEmail>
Specifies whether to send a notification email to the owner specified in the ownerId (1) or not (0, the default).

 $lc->sendNotificationEmail( 1 );
 print $lc->sendNotificationEmail();

=back

=head1 SUPPORT

Please visit Salesforce.com's user/developer forums online for assistance with
this module. You are free to contact the author directly if you are unable to
resolve your issue online.

=head1 SEE ALSO

L<WWW::Salesforce> by Chase Whitener

L<DBD::Salesforce> by Jun Shimizu

L<SOAP::Lite> by Byrne Reese

Examples on Salesforce website:

L<http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_convertlead_leadconvertresult.htm>

L<http://www.salesforce.com/us/developer/docs/api/index.htm>

=head1 AUTHORS

Chase Whitener <cwhitener at gmail dot com>

=head1 COPYRIGHT

Copyright 2003-2004 Chase Whitener. All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
