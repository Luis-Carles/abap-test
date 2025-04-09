*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_F01
*&---------------------------------------------------------------------*

"___________________________________________________________________
"________________GET & MAKE DATA SUBROUTINES________________________
"___________________________________________________________________

" Subroutine that retrieves data from zClients DB Table.
FORM get_client_data.

ENDFORM.

" Subroutine that retrieves data from zProducts DB Table.
FORM get_prod_data.

ENDFORM.

" Subroutine that retrieves data from zCorders DB Table.
FORM get_order_data.

ENDFORM.

" Subroutine that retrieves data from zOrdproducts DB Table.
FORM get_ordprod_data.

ENDFORM.

" Subroutine that prepares the color scheme as an aditional
" field in correspondent results table.
FORM custom_colors.
  CLEAR: gt_colors, gs_color.

  CASE gv_tab.
    WHEN 'CL'.
      " (CLIENT_ID)
      %CUSTOM_COLOR 'CLIENT_ID' 0 1 'X'.

      " (CLIENT_NAME)
      %CUSTOM_COLOR 'CLIENT_NAME' 0 6 ''.

      " (CLIENT_LAST_NAME)
      %CUSTOM_COLOR 'CLIENT_LAST_NAME' 0 6 ''.

      " (ORDER_COUNT)
      %CUSTOM_COLOR 'ORDER_COUNT' 0 5 ''.

    WHEN 'PR'.
      " (PROD_ID)
      %CUSTOM_COLOR 'PROD_ID' 0 1 'X'.

      " (PROD_NAME)
      %CUSTOM_COLOR 'PROD_NAME' 0 6 ''.

      " (PROD_PRICE)
      %CUSTOM_COLOR 'PROD_PRICE' 0 3 ''.

      " (PROD_QUANTITY)
      %CUSTOM_COLOR 'PROD_QUANTITY' 0 3 ''.

      " (MEINS)
      %CUSTOM_COLOR 'MEINS' 0 7 ''.

    WHEN 'OR'.
      " (ORDER_ID)
      %CUSTOM_COLOR 'ORDER_ID' 0 1 'X'.

      " (ORDER_CLIENT)
      %CUSTOM_COLOR 'ORDER_CLIENT' 0 1 ''.

      " (ORDER_DATE)
      %CUSTOM_COLOR 'ORDER_DATE' 0 5 ''.

      " (ORDER_TIME)
      %CUSTOM_COLOR 'ORDER_TIME' 0 5 ''.

      " (TOTAL)
      %CUSTOM_COLOR 'TOTAL' 0 3 ''.

      " (WAERS)
      %CUSTOM_COLOR 'WAERS' 0 7 ''.

      " (PAYMENT_METHOD)
      %CUSTOM_COLOR 'PAYMENT_METHOD' 0 5 ''.

    WHEN 'PO'.
      " (PROD_ID)
      %CUSTOM_COLOR 'PROD_ID' 0 1 'X'.

      " (ORDER_ID)
      %CUSTOM_COLOR 'ORDER_ID' 0 1 'X'.

      " (PROD_QUANTITY)
      %CUSTOM_COLOR 'PROD_QUANTITY' 0 3 ''.

      " (MEINS)
      %CUSTOM_COLOR 'MEINS' 0 7 ''.

  ENDCASE.
ENDFORM.

" Subroutine that complete the still empty derivated fields in
" correspondent results table.
FORM make_data.
  CASE gv_tab.
    WHEN 'CL'.
      LOOP AT gt_clients ASSIGNING FIELD-SYMBOL(<fs_client>).
        <fs_client>-COLOR = gt_colors. " Color Scheme
*        <fc_client>-REG_STATUS =       " Regular Status
      ENDLOOP.

    WHEN 'PR'.
      LOOP AT gt_products ASSIGNING FIELD-SYMBOL(<fs_product>).
        <fs_product>-COLOR = gt_colors.
      ENDLOOP.

    WHEN 'OR'.
      LOOP AT gt_corders ASSIGNING FIELD-SYMBOL(<fs_corder>).
        <fs_corder>-COLOR = gt_colors.
      ENDLOOP.

    WHEN 'PO'.
      LOOP AT gt_ordproducts ASSIGNING FIELD-SYMBOL(<fs_ordproduct>).
        <fs_ordproduct>-COLOR = gt_colors.
      ENDLOOP.

  ENDCASE.
ENDFORM.

" Subroutine that is called from outside and resolves which forms
" are going to be called to retrieve data from DB Table.
FORM search_data.
  CASE gv_tab.
    WHEN 'CL'.
      PERFORM get_client_data.

      DATA(lv_client_lines)  = LINES( gt_clients ).

      IF lv_client_lines  > 0.
        PERFORM custom_colors.
        PERFORM make_data.
      ENDIF.

    WHEN 'PR'.
      PERFORM get_prod_data.

      DATA(lv_prod_lines)    = LINES( gt_products ).

      IF lv_prod_lines  > 0.
        PERFORM custom_colors.
        PERFORM make_data.
      ENDIF.

    WHEN 'OR'.
      PERFORM get_order_data.

      DATA(lv_order_lines)   = LINES( gt_corders ).

      IF lv_order_lines  > 0.
        PERFORM custom_colors.
        PERFORM make_data.
      ENDIF.

    WHEN 'PO'.
      PERFORM get_ordprod_data.

      DATA(lv_ordprod_lines) = LINES( gt_ordproducts ).

      IF lv_ordprod_lines  > 0.
        PERFORM custom_colors.
        PERFORM make_data.
      ENDIF.

  ENDCASE.
ENDFORM.

"___________________________________________________________________
"________________ALV GRID SUBROUTINES_______________________________
"___________________________________________________________________

" Subroutine that creates the docking container within which every
" alv grid element will be.
FORM create_dcontainer.
  go_dcontainer = NEW cl_gui_docking_container(
      repid     = sy-cprog
      dynnr     = SY-dynnr
      side      = cl_gui_docking_container=>dock_at_left
      extension = SWITCH i( gv_tab
                    WHEN 'CL' THEN 2000
                    WHEN 'PR' THEN 3000
                    WHEN 'CO' THEN 3500
                    WHEN 'OP' THEN 2500
                    ELSE           5000 ) ).

  IF sy-subrc <> 0.
    MESSAGE: 'Error Creating the container.' TYPE 'E'.
  ENDIF.
ENDFORM.

"Subroutine that will create the grid.
FORM create_grid.
  go_grid = NEW cl_gui_alv_grid(
      i_parent = go_dcontainer ).

  " Handler for custom sy-ucomm values
  go_handler = NEW lcl_handler( ).
  SET HANDLER go_handler->when_data_changed FOR go_grid.

  IF sy-subrc <> 0.
    MESSAGE: 'Error Creating the Grid.' TYPE 'E'.
  ENDIF.
ENDFORM.

" Subroutine that will create the layout with custom preferences:
*&---------------------------------------------------------------------*
*&      Form  create_layout
*&---------------------------------------------------------------------*
* LVC_S_LAYO
*----------------------------------------------------------------------*
* ZEBRA                  ALV control: Alternating line
* EDIT                   ALV control: Ready for input
* EDIT_MODE              ALV control: Edit mode
* NO_KEYFIX              ALV control: Do not fix key co
* FRONTEND               ALV control: Excel, Crystal or
* OBJECT_KEY             Business Document Service: Obj
* DOC_ID                 Business Document Service: Doc
* TEMPLATE               Business Document Service: Fil
* LANGUAGE               Language ID
* GRAPHICS               GUID in 'CHAR' Format in Upper
* SMALLTITLE             ALV control: Title size
* NO_HGRIDLN             ALV control: Hide horizontal g
* NO_VGRIDLN             ALV control: Hide vertical gri
* NO_HEADERS             ALV control: Hide column headi
* NO_MERGING             ALV control: Disable cell merg
* CWIDTH_OPT             ALV control: Optimize column w
* TOTALS_BEF             ALV control: Totals output bef
* NO_TOTARR              Character field length 1
* NO_TOTEXP              Character field length 1
* NO_ROWMOVE             Character field length 1
* NO_ROWINS              Character field length 1
* NO_COLEXPD             Character field length 1
* NO_F4                  Character field length 1
* COUNTFNAME             ALV control: Field name of int
* COL_OPT                Character field length 1
* VAL_DATA               Character field length 1
* STYLEFNAME             ALV control: Field name of int
* NO_ROWMARK             ALV control: Disable row selec
* NO_TOOLBAR             ALV control: Hide toolbar
* GRID_TITLE             ALV Control: Title Line Text
* SEL_MODE               ALV control: SelectionMode
* BOX_FNAME              ALV control: Field name of int
* SGL_CLK_HD             ALV control: SingleClick on co
* NO_TOTLINE             ALV control: Do not output tot
* NUMC_TOTAL             ALV control: Disallow NUMC fie
* NO_UTSPLIT             ALV control: Split totals line
* EXCP_FNAME             ALV control: Field name with e
* EXCP_ROLLN             ALV control: Data element for
* EXCP_CONDS             ALV control: Aggregate excepti
* EXCP_LED               ALV control: Exception as LED
* EXCP_GROUP             ALV Control: Exception Group
* DETAILINIT             ALV control: Display initial v
* DETAILTITL             ALV control: Title bar of deta
* KEYHOT                 ALV control: Key columns as ho
* NO_AUTHOR              ALV control: Do not perform AL
* XIFUNCKEY              SAP Query (S): Name of additio
* XIDIRECT               General Flag
* CNTR_DDID              ALV control: Drag&Drop handle
* GRID_DDID              ALV control: Drag&Drop handle
* COL_DDID               ALV control: Drag&Drop handle
* ROW_DDID               ALV control: Drag&Drop handle
* FIELDNAME              ALV control: Field name of int
* INFO_FNAME             ALV control: Field name with s
* CTAB_FNAME             ALV control: Field name with c
* WEBLOOK                ALV control: Web look
* WEBSTYLE               ALV control: Style
* WEBROWS                ALV control: Number of lines t
* WEBXWIDTH              Natural number
* WEBXHEIGHT             Natural number
*----------------------------------------------------------------------*
* Selection modes for SEL_MODE
* 'A' : Column and row selection
* 'B' : Simple selection, list box
* 'C' : Multiple selection, list box
* 'D' : Cell selection
* the button at the beginning of a row is hidden in selection modes
* cell selection ( SEL_MODE = 'D' ) and column/row selection
* ( SEL_MODE = 'A' ).
*  p_fcatlayo-no_rowmark = 'X'. "(or 'X')
*----------------------------------------------------------------------*
* In case of PRINT_END_OF_PAGE, you must set 'reservelns' to
* the number of reserved lines at the end of a page.
* reserve two lines for the PRINT_END_OF_PAGE event
* p_print-reservelns = 2.
*----------------------------------------------------------------------*
FORM create_layout.
  CLEAR gs_layout.

  " LVC_S_LAYO
  gs_layout-zebra             = 'X'.         " Stripped Pattern
  gs_layout-cwidth_opt        = 'X'.         " Column-width optimizing
  gs_layout-sel_mode          = 'A'.         " Selection Mode
  gs_layout-no_toolbar        = ''.          " Enable Toolbar
  gs_layout-CTAB_FNAME        = 'COLOR'.

  gs_layout-grid_title = SWITCH i( gv_tab
                           WHEN 'CL' THEN 'Clients Management View'
                           WHEN 'PR' THEN 'Products Management View'
                           WHEN 'CO' THEN 'Closed Orders Management View'
                           WHEN 'OP' THEN 'Order Products Management View' ).

ENDFORM.

" Subroutine that custom each field inside the Field Catalog
FORM custom_fieldcat.
  CASE gv_tab.
    WHEN 'CL'.
      LOOP AT gt_fieldcat INTO gs_fieldcat.
        CASE gs_fieldcat-fieldname.
          WHEN 'CLIENT_ID'.              " Client Code
            %CUSTOM_FIELD 'X' TEXT-C02 1 'X' ''.

          WHEN 'CLIENT_NAME'.               " Client Name
            %CUSTOM_FIELD '' TEXT-C03 2 'X' ''.

          WHEN 'CLIENT_LAST_NAME'.          " Client Last Name
            %CUSTOM_FIELD '' TEXT-C04 3 'X' 'X'.

          WHEN 'ORDER_COUNT'.               " Client Order Count
            %CUSTOM_FIELD '' TEXT-C05 4 '' ''.

          WHEN 'flag_NEW' OR 'flag_CHG' OR 'COLOR'.
            gs_fieldcat-no_out = 'X'.

          WHEN OTHERS.
            "gs_fieldcat-no_out = 'X'.
            CONTINUE.

        ENDCASE.
      ENDLOOP.

    WHEN 'PR'.
      LOOP AT gt_fieldcat INTO gs_fieldcat.
        CASE gs_fieldcat-fieldname.
          WHEN 'PROD_ID'.                  " Product Code
            %CUSTOM_FIELD 'X' TEXT-C12 1 'X' ''.

          WHEN 'PROD_NAME'.                " Product Name
            %CUSTOM_FIELD '' TEXT-C13 2 'X' 'X'.

          WHEN 'PROD_PRICE'.               " Product Price
            %CUSTOM_FIELD '' TEXT-C14 3 'X' ''.

          WHEN 'PROD_QUANTITY'.            " Product Quantity
            %CUSTOM_FIELD '' TEXT-C15 4 'X' ''.

          WHEN 'MEINS'.                    " Unit
            %CUSTOM_FIELD '' TEXT-C17 5 '' ''.

          WHEN 'flag_NEW' OR 'flag_CHG' OR 'COLOR'.
            gs_fieldcat-no_out = 'X'.

          WHEN OTHERS.
            "gs_fieldcat-no_out = 'X'.
            CONTINUE.

        ENDCASE.
      ENDLOOP.

    WHEN 'CO'.
      LOOP AT gt_fieldcat INTO gs_fieldcat.
        CASE gs_fieldcat-fieldname.
          WHEN 'ORDER_ID'.                  " Order Number
            %CUSTOM_FIELD 'X' TEXT-C01 1 '' ''.

          WHEN 'ORDER_CLIENT'.              " Client Code
            %CUSTOM_FIELD 'X' TEXT-C02 2 'X' ''.

          WHEN 'ORDER_DATE'.                " Order Date
            %CUSTOM_FIELD '' TEXT-C06 3 'X' ''.

          WHEN 'ORDER_TIME'.               " Order Time
            %CUSTOM_FIELD '' TEXT-C07 4 'X' ''.

          WHEN 'TOTAL'.                    " Order Total
            %CUSTOM_FIELD '' TEXT-C09 5 'X' ''.

          WHEN 'WAERS'.                    " Currency
            %CUSTOM_FIELD '' TEXT-C10 6 '' ''.

          WHEN 'PAYMENT_METHOD'.           " Payment method
            %CUSTOM_FIELD '' TEXT-C11 7 'X' 'X'.

          WHEN 'flag_NEW' OR 'flag_CHG' OR 'COLOR'.
            gs_fieldcat-no_out = 'X'.

          WHEN OTHERS.
            "gs_fieldcat-no_out = 'X'.
            CONTINUE.

        ENDCASE.
      ENDLOOP.

    WHEN 'OP'.
      LOOP AT gt_fieldcat INTO gs_fieldcat.
        CASE gs_fieldcat-fieldname.
          WHEN 'PROD_ID'.                  " Product Code
            %CUSTOM_FIELD 'X' TEXT-C12 1 'X' ''.

          WHEN 'ORDER_ID'.                  " Order Number
            %CUSTOM_FIELD 'X' TEXT-C01 2 '' ''.

          WHEN 'PROD_QUANTITY'.            " Product Quantity
            %CUSTOM_FIELD '' TEXT-C15 3 'X' ''.

          WHEN 'MEINS'.                    " Unit
            %CUSTOM_FIELD '' TEXT-C17 4 '' ''.

          WHEN 'flag_NEW' OR 'flag_CHG' OR 'COLOR'.
            gs_fieldcat-no_out = 'X'.

          WHEN OTHERS.
            "gs_fieldcat-no_out = 'X'.
            CONTINUE.

        ENDCASE.
      ENDLOOP.

  ENDCASE.
ENDFORM.

" Subroutine that creates the Field Catalog automatically
FORM create_fieldcat.
  CLEAR: gt_fieldcat, gt_fieldcat[],
         gt_fieldcat_slis, gt_fieldcat_slis[],
         gs_fieldcat.

*  " Automaticaly creation of a compatible field catalog
*  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*    EXPORTING
*      i_program_name     = sy-repid
*      i_internal_tabname = 'GT_RESULTS'      " As indicates this Internal Table
*      i_structure_name   = 'ZST_RESULT'      " with this structure
*      i_inclname         = sy-repid
*    CHANGING
*      ct_fieldcat        = gt_fieldcat_slis  " SLIS Field Catalog
*    EXCEPTIONS
*      inconsistent_interface = 1
*      program_error          = 2
*      OTHERS                 = 3.
*
*  " Convert slis fieldcat into LVC Class fieldcat
*  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
*    EXPORTING
*      it_fieldcat_alv = gt_fieldcat_slis     " SLIS Field Catalog
*    IMPORTING
*      et_fieldcat_lvc = gt_fieldcat          " LVC Field Catalog
*    TABLES
*      it_data         = gt_results.          " Data: Internal Table
*
*  CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
*    CHANGING
*      ct_fieldcat = gt_fieldcat.
*
*  PERFORM custom_fieldcat.
ENDFORM.

" Subroutine that eliminates every non neccesary button in AlV toolbar
FORM custom_toolbar CHANGING ct_excluded TYPE ui_functions.
  APPEND:   cl_gui_alv_grid=>mc_fc_refresh           TO  ct_excluded,
            cl_gui_alv_grid=>mc_fc_loc_copy          TO  ct_excluded,
            cl_gui_alv_grid=>mc_fc_loc_paste         TO  ct_excluded,
            cl_gui_alv_grid=>mc_fc_loc_cut           TO  ct_excluded,
            cl_gui_alv_grid=>mc_fc_loc_undo          TO  ct_excluded,
            cl_gui_alv_grid=>mc_fc_loc_insert_row    TO  ct_excluded,
            cl_gui_alv_grid=>mc_fc_loc_append_row    TO  ct_excluded,
            cl_gui_alv_grid=>mc_fc_loc_copy_row      TO  ct_excluded,
            cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO  ct_excluded,
            cl_gui_alv_grid=>mc_fc_loc_delete_row    TO  ct_excluded.
ENDFORM.

" Subroutine that displays the grid for the first time
FORM display_grid.

ENDFORM.

" Subroutine that refresh the Grid ALV in Result Screen, searching
" again and displaying newest information.
FORM refresh_grid USING iv_refind TYPE CHAR1.

ENDFORM.

" Subroutine that is triggered from PBO Modules and call in precise
" order every subroutine necessary to perform write in ALV GRID.
FORM alv_write.

ENDFORM.

" Subroutine that clears every variable that wont be used later
" liberating memory space.
FORM clearing.

ENDFORM.

"___________________________________________________________________
"________________DB TABLES PERSISTANCE SUBROUTINES__________________
"___________________________________________________________________

" Subroutine that insert a new row in the correspondent DB Table.
FORM insert_row.

ENDFORM.

" Subroutine that deletes selected row/s in correspondent Db Table.
FORM delete_row.

ENDFORM.

" Subroutine that check any input values for new rows prior to
" save those changes in the DB tables.
FORM validate_check.

ENDFORM.

" Subroutine that save changes into the Internal and DB table.
FORM save_changes.
  PERFORM validate_check.
  CHECK gv_check IS INITIAL.

  " DOING!!
ENDFORM.