@AbapCatalog.sqlViewName: 'ZARISUMDELIV'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aggregation view for Delivery Date'

@UI.chart: [
{
qualifier: 'ChartOrderQuantity',
title: 'Orders Quantity by Delivery Date',
chartType: #BAR,
dimensions: [ 'DeliveryDate'],
measures: [ 'DateQuantity'],
dimensionAttributes: [{ dimension: 'DeliveryDate', role: #CATEGORY }],
measureAttributes: [{ measure: 'DateQuantity', role: #AXIS_1 }]
}
,
{
qualifier: 'ChartOrderAmount',
title: 'Orders Amounts by Delivery Date',
chartType: #BAR,
dimensions: [ 'DeliveryDate'],
measures: [ 'DateGrossAmount', 'DateNetAmount' ],
dimensionAttributes: [{ dimension: 'DeliveryDate', role: #CATEGORY }],
measureAttributes: [
{ measure: 'DateGrossAmount', role: #AXIS_1 },
{ measure: 'DateNetAmount', role: #AXIS_1 }
]
}
]

define view ZAR_I_SUM_DELIV
  as select from zar_d_mrkt_order
{
  key prod_uuid     as ProdUuid,
  key mrkt_uuid     as MrktUuid,
  key order_uuid    as OrderUuid,
      delivery_date as DeliveryDate,
      @Aggregation.default: #SUM
      quantity      as DateQuantity,
      @Semantics.amount.currencyCode :'AmountCurr'
      @Aggregation.default: #SUM
      grossamount   as DateGrossAmount,
      @Semantics.amount.currencyCode :'AmountCurr'
      @Aggregation.default: #SUM
      netamount     as DateNetAmount,
      amountcurr    as AmountCurr

}

