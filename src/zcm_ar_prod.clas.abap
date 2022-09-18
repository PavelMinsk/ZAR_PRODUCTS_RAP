CLASS zcm_ar_prod DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_abap_behv_message .

    CONSTANTS:
      BEGIN OF pg_not_exist,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF pg_not_exist ,

      BEGIN OF prod_id_exist,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF prod_id_exist ,

      BEGIN OF market_id_is_unknown,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'MARKETNAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF market_id_is_unknown ,

      BEGIN OF start_date_wrong,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF start_date_wrong ,

      BEGIN OF end_date_wrong_today,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF end_date_wrong_today ,

      BEGIN OF end_date_wrong_early,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF end_date_wrong_early,

      BEGIN OF market_is_already_assigned,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'MARKETNAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF market_is_already_assigned,

      BEGIN OF delivery_date_early,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF delivery_date_early,

      BEGIN OF delivery_date_late,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF delivery_date_late,

      BEGIN OF business_partner_is_initial,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE 'BUSSPARTNER',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF business_partner_is_initial,

      BEGIN OF pgname_translation,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '011',
        attr1 TYPE scx_attrname VALUE 'TRCODE',
        attr2 TYPE scx_attrname VALUE 'PGNAME_TRANS',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF pgname_translation,

      BEGIN OF market_dublicates_of_draft,
        msgid TYPE symsgid VALUE 'ZAR_MSG_PROD',
        msgno TYPE symsgno VALUE '012',
        attr1 TYPE scx_attrname VALUE 'MARKETNAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF market_dublicates_of_draft

      .



    METHODS constructor
      IMPORTING
        severity     TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        textid       LIKE if_t100_message=>t100key OPTIONAL
        previous     TYPE REF TO cx_root OPTIONAL
        marketname   TYPE zar_market_name OPTIONAL
        busspartner  TYPE zar_i_business_partner_c-BusinessPartner OPTIONAL
        trcode       TYPE zar_lang_code OPTIONAL
        pgname_trans TYPE zar_pg_name OPTIONAL.

    DATA marketname   TYPE string READ-ONLY.
    DATA busspartner  TYPE string READ-ONLY.
    DATA trcode       TYPE string READ-ONLY.
    DATA pgname_trans TYPE string READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCM_AR_PROD IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = severity.
    me->marketname  = marketname.
    me->busspartner = busspartner.
    me->trcode      = trcode.
    me->pgname_trans = pgname_trans.

  ENDMETHOD.
ENDCLASS.
