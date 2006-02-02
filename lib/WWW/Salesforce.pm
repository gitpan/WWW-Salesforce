package WWW::Salesforce;
{
    use 5.008001;
    use strict;
    use warnings;
    
    use SOAP::Lite;
    use WWW::Salesforce::Constants;
    use WWW::Salesforce::Deserializer;
    use vars qw( $VERSION );
    
    $VERSION = '0.05';
    
    our $errstr = '';
    
    #**************************************************************************
    # new( %params )
    #   -- constructor
    #**************************************************************************
    sub new {
        my $class = shift;
        
        my ( %params ) = @_;
        
        unless ( defined $params{'username'} and length $params{'username'} ) {
            $errstr = "WWW::Salesforce::new() requires a username";
            return undef;
        }
        unless ( defined $params{'password'} and length $params{'password'} ) {
            $errstr = "WWW::Salesforce::new() requires a password";
            return undef;
        }

        my $self = {
            sf_user => $params{'username'},
            sf_pass => $params{'password'},
            sf_sid => undef, #session ID
            sf_uri => 'urn:partner.soap.sforce.com',
            sf_proxy => 'https://www.salesforce.com/services/Soap/u/6.0',
            sf_prefix => 'sforce',
            sf_sobject_urn => 'urn:sobject.partner.soap.sforce.com',
        };
        
        bless $self, $class;
        return $self if $self->login();
        return undef;
    }
    
    #**************************************************************************
    # convertLead()     -- API
    #   -- TODO: add description
    #**************************************************************************
    sub convertLead {
        #todo -- create this function... use
        #http://www.sforce.com/us/resources/soap/sforce60/sforce_API_messages_convertLead.html
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name( "convertLead" )
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'sObjectType' => $in{'type'} )
                ->type( 'xsd:string' ), 
            $self->get_session_header()
        );

        return $r;
    }
    
    #**************************************************************************
    # create()     -- API
    #   -- TODO: add description
    #**************************************************************************
    sub create {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name("create")
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} )
            ->attr( { 'xmlns:sfons' => $self->{'sf_sobject_urn'} } );

        my $type = $in{'type'};
        delete($in{'type'});
    
        my @elems;
        foreach my $key (keys %in) {
	        push @elems, SOAP::Data->prefix('sfons')
	            ->name($key => $in{$key})
	            ->type($WWW::Salesforce::Constants::TYPES{$type}->{$key});
        }

        my $r = $client->call(
            $method => 
                SOAP::Data->name('sObjects' => \SOAP::Data->value(@elems))
                    ->attr( { 'xsi:type' => 'sfons:'.$type } ),
                $self->get_session_header()
        );
        return $r;
    }

    #**************************************************************************
    # describeGlobal()     -- API
    #   -- TODO: add description
    #**************************************************************************
    sub delete {
        my $self = shift;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name("delete")
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_proxy'} );

        my @elems;
        foreach my $id ( @_ ) {
            push @elems, SOAP::Data->name('ids' => $id)->type('tns:ID');
        }

        my $r = $client->call(
            $method => @elems,
            $self->get_session_header()
        );
        return $r;
    }

    #**************************************************************************
    # describeGlobal()     -- API
    #   -- TODO: add description
    #**************************************************************************
    sub describeGlobal {
        my $self = shift;
        my (%in) = @_;
    
        my $client = $self->get_client(1);
    
        my $method = SOAP::Data
    	    ->name("describeGlobal")
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );
    
        my $r = $client->call(
            $method => undef,
            $self->get_session_header()
        );
    
        return $r;
    }

    #**************************************************************************
    # describeLayout()     -- API
    #   -- TODO: add description
    #**************************************************************************
    sub describeLayout {
        # TODO - create function
        #http://www.sforce.com/us/resources/soap/sforce60/sforce_API_messages_describeLayout.html
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name( "describeLayout" )
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'sObjectType' => $in{'type'} )
                ->type( 'xsd:string' ), 
            $self->get_session_header()
        );

        return $r;
    }
    
    #**************************************************************************
    # describeSObject()     -- API
    #   -- TODO: add description
    #**************************************************************************
    sub describeSObject {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name( "describeSObject" )
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'sObjectType' => $in{'type'} )
                ->type( 'xsd:string' ), 
            $self->get_session_header()
        );

        return $r;
    }
    
    #**************************************************************************
    # get_client( $readable )
    #   -- gets the session header
    #**************************************************************************
    sub get_client {
        my $self = shift;
        my $readable = shift;
        if ( defined $readable and $readable ) {
            $readable = 1;
        }
        else {
            $readable = 0;
        }
        
        my $client = SOAP::Lite
            ->readable($readable)
            ->deserializer( WWW::Salesforce::Deserializer->new )
            ->on_action( sub { return '""' } )
            ->uri( $self->{'sf_uri'} )
            ->proxy( $self->{'sf_proxy'} );
        return $client;
    }
    
    #**************************************************************************
    # get_session_header()
    #   -- gets the session header
    #**************************************************************************
    sub get_session_header {
        my $self = shift;
        return SOAP::Header->name(
            'SessionHeader' => \SOAP::Header->name(
                'sessionId' => $self->{'sf_sid'}
            )
        );
    }

    #**************************************************************************
    # getDeleted() -- API
    #   -- returns the deleted items in the trash can
    #**************************************************************************
    sub getDeleted {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name("getDeleted")
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'sObjectType' => $in{'type'} )
                ->type( 'xsd:string' ), 
            SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'startDate' => $in{'start'} )
                ->type( 'xsd:dateTime' ), 
            SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'endDate' => $in{'end'} )
                ->type( 'xsd:dateTime' ), 
            $self->get_session_header()
        );
        return $r;
    }

    #**************************************************************************
    # getServerTimestamp() -- API
    #   -- returns the server's timestamp
    #**************************************************************************
    sub getServerTimestamp {
        my $self = shift;
        my (%in) = @_;
    
        my $client = $self->get_client(1);
    
        my $method = SOAP::Data
            ->name( "getServerTimestamp" )
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} )
            ->attr( { 'xmlns:sfons' => $self->{'sf_sobject_urn'} } );
    
        my $r = $client->call(
            $method => undef,
            $self->get_session_header()
        );
    
        return $r;
    }

    #**************************************************************************
    # getUpdated()  --API
    #   -- gets the updated records
    #**************************************************************************
    sub getUpdated {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name( "getUpdated" )
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'sObjectType' => $in{'type'} )
                ->type( 'xsd:string' ), 
            SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'startDate' => $in{'start'} )
                ->type( 'xsd:dateTime' ), 
            SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'endDate' => $in{'end'} )
                ->type( 'xsd:dateTime' ), 
            $self->get_session_header()
        );

        return $r;
    }

    #**************************************************************************
    # getUserInfo()  --API
    #   -- gets the user's information
    #**************************************************************************
    sub getUserInfo {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name("getUserInfo")
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name('getUserInfo' => $in{'user'})
                ->type('xsd:string'), 
            $self->get_session_header()
        );

        return $r;
    }

    #**************************************************************************
    # login()
    #   -- logs the user into Salesforce.. true on success, false on fail
    #**************************************************************************
    sub login {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client();
    
        my $r = $client->login(
            SOAP::Data->name( 'username' => $self->{'sf_user'} ),
            SOAP::Data->name( 'password' => $self->{'sf_pass'} )
        );
        
        if ( $r->fault() ) {
            $errstr = $r->faultstring();
            return 0;
        }
    
        $self->{'sf_sid'} = $r->valueof('//loginResponse/result/sessionId');
        $self->{'serverUrl'} =
            $self->{'sf_proxy'} = 
    	    $r->valueof('//loginResponse/result/serverUrl');
    	
        $self->{'userId'} = $r->valueof('//loginResponse/result/userId');
        return 1;
    }
    
    #**************************************************************************
    # query()  --API
    #   -- runs a query against salesforce
    #**************************************************************************
    sub query {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client();

        my $r = $client->query(
            $self->get_session_header(),
            SOAP::Data->name( 'query' => $in{'query'} ),
            SOAP::Header->name(
                'QueryOptions' => \SOAP::Header->name(
                    'batchSize' => $in{'limit'}
                )
            )
        );
        return $r;
    }
    
    #**************************************************************************
    # queryMore()  --API
    #   -- query from where you last left off
    #**************************************************************************
    sub queryMore {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client();

        my $r = $client->queryMore(
            $self->get_session_header(),
            SOAP::Data->name( 'queryLocator' => $in{'queryLocator'} ),
            SOAP::Header->name(
                'QueryOptions' => \SOAP::Header->name(
                    'batchSize' => $in{'limit'}
                )
            )
        );
        return $r;
    }
    
    #**************************************************************************
    # resetPassword()  --API
    #   -- reset your password
    #**************************************************************************
    sub resetPassword {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name( "resetPassword" )
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'userId' => $in{'userId'} )
                ->type( 'xsd:string' ), 
            $self->get_session_header()
        );

        return $r;
    }
    
    #**************************************************************************
    # retrieve()  --API
    #   -- TODO: write description
    #**************************************************************************
    sub retrieve {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name( "retrieve" )
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my @elems;
        #foreach my $id (@{%in->{'ids'}}) {
        foreach my $id ( @{ $in{'ids'} } ) {
            push(
                @elems,
                SOAP::Data
                    ->prefix( $self->{'sf_prefix'} )
                    ->name('ids' => $id)
                    ->type('xsd:string')
            );
        }

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'fieldList' => $in{'fields'} )
                ->type( 'xsd:string'), 
            SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'sObjectType' => $in{'type'} )
                ->type( 'xsd:string' ),
            @elems,
            $self->get_session_header()
        );

        return $r;
    }

    #**************************************************************************
    # search()  --API
    #   -- TODO: write description
    #**************************************************************************
    sub search {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name( "search" )
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'searchString' => $in{'searchString'} )
                ->type( 'xsd:string' ), 
            $self->get_session_header()
        );
        return $r;
    }
    
    #**************************************************************************
    # setPassword()  --API
    #   -- TODO: write description
    #**************************************************************************
    sub setPassword {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);

        my $method = SOAP::Data
            ->name( "setPassword" )
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} );

        my $r = $client->call(
            $method => SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'userId' => $in{'userId'} )
                ->type( 'xsd:string' ), 
            SOAP::Data->prefix( $self->{'sf_prefix'} )
                ->name( 'password' => $in{'password'} )
                ->type( 'xsd:string' ), 
            $self->get_session_header()
        );
        return $r;
    }
    
    #**************************************************************************
    # update()  --API
    #   -- TODO: write description
    #**************************************************************************
    sub update {
        my $self = shift;
        my (%in) = @_;

        my $client = $self->get_client(1);
            
        my $method = SOAP::Data
            ->name("update")
            ->prefix( $self->{'sf_prefix'} )
            ->uri( $self->{'sf_uri'} )
            ->attr( { 'xmlns:sfons' => $self->{'sf_object_urn'} } );

        my $type = $in{'type'};
        delete($in{'type'});
        my $id = $in{'id'};
        delete($in{'id'});

        my @elems;
        push @elems,
            SOAP::Data
                ->prefix( $self->{'sf_prefix'} )
                ->name( 'Id' => $id )
                ->type( 'sforce:ID' );
    
        foreach my $key (keys %in) {
            push @elems,
                SOAP::Data
                    ->prefix( $self->{'sf_prefix'} )
                    ->name( $key => $in{$key} )
                    ->type( $WWW::Salesforce::Constants::TYPES{$type}->{$key} );
        }

        my $r = $client->call(
            $method => SOAP::Data
                ->name( 'sObjects' => \SOAP::Data->value( @elems ) )
                ->attr( { 'xsi:type' => 'sforce:'.$type } ),
            $self->get_session_header()
        );
        return $r;
    }
} #end of package scope

#magically delicious
1;

__END__

=pod
=head1 NAME

WWW::Salesforce v0.05 - this class provides a simple abstraction layer between SOAP::Lite and Salesforce.com.

=head1 SYNOPSIS

    use WWW::Salesforce;
  
    my $sforce = WWW::Salesforce->new( username => 'foo', password => 'bar' )
        or die $WWW::Salesforce::errstr;

=head1 DESCRIPTION

This class provides a simple abstraction layer between SOAP::Lite and Salesforce.com. Because SOAP::Lite does not support complexTypes, and document/literal encoding is limited, this module works around those limitations and provides a more intuitive interface a developer can interact with.

=head2 METHODS

=over 

=item login( HASH )

This method should *not* be called manually. it is handled on creation of a new WWW::Salesforce object.

The C<login> method returns a 1 if the login attempt was successful, and 0 otherwise. Upon a successful login, the sessionId is saved and the serverUrl set properly so that developers need not worry about setting these values manually.

The following are the accepted input parameters:

=over

=item username

A Salesforce.com username.

=item password

The password for the user indicated by C<username>.

=back

=item query( HASH )

Executes a query against the specified object and returns data that matches the specified criteria.

=over 

=item query

The query string to use for the query. The query string takes the form of a I<basic> SQL statement. For example, "SELECT Id,Name FROM Account".

See also: http://www.sforce.com/us/docs/sforce40/sforce_API_calls_SOQL.html#wp1452841

=item limit

This sets the batch size, or size of the result returned. This is helpful in producing paginated results, or fetch small sets of data at a time.

=back

=item queryMore( HASH )

Retrieves the next batch of objects from a C<query>.

=over 

=item queryLocator

The handle or string returned by C<query>. This identifies the result set and cursor for fetching the next set of rows from a result set.

=item limit

This sets the batch size, or size of the result returned. This is helpful in producing paginated results, or fetch small sets of data at a time.

=back

=item update( HASH )

Updates one or more existing objects in your organization's data. This subroutine takes as input a single perl HASH containing the fields (the keys of the hash) and the values of the record that will be updated.

The hash must contain the 'Id' key in order to identify the record to update.

=item create( HASH )

Adds one or more new individual objects to your organization's data. This takes as input a HASH containing the fields (the keys of the hash) and the values of the record you wish to add to your arganization.

The hash must contain the 'Type' key in order to identify the type of the record to add.

=item delete( ARRAY )

Deletes one or more individual objects from your organization's data. This subroutine takes as input an array of SCALAR values, where each SCALAR is an sObjectId.

=item getServerTimestamp()

Retrieves the current system timestamp (GMT) from the sforce Web service.

=item getUserInfo( HASH )

Retrieves personal information for the user associated with the current session.

=over

=item user

A user ID

=back

=item getUpdated( HASH )

Retrieves the list of individual objects that have been updated (added or changed) within the given timespan for the specified object.

=over

=item type

Identifies the type of the object you wish to find updates for.

=item start

A string identifying the start date/time for the query

=item end

A string identifying the end date/time for the query

=back

=item getDeleted( HASH )

Retrieves the list of individual objects that have been deleted within the given timespan for the specified object.

=over

=item type

Identifies the type of the object you wish to find deletions for.

=item start

A string identifying the start date/time for the query

=item end

A string identifying the end date/time for the query

=back

=item describeSObject( HASH )

Describes metadata (field list and object properties) for the specified object.

=over

=item type

The type of the object you wish to have described.

=back

=item describeLayout( HASH )

Describes metadata about a given page layout, including layouts for edit and display-only views and record type mappings.

=over

=item type

The type of the object you wish to have described.

=back

=item describeGlobal()

Retrieves a list of available objects for your organization's data.

=item setPassword( HASH )

Sets the specified user's password to the specified value.

=over

=item userId

A user Id.

=item password

The new password to assign to the user identified by C<userId>.

=back

=item resetPassword( HASH )

Changes a user's password to a server-generated value.

=over

=item userId

A user Id.

=back

=item retrieve( HASH )

=over

=item fields

A comma delimitted list of field name you want retrieved.

=item type

The type of the object being queried.

=item id

The id of the object you want returned.

=back

=item search( HASH )

=over

=item searchString

The search string to be used in the query. For example, "find {4159017000} in phone fields returning contact(id, phone, firstname, lastname), lead(id, phone, firstname, lastname), account(id, phone, name)"

=back

=back


=head1 EXAMPLES

=head2 login()

    use WWW::Salesforce;
    
    my $sforce = WWW::Salesforce->new( 'username' => $user,'password' => $pass )
        or die $WWW::Salesforce::errstr;
    
=head2 search()

    $result = $sforce->search('searchString' => 'find {4159017000} in phone fields returning contact(id, phone, firstname, lastname), lead(id, phone, firstname, lastname), account(id, phone, name)');

=head1 SUPPORT

Please visit Salesforce.com's user/developer forums online for assistance with
this module. You are free to contact the author directly if you are unable to
resolve your issue online.

=head1 AUTHORS

Chase Whitener <cwhitener at gmail dot com>

A big thanks to:
Byrne Reese <byrne at majordojo dot com>

Byrne Reese maintains SOAP::Lite and wrote the original Salesforce module.  The code in this module is more or less the original code written by Byrne, edited a lot to fit this structure.

=head1 COPYRIGHT

Copyright 2003-2004 Byrne Reese. All rights reserved.
=cut
