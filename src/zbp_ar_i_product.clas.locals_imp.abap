CLASS lhc_Product DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF phase_id,
        plan TYPE i VALUE '1' , " PLAN
        dev  TYPE i VALUE '2' , " DEV
        prod TYPE i VALUE '3' , " PROD
        out  TYPE i VALUE '4' , " OUT
      END OF phase_id.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Product RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR product RESULT result.

    METHODS move_to_next_phase FOR MODIFY
      IMPORTING keys FOR ACTION product~move_to_next_phase RESULT result.

    METHODS set_first_phase FOR DETERMINE ON SAVE
      IMPORTING keys FOR product~set_first_phase.

    METHODS validate_pg FOR VALIDATE ON SAVE
      IMPORTING keys FOR product~validate_pg.

    METHODS validate_prodid FOR VALIDATE ON SAVE
      IMPORTING keys FOR product~validate_prodid.

    METHODS make_copy FOR MODIFY
      IMPORTING keys FOR ACTION product~make_copy RESULT result.

    METHODS set_pgname_translation FOR DETERMINE ON SAVE
      IMPORTING keys FOR product~set_pgname_translation.

    METHODS get_pgname_transl FOR MODIFY
      IMPORTING keys FOR ACTION product~get_pgname_transl.

    METHODS recalculate_gross_amount FOR DETERMINE ON SAVE
      IMPORTING keys FOR product~recalculate_gross_amount.


    CLASS-METHODS get_translate
      IMPORTING
        iv_pgname       TYPE zar_d_prod_group-pgname
        iv_trcode       TYPE zar_d_product-trans_code
      EXPORTING
        ev_pgname_trans TYPE zar_d_product-pgname_trans.


ENDCLASS.

CLASS lhc_Product IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

    " Read the product status of the existing products
    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Phaseid ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_products)
      FAILED failed.

    result =
      VALUE #(
        FOR ls_product IN lt_products
          LET is_move_to_next_phase = COND #( WHEN ls_product-Phaseid = phase_id-out
                                              THEN if_abap_behv=>fc-o-disabled
                                              ELSE if_abap_behv=>fc-o-enabled  )

          IN
            ( %tky                       = ls_product-%tky
              %action-move_to_next_phase = is_move_to_next_phase
             ) ).

  ENDMETHOD.

  METHOD move_to_next_phase.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY Product
    ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_product).

    SELECT FROM zar_d_prod_mrkt
    FIELDS mrktid AS Mrktid, status AS Status, enddate AS Enddate
    FOR ALL ENTRIES IN @lt_product
    WHERE prod_uuid = @lt_product-ProdUuid
    INTO TABLE @DATA(lt_markets).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_completed) = abap_true.

    LOOP AT lt_markets INTO DATA(ls_markets).
      IF ls_markets-Status = abap_true.
        DATA(lv_confirmed) = abap_true.
      ENDIF.
      IF ls_markets-Enddate > lv_today.
        lv_completed = abap_false.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_product INTO DATA(ls_product).

      "Transition resolution to move from “PLAN” to “DEV” phase
      IF    ( ls_product-Phaseid = 1 AND lt_markets IS NOT INITIAL )
  "Transition resolution to move from “DEV” to “PROD” phase
        OR  ( ls_product-Phaseid = 2 AND lv_confirmed = abap_true )
  "Transition resolution to move from “PROD” to “OUT”  phase
        OR  ( ls_product-Phaseid = 3 AND lv_completed = abap_true ) .
        DATA(lv_move_to_next_phase) = abap_true.
      ENDIF.

    ENDLOOP.

    IF lv_move_to_next_phase = abap_true.

      MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
       ENTITY Product
        UPDATE
        SET FIELDS WITH VALUE #( FOR ls_products IN lt_product (
            %tky                   = ls_product-%tky
            Phaseid                = ls_product-Phaseid + 1
            ) )
        FAILED failed
        REPORTED reported.

      result = VALUE #( FOR ls_products IN lt_product
                          ( %tky   = ls_product-%tky
                            %param = ls_product ) ).
    ENDIF.

    result = VALUE #( FOR ls_products IN lt_product
                     ( %tky   = ls_product-%tky
                       %param = ls_product ) ).


  ENDMETHOD.

  METHOD set_first_phase.

    " Read relevant product instance data
    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Phaseid ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_products).

    " Remove all product instance data with defined phase
    DELETE lt_products WHERE Phaseid IS NOT INITIAL.
    CHECK lt_products IS NOT INITIAL.

    " Set default product status
    MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
    ENTITY Product
      UPDATE
       FIELDS ( Phaseid )
        WITH VALUE #( FOR ls_product IN lt_products
                      ( %tky         = ls_product-%tky
                        Phaseid      = phase_id-plan ) )

    REPORTED DATA(update_reported).
    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD validate_PG.
    " Read relevant product group instance data
    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Pgid Pgname Prodid ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_products).

    LOOP AT lt_products INTO DATA(ls_product).

      " Check if product group ID exist
      SELECT FROM zar_d_prod_group FIELDS pgid, pgname
        WHERE pgname = @ls_product-pgname
        INTO @DATA(ls_prod_group_db).
      ENDSELECT.


      " Raise msg for non existing and initial product group ID

      " Clear state messages that might exist
      APPEND VALUE #(  %tky               = ls_product-%tky
                       %state_area        = 'VALIDATE_PG' )
        TO reported-product.

      IF ls_product-pgname IS INITIAL OR ls_prod_group_db-pgid IS INITIAL .
        APPEND VALUE #( %tky = ls_product-%tky ) TO failed-product.

        APPEND VALUE #( %tky        = ls_product-%tky
                        %state_area = 'VALIDATE_PG'
                        %msg        = NEW zcm_ar_prod(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_ar_prod=>pg_not_exist )
                        )
          TO reported-product.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_prodID.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Prodid ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    LOOP AT products INTO DATA(product).
*      APPEND VALUE #(  %tky               = product-%tky
*                       %state_area        = 'VALIDATE_PRODUCT_ID' )
*      TO reported-product.

      SELECT SINGLE prodid FROM zar_c_product
          WHERE Prodid = @product-Prodid
          INTO @DATA(ex_prod).

      IF ex_prod IS NOT INITIAL.
        APPEND VALUE #( %tky = product-%tky ) TO failed-product.
        APPEND VALUE #( %tky        = product-%tky
*                        %state_area = 'VALIDATE_PRODUCT_ID'
                        %msg        = NEW zcm_ar_prod(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_ar_prod=>prod_id_exist ) )
      TO reported-product.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD make_copy.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
         ENTITY Product
             ALL FIELDS
              WITH CORRESPONDING #( keys )
            RESULT    DATA(lt_read_result)
            FAILED    failed
            REPORTED  reported.

    DATA(lv_today) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_user)  = cl_abap_context_info=>get_user_alias( ).
    TRY.
        DATA(lv_uuid)  = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        "handle exception
    ENDTRY.

    DATA lt_create TYPE TABLE FOR CREATE zar_i_product\\Product.

    LOOP AT keys INTO DATA(key).
      DATA(lv_key) = key-%param-NewProductID.
    ENDLOOP.

    lt_create = VALUE #( FOR row IN  lt_read_result INDEX INTO idx
                             (
                               produuid = lv_uuid
                               Width = row-Width
                               Height = row-Height
                               Depth  = row-Depth
                               Taxrate = row-Taxrate
                               SizeUom = row-SizeUom
                               Prodid  =  lv_key
                               PriceCurrency = row-PriceCurrency
                               Price  = row-Price
                               Phaseid = 1
                               Pgid = row-Pgid
                               Pgname = row-Pgname
                               ChangeTime = lv_today
                               CreationTime = lv_today
                               CreatedBy = lv_user
                               ChangedBy = lv_user ) ).


    MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY Product
        CREATE FIELDS (
                         ProdUuid
                         Width
                         Height
                         Depth
                         Taxrate
                         SizeUom
                         Prodid
                         PriceCurrency
                         Price
                         Phaseid
                         Pgid
                         Pgname
                         ChangeTime
                         CreationTime
                         CreatedBy
                         ChangedBy
                         )
            WITH  lt_create
      MAPPED mapped
      FAILED failed
      REPORTED reported.


    result = VALUE #( FOR create IN  lt_create INDEX INTO indx
                                ( %tky     = keys[ indx ]-%tky
                                  %param   = CORRESPONDING #( create ) ) ) .

  ENDMETHOD.

  METHOD set_pgname_translation.
    " Translation and recording of the translation in the database.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
  ENTITY Product
    FIELDS ( Pgname TransCode ) WITH CORRESPONDING #( keys )
 RESULT DATA(lt_translation).

    LOOP AT lt_translation INTO DATA(ls_translation).

      DATA  lv_pgname_trans TYPE zar_pg_name.

      CALL METHOD get_translate
        EXPORTING
          iv_pgname       = ls_translation-Pgname
          iv_trcode       = ls_translation-TransCode
        IMPORTING
          ev_pgname_trans = lv_pgname_trans.

      MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
       ENTITY Product
        UPDATE
        SET FIELDS WITH VALUE #( (
            %tky                   = ls_translation-%tky
            PgnameTrans            = lv_pgname_trans
            ) )
        REPORTED DATA(update_reported).
      reported = CORRESPONDING #( DEEP update_reported ).

    ENDLOOP.

  ENDMETHOD.


  METHOD get_pgname_transl.
    " Translation into all languages with informative messages.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY Product
    ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_product).

    LOOP AT lt_product INTO DATA(ls_product).
    ENDLOOP.

    SELECT DISTINCT code
      FROM zar_d_market
       INTO TABLE @DATA(lt_code).

    LOOP AT lt_code INTO DATA(ls_code).

      DATA  lv_pgname_trans TYPE zar_pg_name.

      CALL METHOD get_translate
        EXPORTING
          iv_pgname       = ls_product-Pgname
          iv_trcode       = ls_code-code
        IMPORTING
          ev_pgname_trans = lv_pgname_trans.


      APPEND VALUE #(
*                        %tky        = ls_product-%tky
*                        %state_area = 'PGNAME_TRANSLATION'
                        %msg        = NEW zcm_ar_prod(
                                          severity     = if_abap_behv_message=>severity-information
                                          textid       = zcm_ar_prod=>pgname_translation
                                          trcode       = ls_code-code
                                          pgname_trans = lv_pgname_trans ) )
      TO reported-product.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_translate.

    DATA:
      lv_url       TYPE string VALUE 'https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=dict.1.1.20210114T102124Z.02c777e90a7d0d6f.de8b18010e741b082b7a93c50796623ed13cc7fd&lang=en-',
      lv_tr_code   TYPE zar_lang_code,
      lv_pgname_tr TYPE zar_pg_name.

    lv_tr_code = iv_trcode.

    TRANSLATE lv_tr_code+0(2) TO LOWER CASE.

    CONCATENATE lv_url lv_tr_code '&text=' iv_pgname INTO lv_url.

    REPLACE ALL OCCURRENCES OF  ` ` IN lv_url WITH '%20'.

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
                    cl_http_destination_provider=>create_by_url(
                    i_url = lv_url ) ).

        DATA(lo_request) = lo_http_client->get_http_request( ).

        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get ).

        TYPES:
          BEGIN OF ls_tr,
            text TYPE string,
            pos  TYPE string,
          END OF ls_tr,
          lt_tr_table TYPE STANDARD TABLE OF ls_tr WITH EMPTY KEY,
          BEGIN OF ls_def,
            text TYPE string,
            pos  TYPE string,
            ts   TYPE string,
            tr   TYPE lt_tr_table,
          END OF ls_def.

        TYPES lt_result_table TYPE
          STANDARD TABLE OF ls_def
            WITH EMPTY KEY.

        TYPES:
          BEGIN OF ls_complete_result_structure,
            head TYPE string,
            def  TYPE lt_result_table,
          END OF ls_complete_result_structure.

        DATA: ls_json TYPE ls_complete_result_structure.


        CALL METHOD /ui2/cl_json=>deserialize
          EXPORTING
            json         = lo_response->get_text( )
            pretty_name  = /ui2/cl_json=>pretty_mode-camel_case
            assoc_arrays = abap_true
          CHANGING
            data         = ls_json.

        CHECK ls_json IS NOT INITIAL.

        lv_pgname_tr  = ls_json-def[ 1 ]-tr[ 1 ]-text.

        TRANSLATE lv_pgname_tr+0(1) TO UPPER CASE.

      CATCH cx_web_http_client_error cx_http_dest_provider_error.

    ENDTRY.

    ev_pgname_trans = lv_pgname_tr.

  ENDMETHOD.

  METHOD recalculate_gross_amount.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
       ENTITY Product
       fields ( Taxrate Price ) WITH CORRESPONDING #( keys )
     RESULT DATA(lt_taxrate).

     LOOP AT lt_taxrate INTO DATA(ls_taxrate).

      SELECT
        FROM  zar_d_mrkt_order
        FIELDS prod_uuid, mrkt_uuid, order_uuid, quantity
        WHERE prod_uuid = @ls_taxrate-ProdUuid
        INTO TABLE @DATA(lt_order).


    MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
     ENTITY MarketOrder
       UPDATE
         FROM VALUE #( FOR ls_grossamount IN lt_order INDEX INTO i (
                                  %tky-ProdUuid        = ls_grossamount-prod_uuid
                                  %tky-MrktUuid        = ls_grossamount-mrkt_uuid
                                  %tky-OrderUuid       = ls_grossamount-order_uuid
                                  NetAmount            = ls_grossamount-quantity * ls_taxrate-Price
                                  GrossAmount          = ( ls_grossamount-quantity * ls_taxrate-Price ) * ( 1 + ls_taxrate-Taxrate / 100 )
                                  %control-NetAmount   = if_abap_behv=>mk-on
                                  %control-GrossAmount = if_abap_behv=>mk-on ) )

     REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
