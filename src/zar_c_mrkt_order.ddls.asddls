@EndUserText.label: 'Market Order projection view'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity zar_c_mrkt_order
  as projection on zar_i_mrkt_order as MarketOrder
{
  key ProdUuid,
  key MrktUuid,
  key OrderUuid,
      Orderid,
      BussPartner,
      BussPartnerName,
      BussPartnerGroup,
      Quantity,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold : 0.8
      CalendarYear,
      DeliveryDate,
      @Semantics.amount.currencyCode :'Amountcurr'
      NetAmount,
      @Semantics.amount.currencyCode :'Amountcurr'
      GrossAmount,
      AmountCurr,
      OrderStatus,
      OrderStatusCriticality,
      CreatedBy,
      CreationTime,
      ChangedBy,
      ChangeTime,
      ImageOrderURL,

      _Product: redirected to zar_c_product,
      _ProductMarket : redirected to parent zar_c_prod_mrkt

}
