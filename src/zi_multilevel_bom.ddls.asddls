@EndUserText.label: 'View for Multi Level BOM'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_PP_MULTILEVEL_BOM'
@UI: {
        headerInfo: {
            title: {
                value: 'Material',
                type: #STANDARD
            },
            typeName: 'Multi Level BOM Details',
            typeNamePlural: 'Multi Level BOM Details'
        } }

define custom entity ZI_MultiLevel_Bom
{
      @UI.facet                : [{
       id                      : 'MultiLevel',
       position                :10 ,
       label                   : 'Multi-Level BOM Report',
       type                    : #IDENTIFICATION_REFERENCE

      }]


      // @Consumption.filter  : { selectionType: #INTERVAL, mandatory: true, defaultValue: 'Active' }
      @UI.selectionField       : [{position: 10 }]
      @UI                      : { lineItem: [{ position: 30 }],identification: [{ position: 30 }] }
      @EndUserText.label       : 'Plant'
      @Consumption             : { valueHelpDefinition: [{ entity : { name: 'I_Plant',
                                                                      element: 'Plant'  } } ] }
  key Plant                    : werks_d;

      // @Consumption.filter  : { selectionType: #INTERVAL, mandatory: true, defaultValue: 'Active' }
      @UI.selectionField       : [{position: 20 }]
      @UI                      : { lineItem: [{ position: 40 }],identification: [{ position: 40 }] }
      @EndUserText.label       : 'Material'
      @Consumption             : { valueHelpDefinition: [{ entity : { name: 'I_ProductPlantbasic',
                                                                      element: 'Product'  } } ] }
  key Material                 : matnr;

      @UI                      : { lineItem: [{ position: 10 }],identification: [{ position: 10 }] }
      @EndUserText.label       : 'BOM Status'
      @Consumption.filter      : { selectionType: #SINGLE, mandatory: true, defaultValue: 'Active' }
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_BOMSTATUS_VH', element: 'text' } }]
  key BOMStatus                : zd_bomstatus1;

      @UI                      : { lineItem: [{ position: 20 }],identification: [{ position: 20 }] }
      @EndUserText.label       : 'Alternative BOM'
      @UI.selectionField       : [{position: 50 }]
  key AlternativeBOM           : abap.char(2);

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 110 }],identification: [{ position: 110 }] }
      @EndUserText.label       : 'BOM Component Item'
  key BillOfMaterialItemNumber : abap.char( 4 );

      @UI                      : { lineItem: [{ position: 120 }],identification: [{ position: 120 }] }
      @EndUserText.label       : 'BOM Component'
      @UI.selectionField       : [{position: 40 }]
      @Consumption             : { valueHelpDefinition: [{ entity : { name: 'I_ProductPlantbasic',
                                                                      element: 'Product'  } } ] }
  key BOMComponent             : matnr;

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 50 }],identification: [{ position: 50 }] }
      @EndUserText.label       : 'Material Description'
      MaterialDescription      : maktx;

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 60 }],identification: [{ position: 60 }] }
      @EndUserText.label       : 'Sub Alternative BOM'
      SUBAlternativeBOM        : abap.char(2);

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 70 }],identification: [{ position: 70 }] }
      @EndUserText.label       : 'Sub BOM'
      subBOM                   : matnr;

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 80 }],identification: [{ position: 80 }] }
      @EndUserText.label       : 'Sub BOM Description'
      SubBOMDesc               : maktx;

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 90 }],identification: [{ position: 90 }] }
      @EndUserText.label       : 'Base Quantity'
      //      @Semantics.quantity.unitOfMeasure: 'BaseUOM'
      //      Quantity             : abap.quan(13,3);
      Quantity                 : abap.dec(13,3);

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 100 }],identification: [{ position: 100 }] }
      @EndUserText.label       : 'Base UOM'
      BaseUOM                  : abap.unit( 3 );

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 130 }],identification: [{ position: 130 }] }
      @EndUserText.label       : 'Component Description'
      ComponentDescription     : maktx;

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 140 }],identification: [{ position: 140 }] }
      @EndUserText.label       : 'Component Qty'
      //      @Semantics.quantity.unitOfMeasure: 'BaseUOM'
      //      ComponentQty         : abap.quan(13,3);
      ComponentQty             : abap.dec(13,3);

      @Consumption.filter.hidden:true
      @UI                      : { lineItem: [{ position: 150 }],identification: [{ position: 150 }] }
      @EndUserText.label       : 'Component UOM'
      ComponentUOM             : abap.unit( 3 );

      @EndUserText.label       : 'Creation On'
      @UI.selectionField       : [{position: 60 }]
      creationon               : datum;

      @Consumption.filter.hidden:true
      BOMLevel                 : abap.int4;

      @Consumption.filter.hidden:true
      ValidityStartDate        : datuv;

      @Consumption.filter.hidden:true
      ValidityEndDate          : datuv;

}
