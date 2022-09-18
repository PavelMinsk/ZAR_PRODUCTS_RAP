CLASS zar_call_service_iso DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZAR_CALL_SERVICE_ISO IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_url( i_url =
         'http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso').
        DATA(proxy) = NEW zar_co_country_info_service_so(
                        destination = destination
                      ).

        DATA(request) = VALUE zar_country_isocode_soap_reque( s_country_name = 'Belarus' ).
        proxy->country_isocode(
          EXPORTING
            input = request
          IMPORTING
            output = DATA(response)
         ).
        out->write( |{ request-s_country_name } { response-country_isocode_result }| ).

        "handle response
      CATCH cx_soap_destination_error.
        "handle error
      CATCH cx_ai_system_fault.
        "handle error
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
