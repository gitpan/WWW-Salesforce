package WWW::Salesforce::SObject;
use 5.008001;
use Moose; #turns on strict and warnings
use Moose::Util::TypeConstraints;
#use Data::Dumper;
use WWW::Salesforce::Error;

use Carp qw(croak carp confess);

use vars qw( $VERSION );
$VERSION = '0.001'; # note: should be x.xxx (three decimal places)

subtype 'SF::ID'
    => as 'Maybe[Str]'
    => where { (!defined($_) || /^[a-zA-Z0-9]{15,18}$/) };
    #=> message { "The ID you provided, $_, was not a valid ID." };

subtype 'SF::Error'
    => as 'Object'
    => where { $_->isa('WWW::Salesforce::Error') };
    
subtype 'SF::ErrorArray'
    => as 'ArrayRef[SF::Error]'
    ;#=> where {};
coerce 'SF::ErrorArray'
    => from 'HashRef'
    => via {
        my @array = ();
        my %hash = ();
        for my $key ( keys %{$_} ) {
            my $val = $_->{$key};
            $hash{$key} = $val;
            if ( lc($key) eq 'success' ) {
                $hash{$key} = (lc($val) eq 'true')? 1: 0;
            }
        }
        push @array, WWW::Salesforce::Error->new(%hash);
        \@array
    };
no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=pod

=head1 NAME

WWW::Salesforce::SObject - A standard object which all other Salesforce objects extend.

=head1 DESCRIPTION

A base class for all other Salesforce objects

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
