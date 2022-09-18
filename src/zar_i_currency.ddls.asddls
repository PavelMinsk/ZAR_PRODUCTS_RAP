@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Currency view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
//@ObjectModel.resultSet.sizeCategory: #XS
define view entity zar_i_currency
  as select from I_Currency as Currency
{
  key Currency,
      Decimals,
      CurrencyISOCode,
      AlternativeCurrencyKey,
      IsPrimaryCurrencyForISOCrcy,
      /* Associations */
      _Text
}
