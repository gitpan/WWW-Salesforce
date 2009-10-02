package WWW::Salesforce::LeadConvert;
use 5.008001;
use Moose; #turns on strict and warnings

extends 'WWW::Salesforce::SObject';

use Carp qw(croak carp confess);

use vars qw( $VERSION );
$VERSION = '0.001'; # note: should be x.xxx (three decimal places)

has 'leadId' => ( is => 'rw', isa => 'SF::ID', required => 1 );
has 'accountId' => ( is => 'rw', isa => 'SF::ID' );
has 'contactId' => ( is => 'rw', isa => 'SF::ID' );
has 'ownerId' => ( is => 'rw', isa => 'SF::ID' );
has 'doNotCreateOpportunity' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'overwriteLeadSource' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'sendNotificationEmail' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'convertedStatus' => ( is => 'rw', isa => 'Str', required => 1 );
has 'opportunityName' => ( is => 'rw', isa => 'Str', default => '' );

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=pod

=head1 NAME

WWW::Salesforce::LeadConvert - A class to help with the L<WWW::Salesforce/convertLead> method

=head1 DESCRIPTION

WWW::Salesforce::LeadConvert is a subclass of L<WWW::Salesforce::SObject|WWW::Salesforce::SObject>. This is one of the complex types Salesforce requires for a method call.

=head1 SYNOPSIS

 use WWW::Salesforce;
 use WWW::Salesforce::LeadConvert;
 my $sforce = WWW::Salesforce->new();
 my $lc = WWW::Salesforce::LeadConvert->new(
    leadId => 'D0000123anc00000CF',  #required
    convertedStatus => 'Closed - Converted', #required
    #optional
    accountId => '',
    contactId => '',
    ownerId => '',
    opportunityName => ''
    doNotCreateOpportunity => 0,
    overwriteLeadSource => 0,
    sendNotificationEmail => 0,
 );
 #pass a list of LeadConverts to convertLead()
 my $lcr = $sforce->convertLead( $lc );

=head1 METHODS

=over 4

=item new HASH

X<new>
Creates a new WWW::Salesforce::LeadConvert object.

 my $lc = WWW::Salesforce::LeadConvert->new(
    leadId => 'D0000123anc00000CF',  #required
 );

The following are the accepted input parameters:

=over 4

=item leadId

REQUIRED - IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item convertedStatus

REQUIRED - String status.  See more details in the L<convertedStatus> method below.

=item ownerId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item accountId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item contactId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item opportunityName

String name

=item doNotCreateOpportunity

Boolean defaulted to false (0).  1 is true

=item overwriteLeadSource

Boolean defaulted to false (0).  1 is true

=item sendNotificationEmail

Boolean defaulted to false (0).  1 is true

=back


=item leadId  ID

=item leadId

X<leadId>
ID of the Lead to convert. IDs are valid if they pass ^[a-zA-Z0-9]{15,18}$

 $lc->leadId( 'D0000123anc00000CF' );
 print $lc->leadId();

=item ownerId ID

=item ownerId

X<ownerId>
Specifies the ID of the person to own any newly created account, contact, and opportunity. If the client application does not specify this value, then the owner of the new object will be the owner of the lead. Not applicable when merging with existing objects—if an ownerId is specified, the API does not overwrite the ownerId field in an existing account or contact. IDs are valid if they pass ^[a-zA-Z0-9]{15,18}$

 $lc->ownerId( 'D0000000anc00000CF' );
 print $lc->ownerId();

=item accountId ID

=item accountId

X<accountId>
ID of the Account into which the lead will be merged. Required only when updating an existing account, including person accounts. If no accountID is specified, then the API creates a new account. To create a new account, the client application must be logged in with sufficient access rights. To merge a lead into an existing account, the client application must be logged in with read/write access to the specified account. The account name and other existing data are not overwritten. IDs are valid if they pass ^[a-zA-Z0-9]{15,18}$

 $lc->accountId( 'D0000002anc00000CF' );
 print $lc->accountId();

=item contactId ID

=item contactId

X<contactId>
ID of the Contact into which the lead will be merged (this contact must be associated with the specified accountId, and an accountId must be specified). Required only when updating an existing contact. B<Important!> If you are converting a lead into a person account, do not specify the contactId or an error will result. Specify only the accountId of the person account. If no contactID is specified, then the API creates a new contact that is implicitly associated with the Account. To create a new contact, the client application must be logged in with sufficient access rights. To merge a lead into an existing contact, the client application must be logged in with read/write access to the specified contact. The contact name and other existing data are not overwritten (unless overwriteLeadSource is set to true, in which case only the LeadSource field is overwritten). IDs are valid if they pass ^[a-zA-Z0-9]{15,18}$

 $lc->contactId( 'D0000002anc00000CF' );
 print $lc->contactId();

=item opportunityName NAME

=item opportunityName

X<opportunityName>
Name of the opportunity to create. If no name is specified, then this value defaults to the company name of the lead. The maximum length of this field is 80 characters. If doNotCreateOpportunity argument is true, then no Opportunity is created and this field must be left blank; otherwise, an error is returned.

 $lc->opportunityName( 'Some opportunity name' );
 print $lc->opportunityName();

=item convertedStatus STATUS

=item convertedStatus

X<convertedStatus>
Valid LeadStatus value for a converted lead. Required. To obtain the list of possible values, the client application queries the LeadStatus object, as in:

 Select Id, MasterLabel from LeadStatus where IsConverted=true

A valid MasterLabel from that query should be used below:

 $lc->convertedStatus( 'Closed - Converted' );
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

L<http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_convertlead.htm#d1437e268>

L<http://www.salesforce.com/us/developer/docs/api/index.htm>

=head1 AUTHORS

Chase Whitener <cwhitener at gmail dot com>

=head1 COPYRIGHT

Copyright 2003-2004 Chase Whitener. All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
