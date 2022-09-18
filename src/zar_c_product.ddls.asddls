@EndUserText.label: 'Products projection view'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity zar_c_product
  provider contract transactional_query
  as projection on zar_i_product as Product
{
  key ProdUuid,
      Prodid,
      Pgid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold : 0.8
      Pgname, 
      PgnameTrans,
      TransCode,
      _ProductGroup.Imageurl as Imageurl,
      @ObjectModel.text.element: ['Phase']
      Phaseid,
      _Phase.Phase as Phase,
      @Semantics.quantity.unitOfMeasure:'SizeUOM'
      Height,
      @Semantics.quantity.unitOfMeasure:'SizeUOM'
      Depth,
      @Semantics.quantity.unitOfMeasure:'SizeUOM'
      Width,
      @Semantics.unitOfMeasure: true
      SizeUOM,
      @Semantics.amount.currencyCode: 'PriceCurrency'
      Price,
      PriceCurrency,
      Taxrate,
      CreatedBy,
      CreationTime,
      ChangedBy,
      ChangeTime,
      /* Associations */
      _Phase,
      _ProductGroup,
      _ProductMarket : redirected to composition child zar_c_prod_mrkt,
      _UnitOfMeasure
}
