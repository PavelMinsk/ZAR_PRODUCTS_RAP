/********** GENERATED on 06/25/2022 at 08:12:16 by CB9980004616**************/
 @OData.entitySet.name: 'Suppliers' 
 @OData.entityType.name: 'Supplier' 
 define root abstract entity ZAR_SUPPLIERS { 
 key SupplierID : abap.int4 ; 
 CompanyName : abap.char( 40 ) ; 
 @Odata.property.valueControl: 'ContactName_vc' 
 ContactName : abap.char( 30 ) ; 
 ContactName_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'ContactTitle_vc' 
 ContactTitle : abap.char( 30 ) ; 
 ContactTitle_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Address_vc' 
 Address : abap.char( 60 ) ; 
 Address_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'City_vc' 
 City : abap.char( 15 ) ; 
 City_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Region_vc' 
 Region : abap.char( 15 ) ; 
 Region_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'PostalCode_vc' 
 PostalCode : abap.char( 10 ) ; 
 PostalCode_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Country_vc' 
 Country : abap.char( 15 ) ; 
 Country_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Phone_vc' 
 Phone : abap.char( 24 ) ; 
 Phone_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'Fax_vc' 
 Fax : abap.char( 24 ) ; 
 Fax_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'HomePage_vc' 
 HomePage : abap.string( 0 ) ; 
 HomePage_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 
 } 
