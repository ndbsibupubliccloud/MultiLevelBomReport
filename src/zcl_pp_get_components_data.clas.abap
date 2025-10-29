CLASS zcl_pp_get_components_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .
    CLASS-METHODS get_bom_component FOR TABLE FUNCTION zi_bom_components1.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PP_GET_COMPONENTS_DATA IMPLEMENTATION.


  METHOD get_bom_component
           BY DATABASE FUNCTION FOR HDB
           LANGUAGE SQLSCRIPT
           USING  ZI_BillOfMaterial_ML1.
*** variable declaration
    declare lv_count integer;
    declare lv_level integer;

***initialize the BOM Level = 1
    lv_level = 1;
***select the data for 1st Level BOM
    root_bom = select   mandt,
                        Material,
                        Plant,
                        BOMStatus,
                        AlternativeBOM,
                        BillOfMaterialItemNumber,
                        BOMComponent,
                        MaterialDescription,
                       '' as subBOM,
                       '' as SubBOMDesc,
*                       subalternativebom,
                       '' as subalternativebom,
                        Quantity,
                        BaseUOM,
                        componentdescription as ComponentDescription,
                        ComponentQty,
                        ComponentUOM,
                        ValidityStartDate,
                        ValidityEndDate,
                        :lv_level as bomlevel,
                        CreationOn
                        from zi_billofmaterial_ml1
                        where mandt    = :p_clnt
                        and plant    = :p_werks
                        and material = :p_matnr
                        and BOMStatus = :p_status;
***pass the selected BOM data into OUT_BOM
    out_bom = select * from :root_bom;
***select the components from the 1st Level BOM
    components = select BOMcomponent,
                        Material,
                        MaterialDescription,
                        AlternativeBOM,
                        componentdescription from :root_bom;
***select the count of components from the 1st Level BOM
    select count ( * ) into lv_count from :components;
***if the components are found, check for next level BOM data
    while :lv_count > 0 do
***increment the BOM level
        lv_level = lv_level + 1;
***select the data for the BOM of components
        child_bom = select  mandt,
                            b.material,
                            a.Plant,
                            a.BOMStatus,
                            b.AlternativeBOM,
                            a.BillOfMaterialItemNumber,
                            a.BOMComponent,
*                            a.MaterialDescription,
                            b.MaterialDescription,
                            b.BOMcomponent as subBOM,
                            b.componentdescription as SubBOMDesc,
                            a.subalternativebom,
                            a.Quantity,
                            a.BaseUOM,
                            a.componentdescription,
                            a.ComponentQty,
                            a.ComponentUOM,
                            a.ValidityStartDate,
                            a.ValidityEndDate,
                            :lv_level as bomlevel,
                            a.creationon
                             from ZI_BillOfMaterial_ML1 as a
                             inner join :components as b
                               on  a.plant    = :p_werks
                            and a.material = b.BOMcomponent
                            and a.BOMStatus = :p_status;
***select the components from the above selected child BOM
        components = SELECT bomcomponent,
                            material,
                            MaterialDescription,
                            AlternativeBOM,
                            componentdescription from :child_bom;
***select the count of components from the above selected child BOM
*** if the count of component from this level is 0, then while loop will be terminated
        SELECT COUNT ( * ) into lv_count from :components;
***merge the BOM data (OUT_BOM) with the components from current level in selection
        out_bom = select * from:out_bom
                    union all
                  select * from :child_bom;
    end while;

***return the data back to table function using RETURN
    return select * from :out_bom order by Plant,Material;



  ENDMETHOD.
ENDCLASS.
