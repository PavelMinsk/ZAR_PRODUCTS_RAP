@EndUserText.label: 'Custom entity for Business Partners'
@ObjectModel.query.implementedBy: 'ABAP:ZAR_CL_BP_QUERY_PROVIDER'
define custom entity ZAR_I_BUSINESS_PARTNER_C 
{
     @EndUserText.label: 'Business Partner'
 key BusinessPartner : abap.char( 10 ) ; 
     Customer : abap.char( 10 );
     @EndUserText.label: 'Business Partner Category'      
     BusinessPartnerCategory : abap.char( 1 ); 
     @EndUserText.label: 'Business Partner Grouping'  
     BusinessPartnerGrouping : abap.char( 4 );
     @EndUserText.label: 'Business Partner Name'
     BusinessPartnerFullName : abap.char( 81 );
}
