CLASS lhc_ProductMarket DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ProductMarket RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ProductMarket RESULT result.

    METHODS confirm FOR MODIFY
      IMPORTING keys FOR ACTION ProductMarket~confirm RESULT result.

    METHODS check_dublicates FOR VALIDATE ON SAVE
      IMPORTING keys FOR ProductMarket~check_dublicates.

    METHODS validate_end_date FOR VALIDATE ON SAVE
      IMPORTING keys FOR ProductMarket~validate_end_date.

    METHODS validate_mapket FOR VALIDATE ON SAVE
      IMPORTING keys FOR ProductMarket~validate_mapket.

    METHODS validate_start_date FOR VALIDATE ON SAVE
      IMPORTING keys FOR ProductMarket~validate_start_date.

    METHODS set_iso_code FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ProductMarket~set_iso_code.

ENDCLASS.

CLASS lhc_ProductMarket IMPLEMENTATION.

  METHOD get_instance_features.

    " Read the market status of the existing markets
    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY ProductMarket
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_markets)
      FAILED failed.


    result = VALUE #( FOR ls_market IN lt_markets
            ( %tky                = ls_market-%tky
              %action-confirm     = COND #( WHEN ls_market-Status = 'X'
                                            THEN if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled  )
              %assoc-_MarketOrder = COND #( WHEN ls_market-Status = 'X'
                                            THEN if_abap_behv=>fc-o-enabled
                                            ELSE if_abap_behv=>fc-o-disabled  )
             ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD confirm.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY ProductMarket
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_markets).

    MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
     ENTITY ProductMarket
      UPDATE
      SET FIELDS WITH VALUE #( FOR ls_market IN lt_markets (
          %tky                   = ls_market-%tky
          Status                 = 'X'
          ) )
      FAILED failed
      REPORTED reported.

    result = VALUE #( FOR ls_market IN lt_markets
                        ( %tky   = ls_market-%tky
                          %param = ls_market ) ).


  ENDMETHOD.

  METHOD check_dublicates.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
  ENTITY ProductMarket
    FIELDS ( Mrktid ProdUuid MarketName )
    WITH CORRESPONDING #( keys )
  RESULT DATA(lt_productmarket).

  DATA(lv_market) = lines( lt_productmarket ).
  DATA(lv_count) = 1.

  WHILE lv_count <= lv_market - 1.

      APPEND VALUE #(  %tky        = lt_productmarket[ lv_count ]-%tky
                       %state_area = 'MARKET_DUBLICATES_OF_DRAFT' )
         TO reported-productmarket.

    DATA(lv_intercount) = lv_count + 1.

    WHILE lv_intercount <= lv_market.

      IF lt_productmarket[ lv_count ]-Mrktid = lt_productmarket[ lv_intercount ]-Mrktid.

        APPEND VALUE #( %tky = lt_productmarket[ lv_count ]-%tky ) TO failed-productmarket.

        APPEND VALUE #( %tky        = lt_productmarket[ lv_count ]-%tky
                        %state_area = 'MARKET_DUBLICATES_OF_DRAFT'
                        %path       = VALUE #( Product-%is_draft  = lt_productmarket[ lv_count ]-%is_draft
                                               Product-produuid   = lt_productmarket[ lv_count ]-produuid )
                        %msg        = NEW zcm_ar_prod(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_ar_prod=>market_dublicates_of_draft
                                          marketname = lt_productmarket[ lv_count ]-MarketName )
                       )
         TO reported-productmarket.

         EXIT.

       ENDIF.

       lv_intercount = lv_intercount + 1.

    ENDWHILE.

    lv_count = lv_count + 1.

  ENDWHILE.


    LOOP AT lt_productmarket INTO DATA(ls_productmarket).

      SELECT SINGLE FROM zar_d_prod_mrkt
        FIELDS mrktid
        WHERE prod_uuid = @ls_productmarket-ProdUuid
          AND mrktid = @ls_productmarket-Mrktid
      INTO @DATA(lv_market_id).

      APPEND VALUE #(  %tky        = ls_productmarket-%tky
                       %state_area = 'MARKET_IS_ALREADY_ASSIGNED' )
         TO reported-productmarket.

      IF lv_market_id IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_productmarket-%tky ) TO failed-productmarket.

        APPEND VALUE #( %tky        = ls_productmarket-%tky
                        %state_area = 'MARKET_IS_ALREADY_ASSIGNED'
                        %path       = VALUE #( Product-%is_draft  = ls_productmarket-%is_draft
                                               Product-produuid   = ls_productmarket-produuid )
                        %msg        = NEW zcm_ar_prod(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_ar_prod=>market_is_already_assigned
                                          marketname = ls_productmarket-MarketName )
                       )
         TO reported-productmarket.


      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validate_end_date.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY ProductMarket
        FIELDS ( Startdate Enddate )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_end_date).

    LOOP AT lt_end_date INTO DATA(ls_end_date).

      APPEND VALUE #(  %tky        = ls_end_date-%tky
                       %state_area = 'VALIDATE_END_DATE' )
         TO reported-productmarket.


      DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

      IF     ls_end_date-Enddate < lv_today
         AND ls_end_date-Enddate IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_end_date-%tky ) TO failed-productmarket.

        APPEND VALUE #( %tky        = ls_end_date-%tky
                        %state_area = 'WRONG_END_DATE'
                        %path       = VALUE #( Product-%is_draft  = ls_end_date-%is_draft
                                               Product-produuid   = ls_end_date-produuid )
                         %msg        = NEW zcm_ar_prod(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_ar_prod=>end_date_wrong_today )
                       )
          TO reported-productmarket.
      ENDIF.

      IF    ls_end_date-Startdate >= ls_end_date-Enddate
        AND ls_end_date-Enddate IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_end_date-%tky ) TO failed-productmarket.

        APPEND VALUE #( %tky        = ls_end_date-%tky
                        %state_area = 'WRONG_END_DATE'
                        %path       = VALUE #( Product-%is_draft  = ls_end_date-%is_draft
                                               Product-produuid   = ls_end_date-produuid )
                        %msg        = NEW zcm_ar_prod(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_ar_prod=>end_date_wrong_early )
                       )
          TO reported-productmarket.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validate_mapket.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
    ENTITY ProductMarket
      FIELDS ( MarketName )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_productmarket).

    LOOP AT lt_productmarket INTO DATA(ls_productmarket).

      SELECT SINGLE FROM zar_d_market
        FIELDS mrktname
        WHERE mrktname = @ls_productmarket-MarketName
      INTO @DATA(lv_market_name).

      APPEND VALUE #(  %tky        = ls_productmarket-%tky
                       %state_area = 'VALIDATE_MAPKET' )
         TO reported-productmarket.

      IF lv_market_name IS INITIAL.
        APPEND VALUE #( %tky = ls_productmarket-%tky ) TO failed-productmarket.

        APPEND VALUE #( %tky        = ls_productmarket-%tky
                        %state_area = 'MARKET_IS_UNKNOWN'
                        %path       = VALUE #( Product-%is_draft  = ls_productmarket-%is_draft
                                               Product-produuid   = ls_productmarket-produuid )
                        %msg        = NEW zcm_ar_prod(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_ar_prod=>market_id_is_unknown
                                          marketname = ls_productmarket-MarketName )
                       )
          TO reported-productmarket.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validate_start_date.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
  ENTITY ProductMarket
    FIELDS ( Startdate )
    WITH CORRESPONDING #( keys )
  RESULT DATA(lt_start_date).

    LOOP AT lt_start_date INTO DATA(ls_start_date).

      APPEND VALUE #(  %tky        = ls_start_date-%tky
                       %state_area = 'VALIDATE_START_DATE' )
         TO reported-productmarket.

      DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

      IF    ls_start_date-Startdate < lv_today
        AND ls_start_date-Startdate IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_start_date-%tky ) TO failed-productmarket.

        APPEND VALUE #( %tky        = ls_start_date-%tky
                        %state_area = 'WRONG_START_DATE'
                        %path       = VALUE #( Product-%is_draft  = ls_start_date-%is_draft
                                               Product-produuid   = ls_start_date-produuid )
                        %msg        = NEW zcm_ar_prod(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_ar_prod=>start_date_wrong )
                       )
          TO reported-productmarket.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD set_iso_code.

     READ ENTITIES OF zar_i_product IN LOCAL MODE
  ENTITY ProductMarket
    FIELDS ( MarketName )
    WITH CORRESPONDING #( keys )
  RESULT DATA(lt_market_name).

  " Remove lines where MarketName is initial.
    DELETE lt_market_name WHERE MarketName IS INITIAL.

  LOOP AT lt_market_name INTO DATA(ls_market_name).

    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_url( i_url =
         'http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso').
        DATA(proxy) = NEW zar_co_country_info_service_so(
                        destination = destination
                      ).

        DATA(request) = VALUE zar_country_isocode_soap_reque( s_country_name = ls_market_name-MarketName ).
        proxy->country_isocode(
          EXPORTING
            input = request
          IMPORTING
            output = DATA(response)
         ).
        ls_market_name-ISOcode = response-country_isocode_result.

        "handle response
      CATCH cx_soap_destination_error.
        "handle error
      CATCH cx_ai_system_fault.
        "handle error

    ENDTRY.

    MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
     ENTITY ProductMarket
      UPDATE
      SET FIELDS WITH VALUE #( (
          %tky                   = ls_market_name-%tky
          ISOcode                = ls_market_name-ISOcode
          ) )
    REPORTED DATA(update_reported).
    reported = CORRESPONDING #( DEEP update_reported ).

  ENDLOOP.

  ENDMETHOD.

ENDCLASS.
