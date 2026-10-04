"! Unit tests for the input validation of ZCL_FI_JOURNAL_READER.
"!
"! The read( ) method itself touches the database, so it is covered by
"! integration tests / the report. The tests below cover the pure logic
"! that is easy to get wrong: the fail-fast validation of the filter.
CLASS ltc_filter_validation DEFINITION
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS raises_when_company_code_empty FOR TESTING.
    METHODS raises_when_fiscal_year_empty  FOR TESTING.
    METHODS accepts_valid_filter           FOR TESTING.
ENDCLASS.


CLASS ltc_filter_validation IMPLEMENTATION.

  METHOD raises_when_company_code_empty.
    TRY.
        DATA(lo_reader) = NEW zcl_fi_journal_reader(
          is_filter = VALUE #( company_code = ''
                               fiscal_year  = '2024' ) ).
        " Reaching this point means the constructor did NOT raise.
        IF lo_reader IS BOUND.
          cl_abap_unit_assert=>fail(
            msg = 'Expected ZCX_FI_JOURNAL_ERROR for empty company code' ).
        ENDIF.
      CATCH zcx_fi_journal_error.
        " expected -> test passes
    ENDTRY.
  ENDMETHOD.

  METHOD raises_when_fiscal_year_empty.
    TRY.
        DATA(lo_reader) = NEW zcl_fi_journal_reader(
          is_filter = VALUE #( company_code = '1000'
                               fiscal_year  = '' ) ).
        IF lo_reader IS BOUND.
          cl_abap_unit_assert=>fail(
            msg = 'Expected ZCX_FI_JOURNAL_ERROR for empty fiscal year' ).
        ENDIF.
      CATCH zcx_fi_journal_error.
        " expected -> test passes
    ENDTRY.
  ENDMETHOD.

  METHOD accepts_valid_filter.
    TRY.
        DATA(lo_reader) = NEW zcl_fi_journal_reader(
          is_filter = VALUE #( company_code = '1000'
                               fiscal_year  = '2024'
                               period_from  = '001'
                               period_to    = '012' ) ).
        cl_abap_unit_assert=>assert_bound( lo_reader ).
      CATCH zcx_fi_journal_error INTO DATA(lx_error).
        cl_abap_unit_assert=>fail(
          msg = |Unexpected exception: { lx_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
