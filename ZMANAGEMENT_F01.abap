*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_F01
*&---------------------------------------------------------------------*

"___________________________________________________________________
"________________GET & MAKE DATA SUBROUTINES________________________
"___________________________________________________________________

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

" Subroutine that launches the database search and is called from the
" outide.
FORM search_order_list.
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

*  IF gv_mode = 'M'.
*    CREATE OBJECT go_handler.             " Handler for custom sy-ucomm values
*    SET HANDLER go_handler->when_toolbar      FOR go_grid.
*  ENDIF.

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

      WHEN 'CLIENT_ID'.                 " Client Code
        gs_fieldcat-key        = 'X'.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C02.
        gs_fieldcat-col_pos    = 2.

      WHEN 'CLIENT_NAME'.               " Client Name
        gs_fieldcat-key        = ''.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C03.
        gs_fieldcat-col_pos    = 3.
        IF gv_mode = 'M'.
          gs_fieldcat-edit = 'X'.
        ENDIF.

      WHEN 'CLIENT_LAST_NAME'.          " Client Last Name
        gs_fieldcat-key        = ''.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C04.
        gs_fieldcat-col_pos    = 4.
        IF gv_mode = 'M'.
          gs_fieldcat-edit = 'X'.
        ENDIF.

      WHEN 'ORDER_COUNT'.               " Client Order Count
        gs_fieldcat-key        = ''.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C05.
        gs_fieldcat-col_pos    = 5.
        IF gv_mode = 'M'.
          gs_fieldcat-edit = 'X'.
        ENDIF.

      WHEN 'ORDER_DATE'.                " Order Date
        gs_fieldcat-key        = ''.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C06.
        gs_fieldcat-col_pos    = 6.
        IF gv_mode = 'M'.
          gs_fieldcat-edit = 'X'.
        ENDIF.

      WHEN 'ORDER_TIME'.               " Order TIme
        gs_fieldcat-key        = ''.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C07.
        gs_fieldcat-col_pos    = 7.
        IF gv_mode = 'M'.
          gs_fieldcat-edit = 'X'.
        ENDIF.

      WHEN 'REG_STATUS'.               " Regular Customer Status
        gs_fieldcat-key        = ''.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C08.
        gs_fieldcat-col_pos    = 8.

      WHEN 'TOTAL'.                    " Order Total
        gs_fieldcat-key        = ''.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C09.
        gs_fieldcat-col_pos    = 9.
        IF gv_mode = 'M'.
          gs_fieldcat-edit = 'X'.
        ENDIF.

      WHEN 'WAERS'.                    " Currency
        gs_fieldcat-key        = ''.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C10.
        gs_fieldcat-col_pos    = 10.

      WHEN 'PAYMENT_METHOD'.           " Payment method
        gs_fieldcat-key        = ''.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C11.
        gs_fieldcat-col_pos    = 11.
        IF gv_mode = 'M'.
          gs_fieldcat-edit = 'X'.
        ENDIF.

      WHEN 'PROD_ID'.                  " Product Code
        gs_fieldcat-key        = 'X'.
        gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
        gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
        gs_fieldcat-coltext    = TEXT-C12.
        gs_fieldcat-col_pos    = 12.

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

      WHEN OTHERS.
        gs_fieldcat-no_out = 'X'.
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
  DATA: lv_order_id   TYPE i,
        lv_client_id  TYPE i,
        lv_product_id TYPE i.
  CLEAR gs_result.

  PERFORM next_id USING 'orders'   CHANGING lv_order_id.
  gs_result-ORDER_ID = lv_order_id.
  PERFORM next_id USING 'clients'  CHANGING lv_client_id.
  gs_result-ORDER_CLIENT = lv_client_id.
  PERFORM next_id USING 'products' CHANGING lv_product_id.
  gs_result-PROD_ID = lv_product_id.

  gs_result-REG_STATUS = 'Sporadic Client'.
  gs_result-WAERS      = 'EUR'.
  gs_result-MEINS      = 'EA'.
  APPEND gs_result TO gt_results.

ENDFORM.

FORM delete_row.
  DATA: lt_sel_rows TYPE lvc_t_row,
        ls_sel_row  TYPE lvc_s_row,
        lv_answer(1).

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
    " ACTIONS AT DB TABLE
    " DOING!!
    DELETE gt_results INDEX ls_sel_row-index.
  ENDLOOP.

  MESSAGE 'Rows deleted' TYPE 'S'.
ENDFORM.

" Subroutine that check any input values for new rows prior to
" save those changes in the DB tables.
FORM validate_check.

  "DOING!!
ENDFORM.

" Subroutine that save changes into the Internal and DB tables.
FORM save_changes.
  PERFORM validate_check.

  IF sy-subrc = 0.
  " ACTIONS AT DB TABLE
  "  MODIFY zproducts FROM TABLE gt_results.
  "  MODIFY zclients
  "  MODIFY zcorders
  "  MODIFY zordproducts
    "DOING!!

    IF sy-subrc <> 0.
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
  CALL METHOD go_grid->free.
  CALL METHOD go_dcontainer->free.
  cl_gui_cfw=>flush( ).
  CLEAR: go_grid.
  CLEAR: go_dcontainer.
  CLEAR: gs_scroll.
  CLEAR: gt_fieldcat, gs_fieldcat.
  CLEAR: gt_fieldcat_slis.
ENDFORM.