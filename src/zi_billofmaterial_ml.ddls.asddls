@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bill of Material - Multi Level Explosion'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BillOfMaterial_ML

  as select from    I_MaterialBOMLink           as _mast
    inner join      I_BillOfMaterialItemDEX_3   as _Item       on  _mast.BillOfMaterialCategory = _Item.BillOfMaterialCategory
                                                               and _mast.BillOfMaterial         = _Item.BillOfMaterial
                                                               and _mast.BillOfMaterialVariant  = _Item.BillOfMaterialVariant
    inner join      I_BillOfMaterialHeaderDEX_2 as _hdr        on  _Item.BillOfMaterialCategory = _hdr.BillOfMaterialCategory
                                                               and _Item.BillOfMaterial         = _hdr.BillOfMaterial
                                                               and _Item.BillOfMaterialVariant  = _hdr.BillOfMaterialVariant
    left outer join I_ProductText               as _BOMMatDesc on  _mast.Material       = _BOMMatDesc.Product
                                                               and _BOMMatDesc.Language = $session.system_language
    left outer join I_ProductText               as _CompDesc   on  _Item.BillOfMaterialComponent = _CompDesc.Product
                                                               and _BOMMatDesc.Language          = $session.system_language
{
  key     _mast.Plant,
  key     _mast.Material,
  key     _Item.BillOfMaterialCategory,
  key     _Item.BillOfMaterial,
  key     _Item.BillOfMaterialVariant      as AlternativeBOM,
  key     _Item.BillOfMaterialItemNodeNumber,
  key     _Item.BillOfMaterialVersion,
  key     _Item.BOMItemInternalChangeCount,
          _Item.BillOfMaterialVariant      as SUBAlternativeBOM,
          case _hdr.BillOfMaterialStatus
          when '01'
          then 'Active'
          else 'Inactive'  end             as BOMStatus,
          _Item.ValidityStartDate,
          _Item.ValidityEndDate,
          //          _Item.BOMItemDescription         as MaterialDescription,
          _BOMMatDesc.ProductName          as MaterialDescription,
          _mast.Material                   as MainMat,
          @Semantics.quantity.unitOfMeasure: 'BaseUOM'
          _hdr.BOMHeaderQuantityInBaseUnit as Quantity,
          _hdr.BOMHeaderBaseUnit           as BaseUOM,
          _Item.BillOfMaterialComponent    as BOMComponent,
          _CompDesc.ProductName            as ComponentDescription,
          @Semantics.quantity.unitOfMeasure: 'ComponentUOM'
          _Item.BillOfMaterialItemQuantity as ComponentQty,
          _Item.BillOfMaterialItemUnit     as ComponentUOM,
          _mast.BillOfMaterialVariantUsage as BOMUsage,
          _Item.BOMItemRecordCreationDate  as CreationOn


}

////where
////      _BOMItem.ValidityStartDate <= $parameters.p_datum
//  and _BOMItem.ValidityEndDate   >= $parameters.p_datum
