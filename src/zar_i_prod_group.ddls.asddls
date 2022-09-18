@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Group view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zar_i_prod_group
  as select from zar_d_prod_group as ProductGroup
{
  key pgid     as Pgid,
      pgname   as Pgname,
      @Semantics.imageUrl: true
      imageurl as Imageurl
}
