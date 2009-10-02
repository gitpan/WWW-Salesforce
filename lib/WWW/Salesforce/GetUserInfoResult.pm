package WWW::Salesforce::GetUserInfoResult;
use 5.008001;
use Moose; #turns on strict and warnings

extends 'WWW::Salesforce::SObject';

use Carp qw(croak carp confess);

use vars qw( $VERSION );
$VERSION = '0.001'; # note: should be x.xxx (three decimal places)

has 'accessibilityMode' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'currencySymbol' => ( is => 'rw', isa => 'Str', default => '' );
has 'userType' => ( is => 'rw', isa => 'Str', default => '' );
has 'profileId' => ( is => 'rw', isa => 'SF::ID' );
has 'organizationId' => ( is => 'rw', isa => 'Str', default => '' );
has 'organizationMultiCurrency' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'organizationName' => ( is => 'rw', isa => 'Str', default => '' );
has 'roleId' => ( is => 'rw', isa => 'SF::ID' );
has 'userDefaultCurrencyIsoCode' => ( is => 'rw', isa => 'Str', default => '' );
has 'userEmail' => ( is => 'rw', isa => 'Str', default => '' );
has 'userFullName' => ( is => 'rw', isa => 'Str', default => '' );
has 'userId' => ( is => 'rw', isa => 'SF::ID' );
has 'userLanguage' => ( is => 'rw', isa => 'Str', default => '' );
has 'userLocale' => ( is => 'rw', isa => 'Str', default => '' );
has 'userName' => ( is => 'rw', isa => 'Str', default => '' );
has 'userTimeZone' => ( is => 'rw', isa => 'Str', default => '' );
has 'userUiSkin' => ( is => 'rw', isa => 'Str', default => '' );

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=pod

=head1 NAME

WWW::Salesforce::GetUserInfoResult - A class to help with the L<WWW::Salesforce/GetUserInfo> method

=head1 DESCRIPTION

WWW::Salesforce::GetUserInfoResult is a subclass of L<WWW::Salesforce::SObject|WWW::Salesforce::SObject>.  This is one of the complex types Salesforce returns from a method call.

=head1 SYNOPSIS

 use WWW::Salesforce;
 my $sforce = WWW::Salesforce->new();
 
 #the login method returns a WWW::Salesforce::GetUserInfoResult on success
 my $uir = $sforce->login( 'username', 'password' );
 die $sforce->errstr() unless $uir;
 
 #alternately, the GetUserInfo method also returns a WWW::Salesforce::GetUserInfo
 $uir = $sforce->GetUserInfo();
 print $uir->userId();

=head1 METHODS

=over 4

=item new HASH

X<new>
Creates a new WWW::Salesforce::GetUserInfoResult object.

 my $uir = WWW::Salesforce::GetUserInfoRequest->new();

The following are the accepted input parameters:

=over 4

=item accessibilityMode

Boolean, defaulted to 0 (false)

=item currencySymbol

String.  Such as $

=item userType

String.

=item profileId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item organizationId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item organizationMultiCurrency

Boolean, defaulted to 0 (false)

=item organizationName

String.

=item roleId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item userDefaultCurrencyIsoCode

String

=item userEmail

String

=item userFullName

String

=item userId

IDs are valid if: ^[a-zA-Z0-9]{15,18}$

=item userLanguage

String

=item userLocale

String

=item userName

String

=item userTimeZone

String

=item userUiSkin

String

=back

=item accessibilityMode BOOLEAN

=item accessibilityMode

X<accessibilityMode>
Available in API version 7.0 and later. Indicates whether user interface modifications for the visually impaired are on (true 1) or off (false 0). The modifications facilitate the use of screen readers such as JAWS. 

 $uir->accessibilityMode( 1 );
 print $uir->accessibilityMode();

=item currencySymbol  SYMBOL

=item currencySymbol

X<currencySymbol>
Currency symbol to use for displaying currency values. Applicable only when C<organizationMultiCurrency> is false.

 $uir->currencySymbol( '$' );
 print $uir->currencySymbol();

=item userType  TYPE

=item userType

X<userType>
Type of user license assigned to the Profile associated with the user.

 $uir->userType( 'Standard' );
 print $uir->userType();

=item profileId     ID

=item profileId

X<profileId>
ID of the profile associated with the role currently assigned to the user.

 $uir->profileId( 'D0000002anc00000CF' );
 print $uir->profileId();

=item organizationId    ID

=item organizationId

X<organizationId>
ID of the organization. Allows third-party tools to uniquely identify individual organizations in Salesforce.com, which is useful for retrieving billing or organization-wide setup information.

 $uir->organizationId( 'D0000003anc00000CF' );
 print $uir->organizationId();

=item organizationMultiCurrency     BOOLEAN

=item organizationMultiCurrency

X<organizationMultiCurrency>
Indicates whether the user's organization uses multiple currencies (true) or not (false).

 $uir->organizationMultiCurrency( 1 );
 print $uir->organizationMultiCurrency();

=item organizationName  NAME

=item organizationName

X<organizationName>
Name of the user's organization or company.

 $uir->organizationName( 'The Food Company' );
 print $uir->organizationName();

=item roleId   ID

=item roleId

X<roleId>
Role ID of the role currently assigned to the user.

 $uir->roleId( 'D0000004anc00000CF' );
 print $uir->roleId();

=item userDefaultCurrencyIsoCode  CURRENCY_CODE

=item userDefaultCurrencyIsoCode

X<userDefaultCurrencyIsoCode>
Default currency ISO code. Applicable only when organizationMultiCurrency is true. When the logged-in user creates any objects that have a currency ISO code, the API uses this currency ISO code if it is not explicitly specified in the C<create()> call.

 $uir->userDefaultCurrencyIsoCode( 'USD' );
 print $uir->userDefaultCurrencyIsoCode();

=item userEmail     EMAIL_ADDRESS

=item userEmail

X<userEmail>
User's email address.

 $uir->userEmail( 'foo@bar.com' );
 print $uir->userEmail();

=item userFullName      NAME

=item userFullName

X<userFullName>
User's full name.

 $uir->userFullName( 'Bill Gates' );
 print $uir->userFullName();

=item userId    ID

=item userId

X<userId>
User ID.

 $uir->userId( 'D0000005anc00000CF' );
 print $uir->userId();

=item userLanguage( scalar string )

X<userLanguage>
User's language, which controls the language for labels displayed in an application. String is 2-5 characters long. The first two characters are always an ISO language code, for example "fr" or "en." If the value is further qualified by country, then the string also has an underscore (_) and another ISO country code, for example "US" or "UK". For example, the string for the United States is "en_US", and the string for French Canadian is "fr_CA."  For a list of the languages that Salesforce.com supports, see the Salesforce.com online help topic "What languages does Salesforce.com support?"

=item userLocale( scalar string )

X<userLocale>
User's locale, which controls the formatting of dates and choice of symbols for currency. The first two characters are always an ISO language code, for example "fr" or "en." If the value is further qualified by country, then the string also has an underscore (_) and another ISO country code, for example "US" or "UK". For example, the string for the United States is "en_US", and the string for French Canadian is "fr_CA."

=item userName( scalar string )

X<userName>
User's login name.

=item userTimeZone( scalar string )

X<userTimeZone>
User's time zone.

=item userUiSkin SKIN_NAME

=item userUiSkin

X<userUiSkin>
Available in API version 7.0 and later. Returns the value Theme2 if the user is using the newer user interface theme of the online application, labeled "Salesforce.com." Returns Theme1 if the user is using the older user interface theme, labeled "Salesforce.com Classic." In the online application, this look and feel setting is configurable at Setup | Customize | User Interface. See L<http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_partner_themes.htm#topic-title>.

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

L<http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_getuserinfo_getuserinforesult.htm>

L<http://www.salesforce.com/us/developer/docs/api/index.htm>

=head1 AUTHORS

Chase Whitener <cwhitener at gmail dot com>

=head1 COPYRIGHT

Copyright 2003-2004 Chase Whitener. All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
