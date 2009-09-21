package WWW::Salesforce;
use 5.008001;
use Moose; #turns on strict and warnings

use Carp qw(croak carp confess);
use SOAP::Lite;# ( +trace => 'all', readable => 1, );#, outputxml => 1, );
#use Data::Dumper;

use WWW::Salesforce::Constants;
use WWW::Salesforce::Deserializer;
use WWW::Salesforce::Serializer;

use vars qw( $VERSION );
$VERSION = '0.200_1'; # note: should be x.xxx (three decimal places)

has 'sid' => ( is => 'ro', isa => 'Str', default => '' );
has 'uid' => ( is => 'ro', isa => 'Str', default => '' );
has 'errstr' => ( is => 'ro', isa => 'Str', default => '' );
has 'origurl' => ( is => 'ro', isa => 'Str', default => '' );
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
# get_client( $readable )
#   -- get a client
#*******************************************************************************
sub get_client {
    my $self = shift;
    my ( $readable ) = @_;
    $readable = ( $readable )? 1 : 0;

    my $client = SOAP::Lite
        ->readable( $readable )
        ->deserializer( WWW::Salesforce::Deserializer->new )
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
    my $ENOUSER = "A username is required to login.";
    my $ENOPASS = "A password is required to login.";
    my $EALREADYLOGGEDIN = "You seem to be already logged in.";
    my %in = ();
    if ( @_ == 1 && ref($_[0]) eq 'HASH' ) {
        %in = %{$_[0]};
    }
    elsif ( @_ % 2 == 0 ) {
        (%in) = @_;
    }
    confess($ENOUSER) unless exists $in{username} and defined $in{username};
    confess($ENOUSER) unless length $in{username};
    confess($ENOPASS) unless exists $in{password} and defined $in{password};
    confess($ENOPASS) unless length $in{password};
    $in{token} = q() unless exists $in{token} and defined $in{token};
    $in{token} = q() unless length $in{token};

    if ( $self->sid() or $self->uid() ) {
        $self->{errstr} = $EALREADYLOGGEDIN;
        return 0;
    }
    my $client = $self->get_client();
    my $r = $client->login(
        SOAP::Data->name( 'username' => $in{username} ),
        SOAP::Data->name( 'password' => $in{password}.$in{token} )
    );
    return 0 if ( $self->has_error( $r ) );
    $self->{sid} = $r->valueof('//loginResponse/result/sessionId');
    $self->{uid} = $r->valueof('//loginResponse/result/userId');
    $self->{origurl} = $self->{serverurl};
    $self->{serverurl} = $r->valueof('//loginResponse/result/serverUrl');
    return 1;
}

#*******************************************************************************
# logout() -- API
#   -- kill your session
#*******************************************************************************
sub logout {
    my $self = shift;
    $self->confess_if_not_logged_in();
    my $client = $self->get_client(1);
    my $r = $client->logout( $self->get_session_header() );
    return 0 if ( $self->has_error( $r ) );
    $self->{sid} = q();
    $self->{uid} = q();
    $self->{serverurl} = $self->{origurl};
    return 1;
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
    my $ENOUSER = "Expected a hash with key 'userId'.";
    my $ENOPASS = "Expected a hash with key 'password'.";
    my %in = ();
    if ( @_ == 1 && ref($_[0]) eq 'HASH' ) {
        %in = %{$_[0]};
    }
    elsif ( @_ % 2 == 0 ) {
        (%in) = @_;
    }
    confess($ENOUSER) unless exists $in{userId} and defined $in{userId};
    confess($ENOUSER) unless length $in{userId};
    confess($ENOPASS) unless exists $in{password} and defined $in{password};
    confess($ENOPASS) unless length $in{password};
    confess($ENOUSER) unless length $in{userId};
    confess($ENOPASS) unless length $in{password};

    my $client = $self->get_client(1);
    my $method = SOAP::Data
        ->name( "setPassword" )
        ->prefix( $self->prefix() )
        ->uri( $self->uri() );
    my $r = $client->call(
        $method => SOAP::Data->prefix( $self->prefix() )
            ->name( 'userId' => $in{'userId'} )
            ->type( 'xsd:string' ), 
        SOAP::Data->prefix( $self->prefix() )
            ->name( 'password' => $in{'password'} )
            ->type( 'xsd:string' ), 
        $self->get_session_header()
    );
    return 0 if ( $self->has_error( $r ) );
    $r = $r->valueof('//setPasswordResponse/result/');
    return 1 unless length $r;
    return $r;
}

#magically delicious
no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=pod

=head1 NAME

WWW::Salesforce - this class provides a simple abstraction layer between SOAP::Lite and Salesforce.com.

=head1 DESCRIPTION

Because SOAP::Lite does not support complexTypes, and document/literal encoding is limited, this module works around those limitations and provides a more intuitive interface a developer can interact with.

=head1 SYNOPSIS

 use WWW::Salesforce;
 my $sforce = WWW::Salesforce->new(
    #all parameters below are optional.  The values given are the defaults
    serverurl => 'https://www.salesforce.com/services/Soap/u/16.0',
    uri => 'urn:partner.soap.sforce.com',
    object_uri => 'urn:sobject.partner.soap.sforce.com',
    prefix => 'sforce'
 ); #This will confess its errors and die if it fails!
 
 $sforce->login(
    username => 'foo', #required
    password => 'bar', #required
    token => 'nzAx8oThkUopg184FAfOq9Df9'
 ) or die $sforce->errstr;

=head1 METHODS

=head2 new( HASH )

The C<new> method creates the WWW::Salesforce object.  No calls can be made with the object that's returned until you use the C<login> method.  If the creation of the object fails, WWW::Salesforce will confess its errors and die.

The following are the accepted input parameters (all are optional):

=over

=item serverurl

The default is 'https://www.salesforce.com/services/Soap/u/16.0'.  Change this value if you want to use your sandbox account, etc.

=item uri

The default is 'urn:partner.soap.sforce.com'.  Change this for the enterprise account, etc. This is SOAP XML stuff.

=item object_uri

The default is 'urn:sobject.partner.soap.sforce.com'.  Change this for the enterprise account, etc.  This is SOAP XML stuff.

=item prefix

The default is 'sforce'.  You should probably leave this one be.  This is SOAP XML stuff.

=back

=head2 errstr()

The C<errstr> method returns the last error encountered with this object.  Upon the failure of a method call, that method call will return 0 (false) and set the error string which you can obtain with this method.

=head2 CORE METHODS

=head3 login( HASH )

The C<login> method returns an object of type WWW::Salesforce if the login attempt was successful. Upon a successful login, the sessionId is saved so that developers need not worry about setting these values manually.

The following are the accepted input parameters:

=over

=item username  (REQUIRED)

A Salesforce.com username.

=item password  (REQUIRED)

The password for the user indicated by C<username>.

=item token

Salesforce.com checks the IP address from which the client application is logging in, and blocks logins from unknown IP addresses. For a blocked login via the API, Salesforce.com returns a login fault. Then, the user must add their security token to the end of their password in order to log in. A security token is an automatically-generated key from Salesforce.com. For example, if a user's password is mypassword, and their security token is XXXXXXXXXX, then the user must enter mypasswordXXXXXXXXXX to log in. Users can obtain their security token by changing their password or resetting their security token via the Salesforce.com user interface. When a user changes their password or resets their security token, Salesforce.com sends a new security token to the email address on the user's Salesforce.com record. The security token is valid until a user resets their security token, changes their password, or has their password reset. When the security token is invalid, the user must repeat the login process to log in. To avoid this, the administrator can make sure the client's IP address is added to the organization's list of trusted IP addresses. For more information, see L<http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_concepts_security.htm#topic-title_login_token>.

=back

=head3 logout()

The C<logout> method logs the current user out and readies your object for another C<login>.

=head2 UTILITY METHODS

=head3 getServerTimestamp()

Returns a string. Gets the current system timestamp (GMT) from the sforce Web service.

 my $tstamp = $sforce->getServerTimestamp() or die $sforce->errstr;
 print $tstamp;

=head3 getUserInfo()

Returns a hash reference. Use getUserInfo() to obtain personal information about the currently logged-in.

 my $h_ref = $sforce->getUserInfo() or die $sforce->errstr;
 print $h_ref->{'userId'};

=head3 resetPassword( "userId" )

Returns 1 or a string on success. Changes the desired user's password to a server-generated value.

 #supply the user id of the person you want to reset
 my $passwd = $sforce->resetPassword( '00510000000tFa7AAE' );
 if ( $passwd ) {
	 print "Yay!  Your new password is $password";
 }
 else {
	 print "boo! ", $sforce->errstr;
 }

=head3 setPassword( HASH )

Returns 1 or a string on success. Sets the specified user's password to the specified value.

 my $res = $sforce->setPassword(
	'userId' => '00510000000tFa7AAE',
	'password' => 'foobar'
 );
 if ( $res ) {
	 print "yay!";
 }
 else {
	 print "boo! ", $sforce->errstr;
 }

The following are the accepted input parameters:

=over

=item userId  (REQUIRED)

A user Id.

=item password  (REQUIRED)

The new password to assign to the user identified by C<userId>.

=back

=head1 SUPPORT

Please visit Salesforce.com's user/developer forums online for assistance with
this module. You are free to contact the author directly if you are unable to
resolve your issue online.

=head1 SEE ALSO

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

Copyright 2003-2004 Byrne Reese, Chase Whitener. All rights reserved.

=cut
