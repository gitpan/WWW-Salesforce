package WWW::Salesforce::Error;
use 5.008001;
use Moose; #turns on strict and warnings

extends 'WWW::Salesforce::SObject';

use Carp qw(croak carp confess);

use vars qw( $VERSION );
$VERSION = '0.001'; # note: should be x.xxx (three decimal places)

has 'statusCode' => ( is => 'rw', isa => 'Str', default => '' );
has 'message' => ( is => 'rw', isa => 'Str', default => '' );
has 'fields' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    auto_deref => 1,
    default => sub{[]},
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=pod

=head1 NAME

WWW::Salesforce::Error - An Error contains information about an error that occurred during a L<WWW::Salesforce/create>, L<WWW::Salesforce/merge>, L<WWW::Salesforce/process>, L<WWW::Salesforce/update>, L<WWW::Salesforce/upsert>, L<WWW::Salesforce/delete>, or L<WWW::Salesforce/undelete> call. For more information, see ,http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_concepts_errorhandling.htm#topic-title|Error Handling>.

=head1 DESCRIPTION

WWW::Salesforce::Error is a subclass of L<WWW::Salesforce::SObject|WWW::Salesforce::SObject>.

=head1 SYNOPSIS

 use WWW::Salesforce;
 use WWW::Salesforce::LeadConvert;
 my $sforce = WWW::Salesforce->new();
 $sforce->login( ... ) or die $sforce->errstr();
 
 #try to delete something and get an error
 my @res = $sforce->delete( '001x00000000JerAAE' );

 # $res is now a DeleteResult array
 for my $id ( @res ) {
     if ( $id->success() ) {
         print "Yay, deleted id ", $id->id();
     }
     else {
         print "Boo.  Error deleting ", $id->id(), "\n";
         for my $err ( @{$id->errors()} ) {
            print $err->statusCode(), " ";
            print $err->message(), "\nOn Fields: ";
            print join ', ', @{$err->fields()};
         }
     }
 }

=head1 METHODS

=over 4

=item new HASH

X<new>
Creates a new WWW::Salesforce::Error object.  You shouldn't ever have to create this object on your own.

 my $lc = WWW::Salesforce::Error->new();

The following are the accepted input parameters:

=over 4

=item statusCode

Status codes are listed below.

=item message

String message describing the error

=item fields

An array of strings for the fields affected

=back


=item statusCode  code

=item statusCode

X<statusCode>
Code of the error

=over 4

=item ALREADY_IN_PROCESS

You cannot submit a record that is already in an approval process. You must wait for the previous approval process to complete before resubmitting a request with this record.

=item ASSIGNEE_TYPE_REQUIRED

You must designate an assignee for any workflow task (ProcessInstance, ProcessInstanceStep, or ProcessInstanceWorkitem).

=item BAD_CUSTOM_ENTITY_PARENT_DOMAIN

The changes you are trying to make cannot be completed because changes to the associated master-detail relationships cannot be made.

=item BCC_NOT_ALLOWED_IF_BCC_COMPLIANCE_ENABLED

Your client applicationblind carbon-copied an email address on an email even though the organization's Compliance BCC Email option is enabled. This option specifies a particular email address that automatically receives a copy of all outgoing email. When this option is enabled, you cannot BCC any other email address. To disable the option, log in to the Salesforce.com app and select Setup | Security Controls | Compliance BCC Email. 

=item BCC_SELF_NOT_ALLOWED_IF_BCC_COMPLIANCE_ENABLED

Your client application blind carbon copied the logged-in user's email address on an email even though the organization's BCC COMPLIANCE option is set to true. This option specifies a particular email address that automatically receives a copy of all outgoing email. When this option is enabled, you cannot BCC any other email address. To disable the option, log in to the Salesforce.com app and select Setup | Security Controls | Compliance BCC Email. 

=item CANNOT_CASCADE_PRODUCT_ACTIVE

An update to a product caused by a cascade cannot be done because the associated product is active. 

=item CANNOT_CHANGE_FIELD_TYPE_OF_APEX_REFERENCED_FIELD

You cannot change the type of a field that is referenced in an Apex script. 

=item CANNOT_CREATE_ANOTHER_MANAGED_PACKAGE

You can only create one managed package in an organization. 

=item CANNOT_DEACTIVATE_DIVISION

You cannot deactivate Divisions if an assignment rule references divisions or if a user's DefaultDivision field is not set to null. 

=item CANNOT_DELETE_LAST_DATED_CONVERSION_RATE

You must have at least one DatedConversionRate record if dated conversions are enabled.

=item CANNOT_DELETE_MANAGED_OBJECT

You cannot modify components that are included in a managed package. 

=item CANNOT_DISABLE_LAST_ADMIN

You must have at least one active administrator user. 

=item CANNOT_ENABLE_IP_RESTRICT_REQUESTS

If you exceed the limit of five IP ranges specified in a profile, you cannot enable restriction of login by IP addresses. Reduce the number of specified ranges in the profile and try the request again.

=item CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY

You do not have permission to create, update, or activate the specified record. 

=item CANNOT_MODIFY_MANAGED_OBJECT

You cannot modify components that are included in a managed package. 

=item CANNOT_RENAME_APEX_REFERENCED_FIELD

You cannot rename a field that is referenced in an Apex script. 

=item CANNOT_RENAME_APEX_REFERENCED_OBJECT

You cannot rename an object that is referenced in an Apex script. 

=item CANNOT_REPARENT_RECORD

You cannot define a new parent record for the specified record. 

=item CANNOT_RESOLVE_NAME

A sendEmail() call could not resolve an object name. 

=item CANNOT_UPDATE_CONVERTED_LEAD

A converted lead could not be updated. 

=item CANT_DISABLE_CORP_CURRENCY

You cannot disable the corporate currency for an organization. To disable a currency that is set as the corporate currency, first use the Salesforce.com user interface to change the corporate currency to a different currency, and then disable the original currency. 

=item CANT_UNSET_CORP_CURRENCY

You cannot change the corporate currency for an organization from the API. Use the Salesforce.com user interface to change the corporate currency. 

=item CHILD_SHARE_FAILS_PARENT

You cannot change the owner of or define sharing rules for a record that is a child of another record if you do not also have the appropriate permissions on the parent. For example, you cannot change the owner of a a contact record if you cannot edit its parent account record.

=item CIRCULAR_DEPENDENCY

You cannot create a circular dependency between metadata objects in your organization. For example, public group A cannot include public group B, if public group B already includes public group A. 

=item COMMUNITY_NOT_ACCESSIBLE

You do not have permission to access the community that this entity belongs to. You must be given permission to access the community before you can access this entity.

=item CUSTOM_CLOB_FIELD_LIMIT_EXCEEDED

You cannot exceed the maximum size for a CLOB field. 

=item CUSTOM_ENTITY_OR_FIELD_LIMIT

You have reached the maximum number of custom objects or custom fields for your organization. 

=item CUSTOM_FIELD_INDEX_LIMIT_EXCEEDED

You have reached the maximum number of indexes on a field for your organization. 

=item CUSTOM_INDEX_EXISTS

You can create only one custom index per field. 

=item CUSTOM_LINK_LIMIT_EXCEEDED

You have reached the maximum number of custom links for your organization. 

=item CUSTOM_TAB_LIMIT_EXCEEDED

You have reached the maximum number of custom tabs for your organization. 

=item DELETE_FAILED

You cannot delete a record because it is in use by another object. 

=item DEPENDENCY_EXISTS

You cannot perform the requested operation because of an existing dependency on the specified object or field. 

=item DUPLICATE_CASE_SOLUTION

You cannot create a relationship between the specified case and solution because it already exists. 

=item DUPLICATE_CUSTOM_ENTITY_DEFINITION

Custom object or custom field IDs must be unique. 

=item DUPLICATE_CUSTOM_TAB_MOTIF

You cannot create a custom object or custom field with a duplicate master name. 

=item DUPLICATE_DEVELOPER_NAME

You cannot create a custom object or custom field with a duplicate developer name. 

=item DUPLICATE_EXTERNAL_ID

A user-specified external ID matches more than one record in Salesforce.com during an upsert() call. 

=item DUPLICATE_MASTER_LABEL

You cannot create a custom object or custom field with a duplicate master name. 

=item DUPLICATE_SENDER_DISPLAY_NAME

A sendEmail() call could not choose between OrgWideEmailAddress.DisplayName or senderDisplayName. Define only one of the two fields. 

=item DUPLICATE_USERNAME

A create(), update(), or upsert() call failed because of a duplicate user name.

=item DUPLICATE_VALUE

You cannot supply a duplicate value for a field that must be unique. For example, you may have submitted two copies of the same sessionId in a invalidateSessions() call. 

=item EMAIL_NOT_PROCESSED_DUE_TO_PRIOR_ERROR

Because of an error earlier in the call, the current email was not processed. 

=item EMPTY_SCONTROL_FILE_NAME

The Scontrol file name was empty, but the binary was nonempty. 

=item ENTITY_FAILED_IFLASTMODIFIED_ON_UPDATE

You cannot update a record if the date inLastModifiedDate is later than the current date.

=item ENTITY_IS_ARCHIVED

You cannot access a record if it has been archived. 

=item ENTITY_IS_DELETED

You cannot reference an object that has been deleted. Note that this status code only occurs in version 10.0 of the API and later. Previous releases of the API use INVALID_ID_FIELD for this error. 

=item ENTITY_IS_LOCKED

You cannot edit a locked object during a workflow processing operation. 

=item ERROR_IN_MAILER

An email address is invalid, or another error occurred during an email-related transaction. 

=item FAILED_ACTIVATION

The activation of a Contract failed.

=item FIELD_CUSTOM_VALIDATION_EXCEPTION

You cannot define a custom validation formula that violates a field integrity rule. 

=item FIELD_INTEGRITY_EXCEPTION

You cannot violate field integrity rules. 

=item FILTERED_LOOKUP_LIMIT_EXCEEDED

The creation of the lookup filter failed because it exceeds the maximum number of lookup filters allowed per object. 

=item HTML_FILE_UPLOAD_NOT_ALLOWED

Your attempt to upload an HTML file failed. HTML attachments and documents, including HTML attachments to a Solution, cannot be uploaded if the Disallow HTML documents and attachments checkbox is selected in Setup | Security Controls | HTML Documents and Attachments Settings.

=item IMAGE_TOO_LARGE

The image exceeds the maximum width, height, and file size. 

=item INACTIVE_OWNER_OR_USER

The owner of the specified item is an inactive user. To reference this item, either reactivate the owner or reassign ownership to another active user. 

=item INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY

An operation affects an object that is cross-referenced by the specified object, but the logged-in user does not have sufficient permissions on the cross-referenced object. For example, if the logged in user attempts to modify an account record, that user might not have permission to approve, reject, or reassign a ProcessInstanceWorkitem that is submitted after that action. 

=item INSUFFICIENT_ACCESS_OR_READONLY

You cannot perform the specified action because you do not have sufficient permissions. 

=item INVALID_ACCESS_LEVEL

You cannot define a new sharing rule if it provides less access than the specified organization-wide default. 

=item INVALID_ARGUMENT_TYPE

You supplied an argument that is of the wrong type for the operation being attempted. 

=item INVALID_ASSIGNEE_TYPE

You specified an assignee type that is not a valid integer between one and six. 

=item INVALID_ASSIGNMENT_RULE

You specified an assignment rule that is invalid or that is not defined in the organization. 

=item INVALID_BATCH_OPERATION

The specified batch operation is invalid. 

=item INVALID_CONTENT_TYPE

The outgoing email's EmailFileAttachmentcontentType property is invalid. See RFC2045 - Internet Message Format.

=item INVALID_CREDIT_CARD_INFO

The specified credit card information is not valid.

=item INVALID_CROSS_REFERENCE_KEY

The specified value in a relationship field is not valid, or data is not of the expected type.

=item INVALID_CROSS_REFERENCE_TYPE_FOR_FIELD

The specified cross reference type is not valid for the specified field. 

=item INVALID_CURRENCY_CONV_RATE

You must specify a positive, non-zero value for the currency conversion rate. 


=item INVALID_CURRENCY_CORP_RATE

You cannot modify the corporate currency conversion rate. 

=item INVALID_CURRENCY_ISO

The specified currency ISO code is not valid. For more information, see IsoCode.

=item INVALID_EMAIL_ADDRESS

A specified email address is invalid. 

=item INVALID_EMPTY_KEY_OWNER

You cannot set the value for owner to null. 

=item INVALID_FIELD

You specified an invalid field name in an update() or upsert() call. 

=item INVALID_FIELD_FOR_INSERT_UPDATE

You cannot comobine a person account record type change with any other field update. 

=item INVALID_FIELD_WHEN_USING_TEMPLATE

You cannot use an email template with an invalid field name. 

=item INVALID_FILTER_ACTION

The specified filter action cannot be used with the specified object. For example, an alert is not a valid filter action for a Task. 

=item INVALID_ID_FIELD

The specified ID field (ID, ownerId), or cross-reference field is invalid. 

=item INVALID_INET_ADDRESS

A specified Inet address is not valid. 

=item INVALID_LINEITEM_CLONE_STATE

You cannot clone a Pricebook2 or PricebookEntry record if those objects are not active. 

=item INVALID_MASTER_OR_TRANSLATED_SOLUTION

The solution is invalid. For example, this error can occur if you try to associate a translated solution with a master solution when another translated solution in the same language is already associated with the master solution. 

=item INVALID_MESSAGE_ID_REFERENCE

The outgoing email's References or In-Reply-To fields are invalid. These fields must contain valid Message-IDs. See RFC2822 - Internet Message Format.

=item INVALID_OPERATION

There is no applicable approval process for the specified object. 

=item INVALID_OPERATOR

The specified operator is not applicable for the field type when used as a workflow filter. 

=item INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST

You specified an invalid or null value for a restricted picklist. 

=item INVALID_PARTNER_NETWORK_STATUS

The specified partner network status is invalid for the specified template field. 

=item INVALID_PERSON_ACCOUNT_OPERATION

You cannot delete a person account.

=item INVALID_SAVE_AS_ACTIVITY_FLAG

You must specify true or false for the Save_as_Activity flag. 

=item INVALID_SESSION_ID

The specified sessionId is malformed (incorrect length or format) or has expired. Log in again to start a new session. 

=item INVALID_STATUS

The specified organization status change is not valid. 

=item INVALID_TYPE

The specified type is not valid for the specified object. 

=item INVALID_TYPE_FOR_OPERATION

The specified type is not valid for the specified operation. 

=item INVALID_TYPE_ON_FIELD_IN_RECORD

The specified value is not valid for the specified field's type. 

=item IP_RANGE_LIMIT_EXCEEDED

The specified IP address is outside the IP range specified for the organization. 

=item LICENSE_LIMIT_EXCEEDED

You have exceeded the number of licenses assigned to your organization. 

=item LIGHT_PORTAL_USER_EXCEPTION

You attempted an action with a high-volume Customer Portal user that's not allowed. For example, trying to add the user to a case team. 

=item LIMIT_EXCEEDED

You have exceeded a limit. The limit may be on a field size or value, license, or other component. 

=item LOGIN_CHALLENGE_ISSUED

An email containing a security token was sent to the user's email address because he or she logged in from an IP address that is not included in their organization's list of trusted IP addresses. The user cannot log in until he or she adds the security token to the end of his or her password. 

=item LOGIN_CHALLENGE_PENDING

The user logged in from an IP address that is not included in their organization's list of trusted IP addresses, but a security token has not yet been issued. 

=item LOGIN_MUST_USE_SECURITY_TOKEN

The user must add a security token to the end of his or her password to log in. 

=item MALFORMED_ID

An ID must be either 15 characters, or 18 characters with a valid case-insensitive extension. There is also an exception code of the same name. 

=item MANAGER_NOT_DEFINED

A manager has not been defined for the specified approval process. 

=item MASSMAIL_RETRY_LIMIT_EXCEEDED

A mass mail retry failed because your organization has exceeded its mass mail retry limit. 

=item MASS_MAIL_LIMIT_EXCEEDED

The organization has exceeded its daily limit for mass email. Mass email messages cannot be sent again until the next day. 

=item MAXIMUM_CCEMAILS_EXCEEDED

You have exceeded the maximum number of specified CC addresses in a workflow alert. 

=item MAXIMUM_DASHBOARD_COMPONENTS_EXCEEDED

You have exceeded the document size limit for a dashboard. 

=item MAXIMUM_HIERARCHY_LEVELS_REACHED

You have reached the maximum number of levels in a hierarchy. 

=item MAXIMUM_SIZE_OF_ATTACHMENT

You have exceeded the maximum size of an attachment. 

=item MAXIMUM_SIZE_OF_DOCUMENT

You have exceeded the maximum size of a document. 

=item MAX_ACTIONS_PER_RULE_EXCEEDED

You have exceeded the maximum number of actions per rule. 

=item MAX_ACTIVE_RULES_EXCEEDED

You have exceeded the maximum number of active rules. 

=item MAX_APPROVAL_STEPS_EXCEEDED

You have exceeded the maximum number of approval steps for an approval process. 

=item MAX_FORMULAS_PER_RULE_EXCEEDED

You have exceeded the maximum number of formulas per rule. 

=item MAX_RULES_EXCEEDED

You have exceeded the maximum number of rules for an object. 

=item MAX_RULE_ENTRIES_EXCEEDED

You have exceeded the maximum number of entries for a rule. 

=item MAX_TASK_DESCRIPTION_EXCEEDED

The task description is too long. 

=item MAX_TM_RULES_EXCEEDED

You have exceeded the maximum number of rules per Territory. 

=item MAX_TM_RULE_ITEMS_EXCEEDED

You have exceeded the maximum number of rule criteria per rule for a Territory. 

=item MERGE_FAILED

A merge operation failed. 

=item MISSING_ARGUMENT

You did not specify a required argument. 

=item NONUNIQUE_SHIPPING_ADDRESS

You cannot insert a reduction order item if the original order shipping address is different from the shipping address of other items in the reduction order. 

=item NO_APPLICABLE_PROCESS

A process() request failed because the record submitted does not satisfy the entry criteria of any workflow process for which the user has permission. 

=item NO_ATTACHMENT_PERMISSION

Your organization does not permit email attachments. 

=item NO_INACTIVE_DIVISION_MEMBERS

You cannot add members to an inactive Division. 

=item NO_MASS_MAIL_PERMISSION

You do not have permission to send the specified email. You must have “Mass Email” if you are sending mass mail or “Send Email” if you are sending individual email. 

=item NUMBER_OUTSIDE_VALID_RANGE

The number specified is outside the valid range of values. 

=item NUM_HISTORY_FIELDS_BY_SOBJECT_EXCEEDED

The number of history fields specified for the sObject exceeds the allowed limit. 

=item OPTED_OUT_OF_MASS_MAIL

An email cannot be sent because the specified User has opted out of mass mail. 

=item PACKAGE_LICENSE_REQUIRED

The logged-in user cannot access an object that is in a licensed package if the logged-in user does not have a license for the package. 

=item PORTAL_USER_ALREADY_EXISTS_FOR_CONTACT

A create()User operation failed because you cannot create a second portal user under a Contact. 

=item PRIVATE_CONTACT_ON_ASSET

You cannot have a private contact on an asset. 

=item RECORD_IN_USE_BY_WORKFLOW

You cannot access a record if it is currently in use by a workflow process. 

=item REQUEST_RUNNING_TOO_
LONG

A request that has been running too long may be cancelled.

=item REQUIRED_FIELD_MISSING

A call requires a field that was not specified. 

=item SELF_REFERENCE_FROM_TRIGGER

You cannot recursively update or delete the same object from an Apex trigger. This error often occurs when:

* You try to update or delete an object from within its before trigger.
* You try to delete an object from within its after trigger.

This error occurs with both direct and indirect operations. The following is an example of an indirect operation:

1. A request is submitted to update Object A.
2. A before update trigger on object A creates an object B.
3. Object A is updated.
4. An after insert trigger on object B queries object A and updates it. This is an indirect update of object A because of the before trigger of object A, so an error is generated.

=item SHARE_NEEDED_FOR_CHILD_OWNER

You cannot delete a sharing rule for a parent record if its child record needs it. 

=item STANDARD_PRICE_NOT_DEFINED

Custom prices cannot be defined without corresponding standard prices. 

=item STORAGE_LIMIT_EXCEEDED

You have exceeded your organization's storage limit. 

=item STRING_TOO_LONG

The specified string exceeds the maximum allowed length. 

=item TABSET_LIMIT_EXCEEDED

You have exceeded the number of tabs allowed for a tabset.

=item TEMPLATE_NOT_ACTIVE

The template specified is unavailable. Specify another template or make the template available for use. 

=item TERRITORY_REALIGN_IN_PROGRESS

An operation cannot be performed because a territory realignment is in progress. 

=item TEXT_DATA_OUTSIDE_SUPPORTED_CHARSET

The specified text uses a character set that is not supported. 

=item TOO_MANY_APEX_REQUESTS

Too many Apex requests have been sent to Salesforce.com. This error is transient. Resend your request after a short wait. 

=item TOO_MANY_ENUM_VALUE

A request failed because too many values were passed in for a multi-select picklist. You can select a maximum of 100 values for a multi-select picklist. 

=item TRANSFER_REQUIRES_READ

You cannot assign the record to the specified User because the user does not have read permission. 

=item UNABLE_TO_LOCK_ROW

A deadlock or timeout condition has been detected:

* Deadlocks involve at least two transactions that are attempting to update overlapping sets of objects. Note that if the transaction involves a summary field, the parent objects are locked, making these transactions especially prone to deadlocks. To debug, check your code for deadlocks and correct. Deadlocks are usually not the result of an issue with Salesforce.com operations.
* Timeouts occur when a transaction takes too long to complete, for example, when replacing a value in a picklist, or changing a custom field definition. These are temporary states. There is no corrective action needed.

If an object in a batch cannot be locked, the entire batch fails with this error. 

=item UNAVAILABLE_RECORDTYPE_EXCEPTION

The appropriate default record type could not be found. 

=item UNDELETE_FAILED

An object could not be undeleted because it does not exist or has not been deleted. 

=item UNKNOWN_EXCEPTION

The system encountered an internal error. Please report this problem to salesforce.com.
*Note
Do not report this exception code to salesforce.com if it results from a sendEmail() call. The sendEmail() call returns this exception code when it is used to send an email to one or more recipients who have the Email Opt Out option selected.

=item UNSPECIFIED_EMAIL_ADDRESS

The specified user does not have an email address. 

=item UNSUPPORTED_APEX_TRIGGER_OPERATION

You cannot save recurring events with an Apex trigger. 

=item UNVERIFIED_SENDER_ADDRESS

A sendEmail() call attempted to use an unverified email address defined in the OrgWideEmailAddress object. 

=item WEBLINK_SIZE_LIMIT_EXCEEDED

The size of a WebLink URL or JavaScript code exceeds the limit. 

=item WRONG_CONTROLLER_TYPE

The controller type for your Visualforce email template does not match the object type being used.

=back

 $lc->statusCode( 'ALREADY_IN_PROCESS' );
 print $lc->statuscode();

=item message STRING

=item message

X<message>
Error message text

 $lc->message( 'This is an error message' );
 print $lc->message();

=item fields ARRAY

=item fields

X<fields>
Array of one or more field names. Identifies which fields in the object, if any, affected the error condition.

 $lc->fields( 'AccountId', 'OpportunityId' );
 print @{$lc->fields()};

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

L<http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_concepts_core_data_objects.htm#i1421521>

L<http://www.salesforce.com/us/developer/docs/api/index.htm>

=head1 AUTHORS

Chase Whitener <cwhitener at gmail dot com>

=head1 COPYRIGHT

Copyright 2003-2004 Chase Whitener. All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
