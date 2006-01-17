package WWW::Salesforce::Constants;
{
    use strict;
    use warnings;
    BEGIN {
        use vars qw(%TYPES);
        %TYPES = (
            'Account' => {
                'AccountNumber' => 'xsd:string',
                'Active__c' => 'xsd:string',
                'AnnualRevenue' => 'xsd:double',
                'BillingCity' => 'xsd:string',
                'BillingCountry' => 'xsd:string',
                'BillingPostalCode' => 'xsd:string',
                'BillingState' => 'xsd:string',
                'BillingStreet' => 'xsd:string',
                'CreatedById' => 'tns:ID',
                'CreatedDate' => 'xsd:dateTime',
                'CustomerPriority__c' => 'xsd:string',
                'Description' => 'xsd:string',
                'Fax' => 'xsd:string',
                'Industry' => 'xsd:string',
                'LastModifiedById' => 'tns:ID',
                'LastModifiedDate' => 'xsd:dateTime',
                'Name' => 'xsd:string',
                'NumberOfEmployees' => 'xsd:int',
                'NumberofLocations__c' => 'xsd:double',
                'OwnerId' => 'tns:ID',
                'Ownership' => 'xsd:string',
                'ParentId' => 'tns:ID',
                'Phone' => 'xsd:string',
                'Rating' => 'xsd:string',
                'SLAExpirationDate__c' => 'xsd:date',
                'SLASerialNumber_c' => 'xsd:string',
                'SLA__c' => 'xsd:string',
                'ShippingCity' => 'xsd:string',
                'ShippingCountry' => 'xsd:string',
                'ShippingPostalCode' => 'xsd:string',
                'ShippingState' => 'xsd:string',
                'ShippingStreet' => 'xsd:string',
                'Sic' => 'xsd:string',
                'Site' => 'xsd:string',
                'SystemModstamp' => 'xsd:sateTime',
                'TickerSymbol' => 'xsd:string',
                'Type' => 'xsd:string',
                'UpsellOpportunity__c' => 'xsd:string',
                'Website' => 'xsd:string',
            },
        );
    }
}

#magically delicious
1;
