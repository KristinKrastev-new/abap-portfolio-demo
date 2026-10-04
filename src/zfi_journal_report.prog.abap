*&---------------------------------------------------------------------*
*& Report ZFI_JOURNAL_REPORT
*&---------------------------------------------------------------------*
*& Demo report that lists finance journal items from the S/4HANA
*& Universal Journal (table ACDOCA).
*&
*& This program only wires components together:
*&   - ZCL_FI_JOURNAL_READER -> data access (ACDOCA)
*&   - ZCL_FI_ALV_REPORT     -> presentation (SALV)
*& There is no business logic and no SQL in this report on purpose.
*&---------------------------------------------------------------------*
REPORT zfi_journal_report.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  PARAMETERS:
    p_bukrs TYPE bukrs OBLIGATORY,
    p_gjahr TYPE gjahr OBLIGATORY,
    p_pfrom TYPE poper DEFAULT '001',
    p_pto   TYPE poper DEFAULT '012'.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  TRY.
      DATA(lo_reader) = NEW zcl_fi_journal_reader(
        is_filter = VALUE zcl_fi_journal_reader=>ty_filter(
          company_code = p_bukrs
          fiscal_year  = p_gjahr
          period_from  = p_pfrom
          period_to    = p_pto ) ).

      DATA(lt_items) = lo_reader->read( ).

      IF lt_items IS INITIAL.
        MESSAGE 'No journal items found for the selection.' TYPE 'S'.
        RETURN.
      ENDIF.

      DATA(lo_report) = NEW zcl_fi_alv_report( it_items = lt_items ).
      lo_report->display( ).

    CATCH zcx_fi_journal_error INTO DATA(lx_error).
      MESSAGE lx_error TYPE 'E'.
  ENDTRY.
