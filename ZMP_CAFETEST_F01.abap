*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_F01
*&---------------------------------------------------------------------*

"___________________________________________________________________
"________________PROGRAM SECTIONS SUBROUTINES_______________________
"___________________________________________________________________

" Form called from INITIALIZE section that is in charge of adding
" the downloading button to the toolbar in the selection-screen
FORM initialize.
  *  CLEAR gs_funcdown.
  *  gs_funcdown-ICON_ID     = ICON_XXL.
  *  gs_funcdown-QUICKINFO   = 'EXTRA FUNCTION'.
  *  gs_funcdown-ICON_TEXT   = 'CHANGE DARK MODE'.
  *  gs_funcdown-TEXT        = 'DARK MODE'.
  *  SSCRFIELDS-FUNCTXT_01  = gs_funcdown.
  
    IF p_ufile IS INITIAL.
      p_ufile = 'C:\'.
    ENDIF.
  ENDFORM.
  
  " Subroutine that hides selection screen boxes judging by the chosen
  " Uploading method: Database Search and Excel Uploading
  FORM selection_screen_output.
    LOOP AT SCREEN.
      IF r_sear = 'X'.
        IF SCREEN-GROUP1 = 'SG2'.
          SCREEN-INPUT = 0.
          SCREEN-INVISIBLE = 1.
          MODIFY SCREEN.
        ENDIF.
      ELSE.
        IF SCREEN-GROUP1 = 'SG1'.
          SCREEN-INPUT = 0.
          SCREEN-INVISIBLE = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDFORM.
  
  " Subroutine that gets the downloading excel filename and directory
  FORM get_ufilename USING p_ufile.
    DATA: lv_mask TYPE string.
    lv_mask = cl_gui_frontend_services=>FILETYPE_EXCEL.
  
    CALL METHOD cl_gui_frontend_services=>DIRECTORY_GET_CURRENT
      CHANGING
        CURRENT_DIRECTORY = gv_u_path.
  
    CALL METHOD cl_gui_frontend_services=>FILE_OPEN_DIALOG
      EXPORTING
        WINDOW_TITLE      = gv_win_title
        DEFAULT_FILENAME  = SPACE
        FILE_FILTER       = lv_mask
        INITIAL_DIRECTORY = gv_u_path
      CHANGING
        FILE_TABLE        = gv_u_files
        RC                = gv_u_rc.
  
    READ TABLE gv_u_files INTO gv_u_filename INDEX 1.
    p_ufile = gv_u_filename.
  ENDFORM.
  
  " Subroutine that checks for the given uploading filename and path
  FORM check_u_file.
    IF p_ufile IS NOT INITIAL.
      CLEAR: gv_u_check_file, gv_u_check_flag.
      gv_u_check_file = p_ufile.
  
      CALL METHOD cl_gui_frontend_services=>FILE_EXIST
        EXPORTING
          file = gv_u_check_file
         RECEIVING
          result = gv_u_check_flag.
      IF sy-subrc <> 0 OR gv_u_check_flag <> abap_true.
        MESSAGE 'Please specify a valid path to filename.' TYPE 'E'.
      ENDIF.
  
    ELSE.
      MESSAGE 'Please specify an excel uploading file.' TYPE 'E'.
  
    ENDIF.
  ENDFORM.
  
  "___________________________________________________________________
  "________________GET & MAKE DATA SUBROUTINES________________________
  "___________________________________________________________________
  
  " Subroutine that retrieves the data from the database tables
  " both non-dynamic and dynamic conditions approaches
  FORM get_data.
    CLEAR: gt_results, gs_result,gt_master_clients,gt_master_products.
  
    CASE gv_approach.
      WHEN 'ND'. " NON DYNAMIC CONDITIONS APPROACH
  *     ___________STEP 1________________________________________________________
        SELECT a~ORDER_ID, b~ORDER_CLIENT, b~ORDER_DATE, b~ORDER_TIME,
               b~TOTAL, b~PAYMENT_METHOD, a~PROD_ID, a~PROD_QUANTITY,
               a~MEINS, b~WAERS
          INTO CORRESPONDING FIELDS OF TABLE @gt_results
          FROM ZORDPRODUCTS AS a INNER JOIN ZCORDERS AS b
          ON a~ORDER_ID = b~ORDER_ID
          WHERE a~ORDER_ID       IN @s_ORDID AND
                b~ORDER_CLIENT   IN @s_CLID  AND
                b~ORDER_DATE     IN @s_ODATE AND
                b~ORDER_TIME     IN @s_OTIME AND
                b~TOTAL          IN @s_TOTAL AND
                b~PAYMENT_METHOD IN @s_PAYM  AND
                a~PROD_ID        IN @s_PROID AND
                a~PROD_QUANTITY  IN @s_PQUAN.
  
  *     ___________STEP 2________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_clients
          FROM ZCLIENTS
          WHERE CLIENT_NAME      IN @s_CNAME  AND
                CLIENT_LAST_NAME IN @s_CLNAME AND
                ORDER_COUNT      IN @s_OCOUNT.
        SORT gt_master_clients BY CLIENT_ID.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY, PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_products
          FROM ZPRODUCTS
          WHERE PROD_NAME     IN @s_PNAME  AND
                PROD_QUANTITY IN @s_PSTOCK AND
                PROD_PRICE    IN @s_PPRICE.
        SORT gt_master_products BY PROD_ID.
  
      WHEN 'DY'.
        PERFORM dynamic_conditions.
  
        "________STEP 1___________________________________________________________
        SELECT a~ORDER_ID, b~ORDER_CLIENT, b~ORDER_DATE, b~ORDER_TIME,
               b~TOTAL, b~PAYMENT_METHOD, a~PROD_ID, a~PROD_QUANTITY,
               a~MEINS, b~WAERS
          INTO CORRESPONDING FIELDS OF TABLE @gt_results
          FROM ZORDPRODUCTS AS a INNER JOIN ZCORDERS AS b
          ON a~ORDER_ID = b~ORDER_ID
          WHERE (gv_where).
  
        "________STEP 2___________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_clients
          FROM ZCLIENTS
          WHERE (gv_where_cl).
        SORT gt_master_clients BY CLIENT_ID.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY,PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_products
          FROM ZPRODUCTS
          WHERE (gv_where_pr).
        SORT gt_master_products BY PROD_ID.
  
    ENDCASE.
  ENDFORM.
  
  " Form that prepare extra empty fields looping through the results
  " table after Database Tables consult.
  FORM make_data.
    DATA: lv_del TYPE CHAR1 VALUE ''.
  
    LOOP AT gt_results INTO gs_result.
      lv_del = ''.
  
      READ TABLE gt_master_clients INTO DATA(ls_client)
        WITH KEY CLIENT_ID = gs_result-ORDER_CLIENT
        BINARY SEARCH.
      IF sy-subrc <> 0.
        DELETE gt_results.
        lv_del = 'X'.
      ELSE.
        gs_result-CLIENT_NAME = ls_client-CLIENT_NAME.
        gs_result-CLIENT_LAST_NAME = ls_client-CLIENT_LAST_NAME.
        gs_result-ORDER_COUNT = ls_client-ORDER_COUNT.
  
        READ TABLE gt_master_products INTO DATA(ls_product)
          WITH KEY PROD_ID = gs_result-PROD_ID
          BINARY SEARCH.
        IF sy-subrc <> 0.
          DELETE gt_results.
          lv_del = 'X'.
        ELSE.
          gs_result-PROD_NAME  = ls_product-PROD_NAME.
          gs_result-PROD_STOCK = ls_product-PROD_QUANTITY.
          gs_result-PROD_PRICE = ls_product-PROD_PRICE.
        ENDIF.
      ENDIF.
  
      IF gs_result-ORDER_COUNT > 5.
        gs_result-REG_STATUS = 'Regular Client'.
      ELSE.
        gs_result-REG_STATUS = 'Sporadic Client'.
      ENDIF.
  
      gs_result-COLOR = gt_colors.
  
      IF lv_del = ''.
        MODIFY gt_results FROM gs_result
        TRANSPORTING CLIENT_NAME CLIENT_LAST_NAME ORDER_COUNT
                     REG_STATUS PROD_NAME PROD_STOCK PROD_PRICE COLOR.
      ENDIF.
    ENDLOOP.
  
  ENDFORM.
  
  " Subroutine that calcules the WHERE conditions dynamically
  FORM dynamic_conditions.
    gv_where    = ' '.
    gv_where_cl = ' '.
    gv_where_pr = ' '.
  
    IF s_ORDID IS NOT INITIAL.
      IF gv_where = ' '.
        CONCATENATE gv_where 'a~ORDER_ID IN @s_ORDID ' INTO gv_where SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where 'AND a~ORDER_ID IN @s_ORDID ' INTO gv_where SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_CLID IS NOT INITIAL.
      IF gv_where = ' '.
        CONCATENATE gv_where 'b~ORDER_CLIENT IN @s_CLID  ' INTO gv_where SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where 'AND b~ORDER_CLIENT IN @s_CLID  ' INTO gv_where SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_CNAME IS NOT INITIAL.
      IF gv_where_cl = ' '.
        CONCATENATE gv_where_cl 'CLIENT_NAME IN @s_CNAME ' INTO gv_where_cl SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_cl 'AND CLIENT_NAME IN @s_CNAME ' INTO gv_where_cl SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_CLNAME IS NOT INITIAL.
      IF gv_where_cl = ' '.
        CONCATENATE gv_where_cl 'CLIENT_LAST_NAME IN @s_CLNAME ' INTO gv_where_cl SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_cl 'AND CLIENT_LAST_NAME IN @s_CLNAME ' INTO gv_where_cl SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_OCOUNT IS NOT INITIAL.
      IF gv_where_cl = ' '.
        CONCATENATE gv_where_cl 'ORDER_COUNT IN @s_OCOUNT ' INTO gv_where_cl SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_cl 'ORDER_COUNT IN @s_OCOUNT ' INTO gv_where_cl SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_ODATE IS NOT INITIAL.
      IF gv_where = ' '.
        CONCATENATE gv_where 'b~ORDER_DATE IN @s_ODATE ' INTO gv_where SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where 'AND b~ORDER_DATE IN @s_ODATE ' INTO gv_where SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_OTIME IS NOT INITIAL.
      IF gv_where = ' '.
        CONCATENATE gv_where 'b~ORDER_TIME IN @s_OTIME ' INTO gv_where SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where 'AND b~ORDER_TIME IN @s_OTIME ' INTO gv_where SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_TOTAL IS NOT INITIAL.
      IF gv_where = ' '.
        CONCATENATE gv_where 'b~TOTAL IN @s_TOTAL ' INTO gv_where SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where 'AND b~TOTAL IN @s_TOTAL ' INTO gv_where SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PAYM IS NOT INITIAL.
      IF gv_where = ' '.
        CONCATENATE gv_where 'b~PAYMENT_METHOD IN @s_PAYM ' INTO gv_where SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where 'AND b~PAYMENT_METHOD IN @s_PAYM ' INTO gv_where SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PROID IS NOT INITIAL.
      IF gv_where = ' '.
        CONCATENATE gv_where 'a~PROD_ID IN @s_PROID ' INTO gv_where SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where 'AND a~PROD_ID IN @s_PROID ' INTO gv_where SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PNAME IS NOT INITIAL.
      IF gv_where_pr = ' '.
        CONCATENATE gv_where_pr 'PROD_NAME IN @s_PNAME ' INTO gv_where_pr SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_pr 'AND PROD_NAME IN @s_PNAME ' INTO gv_where_pr SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PPRICE IS NOT INITIAL.
      IF gv_where_pr = ' '.
        CONCATENATE gv_where_pr 'PROD_PRICE IN @s_PPRICE ' INTO gv_where_pr SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_pr 'AND PROD_PRICE IN @s_PPRICE ' INTO gv_where_pr SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PSTOCK IS NOT INITIAL.
      IF gv_where_pr = ' '.
        CONCATENATE gv_where_pr 'PROD_QUANTITY IN @s_PSTOCK ' INTO gv_where_pr SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_pr 'AND PROD_QUANTITY IN @s_PSTOCK ' INTO gv_where_pr SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PQUAN IS NOT INITIAL.
      IF gv_where = ' '.
        CONCATENATE gv_where 'a~PROD_QUANTITY IN @s_PQUAN ' INTO gv_where SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where 'AND a~PROD_QUANTITY IN @s_PQUAN ' INTO gv_where SEPARATED BY space.
      ENDIF.
    ENDIF.
  ENDFORM.
  
  " Subroutine that retrieves data from an excel file
  FORM get_data_excel.
    DATA: ls_intern TYPE alsmex_tabline,
          lv_fname  LIKE RLGRAP-FILENAME,
          lv_err_msg type string.
  
    CLEAR: gt_excel.
  
    IF p_ufile IS NOT INITIAL AND p_ufile <> 'C:\'.
      "____________________________________________________________
      lv_fname = gv_u_filename.
  
      CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
        EXPORTING
          filename                = lv_fname
          i_begin_col             = '1'
          i_begin_row             = '2'
          i_end_col               = '17'
          i_end_row               = '11'
        TABLES
          intern                  = gt_excel
        EXCEPTIONS
          inconsistent_parameters = 1
          upload_ole              = 2
          OTHERS                  = 3.
      IF sy-subrc <> 0.
        lv_err_msg = conv string( sy-subrc ).
        CONCATENATE 'Error reading Excel file.' lv_err_msg INTO lv_err_msg.
        MESSAGE lv_err_msg TYPE 'E'.
      ENDIF.
      "_____________________________________________________________
  
  
    ELSE.
      MESSAGE 'The uploading excel file must not be empty.' TYPE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  
  ENDFORM.
  
  "Subroutine that handles gt_results from the data retrieved from Excel
  FORM make_data_excel.
    DATA: lt_columns TYPE STANDARD TABLE OF string,
          lv_index   TYPE i.
    CLEAR: gs_excel.
  
  *  LOOP AT gt_excel INTO gs_excel.
  *    CLEAR gs_result.
  *
  *    SPLIT gs_excel_row AT cl_abap_char_utilities=>horizontal_tab INTO TABLE lt_columns.
  *
  *    IF LINES( lt_columns ) >= 17.
  *      READ TABLE lt_columns INDEX 1  INTO gs_result-ORDER_ID.
  *      READ TABLE lt_columns INDEX 2  INTO gs_result-ORDER_CLIENT.
  *      READ TABLE lt_columns INDEX 3  INTO gs_result-PROD_ID.
  *      READ TABLE lt_columns INDEX 4  INTO gs_result-CLIENT_NAME.
  *      READ TABLE lt_columns INDEX 5  INTO gs_result-CLIENT_LAST_NAME.
  *      READ TABLE lt_columns INDEX 6  INTO gs_result-ORDER_COUNT.
  *      READ TABLE lt_columns INDEX 7  INTO gs_result-ORDER_DATE.
  *      READ TABLE lt_columns INDEX 8  INTO gs_result-ORDER_TIME.
  *      READ TABLE lt_columns INDEX 9  INTO gs_result-REG_STATUS.
  *      READ TABLE lt_columns INDEX 10 INTO gs_result-TOTAL.
  *      READ TABLE lt_columns INDEX 11 INTO gs_result-WAERS.
  *      READ TABLE lt_columns INDEX 12 INTO gs_result-PAYMENT_METHOD.
  *      READ TABLE lt_columns INDEX 13 INTO gs_result-PROD_NAME.
  *      READ TABLE lt_columns INDEX 14 INTO gs_result-PROD_PRICE.
  *      READ TABLE lt_columns INDEX 15 INTO gs_result-PROD_QUANTITY.
  *      READ TABLE lt_columns INDEX 16 INTO gs_result-PROD_STOCK.
  *      READ TABLE lt_columns INDEX 17 INTO gs_result-MEINS.
  *
  *      APPEND gs_result TO gt_results.
  *    ENDIF.
  *  ENDLOOP.
  ENDFORM.
  
  " Subroutine that launches the database search and is called from the
  " outide.
  FORM search_order_list.
  
    IF r_exce = 'X'.
      PERFORM get_data_excel.
      " IF gt_excel is not void
      PERFORM make_data_excel.
  
    ELSE.
      DATA: lv_client_mlines  TYPE i,
            lv_product_mlines TYPE i.
  
      PERFORM get_data.
  
      lv_client_mlines  = LINES( gt_master_clients ).
      lv_product_mlines = LINES( gt_master_products ).
  
      IF lv_client_mlines  > 0 AND
         lv_product_mlines > 0.
        PERFORM custom_colors.
        PERFORM make_data.
      ENDIF.
  
    ENDIF.
  ENDFORM.
  
  "___________________________________________________________________
  "________________ALV GRID SUBROUTINES_______________________________
  "___________________________________________________________________
  
  " Subroutine that creates the docking container within which every
  " alv grid element will be.
  FORM create_dcontainer.
    CREATE OBJECT go_dcontainer
      EXPORTING
        repid     = sy-cprog
        dynnr     = SY-dynnr
        side      = cl_gui_docking_container=>dock_at_left
  *      ratio     = 40
        extension = 5000
      EXCEPTIONS
        others    = 1.
    IF sy-subrc <> 0.
      MESSAGE: 'Error Creating the container.' TYPE 'E'.
    ENDIF.
  ENDFORM.
  
  "Subroutine that will create the grid.
  FORM create_grid.
    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_dcontainer          " Inside that docking container
      EXCEPTIONS
        others   = 1.
  
    IF gv_mode = 'M'.
      CREATE OBJECT go_handler.             " Handler for custom sy-ucomm values
      SET HANDLER go_handler->when_data_changed FOR go_grid.
    ENDIF.
  
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
  
    CASE gv_mode.
      WHEN 'D'.
        gs_layout-grid_title        = 'Overall Display View'.
  
      WHEN 'M'.
        gs_layout-grid_title        = 'Overall Management View'.
        gs_layout-edit              = 'X'.
    ENDCASE.
  ENDFORM.
  
  " Subroutine that customizes the color for each field.
  FORM custom_colors.
    CLEAR gt_colors.
  
    " (ORDER_ID)
    CLEAR gs_color.
    gs_color-fname = 'ORDER_ID'.
    gs_color-color-int = 0.
    gs_color-color-col = 1.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (ORDER_CLIENT)
    CLEAR gs_color.
    gs_color-fname = 'ORDER_CLIENT'.
    gs_color-color-int = 0.
    gs_color-color-col = 1.
    gs_color-nokeycol  = 'X'.
    APPEND gs_color TO gt_colors.
  
    " (CLIENT_NAME)
    CLEAR gs_color.
    gs_color-fname = 'CLIENT_NAME'.
    gs_color-color-int = 0.
    gs_color-color-col = 6.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (CLIENT_LAST_NAME)
    CLEAR gs_color.
    gs_color-fname = 'CLIENT_LAST_NAME'.
    gs_color-color-int = 0.
    gs_color-color-col = 6.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (ORDER_COUNT)
    CLEAR gs_color.
    gs_color-fname = 'ORDER_COUNT'.
    gs_color-color-int = 0.
    gs_color-color-col = 6.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (ORDER_DATE)
    CLEAR gs_color.
    gs_color-fname = 'ORDER_DATE'.
    gs_color-color-int = 0.
    gs_color-color-col = 3.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (ORDER_TIME)
    CLEAR gs_color.
    gs_color-fname = 'ORDER_TIME'.
    gs_color-color-int = 0.
    gs_color-color-col = 3.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (REG_STATUS)
    CLEAR gs_color.
    gs_color-fname = 'REG_STATUS'.
    gs_color-color-int = 0.
    gs_color-color-col = 6.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (TOTAL)
    CLEAR gs_color.
    gs_color-fname = 'TOTAL'.
    gs_color-color-int = 0.
    gs_color-color-col = 3.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (WAERS)
    CLEAR gs_color.
    gs_color-fname = 'WAERS'.
    gs_color-color-int = 0.
    gs_color-color-col = 7.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (PAYMENT_METHOD)
    CLEAR gs_color.
    gs_color-fname = 'PAYMENT_METHOD'.
    gs_color-color-int = 0.
    gs_color-color-col = 3.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (PROD_ID)
    CLEAR gs_color.
    gs_color-fname = 'PROD_ID'.
    gs_color-color-int = 0.
    gs_color-color-col = 1.
    gs_color-nokeycol  = 'X'.
    APPEND gs_color TO gt_colors.
  
    " (PROD_NAME)
    CLEAR gs_color.
    gs_color-fname = 'PROD_NAME'.
    gs_color-color-int = 0.
    gs_color-color-col = 5.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (PROD_PRICE)
    CLEAR gs_color.
    gs_color-fname = 'PROD_PRICE'.
    gs_color-color-int = 0.
    gs_color-color-col = 5.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (PROD_QUANTITY)
    CLEAR gs_color.
    gs_color-fname = 'PROD_QUANTITY'.
    gs_color-color-int = 0.
    gs_color-color-col = 3.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (PROD_STOCK)
    CLEAR gs_color.
    gs_color-fname = 'PROD_STOCK'.
    gs_color-color-int = 0.
    gs_color-color-col = 5.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  
    " (MEINS)
    CLEAR gs_color.
    gs_color-fname = 'MEINS'.
    gs_color-color-int = 0.
    gs_color-color-col = 7.
    gs_color-nokeycol  = ''.
    APPEND gs_color TO gt_colors.
  ENDFORM.
  
  " Subroutine that custom each field inside the Field Catalog
  FORM custom_fieldcat.
    LOOP AT gt_fieldcat INTO gs_fieldcat. " Loop through created Fieldcat
      CASE gs_fieldcat-fieldname.
      "_________________________________________________
      " Field Catalog Values
        WHEN 'ORDER_ID'.                  " Order Number
          gs_fieldcat-key        = 'X'.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C01.
          gs_fieldcat-col_pos    = 1.
  
        WHEN 'ORDER_CLIENT'.              " Client Code
          gs_fieldcat-key        = 'X'.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C02.
          gs_fieldcat-col_pos    = 2.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'PROD_ID'.                  " Product Code
          gs_fieldcat-key        = 'X'.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C12.
          gs_fieldcat-col_pos    = 3.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'CLIENT_NAME'.               " Client Name
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C03.
          gs_fieldcat-col_pos    = 4.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'CLIENT_LAST_NAME'.          " Client Last Name
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C04.
          gs_fieldcat-col_pos    = 5.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'ORDER_COUNT'.               " Client Order Count
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C05.
          gs_fieldcat-col_pos    = 6.
  
        WHEN 'ORDER_DATE'.                " Order Date
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C06.
          gs_fieldcat-col_pos    = 7.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'ORDER_TIME'.               " Order TIme
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C07.
          gs_fieldcat-col_pos    = 8.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'REG_STATUS'.               " Regular Customer Status
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C08.
          gs_fieldcat-col_pos    = 9.
  
        WHEN 'TOTAL'.                    " Order Total
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C09.
          gs_fieldcat-col_pos    = 10.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'WAERS'.                    " Currency
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C10.
          gs_fieldcat-col_pos    = 11.
  
        WHEN 'PAYMENT_METHOD'.           " Payment method
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C11.
          gs_fieldcat-col_pos    = 12.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'PROD_NAME'.                " Product Name
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C13.
          gs_fieldcat-col_pos    = 13.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'PROD_PRICE'.               " Product Price
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C14.
          gs_fieldcat-col_pos    = 14.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'PROD_QUANTITY'.            " Product Quantity
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C15.
          gs_fieldcat-col_pos    = 15.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'PROD_STOCK'.               " Product Stock
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C16.
          gs_fieldcat-col_pos    = 16.
          IF gv_mode = 'M'.
            gs_fieldcat-edit = 'X'.
          ENDIF.
  
        WHEN 'MEINS'.                    " Unit
          gs_fieldcat-key        = ''.
          gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
          gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
          gs_fieldcat-coltext    = TEXT-C17.
          gs_fieldcat-col_pos    = 17.
  
        WHEN 'flag_NEW' OR 'flag_CHG' OR 'COLOR'.
          gs_fieldcat-no_out = 'X'.
  
        WHEN OTHERS.
          "gs_fieldcat-no_out = 'X'.
          CONTINUE.
      ENDCASE.
  
    ENDLOOP.
  ENDFORM.
  
  " Subroutine that creates the Field Catalog automatically
  FORM create_fieldcat.
    CLEAR: gt_fieldcat, gt_fieldcat[],
           gt_fieldcat_slis, gt_fieldcat_slis[],
           gs_fieldcat.
  
    " Automaticaly creation of a compatible field catalog
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_program_name     = sy-repid
        i_internal_tabname = 'GT_RESULTS'      " As indicates this Internal Table
        i_structure_name   = 'ZST_RESULT'      " with this structure
        i_inclname         = sy-repid
      CHANGING
        ct_fieldcat        = gt_fieldcat_slis  " SLIS Field Catalog
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
  
    " Convert slis fieldcat into LVC Class fieldcat
    CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
      EXPORTING
        it_fieldcat_alv = gt_fieldcat_slis     " SLIS Field Catalog
      IMPORTING
        et_fieldcat_lvc = gt_fieldcat          " LVC Field Catalog
      TABLES
        it_data         = gt_results.          " Data: Internal Table
  
    CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
      CHANGING
        ct_fieldcat = gt_fieldcat.
  
    PERFORM custom_fieldcat.
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
    " Method (OOP)
    go_grid->set_table_for_first_display(
      EXPORTING
        is_layout             = gs_layout        " Layout
        it_toolbar_excluding  = gt_toolbar_ex    " Functions Excluded
        i_save                = 'A'              " Save for all users
        i_default             = 'X'              " Applies default ALV Config
      CHANGING
        it_outtab             = gt_results       " Data: Internal Table
        it_fieldcatalog       = gt_fieldcat      " Field Catalog
    ).
  ENDFORM.
  
  " Subroutine that refresh the Grid ALV in Result Screen, searching again
  " and displaying newest information.
  FORM refresh_grid USING iv_refind TYPE CHAR1.
    IF iv_refind = 'X'.
      " Re retrieve data from DB Tables:
      PERFORM search_order_list.
    ENDIF.
  
    " Refresh the grid
    gs_scroll-row = 'X'.
    gs_scroll-col = 'X'.
    CALL METHOD go_grid->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'         " Soft Refresh option
        is_stable      = gs_scroll.
  
  
    CALL METHOD cl_gui_cfw=>flush.
  ENDFORM.
  
  " Subroutine that is triggered from PBO Modules and call in precise order
  " every alv subroutine necessary to perform write requirement
  FORM alv_write.
    IF go_dcontainer IS NOT BOUND.    " Displaying for the first time
      PERFORM create_dcontainer.
      PERFORM create_grid.
      PERFORM create_layout.
      PERFORM create_fieldcat.
      PERFORM custom_toolbar CHANGING gt_toolbar_ex.
      PERFORM display_grid.
    ELSE.
      CASE gv_mode.
        WHEN 'D'.
           PERFORM refresh_grid USING 'X'. " Refreshing, refind enabled
  
        WHEN 'M'.
           PERFORM refresh_grid USING ''.  " Refreshing refind disabled
      ENDCASE.
    ENDIF.
  ENDFORM.
  
  FORM insert_row.
    DATA: lv_order_id   TYPE i.
    CLEAR gs_result.
  
    " Fields not up to edit:
    " Order ID
    READ TABLE gt_results INTO DATA(ls_result) INDEX LINES( gt_results ).
    gs_result-ORDER_ID = ls_result-ORDER_ID + 1.
  
    " Regular status and Currency/Unit
    gs_result-REG_STATUS = 'Sporadic Client'.
    gs_result-WAERS      = 'EUR'.
    gs_result-MEINS      = 'EA'.
  
    " Colors
    PERFORM custom_colors.
    gs_result-COLOR = gt_colors.
  
    " new flag
    gs_result-flag_NEW = 'X'.
  
    APPEND gs_result TO gt_results.
    MESSAGE 'New Row Added' TYPE 'S'.
  ENDFORM.
  
  FORM delete_row.
    DATA: lt_sel_rows TYPE lvc_t_row,
          ls_sel_row  TYPE lvc_s_row,
          lv_answer(1).
    CLEAR: gv_delete.
  
    " Get selected row(s)
    CALL METHOD go_grid->get_selected_rows
      IMPORTING et_index_rows = lt_sel_rows.
  
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TEXT_QUESTION  = 'Do you really want to delete those rows?'
        TEXT_BUTTON_1  = 'Yes'
        TEXT_BUTTON_2  = 'No'
      IMPORTING
        ANSWER         = lv_answer
      EXCEPTIONS
        TEXT_NOT_FOUND = 1
        OTHERS         = 2.
  
    CHECK lv_answer = 1.
  
    LOOP AT lt_sel_rows INTO ls_sel_row.
      " DELETIONS AT DB TABLE
      READ TABLE gt_results INTO gs_result INDEX ls_sel_row-INDEX.
      IF sy-subrc = 0.
          IF gs_result-flag_NEW = ''.
            DELETE FROM zcorders WHERE ORDER_ID = gs_result-ORDER_ID.
            IF sy-subrc <> 0.
              gv_delete = 'E'.
            ENDIF.
  
            DELETE FROM zordproducts WHERE ORDER_ID = gs_result-ORDER_ID.
            IF sy-subrc <> 0.
              gv_delete = 'E'.
            ENDIF.
          ENDIF.
      ENDIF.
    ENDLOOP.
  
    IF gv_delete = 'E'.
      " If DB deletion fails, rollback and exit
      ROLLBACK WORK.
      EXIT.
    ELSE.
        " DELETIONS AT Internal Table
        DELETE gt_results WHERE ORDER_ID = gs_result-ORDER_ID.
        MESSAGE 'Rows deleted' TYPE 'S'.
    ENDIF.
  ENDFORM.
  
  " Subroutine that check any input values for new rows prior to
  " save those changes in the DB tables.
  FORM validate_check.
    DATA:f_valid(1) TYPE C,
         lv_answer(1),
         lv_message TYPE string.
  
    DATA:lv_id      TYPE i,
         lv_id_int2 TYPE int2.
  
    "__________________________________________________________________
    " Check for changed values and apply them to results table
    CALL METHOD go_grid->check_changed_data
      IMPORTING
        e_valid = f_valid.
  
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TEXT_QUESTION  = 'Do you really want to save changes?'
        TEXT_BUTTON_1  = 'Yes'
        TEXT_BUTTON_2  = 'No'
      IMPORTING
        ANSWER         = lv_answer
      EXCEPTIONS
        TEXT_NOT_FOUND = 1
        OTHERS         = 2.
  
    CHECK lv_answer = 1.
  
    "__________________________________________________________________
    " Loop through results performing input validation
    CLEAR: gv_check.
    LOOP AT gt_results INTO gs_result WHERE flag_CHG = 'X'
                                      OR    flag_NEW = 'X'.
  
      " Check for introduced product data
      IF gs_result-PROD_NAME   IS INITIAL OR gs_result-PROD_PRICE  IS INITIAL OR
         gs_result-PROD_STOCK  IS INITIAL .
  
        GV_CHECK = 'E'.
        lv_message = 'When introducing a product please input Name / Price / Stock'.
        MESSAGE lv_message TYPE 'E'.
        EXIT.
      ENDIF.
  
      " Check for introduced client data
      IF gs_result-CLIENT_NAME IS INITIAL OR gs_result-CLIENT_LAST_NAME IS INITIAL.
  
        GV_CHECK = 'E'.
        lv_message = 'When introducing a client please input both Name / Lastname'.
        MESSAGE lv_message TYPE 'E'.
        EXIT.
      ENDIF.
  
      " Check for introduced order data
      IF gs_result-TOTAL IS INITIAL OR gs_result-PROD_QUANTITY  IS INITIAL OR
         gs_result-PAYMENT_METHOD IS INITIAL.
  
        GV_CHECK = 'E'.
        lv_message = 'When introducing an order please input TOTAL / Payment Method / specific product quantity'.
        MESSAGE lv_message TYPE 'E'.
        EXIT.
      ENDIF.
  
      IF gs_result-TOTAL <> ( gs_result-PROD_QUANTITY * gs_result-PROD_PRICE ) OR
         ( gs_result-TOTAL < 45 AND ( gs_result-TOTAL <> ( gs_result-PROD_QUANTITY * gs_result-PROD_PRICE ) / 2 )
         AND gs_result-ORDER_COUNT MOD 3 = 0 ).
  
        GV_CHECK = 'E'.
        lv_message = 'The introduced total:' + gs_result-TOTAL + ', Is not consitent with the product list.' .
        MESSAGE lv_message TYPE 'E'.
        EXIT.
      ENDIF.
    ENDLOOP.
  
  ENDFORM.
  
  " Subroutine that save changes into the Internal and DB tables.
  FORM save_changes.
    PERFORM validate_check.
    CHECK gv_check IS INITIAL.
  
    CLEAR: gv_save.
    IF sy-subrc = 0.
      " ACTIONS AT DB TABLE
      LOOP AT gt_results INTO gs_result WHERE flag_CHG = 'X'
                                        OR    flag_NEW = 'X'.
  
        CLEAR: gs_zclient, gs_zproduct, gs_zcorder, gs_zordproduct.
        IF gs_result-flag_NEW = 'X'.
          "________________________________________________________
          " CHANGES ON zclients
          READ TABLE gt_master_clients INTO DATA(ls_client)
          WITH KEY CLIENT_ID = gs_result-ORDER_CLIENT
          BINARY SEARCH.
          IF sy-subrc = 0.
            gs_result-ORDER_COUNT = gs_result-ORDER_COUNT + 1.
            UPDATE zclients SET order_count = gs_result-ORDER_COUNT
              WHERE client_id = gs_result-ORDER_CLIENT.
            IF sy-subrc <> 0.
              gv_save = 'E'.
            ENDIF.
  
          ELSE.
            READ TABLE gt_master_clients INTO DATA(ls_new_client) INDEX LINES( gt_master_clients ).
            IF sy-subrc = 0.
              gs_result-ORDER_CLIENT = ls_new_client-CLIENT_ID + 1.
              gs_zclient-CLIENT_ID = gs_result-ORDER_CLIENT.
              gs_zclient-CLIENT_NAME = gs_result-CLIENT_NAME.
              gs_zclient-CLIENT_LAST_NAME = gs_result-CLIENT_LAST_NAME.
              gs_zclient-ORDER_COUNT = 1.
              INSERT INTO zclients VALUES gs_zclient.
              IF sy-subrc <> 0.
                gv_save = 'E'.
              ENDIF.
  
            ENDIF.
          ENDIF.
  
         "_________________________________________________________
         " CHANGES ON zproduct
          READ TABLE gt_master_products INTO DATA(ls_product)
          WITH KEY PROD_ID = gs_result-PROD_ID
          BINARY SEARCH.
          IF sy-subrc = 0.
            gs_result-PROD_STOCK = gs_result-PROD_STOCK - gs_result-PROD_QUANTITY.
            UPDATE zproducts SET prod_quantity = gs_result-PROD_STOCK
                                 prod_name = gs_result-PROD_NAME
                                 prod_price = gs_result-PROD_PRICE
              WHERE prod_id = gs_result-PROD_ID.
            IF sy-subrc <> 0.
              gv_save = 'E'.
            ENDIF.
          ELSE.
            READ TABLE gt_master_products INTO DATA(ls_new_product) INDEX LINES( gt_master_products ).
            IF sy-subrc = 0.
              gs_result-PROD_ID = ls_new_product-PROD_ID + 1.
              gs_zproduct-PROD_ID = gs_result-PROD_ID.
              gs_zproduct-PROD_NAME = gs_result-PROD_NAME.
              gs_zproduct-PROD_PRICE = gs_result-PROD_PRICE.
              gs_zproduct-PROD_QUANTITY = gs_result-PROD_STOCK - gs_result-PROD_QUANTITY.
              gs_zproduct-MEINS = gs_result-MEINS.
              gs_zproduct-WAERS = gs_result-WAERS.
              INSERT INTO zproducts VALUES gs_zproduct.
              IF sy-subrc <> 0.
                gv_save = 'E'.
              ENDIF.
            ENDIF.
          ENDIF.
  
          "________________________________________________________
          " CHANGES ON zcorders
          gs_zcorder-ORDER_ID = gs_result-ORDER_ID.
          gs_zcorder-PAYMENT_METHOD = gs_result-PAYMENT_METHOD.
          gs_zcorder-TOTAL = gs_result-TOTAL.
          gs_zcorder-WAERS = gs_result-WAERS.
          gs_zcorder-ORDER_DATE = gs_result-ORDER_DATE.
          gs_zcorder-ORDER_TIME = gs_result-ORDER_TIME.
          gs_zcorder-ORDER_CLIENT = gs_result-ORDER_CLIENT.
          INSERT INTO zcorders VALUES gs_zcorder.
          IF sy-subrc <> 0.
            gv_save = 'E'.
          ENDIF.
  
          "________________________________________________________
          " CHANGES ON zordproducts
          gs_zordproduct-ORDER_ID = gs_result-ORDER_ID.
          gs_zordproduct-PROD_ID = gs_result-PROD_ID.
          gs_zordproduct-PROD_QUANTITY = gs_result-PROD_QUANTITY.
          gs_zordproduct-MEINS = gs_result-MEINS.
          INSERT INTO zordproducts VALUES gs_zordproduct.
          IF sy-subrc <> 0.
            gv_save = 'E'.
          ENDIF.
  
          " If everything went well, take down the new or chg flag
          IF gv_save <> 'E'.
            gs_result-flag_NEW = ''.
            gs_result-flag_CHG = ''.
          ENDIF.
  
        ELSEIF gs_result-flag_CHG = 'X'.
          " ON CLOSED ORDERS ONLY PRODUCT INFO CAN BE CHANGED
          " Even if price and stock changes, we could still know the
          " price at that day.
  
          " CHANGES ON zproduct
          UPDATE zproducts SET prod_quantity = gs_result-PROD_STOCK
                               prod_name     = gs_result-PROD_NAME
                               prod_price    = gs_result-PROD_PRICE
            WHERE prod_id = gs_result-PROD_ID.
          IF sy-subrc <> 0.
            gv_save = 'E'.
          ENDIF.
  
          " If everything went well, take down the chg flag
          IF gv_save <> 'E'.
            gs_result-flag_CHG = ''.
          ENDIF.
  
        ENDIF.
      ENDLOOP.
  
      " Given any error , rollback.
      IF gv_save = 'E'.
        ROLLBACK WORK.
        MESSAGE 'Error while saving' TYPE 'E'.
      ELSE.
        COMMIT WORK AND WAIT.
        MESSAGE 'Changes saved successfully' TYPE 'S'.
      ENDIF.
    ENDIF.
  ENDFORM.
  
  " Subroutine that liberates memory and clears alv variables / objects
  FORM clearing.
    CLEAR: gs_zclient, gs_zproduct, gs_zcorder, gs_zordproduct,
           gv_check, gv_save.
  
    CALL METHOD go_grid->free.
    CALL METHOD go_dcontainer->free.
    cl_gui_cfw=>flush( ).
    CLEAR: go_grid.
    CLEAR: go_dcontainer.
    CLEAR: gs_scroll.
    CLEAR: gt_fieldcat, gs_fieldcat.
    CLEAR: gt_fieldcat_slis.
  
    CLEAR: gv_u_path, gv_u_files,
           gv_u_filename, gv_u_check_file,
           gv_u_check_flag, gt_excel,
           gs_excel.
  ENDFORM.