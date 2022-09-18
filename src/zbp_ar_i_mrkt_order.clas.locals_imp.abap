CLASS lhc_MarketOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculate_amount FOR DETERMINE ON SAVE
      IMPORTING keys FOR MarketOrder~calculate_amount.

    METHODS calculate_orderid FOR DETERMINE ON SAVE
      IMPORTING keys FOR MarketOrder~calculate_orderid.

    METHODS set_calendar_year FOR DETERMINE ON SAVE
      IMPORTING keys FOR MarketOrder~set_calendar_year.

    METHODS validate_delivery_date FOR VALIDATE ON SAVE
      IMPORTING keys FOR MarketOrder~validate_delivery_date.

    METHODS validate_business_partner FOR VALIDATE ON SAVE
      IMPORTING keys FOR MarketOrder~validate_business_partner.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MarketOrder RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR MarketOrder RESULT result.

    METHODS confirm_order FOR MODIFY
      IMPORTING keys FOR ACTION MarketOrder~confirm_order RESULT result.


ENDCLASS.

CLASS lhc_MarketOrder IMPLEMENTATION.

  METHOD calculate_amount.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
       ENTITY Product
       FIELDS ( Price Taxrate PriceCurrency ) WITH CORRESPONDING #( keys )
     RESULT DATA(lt_product).

    READ ENTITIES OF zar_i_product IN LOCAL MODE
       ENTITY MarketOrder
       FIELDS ( Quantity ) WITH CORRESPONDING #( keys )
     RESULT DATA(lt_order).

    LOOP AT lt_order INTO DATA(ls_order).

    DATA(lv_price)   = lt_product[ produuid = ls_order-ProdUuid ]-Price.
    DATA(lv_taxrate) = lt_product[ produuid = ls_order-ProdUuid ]-Taxrate.
*    DATA(lv_amountcurrent) = lt_product[ produuid = ls_order-ProdUuid ]-PriceCurrency.

    DATA(lv_quantity) = ls_order-Quantity.

    DATA lv_netamount TYPE zar_netamount.
    DATA lv_grossamount TYPE zar_grossamount.
    lv_netamount   = lv_quantity * lv_price.
    lv_grossamount = lv_netamount + lv_netamount * lv_taxrate / 100.

    MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
     ENTITY MarketOrder
       UPDATE
      SET FIELDS WITH VALUE #( (
                                  %tky                 = ls_order-%tky
                                  NetAmount            = lv_netamount
                                  GrossAmount          = lv_grossamount
*                                  AmountCurr           = lv_amountcurrent
                                  %control-NetAmount   = if_abap_behv=>mk-on
                                  %control-GrossAmount = if_abap_behv=>mk-on
*                                  %control-AmountCurr  = if_abap_behv=>mk-on
                                   ) )

     REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

    ENDLOOP.


  ENDMETHOD.

  METHOD calculate_orderid.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY MarketOrder
      FIELDS ( Orderid ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_order).

    " Remove lines where order ID is already filled.
    DELETE lt_order WHERE Orderid IS NOT INITIAL.

    " Anything left ?
    CHECK lt_order IS NOT INITIAL.

    LOOP AT lt_order INTO DATA(ls_order_id).

*      DATA(lv_mrkt_uuid) = ls_order_id-MrktUuid.
      " Select max order ID.
      SELECT SINGLE
          FROM  zar_d_mrkt_order
          FIELDS MAX( orderid )
          WHERE ( mrkt_uuid = @ls_order_id-MrktUuid )
          INTO @DATA(lv_max_order).

      " Set the Order ID
      MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY MarketOrder
        UPDATE
          FROM VALUE #( FOR ls_order IN lt_order INDEX INTO i (
                                   %tky             = ls_order-%tky
                                   Orderid          = lv_max_order + i
                                   %control-Orderid = if_abap_behv=>mk-on ) )

      REPORTED DATA(update_reported).

      reported = CORRESPONDING #( DEEP update_reported ).

    ENDLOOP.

  ENDMETHOD.

  METHOD set_calendar_year.
    " Read Delivery date
    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY MarketOrder
      FIELDS ( CalendarYear DeliveryDate ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_calendaryear).

    " Remove lines where calendar year is already filled.
    DELETE lt_calendaryear WHERE CalendarYear IS NOT INITIAL.

    " Anything left ?
    CHECK lt_calendaryear IS NOT INITIAL.

    " Set the Calendar Year
    MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
    ENTITY MarketOrder
      UPDATE
        FROM VALUE #( FOR ls_calendaryear IN lt_calendaryear INDEX INTO i (
                                 %tky                  = ls_calendaryear-%tky
                                 CalendarYear          = ls_calendaryear-DeliveryDate
                                 %control-CalendarYear = if_abap_behv=>mk-on ) )

    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD validate_delivery_date.

    " Read Delivery date
    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY MarketOrder
    FIELDS ( DeliveryDate )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_delivery_date).

    LOOP AT lt_delivery_date INTO DATA(ls_delivery_date).
      DATA(lv_delivery_date) = ls_delivery_date-DeliveryDate.

      APPEND VALUE #(  %tky        = ls_delivery_date-%tky
                        %state_area = 'WRONG_DELIVERY_DATE' )
          TO reported-marketorder.

      " Read Start Date and End Date
      READ ENTITIES OF zar_i_product IN LOCAL MODE
         ENTITY ProductMarket
         FIELDS ( Startdate Enddate ) WITH CORRESPONDING #( keys )
       RESULT DATA(lt_period_date).

      LOOP AT lt_period_date INTO DATA(ls_period_date).
        DATA(lv_start_date) = ls_period_date-Startdate.
        DATA(lv_end_date) = ls_period_date-Enddate.

        " Check Delivery Date must be greater than Market Start Date


        IF  lv_delivery_date <= lv_start_date .
          APPEND VALUE #( %tky = ls_delivery_date-%tky ) TO failed-marketorder.

          APPEND VALUE #( %tky        = ls_delivery_date-%tky
                          %state_area = 'WRONG_DELIVERY_DATE'
                          %path       = VALUE #( product-%is_draft        = ls_period_date-%is_draft
                                                 product-produuid         = ls_period_date-produuid
                                                 productmarket-%is_draft  = ls_period_date-%is_draft
                                                 productmarket-produuid   = ls_period_date-ProdUuid
                                                 productmarket-mrktuuid   = ls_period_date-MrktUuid )
                          %msg        = NEW zcm_ar_prod(
                                            severity = if_abap_behv_message=>severity-error
                                            textid   = zcm_ar_prod=>delivery_date_early )  )
            TO reported-marketorder.
        ENDIF.

        " Check Delivery date must be less than or equal to Market End Date
        IF  lv_delivery_date > lv_end_date .
          APPEND VALUE #( %tky = ls_delivery_date-%tky ) TO failed-marketorder.

          APPEND VALUE #( %tky        = ls_delivery_date-%tky
                          %state_area = 'WRONG_DELIVERY_DATE'
                          %path       = VALUE #(
                                                 product-%is_draft        = ls_period_date-%is_draft
                                                 product-produuid         = ls_period_date-produuid
                                                 productmarket-%is_draft  = ls_period_date-%is_draft
                                                 productmarket-produuid   = ls_period_date-ProdUuid
                                                 productmarket-mrktuuid   = ls_period_date-MrktUuid )
                          %msg        = NEW zcm_ar_prod(
                                            severity = if_abap_behv_message=>severity-error
                                            textid   = zcm_ar_prod=>delivery_date_late )  )
            TO reported-marketorder.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_business_partner.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
  ENTITY MarketOrder
    FIELDS ( BussPartner )
    WITH CORRESPONDING #( keys )
  RESULT DATA(lt_bussPartner).

    LOOP AT lt_bussPartner INTO DATA(ls_bussPartner).

      APPEND VALUE #(  %tky        = ls_bussPartner-%tky
                       %state_area = 'VALIDATE_BUSINESS_PARTNER' )
           TO reported-marketorder.

      " Check the existence of Business Partner
      DATA lo_busspartner TYPE REF TO zar_cl_bp_query_provider.
      CREATE OBJECT lo_busspartner TYPE zar_cl_bp_query_provider.

      DATA business_data TYPE zar_cl_bp_query_provider=>t_business_data .
      DATA count TYPE int8.
      DATA filter_conditions  TYPE if_rap_query_filter=>tt_name_range_pairs .
      DATA ranges_table TYPE if_rap_query_filter=>tt_range_option .

      ranges_table      = VALUE #( ( sign = 'I' option = 'EQ' low = ls_busspartner-BussPartner ) ).
      filter_conditions = VALUE #( ( name = 'BUSINESSPARTNER' range = ranges_table ) ).

      TRY.
          lo_busspartner->get_business_partners(
            EXPORTING
              filter_cond        = filter_conditions
              top                = 1
              skip               = 0
              is_count_requested = abap_true
              is_data_requested  = abap_true
            IMPORTING
              business_data  = business_data
              count          = count
            ) .

        CATCH cx_root INTO DATA(exception).

      ENDTRY.

      IF business_data IS INITIAL.
        APPEND VALUE #( %tky = ls_bussPartner-%tky ) TO failed-marketorder.

        APPEND VALUE #( %tky        = ls_bussPartner-%tky
                        %state_area = 'BUSINESS_PARTNER_IS_INVALID'
                        %path       = VALUE #(
                                     product-%is_draft        = ls_bussPartner-%is_draft
                                     product-produuid         = ls_bussPartner-produuid
                                     productmarket-%is_draft  = ls_bussPartner-%is_draft
                                     productmarket-produuid   = ls_bussPartner-ProdUuid
                                     productmarket-mrktuuid   = ls_bussPartner-MrktUuid )

                        %msg        = NEW zcm_ar_prod(
                                          severity = if_abap_behv_message=>severity-error
                                          textid = zcm_ar_prod=>business_partner_is_initial
                                          busspartner = ls_bussPartner-BussPartner )
                       )
          TO reported-marketorder.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_instance_features.

    " Read the market status of the existing markets
    READ ENTITIES OF zar_i_product IN LOCAL MODE
      ENTITY MarketOrder
        FIELDS ( OrderStatus BussPartner Quantity DeliveryDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_order)
      FAILED failed.

    result = VALUE #( FOR ls_order IN lt_order
            ( %tky                  = ls_order-%tky
              %action-confirm_order    = COND #( WHEN ls_order-OrderStatus = 'X'
                                                   OR ls_order-BussPartner IS INITIAL
                                                   OR ls_order-Quantity IS INITIAL
                                                   OR ls_order-DeliveryDate IS INITIAL
                                                 THEN if_abap_behv=>fc-o-disabled
                                                 ELSE if_abap_behv=>fc-o-enabled  )
              %field-Quantity          = COND #( WHEN ls_order-OrderStatus = 'X'
                                                 THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-f-mandatory )
              %field-DeliveryDate      = COND #( WHEN ls_order-OrderStatus = 'X'
                                                 THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-f-mandatory )
              %field-BussPartner       = COND #( WHEN ls_order-OrderStatus = 'X'
                                                 THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-f-unrestricted )
              %field-BussPartnerGroup  = COND #( WHEN ls_order-OrderStatus = 'X'
                                                 THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-f-unrestricted )
              %field-BussPartnerName   = COND #( WHEN ls_order-OrderStatus = 'X'
                                                 THEN if_abap_behv=>fc-f-read_only
                                                 ELSE if_abap_behv=>fc-f-unrestricted )

             ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD confirm_order.

    READ ENTITIES OF zar_i_product IN LOCAL MODE
    ENTITY MarketOrder
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

    MODIFY ENTITIES OF zar_i_product IN LOCAL MODE
     ENTITY MarketOrder
      UPDATE
      SET FIELDS WITH VALUE #( FOR ls_order IN lt_orders (
          %tky                   = ls_order-%tky
          OrderStatus            = 'X'
          ) )
      FAILED failed
      REPORTED reported.

    result = VALUE #( FOR ls_order IN lt_orders
                        ( %tky   = ls_order-%tky
                          %param = ls_order ) ).

  ENDMETHOD.

ENDCLASS.
