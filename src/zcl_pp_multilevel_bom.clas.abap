CLASS zcl_pp_multilevel_bom DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    TYPES: BEGIN OF ty_filters,
             Plant          TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             Material       TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             BOMComponent   TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             AlternativeBOM TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             CreateOn       TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             Validfrom      TYPE if_rap_query_filter=>ty_name_range_pairs-range,
             BOMStatus      TYPE if_rap_query_filter=>ty_name_range_pairs-range,
           END OF ty_filters.



    DATA: lt_paged_data TYPE TABLE OF ZI_MultiLevel_Bom,
          lt_BOMDATA    TYPE TABLE OF ZI_MultiLevel_Bom.

    METHODS:  read_filters IMPORTING filters_pair  TYPE if_rap_query_filter=>tt_name_range_pairs
                           RETURNING VALUE(result) TYPE ty_filters
                           RAISING   cx_root.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PP_MULTILEVEL_BOM IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_elements)    = io_request->get_sort_elements( ).

    "Ensure top is at least 1
    top = COND #( WHEN top < 0
                  THEN 1
                  ELSE top ).
**==>Gets the filters as ranges from the request.
    TRY.
        DATA(filters_pair) = io_request->get_filter( )->get_as_ranges( ).
      CATCH  cx_sy_ref_is_initial INTO DATA(lv_ref).
        lv_ref->get_longtext(  ).
      CATCH cx_rap_query_filter_no_range INTO DATA(error).
        error->get_longtext(  ).
        RETURN.
    ENDTRY.

**==>Reads the collection of filters from the filter pairs.
    TRY.
        DATA(filters) = read_filters( filters_pair ).
      CATCH cx_root INTO DATA(lv_root).
        lv_root->get_longtext(  ).
    ENDTRY.

**==> Get The BOM Status
    DATA:ls1 TYPE zd_bomstatus1.
    ls1 =  filters-bomstatus[ sign = 'I' option = 'EQ' ]-low.

**==>Query to select plants and materials from the I_MaterialBOMLink database.
    SELECT DISTINCT plant,
                    Material FROM I_MaterialBOMLink
                             WHERE Material IN @filters-material AND Plant IN @filters-plant
                             INTO TABLE @DATA(lt_BomLink).
    IF sy-subrc = 0.
      "iterates through the results for multiple Material's
      LOOP AT lt_BomLink ASSIGNING FIELD-SYMBOL(<fs_data>).

**==>To get the BOM components associated with the material and plant.
        SELECT * FROM ZI_BOM_Components1(  p_werks = @<fs_data>-Plant ,p_matnr = @<fs_data>-Material,
                                           p_status = @ls1 )
                 APPENDING CORRESPONDING FIELDS OF TABLE @lt_BOMDATA.

      ENDLOOP.
    ENDIF.

**==>Counts the number of rows obtained in lt_BOMDATA.
    DATA(max_rows) = lines( lt_BOMDATA ).
    "Calculate max index for pagination
    DATA(max_index) = COND int8( WHEN top IS NOT INITIAL AND top > 0
                                 THEN top + skip
                                 ELSE 0 ).

**==>Selects records from the lt_BOMDATA table with applied filters.
    SELECT  FROM @lt_BOMDATA AS _bomdata
    FIELDS *
            WHERE Material IN @filters-material
            AND Plant IN  @filters-plant
            AND BOMComponent IN  @filters-bomcomponent
            AND BOMStatus IN  @filters-bomstatus
            AND AlternativeBOM IN  @filters-alternativebom
            AND creationon IN  @filters-createon
            AND ValidityStartDate IN  @filters-validfrom
            INTO TABLE @DATA(ap_records)
            UP TO @max_index ROWS.
    IF sy-subrc = 0 AND skip IS NOT INITIAL.
      DELETE ap_records TO skip.
    ENDIF.
    SORT ap_records BY Plant Material AlternativeBOM BOMLevel BillOfMaterialItemNumber.

    "Apply filter on the Key fields to prevent the object page(Single Record) loading issue in the UI
    IF lines( ap_records ) = 1.
      max_rows = 1.
    ENDIF.

**==>Set the Data & total number of records
    TRY.
        io_response->set_total_number_of_records( CONV #( max_rows ) ).
        io_response->set_data( ap_records ).
      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).
    ENDTRY.

  ENDMETHOD.


  METHOD read_filters.


    result-plant = VALUE #( filters_pair[ name = 'PLANT' ]-range OPTIONAL ).
    result-material  = VALUE #( filters_pair[ name = 'MATERIAL' ]-range OPTIONAL ).
    result-bomcomponent  = VALUE #( filters_pair[ name = 'BOMCOMPONENT' ]-range OPTIONAL ).
    result-alternativebom  = VALUE #( filters_pair[ name = 'ALTERNATIVEBOM' ]-range OPTIONAL ).
    result-createon  = VALUE #( filters_pair[ name = 'CREATEON' ]-range OPTIONAL ).
    result-Validfrom  = VALUE #( filters_pair[ name = 'VALIDFROM' ]-range OPTIONAL ).
    result-bomstatus  = VALUE #( filters_pair[ name = 'BOMSTATUS' ]-range OPTIONAL ).


  ENDMETHOD.
ENDCLASS.
