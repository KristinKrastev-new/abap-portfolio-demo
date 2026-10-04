"! <p class="shorttext">FI Journal Reader Error</p>
"! Raised when the journal reader cannot run with the given input.
"!
"! Message-based exception (T100) following the standard SAP pattern:
"! the constants below reference messages in message class ZFI_JOURNAL,
"! so the text is maintained in SE91 and translated normally.
CLASS zcx_fi_journal_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF missing_company_code,
        msgid TYPE symsgid VALUE 'ZFI_JOURNAL',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF missing_company_code,
      BEGIN OF missing_fiscal_year,
        msgid TYPE symsgid VALUE 'ZFI_JOURNAL',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF missing_fiscal_year.

    METHODS constructor
      IMPORTING
        textid   TYPE scx_t100key OPTIONAL
        previous TYPE REF TO cx_root OPTIONAL.

ENDCLASS.


CLASS zcx_fi_journal_error IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( textid = textid previous = previous ).

    " Default to the missing company code message if no explicit textid
    " was supplied by the caller.
    IF textid IS INITIAL.
      me->textid = missing_company_code.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
