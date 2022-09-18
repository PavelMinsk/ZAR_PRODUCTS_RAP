@AbapCatalog.sqlViewName: 'ZARISUMORDER'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aggregation view for ZAR_I_MRKT_ORDER'


define view ZAR_I_SUM_ORDER as select from zar_d_mrkt_order {

      key mrkt_uuid as MrktUuid,
      sum(quantity) as TotalQuantity,
      @Semantics.amount.currencyCode :'AmountCurr'
      sum(netamount) as TotalNetAmount,
      @Semantics.amount.currencyCode :'AmountCurr'
      sum(grossamount)   as TotalGrossAmount,
      amountcurr as AmountCurr

}
group by mrkt_uuid,
         amountcurr
