@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Products view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zar_i_product
  as select from zar_d_product as Product

  composition [0..*] of zar_i_prod_mrkt as _ProductMarket

  association [0..1] to zar_i_prod_group as _ProductGroup  on $projection.Pgid = _ProductGroup.Pgid
  association [0..1] to zar_i_phase      as _Phase         on $projection.Phaseid = _Phase.Phaseid
  association [0..1] to zar_i_uom        as _UnitOfMeasure on $projection.SizeUOM = _UnitOfMeasure.Msehi

{
  key prod_uuid      as ProdUuid,
      prodid         as Prodid,
      pgid           as Pgid,
      _ProductGroup.Pgname as Pgname,
      pgname_trans   as PgnameTrans,
      trans_code     as TransCode,
      phaseid        as Phaseid,
      height         as Height,
      depth          as Depth,
      width          as Width,
      size_uom       as SizeUOM,
      @Semantics.amount.currencyCode: 'PriceCurrency'
      price          as Price,
      price_currency as PriceCurrency,
      taxrate        as Taxrate,
      @Semantics.user.createdBy: true
      created_by     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      creation_time  as CreationTime,
      @Semantics.user.lastChangedBy: true
      changed_by     as ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      change_time    as ChangeTime,
      @Semantics.systemDateTime.lastChangedAt: true
      total_changed_at as TotalChangedAt,

      _ProductMarket,
      _ProductGroup,
      _Phase,
      _UnitOfMeasure

}
