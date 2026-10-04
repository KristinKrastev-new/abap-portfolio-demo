"! <p class="shorttext">FI Journal ALV Report</p>
"! Presents finance journal items using SALV (CL_SALV_TABLE).
"!
"! Pure presentation: the data is injected, so this class has no knowledge
"! of ACDOCA or any database table. That keeps the UI testable and lets the
"! data source change without touching the output layer.
CLASS zcl_fi_alv_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING it_items TYPE zcl_fi_journal_reader=>ty_journal_items.

    "! Builds and displays the ALV list.
    METHODS display.

  PRIVATE SECTION.
    DATA mt_items TYPE zcl_fi_journal_reader=>ty_journal_items.

    METHODS build_salv
      RETURNING VALUE(ro_salv) TYPE REF TO cl_salv_table
      RAISING   cx_salv_msg.

    METHODS configure_columns
      IMPORTING io_columns TYPE REF TO cl_salv_columns_table.

    METHODS configure_functions
      IMPORTING io_functions TYPE REF TO cl_salv_functions_list.

    METHODS set_column_text
      IMPORTING io_columns TYPE REF TO cl_salv_columns_table
                iv_name    TYPE lvc_fname
                iv_short   TYPE scrtext_s
                iv_medium  TYPE scrtext_m
                iv_long    TYPE scrtext_l
      RAISING   cx_salv_not_found.
ENDCLASS.


CLASS zcl_fi_alv_report IMPLEMENTATION.

  METHOD constructor.
    mt_items = it_items.
  ENDMETHOD.

  METHOD display.
    TRY.
        DATA(lo_salv) = build_salv( ).
        lo_salv->display( ).
      CATCH cx_salv_msg INTO DATA(lx_salv).
        MESSAGE lx_salv TYPE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD build_salv.
    cl_salv_table=>factory(
      IMPORTING r_salv_table = ro_salv
      CHANGING  t_table      = mt_items ).

    configure_columns( ro_salv->get_columns( ) ).
    configure_functions( ro_salv->get_functions( ) ).
  ENDMETHOD.

  METHOD configure_columns.
    io_columns->set_optimize( abap_true ).

    TRY.
        set_column_text( io_columns = io_columns
                         iv_name    = 'AMOUNT'
                         iv_short   = 'Amount'
                         iv_medium  = 'Amount (CC curr.)'
                         iv_long    = 'Amount in company code currency (HSL)' ).

        set_column_text( io_columns = io_columns
                         iv_name    = 'CURRENCY'
                         iv_short   = 'Curr.'
                         iv_medium  = 'Currency'
                         iv_long    = 'Company code currency' ).
      CATCH cx_salv_not_found.
        " A column we wanted to label does not exist - the list still works.
    ENDTRY.
  ENDMETHOD.

  METHOD configure_functions.
    io_functions->set_all( abap_true ).
  ENDMETHOD.

  METHOD set_column_text.
    DATA(lo_column) = io_columns->get_column( iv_name ).
    lo_column->set_short_text( iv_short ).
    lo_column->set_medium_text( iv_medium ).
    lo_column->set_long_text( iv_long ).
  ENDMETHOD.

ENDCLASS.
