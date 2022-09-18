@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Product Market view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zar_i_prod_mrkt
  as select from zar_d_prod_mrkt as ProductMarket

  association to parent zar_i_product        as _Product       on $projection.ProdUuid = _Product.ProdUuid
  composition [0..*] of zar_i_mrkt_order     as _MarketOrder

  association [0..1] to zar_d_market         as _CountryMarket on $projection.Mrktid = _CountryMarket.mrktid
  association [1..1] to ZAR_I_SUM_ORDER      as _TotalSum      on $projection.MrktUuid = _TotalSum.MrktUuid
  association [0..*] to ZAR_I_SUM_DELIV      as _TotalDeliv    on $projection.MrktUuid = _TotalDeliv.MrktUuid

{
  key prod_uuid               as ProdUuid,
  key mrkt_uuid               as MrktUuid,
      mrktid                  as Mrktid,
      _CountryMarket.mrktname as MarketName,
      status                  as Status,
      isocode                 as ISOcode,
      case status
        when 'X' then 3
        else 1
      end                     as StatusCriticality,
      startdate               as Startdate,
      enddate                 as Enddate,
      @Semantics.user.createdBy: true
      created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      creation_time           as CreationTime,
      @Semantics.user.lastChangedBy: true
      changed_by              as ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      change_time             as ChangeTime,

      _Product,
      _MarketOrder,
      _CountryMarket,
      _TotalSum
     , _TotalDeliv
}
