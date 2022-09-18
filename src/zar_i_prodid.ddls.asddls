@AbapCatalog.sqlViewName: 'ZARIPRODID'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product ID View'
@ObjectModel.resultSet.sizeCategory: #XS
define view ZAR_I_PRODID as select from zar_d_product {

key prod_uuid as prod_uuid,
    prodid  as  Prodid  

    
}
