@EndUserText.label: 'Product Market projection view'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity zar_c_prod_mrkt
  as projection on zar_i_prod_mrkt as ProductMarket
{
  key ProdUuid,
  key MrktUuid,
      Mrktid,
      _CountryMarket.imageurl as ImageCountryURL,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold : 0.8
      MarketName,
      Status,
      ISOcode,
      StatusCriticality,
      Startdate,
      Enddate,
      _TotalSum.TotalQuantity as TotalQuantity,
      @Semantics.amount.currencyCode :'Amountcurr'     
      _TotalSum.TotalNetAmount,  
      @Semantics.amount.currencyCode :'Amountcurr'
      _TotalSum.TotalGrossAmount, 
      _TotalSum.AmountCurr, 
      CreatedBy,
      CreationTime,
      ChangedBy,
      ChangeTime,

      /* Associations */
      _CountryMarket,
      _MarketOrder : redirected to composition child zar_c_mrkt_order,
      _Product : redirected to parent zar_c_product,
      _TotalSum,
      _TotalDeliv
      
}
