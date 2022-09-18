@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Market Order view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity zar_i_mrkt_order
  as select from zar_d_mrkt_order as MarketOrder

  association to parent zar_i_prod_mrkt as _ProductMarket on $projection.MrktUuid = _ProductMarket.MrktUuid
                                                         and $projection.ProdUuid = _ProductMarket.ProdUuid
  association [1..1] to zar_i_product   as _Product       on $projection.ProdUuid = _Product.ProdUuid
                                            
//  association [1..1] to ZAR_I_SUM_DELIV as _DeliverySum   on $projection.MrktUuid = _DeliverySum.MrktUuid
{
  key prod_uuid               as ProdUuid,
  key mrkt_uuid               as MrktUuid,
  key order_uuid              as OrderUuid,
      orderid                 as Orderid,
      busspartner             as BussPartner,
      busspartnername         as BussPartnerName,
      busspartnergroup        as BussPartnerGroup,
      quantity                as Quantity,
      calendar_year           as CalendarYear,
      delivery_date           as DeliveryDate,
      @Semantics.amount.currencyCode :'AmountCurr'
      netamount               as NetAmount,
      @Semantics.amount.currencyCode :'AmountCurr'
      grossamount             as GrossAmount,
      amountcurr              as AmountCurr,
      status                  as OrderStatus,
      case status
        when 'X' then 3
        else 1
      end                     as OrderStatusCriticality,
      @Semantics.user.createdBy: true
      created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      creation_time           as CreationTime,
      @Semantics.user.lastChangedBy: true
      changed_by              as ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      change_time             as ChangeTime,
     
      'https://i7.pngguru.com/preview/423/632/57/computer-icons-purchase-order-order-fulfillment-purchasing-order-icon.jpg' as ImageOrderURL,
      
      _Product,
      _ProductMarket
//      ,_DeliverySum
}
