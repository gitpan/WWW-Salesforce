package WWW::Salesforce;
use 5.008001;
use Moose; #turns on strict and warnings

use Carp qw(croak carp confess);
use SOAP::Lite;# ( +trace => 'all', readable => 1, );#, outputxml => 1, );
#use Data::Dumper;

use WWW::Salesforce::Constants;
use WWW::Salesforce::Serializer;

use WWW::Salesforce::SObject;
use WWW::Salesforce::LeadConvert;
use WWW::Salesforce::LeadConvertResult;
use WWW::Salesforce::GetUserInfoResult;

use vars qw( $VERSION );
$VERSION = '0.200_2'; # note: should be x.xxx (three decimal places)

has 'sid' => ( is => 'ro', isa => 'Str', default => '' );
has 'uid' => ( is => 'ro', isa => 'Str', default => '' );
has 'errstr' => ( is => 'ro', isa => 'Str', default => '' );
has 'origurl' => ( is => 'ro', isa => 'Str', default => '' );
has 'metaurl' => ( is => 'ro', isa => 'Str', default => '' );
has 'sandbox' => ( is => 'ro', isa => 'Bool', default => '0' );
has 'serverurl' => (
    is => 'ro',
    isa => 'Str',
    default => 'https://www.salesforce.com/services/Soap/u/16.0'
);
has 'uri' => (
    is => 'ro',
    isa => 'Str',
    default => 'urn:partner.soap.sforce.com'
);
has 'object_uri' => (
    is => 'ro',
    isa => 'Str',
    default => 'urn:sobject.partner.soap.sforce.com'
);
has 'prefix' => (
    is => 'ro',
    isa => 'Str',
    default => 'sforce'
);


#*******************************************************************************
# BUILD()
#   -- Make sure they didn't pass empty strings to the necessary bits
#   -- Also, make sure we know we're not connected yet by clearing SID and UID
#*******************************************************************************
sub BUILD {
    my $self = shift;
    
    confess("A server URL is required.") unless $self->serverurl();
    confess("A URI is required.") unless $self->uri();
    confess("An object URI is required.") unless $self->object_uri();
    confess("A prefix is required.") unless $self->prefix();
    $self->{sid} = q();
    $self->{uid} = q();
    $self->{origurl} = q();
}

#*******************************************************************************
# confess_if_not_logged_in()
#   -- Yell and die if the user tries to do something before being logged in
#*******************************************************************************
sub confess_if_not_logged_in {
    my $self = shift;
    unless ( $self->{sid} and $self->{uid} ) {
        confess( "You must first use the login() method." );
    }
}

#*******************************************************************************
# convertLead( WWW::Salesforce::LeadConvert )     -- API
#   -- Converts a Lead into an Account, Contact, or (optionally) an Opportunity
#*******************************************************************************
sub convertLead {
    my $self = shift;
    $self->confess_if_not_logged_in();
    my $EONLY = "convertLead() expects ONLY objects of type WWW::Salesforce::LeadConvert.";
    my $ELIST = "convertLead() expects a list of WWW::Salesforce::LeadConvert objects";
    
    #handle error with no params passed, a single object, or a list of objects
    my @in = ();
    if ( @_ == 0 ) {
        confess($ELIST);
        return 0;
    }
    else {
        for my $v ( @_ ) {
            confess ($EONLY) unless UNIVERSAL::isa( $v, 'WWW::Salesforce::LeadConvert' );
            push @in, $v;
        }
    }
            
    my @converts = ();
    for my $lc ( @in ) {
        #take in data to be passed in our call
        my @data = ();
        push @data, SOAP::Data->name(leadId => $lc->leadId() );
        push @data, SOAP::Data->name(accountId => $lc->accountId() )
            if $lc->accountId;
        push @data, SOAP::Data->name(contactId => $lc->contactId() )
            if $lc->contactId;
        push @data, SOAP::Data->name(ownerId => $lc->ownerId() )
            if $lc->ownerId;
        push @data, SOAP::Data->name(convertedStatus => $lc->convertedStatus() )
            if $lc->convertedStatus;
        push @data, SOAP::Data->name(opportunityName => $lc->opportunityName() )
            if $lc->opportunityName;
        push @data, SOAP::Data->name(doNotCreateOpportunity => $lc->doNotCreateOpportunity() )
            if $lc->doNotCreateOpportunity;
        push @data, SOAP::Data->name(overwriteLeadSource => $lc->overwriteLeadSource() )
            if $lc->overwriteLeadSource;
        push @data, SOAP::Data->name(sendNotificationEmail => $lc->sendNotificationEmail() )
            if $lc->sendNotificationEmail;
        push @converts, SOAP::Data->name( LeadConvert => \SOAP::Data->value(@data) );
    }

    #got the data lined up, make the call
    my $client = $self->get_client( 1 );
    my $r = $client->convertLead(
        SOAP::Data
            ->name( "leadConverts" => SOAP::Data->value( @converts ) ),
        $self->get_session_header()
    );
    #check the actual faultstring
    return 0 if ( $self->has_error( $r ) );
    my @array = ();
    for my $v ( $r->valueof('//convertLeadResponse/result') ) {
        #print Dumper $v unless exists $v->{leadId} and defined $v->{leadId};
        $v->{success} = 1 unless exists $v->{success};
        $v->{success} = 1 unless defined $v->{success};
        $v->{success} = ($v->{success} eq 'true')? 1: 0;
        push @array, WWW::Salesforce::LeadConvertResult->new($v);
    }
    return @array;
}

#*******************************************************************************
# create()     -- API
#   -- Adds one or more new individual objects to your organization's data
#*******************************************************************************
sub create {
    my $self = shift;
    my (%in) = @_;

    if ( !keys %in ) {
        carp( "Expected a hash of arrays." );
        return 0;
    }
    my $client = $self->get_client(1);
    my $method = SOAP::Data
        ->name("create")
        ->prefix( $self->prefix() )
        ->uri( $self->uri() )
        ->attr( { 'xmlns:sfons' => $self->object_uri() } );

    my $type = $in{'type'};
    delete($in{'type'});

    my @elems;
    foreach my $key (keys %in) {
        push @elems, SOAP::Data->prefix('sfons')
            ->name($key => $in{$key})
            ->type( WWW::Salesforce::Constants->type($type, $key) );
    }

    my $r = $client->call(
        $method => 
            SOAP::Data->name('sObjects' => \SOAP::Data->value(@elems))
                ->attr( { 'xsi:type' => 'sfons:'.$type } ),
            $self->get_session_header()
    );
    if ( $r->fault() ) {
        carp( $r->faultstring() );
        return 0;
    }
    return $r;
}

#*******************************************************************************
# get_client( $readable )
#   -- get a client
#*******************************************************************************
sub get_client {
    my $self = shift;
    my ( $readable ) = @_;
    $readable = ( $readable )? 1 : 0;

    my $client = SOAP::Lite
        ->readable( $readable )
        ->serializer( WWW::Salesforce::Serializer->new )
        ->on_action( sub { return '""' } )
        ->uri( $self->uri() )
        ->multirefinplace(1)
        ->proxy( $self->serverurl() );
    return $client;
}

#*******************************************************************************
# get_session_header( $mustunderstand )
#   -- gets the session header
#*******************************************************************************
sub get_session_header {
    my ( $self ) = @_;
    return SOAP::Header
        ->name( 'SessionHeader' => 
            \SOAP::Header->name(
                'sessionId' => $self->sid()
            )
        )
        ->uri( $self->uri() )
        ->prefix( $self->prefix() );
}

#*******************************************************************************
# getServerTimestamp() -- API
#   -- Retrieves the current system timestamp (GMT) from the Web service.
#*******************************************************************************
sub getServerTimestamp {
    my $self = shift;
    $self->confess_if_not_logged_in();
    my $client = $self->get_client(1);
    my $r = $client->getServerTimestamp( $self->get_session_header() );
    return 0 if ( $self->has_error( $r ) );
    return $r->valueof('//getServerTimestampResponse/result/timestamp');
}

#*******************************************************************************
# getUserInfo()  --API
#   -- Retrieves personal information for the user associated with the
#       current session.
#*******************************************************************************
sub getUserInfo {
    my $self = shift;
    $self->confess_if_not_logged_in();
    my $client = $self->get_client(1);
    my $r = $client->getUserInfo( $self->get_session_header() );
    return 0 if ( $self->has_error( $r ) );
    return $r->valueof('//getUserInfoResponse/result/');
}

#*******************************************************************************
# has_error( $r )
#   -- check the response from all method calls for errors
#*******************************************************************************
sub has_error {
    my $self = shift;
    my $r = shift;
    my $EUHOH = "Unknown error occured.";
    
    $self->{errstr} = q();
    unless ( defined $r ) {
        $self->{errstr} = $EUHOH;
        return 1;
    }
    unless ( ref $r ) {
        $self->{errstr} = (length $r)? $r: $EUHOH;
        return 1;
    }
    if ( $r->fault() ) {
        $self->{errstr} = $r->faultstring();
        return 1;
    }
    return 0;
}

#*******************************************************************************
# login( HASH )
#   -- accepts username, password, and token as parameters
#*******************************************************************************
sub login {
    my $self = shift;
    my ( $username, $password, $token ) = @_;
    my $ENOUSER = "A username is required to login.";
    my $ENOPASS = "A password is required to login.";
    my $EALREADYLOGGEDIN = "You seem to be already logged in.";

    confess($ENOUSER) unless defined $username and length $username;
    confess($ENOPASS) unless defined $password and length $password;
    $token = q() unless defined $token and length $token;

    if ( $self->sid() or $self->uid() ) {
        $self->{errstr} = $EALREADYLOGGEDIN;
        return 0;
    }
    my $client = $self->get_client();
    my $r = $client->login(
        SOAP::Data->name( 'username' => $username ),
        SOAP::Data->name( 'password' => $password.$token )
    );
    return 0 if ( $self->has_error( $r ) );
    $self->{origurl} = $self->{serverurl}; #save incase logout/login again
    $self->{sid} = $r->valueof('//loginResponse/result/sessionId');
    $self->{uid} = $r->valueof('//loginResponse/result/userId');
    $self->{sandbox} = $r->valueof('//loginResponse/result/sandbox');
    $self->{metaurl} = $r->valueof('//loginResponse/result/metadataServerUrl');
    $self->{serverurl} = $r->valueof('//loginResponse/result/serverUrl');
    
    my %uinfo = %{$r->valueof('//loginResponse/result/userInfo')};
    for my $key ( keys %uinfo ) {
        next unless exists $uinfo{$key};
        unless ( exists($uinfo{$key}) and defined($uinfo{$key}) ) {
            delete($uinfo{$key});
            next;
        }
        $uinfo{$key} = 0 if lc($uinfo{$key}) eq 'false';
        $uinfo{$key} = 1 if lc($uinfo{$key}) eq 'true';
    }
    return WWW::Salesforce::GetUserInfoResult->new( %uinfo );
}

#*******************************************************************************
# logout() -- API
#   -- kill your session
#*******************************************************************************
sub logout {
    my $self = shift;
    my $client = $self->get_client(1);
    my $r = $client->logout( $self->get_session_header() );
    $self->{sid} = q();
    $self->{uid} = q();
    $self->{serverurl} = $self->{origurl};
    return 0 if ( $self->has_error( $r ) );
    return 1;
}

#*******************************************************************************
# query( %in )  --API
#   -- runs a query against salesforce
#*******************************************************************************
sub query {
    my $self = shift;
    my ($query, $limit ) = @_;
    
    unless ( defined $query and length $query ) {
        confess( "A query string is needed for the query() method." );
        return 0;
    }
    $limit = 500 unless ( defined $limit and $limit =~ m/^\d+$/ );
    $limit = 50 if $limit < 1;
    $limit = 2000 if $limit > 2000;

    my $lim = SOAP::Header
        ->name( 'QueryOptions' => 
            \SOAP::Header->name(
                'batchSize' => $limit
            )
        )
        ->prefix( $self->prefix() )
        ->uri( $self->uri() );
    my $client = $self->get_client();
    my $r = $client->query(
        SOAP::Data->name( 'queryString' => $query ),
        $lim,
        $self->get_session_header()
    );
    return 0 if ( $self->has_error( $r ) );
    return $r;
}

#*******************************************************************************
# resetPassword()  --API
#   -- reset your password
#*******************************************************************************
sub resetPassword {
    my $self = shift;
    $self->confess_if_not_logged_in();
    my $userid = shift;

    $userid = q() unless defined $userid and !ref($userid);
    confess( "Expected a string with a user ID" ) unless length $userid;

    my $client = $self->get_client(1);
    my $method = SOAP::Data
        ->name( "resetPassword" )
        ->prefix( $self->prefix() )
        ->uri( $self->uri() );
    my $r = $client->call(
        $method => SOAP::Data->prefix( $self->prefix() )
            ->name( 'userId' => $userid )
            ->type( 'xsd:string' ), 
        $self->get_session_header()
    );

    return 0 if ( $self->has_error( $r ) );
    $r = $r->valueof('//resetPasswordResponse/result/password');
    return 1 unless length $r;
    return $r;
}

#*******************************************************************************
# setPassword()  --API
#   -- Sets the specified user's password to the specified value.
#*******************************************************************************
sub setPassword {
    my $self = shift;
    $self->confess_if_not_logged_in();
    my $ENOUSER = "Please supply a valid User ID";
    my $ENOPASS = "Please supply a new password for the given User ID";
    my ( $user, $pass ) = @_;
    confess($ENOUSER) unless defined $user and length $user;
    confess($ENOPASS) unless defined $pass and length $pass;

    my $client = $self->get_client(1);
    my $method = SOAP::Data
        ->name( "setPassword" )
        ->prefix( $self->prefix() )
        ->uri( $self->uri() );
    my $r = $client->call(
        $method => SOAP::Data->prefix( $self->prefix() )
            ->name( 'userId' => $user )
            ->type( 'xsd:string' ), 
        SOAP::Data->prefix( $self->prefix() )
            ->name( 'password' => $pass )
            ->type( 'xsd:string' ), 
        $self->get_session_header()
    );
    return 0 if ( $self->has_error( $r ) );
    $r = $r->valueof('//setPasswordResponse/result/');
    return 1 unless length $r;
    return $r;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=pod

=head1 NAME

WWW::Salesforce - this class provides a simple abstraction layer between L<SOAP::Lite|SOAP::Lite> and <http://www.salesforce.com|Salesforce.com>.

=head1 DESCRIPTION

Because L<SOAP::Lite|SOAP::Lite> is somewhat of a pain, this module handles the tasks of dealing with it for you and provides a more intuitive interface a developer can interact with.

=head1 SYNOPSIS

 use WWW::Salesforce;
 my $sforce = WWW::Salesforce->new(
    #all parameters below are optional.  The values given are the defaults
    serverurl => 'https://www.salesforce.com/services/Soap/u/16.0',
    uri => 'urn:partner.soap.sforce.com',
    object_uri => 'urn:sobject.partner.soap.sforce.com',
    prefix => 'sforce'
 ); #This will confess its errors and die if it fails!
 
 $sforce->login('username', 'password') or die $sforce->errstr;

=head1 METHODS

=over 4

=item new   HASH

=item new

X<new>

The C<new> method creates the WWW::Salesforce object.  No calls can be made with the object that's returned until you use the C<login> method.  If the creation of the object fails, WWW::Salesforce will confess its errors and die.

 my $sforce = WWW::Salesforce->new();

The following are the accepted input parameters:

=over 4

=item serverurl

The default is 'https://www.salesforce.com/services/Soap/u/16.0'. You might want to use 'https://test.salesforce.com/services/Soap/u/16.0' to connect to your sandbox.  Here is the documentation for login URLs: L<http://www.salesforce.com/us/developer/docs/api/Content/implementation_considerations.htm>

=item uri   

The default is 'urn:partner.soap.sforce.com'.  Change this for the enterprise account, etc.

=item object_uri

The default is 'urn:sobject.partner.soap.sforce.com'.  Change this for the enterprise account, etc.

=item prefix

The default is 'sforce'.  You should probably leave this one be.

=back

=item errstr

X<errstr>
The C<errstr> method returns the last error encountered with this object.  Upon the failure of a method call, that method call will return 0 (false) and set the error string which you can obtain with this method.

 die "Uh oh, there was an error ". $sforce->errstr();

=item uid

X<uid>
The C<uid> method returns the user ID string of the user you're currently logged in as. If you're not logged in, you will get an empty string.

 print "My user ID is: ", $sforce->uid(), "\n";

=back

=head2 CORE METHODS

=over 4

=item convertLead ARRAY

X<convertLead>

The C<convertLead> method takes an array of L<WWW::Salesforce::LeadConvert|WWW::Salesforce::LeadConvert> objects. Use C<convertLead> to convert a Lead into an Account and Contact, as well as (optionally) an Opportunity. To convert a Lead, your client application must be logged in with the "Convert Leads" permission and the "Edit" permission on leads, as well as "Create" and "Edit" on the Account, Contact, and Opportunity objects.

 use WWW::Salesforce::LeadConvert;

 ...

 my $lc = WWW::Salesforce::LeadConvert->new(
    leadId => '0FQ30000009gBn8',
    convertedStatus => 'Closed - Converted',
 );

 #I'm just providing a list of LeadConverts for example purposes.
 #you could just as easily only provide one LeadConvert
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

=item login USERNAME, PASSWORD, TOKEN

=item login USERNAME, PASSWORD

X<login>

The C<login> method returns an object of type L<WWW::Salesforce::GetUserInfoResult|WWW::Salesforce::GetUserInfoResult> if the login attempt was successful. Upon a successful login, the sessionId is saved so that developers need not worry about setting these values manually.
Salesforce.com checks the IP address from which the client application is logging in, and blocks logins from unknown IP addresses. For a blocked login via the API, Salesforce.com returns a login fault. Then, the user must add their security token to the end of their password in order to log in. A security token is an automatically-generated key from Salesforce.com. For example, if a user's password is mypassword, and their security token is XXXXXXXXXX, then the user must enter mypasswordXXXXXXXXXX to log in. Users can obtain their security token by changing their password or resetting their security token via the Salesforce.com user interface. When a user changes their password or resets their security token, Salesforce.com sends a new security token to the email address on the user's Salesforce.com record. The security token is valid until a user resets their security token, changes their password, or has their password reset. When the security token is invalid, the user must repeat the login process to log in. To avoid this, the administrator can make sure the client's IP address is added to the organization's list of trusted IP addresses. For more information, see L<http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_concepts_security.htm#topic-title_login_token>.

 $sforce->login( 'username', 'password', 'ypLbB47zm1qkM98Q3NWd4uWWqZ' )
    or die $sforce->errstr();

OR

 $sforce->login( 'username', 'password' ) or die $sforce->errstr();
 
OR

 my $info = $sforce->login( 'username', 'password' );
 die $sforce->errstr() unless $info;
 print $info->userId();

=item logout

X<logout>

The C<logout> method logs the current user out and readies your object for another C<login>.

 $sforce->logout() or die $sforce->errstr();

=back

=head2 UTILITY METHODS

=over 4

=item getServerTimestamp

X<getServerTimestamp>
Returns a string. Gets the current system timestamp (GMT) from the sforce Web service.  The C<login> method must be called prior to using this method.

 my $tstamp = $sforce->getServerTimestamp() or die $sforce->errstr;
 print $tstamp;

=item getUserInfo

X<getUserInfo>
Returns a L<WWW::Salesforce::GetuserInfoResult|WWW::Salesforce::GetuserInfoResult> object. Use getUserInfo() to obtain personal information about the currently logged-in user. The C<login> method must be called prior to using this method.

 my $userinfo = $sforce->getUserInfo() or die $sforce->errstr;
 print $userinfo->userId();

=item resetPassword    USERID

X<resetPassword>
Returns 1 or a string on success. Changes the desired user's password to a server-generated value.  The C<login> method must be called prior to using this method.

 #supply the user id of the person you want to reset
 my $passwd = $sforce->resetPassword( '00510000000tFa7AAE' );
 if ( $passwd ) {
	 print "Yay!  Your new password is $password";
 }
 else {
	 print "boo! ", $sforce->errstr;
 }

=item setPassword  USERID, PASSWORD

X<setPassword>
Returns 1 or a string and sets the specified user's password to the specified value on success.  The C<login> method must be called prior to using this method.

 my $res = $sforce->setPassword( '00510000000tFa7AAE', 'foobar' );
 if ( $res ) {
	 print "yay!";
 }
 else {
	 print "boo! ", $sforce->errstr;
 }

=back

=head1 SUPPORT

Please visit Salesforce.com's user/developer forums online for assistance with
this module. You are free to contact the author directly if you are unable to
resolve your issue online.

#perl on EFNet is also a place to get help.  The author is 'genio' on that channel.

=head1 SEE ALSO

L<WWW::Salesforce::LeadConvert>

L<WWW::Salesforce::GetUserInfo>

L<DBD::Salesforce> by Jun Shimizu

L<SOAP::Lite> by Byrne Reese

Examples on Salesforce website:

L<http://www.salesforce.com/us/developer/docs/api/index.htm>

=head1 AUTHORS

Chase Whitener <cwhitener at gmail dot com>

Thanks to:

Michael Blanco -
Finding and fixing some bugs.

Garth Webb - 
Finding and fixing bugs. Adding some additional features and more constant types.

Ron Hess -
Finding and fixing bugs. Adding some additional features. Adding more tests
to the build. Providing a lot of other help.

Tony Stubblebine -
Finding a bug and providing a fix.

Jun Shimizu - 
Providing more to the WWW::Salesforce::Constants module
and submitting fixes for various other bugs.

Byrne Reese - <byrne at majordojo dot com> -
Byrne Reese wrote the original Salesforce module.

=head1 COPYRIGHT

Copyright 2009, Chase Whitener.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
