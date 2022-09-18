@AbapCatalog.sqlViewName: 'ZARIMARKETLANG'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Language Code View'
@ObjectModel.resultSet.sizeCategory: #XS
define view ZAR_I_MARKET_LANG as select from zar_d_market {

   key code as Code

}
group by code
