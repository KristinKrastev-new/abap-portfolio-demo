"! <p class="shorttext">FI Journal Reader</p>
"! Reads finance journal entry line items from the S/4HANA Universal Journal
"! (table ACDOCA) and exposes them as a typed internal table.
"!
"! Design notes:
"! - Single responsibility: data access only. No UI / no ALV in here.
"! - The filter is passed as an object (TY_FILTER) so the public API can
"!   grow without breaking existing callers.
"! - Only the leading ledger is read; otherwise every posting would be
"!   returned once per ledger.
"! - Input is validated in the constructor so callers fail fast instead of
"!   silently producing wrong numbers.
CLASS zcl_fi_journal_reader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Leading ledger as delivered in S/4HANA. Adjust if your system uses a
    "! different leading ledger (see table FINSC_LEDGER).
    CONSTANTS c_leading_ledger TYPE rldnr VALUE '0L'.

    "! Selection criteria for reading journal items.
    TYPES:
      BEGIN OF ty_filter,
        company_code TYPE bukrs,
        fiscal_year  TYPE gjahr,
        period_from  TYPE poper,
        period_to    TYPE poper,
      END OF ty_filter.

    "! One flattened journal item as used for reporting.
    TYPES:
      BEGIN OF ty_journal_item,
        company_code  TYPE bukrs,
        currency      TYPE waers,
        fiscal_year   TYPE gjahr,
        period        TYPE poper,
        document_no   TYPE belnr_d,
        line_item     TYPE docln6,
        posting_date  TYPE budat,
        document_date TYPE bldat,
        gl_account    TYPE racct,
        amount        TYPE dmbtr,
      END OF ty_journal_item.

    TYPES ty_journal_items TYPE STANDARD TABLE OF ty_journal_item WITH EMPTY KEY.

    "! Creates a reader for the given filter and validates the input.
    METHODS constructor
      IMPORTING is_filter TYPE ty_filter
      RAISING   zcx_fi_journal_error.

    "! Reads the journal items that match the constructor filter.
    METHODS read
      RETURNING VALUE(rt_items) TYPE ty_journal_items.

  PRIVATE SECTION.
    DATA ms_filter TYPE ty_filter.

    METHODS validate
      IMPORTING is_filter TYPE ty_filter
      RAISING   zcx_fi_journal_error.
ENDCLASS.


CLASS zcl_fi_journal_reader IMPLEMENTATION.

  METHOD constructor.
    validate( is_filter ).
    ms_filter = is_filter.
  ENDMETHOD.

  METHOD validate.
    IF is_filter-company_code IS INITIAL.
      RAISE EXCEPTION TYPE zcx_fi_journal_error
        EXPORTING textid = zcx_fi_journal_error=>missing_company_code.
    ENDIF.

    IF is_filter-fiscal_year IS INITIAL.
      RAISE EXCEPTION TYPE zcx_fi_journal_error
        EXPORTING textid = zcx_fi_journal_error=>missing_fiscal_year.
    ENDIF.
  ENDMETHOD.

  METHOD read.
    " The select list is ordered exactly like TY_JOURNAL_ITEM because the
    " result is assigned to the target structure by position.
    SELECT
        a~rbukrs AS company_code,
        t~waers  AS currency,
        a~gjahr  AS fiscal_year,
        a~poper  AS period,
        a~belnr  AS document_no,
        a~docln  AS line_item,
        a~budat  AS posting_date,
        a~bldat  AS document_date,
        a~racct  AS gl_account,
        a~hsl    AS amount
      FROM acdoca AS a
      INNER JOIN t001 AS t ON t~bukrs = a~rbukrs
      INTO TABLE @rt_items
      WHERE a~rldnr  = @c_leading_ledger
        AND a~rbukrs = @ms_filter-company_code
        AND a~gjahr  = @ms_filter-fiscal_year
        AND a~poper BETWEEN @ms_filter-period_from AND @ms_filter-period_to.
  ENDMETHOD.

ENDCLASS.
