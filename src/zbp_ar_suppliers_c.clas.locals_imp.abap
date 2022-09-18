CLASS lcl_buffer DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO lcl_buffer.

    "types used in get_data
    TYPES: BEGIN OF mty_s_message,
             supplierid TYPE zar_suppliers_c-SupplierID,
             symsg      TYPE symsg,
             fields     TYPE string_table,
           END OF mty_s_message,
           mty_t_suppliers        TYPE STANDARD TABLE OF zar_suppliers_c,
           mty_t_suppliers_in     TYPE TABLE FOR READ IMPORT zar_suppliers_c,
           mty_t_suppliers_out    TYPE TABLE FOR READ RESULT zar_suppliers_c,
           mty_t_suppliers_failed TYPE TABLE FOR FAILED zar_suppliers_c,
           mty_t_message          TYPE STANDARD TABLE OF mty_s_message,
    "types used in put_data
           mty_t_suppliers_upd    TYPE TABLE FOR UPDATE zar_suppliers_c,
           mty_t_suppliers_mapped TYPE TABLE FOR MAPPED zar_suppliers_c.

    METHODS put_data
      IMPORTING it_suppliers_upd     TYPE mty_t_suppliers_upd
      EXPORTING et_supppliers_failed TYPE mty_t_suppliers_failed
                et_message           TYPE mty_t_message.

    METHODS get_data
      IMPORTING it_suppliers        TYPE mty_t_suppliers_in OPTIONAL
      EXPORTING et_suppliers        TYPE mty_t_suppliers_out
                et_suppliers_failed TYPE mty_t_suppliers_failed
                et_message          TYPE mty_t_message.

  PROTECTED SECTION.
    CLASS-DATA: go_instance TYPE REF TO lcl_buffer.
    DATA: mt_suppliers TYPE mty_t_suppliers.
  PRIVATE SECTION.

ENDCLASS.

CLASS lhc_ZAR_SUPPLIERS_C DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES: mty_t_suppliers_reported TYPE TABLE FOR REPORTED zar_suppliers_c.

    METHODS read_suppliers FOR READ
      IMPORTING it_suppliers_read FOR READ Suppliers
      RESULT    et_result.

    METHODS update_suppliers FOR MODIFY
      IMPORTING it_suppliers_update FOR UPDATE Suppliers.

ENDCLASS.


CLASS lsc_zar_suppliers_c DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

ENDCLASS.




CLASS lhc_zar_suppliers_c IMPLEMENTATION.

  METHOD read_suppliers.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    lo_buffer->get_data( EXPORTING it_suppliers        = it_suppliers_read
                         IMPORTING et_suppliers        = et_result
                                   et_suppliers_failed = failed-suppliers ).
  ENDMETHOD.

  METHOD update_suppliers.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    lo_buffer->put_data( EXPORTING it_suppliers_upd = it_suppliers_update ).

  ENDMETHOD.

ENDCLASS.

CLASS lcl_buffer IMPLEMENTATION.

  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD get_data.

    DATA: ls_result            LIKE LINE OF et_suppliers.
    DATA: lt_supplier_id       TYPE STANDARD TABLE OF zar_suppliers_c-SupplierID.
    DATA: lt_ranges            TYPE if_rap_query_filter=>tt_range_option.
    DATA: lt_filter_conditions TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_business_data_ce  TYPE STANDARD TABLE OF zar_suppliers_c.
    DATA: lt_suppladd          TYPE STANDARD TABLE OF zar_suppladd.

    FIELD-SYMBOLS: <ls_business_data_ce> LIKE LINE OF lt_business_data_ce.

    IF it_suppliers IS NOT SUPPLIED. "IS INITIAL.
      et_suppliers = CORRESPONDING #( mt_suppliers ).
      EXIT.
    ENDIF.

    LOOP AT it_suppliers ASSIGNING FIELD-SYMBOL(<ls_supplier>).
      IF line_exists( mt_suppliers[ SupplierID = <ls_supplier>-SupplierID ] ).
        ls_result = CORRESPONDING #( mt_suppliers[ SupplierID = <ls_supplier>-SupplierID ] ).
        " collect from buffer for result
        APPEND ls_result TO et_suppliers.
      ELSE.
        " collect to retrieve from persistence
        APPEND <ls_supplier>-SupplierID TO lt_supplier_id.
      ENDIF.
    ENDLOOP.

    CHECK lt_supplier_id IS NOT INITIAL.


    TRY.
        lt_ranges = VALUE #( FOR ls_supplier_id IN lt_supplier_id ( sign = 'I' option = 'EQ' low = ls_supplier_id ) ).
        lt_filter_conditions = VALUE #( ( name = 'SUPPLIERID' range = lt_ranges ) ).

        NEW zar_cl_suppl_query_provider(  )->get_suppliers(
          EXPORTING
            it_filter_conditions  = lt_filter_conditions
          IMPORTING
            et_business_data     = DATA(lt_business_data) ).

        " add local data
        CHECK lt_business_data IS NOT INITIAL.

        " map OData service to custom entity
        lt_business_data_ce = CORRESPONDING #( lt_business_data ).

        CHECK lt_business_data_ce IS NOT INITIAL.

        SELECT * FROM zar_suppladd
          FOR ALL ENTRIES IN @lt_business_data_ce
            WHERE supplierid = @lt_business_data_ce-SupplierID
          INTO TABLE @lt_suppladd.

        LOOP AT lt_supplier_id ASSIGNING FIELD-SYMBOL(<ls_suppplier_id>).
          IF line_exists( lt_business_data_ce[ SupplierID = <ls_suppplier_id> ] ).

            ASSIGN lt_business_data_ce[ SupplierID = <ls_suppplier_id> ] TO <ls_business_data_ce>.

            IF line_exists( lt_suppladd[ supplierid = <ls_business_data_ce>-SupplierID ] ).
              <ls_business_data_ce>-discount_pct = lt_suppladd[ supplierid = <ls_business_data_ce>-SupplierID ]-discount_pct.
              <ls_business_data_ce>-lastchangedat = lt_suppladd[ supplierid = <ls_business_data_ce>-SupplierID ]-lastchangedat.
            ELSE.
              <ls_business_data_ce>-lastchangedat = '20000101120000'.
            ENDIF.
            ls_result = CORRESPONDING #( <ls_business_data_ce> ).
            APPEND <ls_business_data_ce> TO mt_suppliers.
            APPEND ls_result TO et_suppliers.

          ENDIF.
        ENDLOOP.

      CATCH cx_http_dest_provider_error
            cx_web_http_client_error
            cx_rap_query_filter_no_range
            /iwbep/cx_cp_remote
            /iwbep/cx_gateway.
        et_suppliers_failed = CORRESPONDING #( lt_supplier_id MAPPING SupplierID = table_line ).
        et_message = CORRESPONDING #( lt_supplier_id MAPPING supplierid = table_line ).


    ENDTRY.
  ENDMETHOD.

  METHOD put_data.
    get_data( EXPORTING it_suppliers        = CORRESPONDING #( it_suppliers_upd
                                                                 MAPPING SupplierID = SupplierID
                                                                         %control   = %control
                                                                 EXCEPT * ) "CORRESPONDING #( it_suppliers_upd MAPPING %key = %key EXCEPT * )
              IMPORTING et_suppliers        = DATA(lt_suppliers)
                        et_suppliers_failed = DATA(lt_suppliers_failed)
                        et_message          = DATA(lt_message) ).

    LOOP AT it_suppliers_upd ASSIGNING FIELD-SYMBOL(<ls_supplier_upd>).
      CHECK line_exists( lt_suppliers[ KEY entity COMPONENTS SupplierID = <ls_supplier_upd>-SupplierID ] ).

      ASSIGN lt_suppliers[ KEY entity COMPONENTS SupplierID = <ls_supplier_upd>-SupplierID ] TO FIELD-SYMBOL(<ls_supplier>).
      IF <ls_supplier_upd>-%control-discount_pct = if_abap_behv=>mk-on.
        <ls_supplier>-discount_pct = <ls_supplier_upd>-discount_pct.
      ENDIF.
    ENDLOOP.

    "save data in buffer
    mt_suppliers = CORRESPONDING #( lt_suppliers ) .
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zar_suppliers_c IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    DATA: ls_suppladd TYPE zar_suppladd.

    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    lo_buffer->get_data( IMPORTING et_suppliers = DATA(lt_suppliers) ).

    LOOP AT lt_suppliers ASSIGNING FIELD-SYMBOL(<ls_supplier>).
      ls_suppladd = CORRESPONDING #( <ls_supplier> MAPPING supplierid    = SupplierID
                                                           discount_pct  = discount_pct
                                                           lastchangedat = lastchangedat ).
      GET TIME STAMP FIELD ls_suppladd-lastchangedat.
      MODIFY zar_suppladd FROM @ls_suppladd.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
