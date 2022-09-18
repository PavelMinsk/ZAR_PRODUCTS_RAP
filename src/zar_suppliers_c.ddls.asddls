@EndUserText.label: 'Custom Entity for Suppliers'
@ObjectModel.query.implementedBy: 'ABAP:ZAR_CL_SUPPL_QUERY_PROVIDER'
@UI.headerInfo: { typeNamePlural: 'Suppliers',
                        typeName: 'Supplier' }


define root custom entity ZAR_SUPPLIERS_C  {

  // Header Facet
  @UI.facet: [
             {purpose:  #HEADER,
             position: 10,
             type: #DATAPOINT_REFERENCE,
             targetQualifier: 'HeaderCity'
             },
             {purpose:  #HEADER,
             position: 20,
             type: #DATAPOINT_REFERENCE,
             targetQualifier: 'HeaderCountry'
             },
             {purpose:  #HEADER,
             position: 30,
             type: #DATAPOINT_REFERENCE,
             targetQualifier: 'HeaderSupplierID'
             },
  //Collection Facet
  //Facet General Information
             {label: 'General Information',
             id: 'GeneralInfo',
             purpose: #STANDARD,
             position: 10,
             type: #COLLECTION
             },
  //General Information Groups 
  //Field Group 'General Information'
             {label: 'General Information',
             purpose: #STANDARD,
             position: 10,
             type: #IDENTIFICATION_REFERENCE,
             parentId: 'GeneralInfo'}
            ]

 @EndUserText.label: 'Supplier ID'
 @UI: { lineItem      : [{ position: 10 }],
        selectionField: [{ position: 10 }],
        identification: [{ position: 10 }],
        dataPoint: { qualifier: 'HeaderSupplierID' } }
 @Consumption.valueHelpDefinition:
     [{ entity: { name:    'zar_suppliers_c',
                  element: 'SupplierID' } }]        
 key SupplierID : abap.int4 ; 

 @EndUserText.label: 'Company Name'
 @UI: { lineItem      : [{ position: 20 }],
        identification: [{ position: 20 }],
        selectionField: [{ position: 20 }] }
 @Consumption.valueHelpDefinition:
     [{ entity: { name:    'zar_suppliers_c',
                  element: 'CompanyName' } }] 
 CompanyName : abap.char( 40 ) ;
 
 @EndUserText.label: 'Contact Name'
 @UI: { lineItem      : [{ position: 30 }],
        identification: [{ position: 30 }],
        selectionField: [{ position: 30 }] }
 @Consumption.valueHelpDefinition:
     [{ entity: { name:    'zar_suppliers_c',
                  element: 'ContactName' } }] 
 ContactName : abap.char( 30 ) ;
 
 @EndUserText.label: 'Contact Title'
 @UI: { lineItem      : [{ position: 40 }],
        identification: [{ position: 40 }] }
 ContactTitle : abap.char( 30 ) ;
 
 @EndUserText.label: 'Address' 
 @UI: { lineItem      : [{ position: 70 }],
        identification: [{ position: 70 }] }    
 Address : abap.char( 60 ) ;
 
 @EndUserText.label: 'City'
 @UI: { lineItem      : [{ position: 60 }],
        identification: [{ position: 60 }],
        dataPoint     :  { qualifier: 'HeaderCity' } }
 City : abap.char( 15 ) ;
 
 @EndUserText.label: 'Region' 
 @UI: { identification: [{ position: 80 }]}
 Region : abap.char( 15 ) ; 
 
 @EndUserText.label: 'Postal Code' 
 @UI: { identification: [{ position: 90 }]}
 PostalCode : abap.char( 10 ) ;
 @EndUserText.label: 'Country'
 @UI: { lineItem      : [{ position: 50 }],
        identification: [{ position: 50 }],
        selectionField: [{ position: 30 }],
        dataPoint     : { qualifier: 'HeaderCountry' } }
 @Consumption.valueHelpDefinition:
     [{ entity: { name:    'zar_suppliers_c',
                  element: 'Country' } }] 
 Country : abap.char( 15 ) ; 
 
 @EndUserText.label: 'Phone'  
 @UI: { lineItem   : [{ position: 75 }],
        identification: [{ position: 100 }] } 
 Phone : abap.char( 24 ) ;
  
 @EndUserText.label: 'Fax'  
 @UI: { identification: [{ position: 110 }]}
 Fax : abap.char( 24 ) ; 

 @EndUserText.label: 'Home Page' 
 @UI: { identification: [{ position: 120 }]}
 HomePage : abap.string( 0 ) ; 
 
 @EndUserText.label: 'Discount (%)'
 @UI: { lineItem   : [{ position: 80 }],
        identification: [{ position: 130 }] }
 discount_pct   : abap.dec(3,1);
 
 @EndUserText.label: 'Last Сhanged At' 
 @UI: { identification: [{ position: 140 }]}
 lastchangedat  : timestampl;
}
