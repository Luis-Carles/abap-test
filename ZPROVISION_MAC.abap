*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_MAC
*&---------------------------------------------------------------------*

" Macro that calls to the external function to
" raise a Pop-Up window for confirmation receiving:
"   &1: QUESTION TEXT
DEFINE %POP_UP.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TEXT_QUESTION  = &1
      TEXT_BUTTON_1  = SWITCH string( gv_langu
                                WHEN 'KR' THEN TEXT-R01
                                ELSE TEXT-R02 )
      TEXT_BUTTON_2  = SWITCH string( gv_langu
                                WHEN 'KR' THEN TEXT-R03
                                ELSE TEXT-R04 )
    IMPORTING
      ANSWER         = gv_answer
    EXCEPTIONS
      TEXT_NOT_FOUND = 1
      OTHERS         = 2.

END-OF-DEFINITION.

" Macro that adds a color to the scheme receiving:
"   &1: FIELDNAME   &2: COLOR INTENSE ''/X
"   &3: COLOR N     &4: KEYCOLOR ''/X
DEFINE %ADD_COLOR.
  APPEND VALUE #(
    fname     = &1
    color-int = &2
    color-col = &3
    nokeycol  = &4
  ) TO gt_colors.

END-OF-DEFINITION.

" Macro that adds a field to the Field catalog,
" customizing each field properties receiving:
"   &1: FIELDNAME           &2: KEYFIELD ''/X
"   &3: LABEL/COL TEXT      &4: COLUMN POSITION N
"   &5: EDITABLE ''/X       &6: LOWERCASE  ''/X
"   &7: JUSTIFIED L/C/R
DEFINE %ADD_FIELD.
  APPEND VALUE #(
    fieldname  = &1
    key        = &2
    coltext    = &3
    reptext    = &3
    scrtext_l  = &3
    scrtext_m  = &3
    scrtext_s  = &3
    col_pos    = &4
    edit       = &5
    lowercase  = &6
    just       = &7
  ) TO gt_fieldcat.

END-OF-DEFINITION.

" Macro that marks one field as hidden and adds it
" to the field Catalog receiving:
"   &1: FIELDNAME
DEFINE %HIDE_FIELD.
  APPEND VALUE #(
    fieldname  = &1
    no_out     = 'X'
  ) TO gt_fieldcat.

END-OF-DEFINITION.

" Macro that calls the method for display data of
" GRID ALV receiving:
"   &1: DATA Internal Table
DEFINE %DISPLAY.
  " Method (OOP)
  go_grid->set_table_for_first_display(
    EXPORTING
      is_layout             = gs_layout      " Layout
      it_toolbar_excluding  = gt_toolbar_ex  " Functions Excluded
      i_save                = 'A'            " Save for all users
      i_default             = 'X'            " Applies default ALV Config
    CHANGING
      it_fieldcatalog       = gt_fieldcat    " Field Catalog
      it_outtab             = &1             " Data: Internal Table
  ).
  IF sy-subrc <> 0.
    MESSAGE TEXT-E08 TYPE 'E'.
  ENDIF.

END-OF-DEFINITION.

" Macro that adds a new row to Internal table
" in Clients View receiving:
"   &1: CLIENT_ID
DEFINE %ADD_CLIENT.
  APPEND VALUE #(
    CLIENT_ID   = &1
    ORDER_COUNT = 0
    COLOR       = gt_colors
    flag_NEW    = 'X'
  ) TO gt_clients.

END-OF-DEFINITION.

" Macro that adds a new row to Internal table
" in Products View receiving:
"   &1: PROD_ID
DEFINE %ADD_PRODUCT.
  APPEND VALUE #(
    PROD_ID    = &1
    MEINS      = 'EA'
    COLOR      = gt_colors
    flag_NEW   = 'X'
  ) TO gt_products.

END-OF-DEFINITION.

" Macro that adds a new row to Internal table
" in Closed Orders View receiving:
"   &1: ORDER_ID
DEFINE %ADD_ORDER.
  APPEND VALUE #(
    ORDER_ID   = &1
    ORDER_DATE = sy-datum
    ORDER_TIME = sy-uzeit
    WAERS      = 'EUR'
    PAYMENT_METHOD = 'Credit Card'
    COLOR      = gt_colors
    flag_NEW   = 'X'
  ) TO gt_corders.

END-OF-DEFINITION.

" Macro that adds a new row to Internal table
" in Order Products View.
DEFINE %ADD_ORDPRODUCT.
  APPEND VALUE #(
    MEINS      = 'EA'
    COLOR      = gt_colors
    flag_NEW   = 'X'
  ) TO gt_ordproducts.

END-OF-DEFINITION.