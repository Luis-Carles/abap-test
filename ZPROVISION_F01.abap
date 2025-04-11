*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_F01
*&---------------------------------------------------------------------*

"___________________________________________________________________
"________________GET & MAKE DATA SUBROUTINES________________________
"___________________________________________________________________

" Subroutine that retrieves data from zClients DB Table.
FORM get_client_data.

  *  IF sy-subrc <> 0.
  *    MESSAGE TEXT-E01 TYPE 'E'.
  *  ENDIF
  
  ENDFORM.
  
  " Subroutine that retrieves data from zProducts DB Table.
  FORM get_prod_data.
  
  *  IF sy-subrc <> 0.
  *    MESSAGE TEXT-E02 TYPE 'E'.
  *  ENDIF
  
  ENDFORM.
  
  " Subroutine that retrieves data from zCorders DB Table.
  FORM get_order_data.
  
  *  IF sy-subrc <> 0.
  *    MESSAGE TEXT-E03 TYPE 'E'.
  *  ENDIF
  
  ENDFORM.
  
  " Subroutine that retrieves data from zOrdproducts DB Table.
  FORM get_ordprod_data.
  
  *  IF sy-subrc <> 0.
  *    MESSAGE TEXT-E04 TYPE 'E'.
  *  ENDIF
  
  ENDFORM.
  
  " Subroutine that prepares the color scheme as an aditional
  " field in correspondent results table.
  FORM custom_colors.
    CLEAR: gt_colors, gt_colors[].
  
    CASE gv_tab.
      WHEN 'CL'.
        %ADD_COLOR: TEXT-D02 0 1 'X',  " (CLIENT_ID)
                    TEXT-D03 0 6 '' ,  " (CLIENT_NAME)
                    TEXT-D04 0 6 '' ,  " (CLIENT_LAST_NAME)
                    TEXT-D05 0 5 '' .  " (ORDER_COUNT)
  
      WHEN 'PR'.
        %ADD_COLOR: TEXT-D12 0 1 'X',  " (PROD_ID)
                    TEXT-D13 0 6 '' ,  " (PROD_NAME)
                    TEXT-D14 0 3 '' ,  " (PROD_PRICE)
                    TEXT-D15 0 3 '' ,  " (PROD_QUANTITY)
                    TEXT-D17 0 7 '' .  " (MEINS)
  
      WHEN 'OR'.
        %ADD_COLOR: TEXT-D01 0 1 'X',  " (ORDER_ID)
                    TEXT-D18 0 1 '' ,  " (ORDER_CLIENT)
                    TEXT-D06 0 5 '' ,  " (ORDER_DATE)
                    TEXT-D07 0 5 '' ,  " (ORDER_TIME)
                    TEXT-D09 0 3 '' ,  " (TOTAL)
                    TEXT-D10 0 7 '' ,  " (WAERS)
                    TEXT-D11 0 5 '' .  " (PAYMENT_METHOD)
  
      WHEN 'OP'.
  
        %ADD_COLOR: TEXT-D12 0 1 'X',  " (PROD_ID)
                    TEXT-D01 0 1 'X',  " (ORDER_ID)
                    TEXT-D15 0 3 '' ,  " (PROD_QUANTITY)
                    TEXT-D17 0 7 '' .  " (MEINS)
  
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
  
      WHEN 'OP'.
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
  
      WHEN 'POP'.
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
      MESSAGE: TEXT-E06 TYPE 'E'.
    ENDIF.
  ENDFORM.
  
  "Subroutine that will create the grid.
  FORM create_grid.
    go_grid = NEW cl_gui_alv_grid(
        i_parent = go_dcontainer
    ).
  
    " Handler for custom sy-ucomm values
    go_handler = NEW lcl_handler( ).
    SET HANDLER go_handler->when_data_changed FOR go_grid.
  
    IF sy-subrc <> 0.
      MESSAGE: TEXT-E07 TYPE 'E'.
    ENDIF.
  ENDFORM.
  
  " Subroutine that will create the layout with custom preferences.
  FORM create_layout.
    CLEAR gs_layout.
  
    " LVC_S_LAYO
    gs_layout-zebra             = 'X'.         " Stripped Pattern
    gs_layout-cwidth_opt        = 'X'.         " Column-width optimizing
    gs_layout-sel_mode          = 'A'.         " Selection Mode
    gs_layout-no_toolbar        = ''.          " Enable Toolbar
    gs_layout-CTAB_FNAME        = 'COLOR'.
  
    gs_layout-grid_title = SWITCH i( gv_tab
                             WHEN 'CL' THEN TEXT-A01    " Clients
                             WHEN 'PR' THEN TEXT-A02    " Products
                             WHEN 'CO' THEN TEXT-A03    " Closed Orders
                             WHEN 'OP' THEN TEXT-A04    " Order Products
    ).
  
  ENDFORM.
  
  " Subroutine that custom each field inside the Field Catalog.
  FORM custom_fieldcat.
    CLEAR: gt_fieldcat, gt_fieldcat[].
  
    CASE gv_tab.
      WHEN 'CL'.
        %ADD_FIELD: TEXT-D02 'X' TEXT-C02 1 ''  ''  'C'," Client Code
                    TEXT-D03 ''  TEXT-C03 2 'X' 'X' 'C'," Client Name
                    TEXT-D04 ''  TEXT-C04 3 'X' 'X' 'C'," Cl. Lastname
                    TEXT-D05 ''  TEXT-C05 4 'X' ''  'C'." Cl. OrderCount
  
        %HIDE_FIELD: TEXT-D19, " flag_NEW
                     TEXT-D20, " flag_CHG
                     TEXT-D21. " COLOR
  
      WHEN 'PR'.
        %ADD_FIELD: TEXT-D12 'X' TEXT-C12 1 ''  ''  'C'," Product Code
                    TEXT-D13 ''  TEXT-C13 2 'X' 'X' 'C'," Product Name
                    TEXT-D14 ''  TEXT-C14 3 'X' ''  'C'," Product Price
                    TEXT-D15 ''  TEXT-C15 4 'X' ''  'C'," Product Stock
                    TEXT-D17 ''  TEXT-C17 5 ''  ''  'C'. " Unit
  
        %HIDE_FIELD: TEXT-D19, " flag_NEW
                     TEXT-D20, " flag_CHG
                     TEXT-D21. " COLOR
  
      WHEN 'CO'.
        %ADD_FIELD: TEXT-D01 'X' TEXT-C01 1 ''  ''  'C'," Order Number
                    TEXT-D18 'X' TEXT-C02 2 'X' ''  'C'," Client Code
                    TEXT-D06 ''  TEXT-C06 3 'X' ''  'C'," Order Date
                    TEXT-D07 ''  TEXT-C07 4 'X' ''  'C'," Order Time
                    TEXT-D09 ''  TEXT-C09 5 ''  ''  'C'," Order Total
                    TEXT-D10 ''  TEXT-C10 6 ''  ''  'C'," Currency
                    TEXT-D11 ''  TEXT-C11 7 'X' 'X' 'C'." Payment Method
  
        %HIDE_FIELD: TEXT-D19, " flag_NEW
                     TEXT-D20, " flag_CHG
                     TEXT-D21. " COLOR
  
      WHEN 'OP'.
        %ADD_FIELD: TEXT-D12 'X' TEXT-C12 1 ''  ''  'C'," Product Code
                    TEXT-D01 'X' TEXT-C01 2 ''  ''  'C'," Order Number
                    TEXT-D15 ''  TEXT-C15 3 'X' ''  'C'," Product Quan.
                    TEXT-D17 ''  TEXT-C17 4 ''  ''  'C'." Unit
  
        %HIDE_FIELD: TEXT-D19, " flag_NEW
                     TEXT-D20, " flag_CHG
                     TEXT-D21. " COLOR
  
    ENDCASE.
  ENDFORM.
  
  " Subroutine that eliminates every non neccesary button in  toolbar
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
  
  " Subroutine that displays the grid for the first time.
  FORM display_grid.
    CASE gv_tab.
      WHEN 'CL'.
        %DISPLAY gt_clients.
  
      WHEN 'PR'.
        %DISPLAY gt_products.
  
      WHEN 'CO'.
        %DISPLAY gt_corders.
  
      WHEN 'OP'.
        %DISPLAY gt_ordproducts.
    ENDCASE.
  ENDFORM.
  
  " Subroutine that refresh the Grid ALV in Result Screen, searching
  " again and displaying newest information.
  FORM refresh_grid USING iv_refind TYPE CHAR1.
    DATA(ls_scroll) = VALUE lvc_s_stbl( row = 'X' col = 'X' ).
  
    IF iv_refind = 'X'.
      " Re retrieve data from DB Tables:
      PERFORM search_data.
    ENDIF.
  
    " Refresh the grid
    go_grid->refresh_table_display(
        i_soft_refresh = 'X'
        is_stable      = ls_scroll
    ).
    cl_gui_cfw=>flush( ).
  ENDFORM.
  
  " Subroutine that is triggered from PBO Modules and call in precise
  " order every subroutine necessary to perform write in ALV GRID.
  FORM alv_write.
    IF go_dcontainer IS NOT BOUND.    " Displaying for the first time
      PERFORM create_dcontainer.
      PERFORM create_grid.
      PERFORM create_layout.
      PERFORM custom_fieldcat.
      PERFORM custom_toolbar CHANGING gt_toolbar_ex.
      PERFORM display_grid.
    ELSE.
      PERFORM refresh_grid USING ''.
    ENDIF.
  ENDFORM.
  
  " Subroutine that clears every variable that wont be used later
  " liberating memory space.
  FORM clearing.
    " Clear internal tables / Persistance var. / ALV var. / Flags.
    CLEAR: gt_clients, gt_products, gt_corders, gt_ordproducts,
           gs_layout,  gt_fieldcat, gt_toolbar_ex, gt_colors,
           gv_code,    ok_code,     gv_answer,  gs_chg_row.
    gv_filled = abap_false.
  
    " Clear object Instances
    go_grid->free( ).
    go_dcontainer->free( ).
    cl_gui_cfw=>flush( ).
    CLEAR: go_grid, go_dcontainer.
  
    IF go_handler IS NOT INITIAL.
      CLEAR go_handler.
    ENDIF.
  
  ENDFORM.
  
  "___________________________________________________________________
  "________________DB TABLES PERSISTANCE SUBROUTINES__________________
  "___________________________________________________________________
  
  " Subroutine that insert a new row in the correspondent DB Table.
  FORM add_row.
    CASE gv_tab.
      WHEN 'CL'.
        DATA(lv_cl_next_id) = REDUCE int2( INIT max_id = 0
                                  FOR wa_cl IN gt_clients
                                  NEXT max_id = COND #(
                                       WHEN wa_cl-CLIENT_ID > max_id
                                            THEN wa_cl-CLIENT_ID
                                       ELSE max_id )
                              ) + 1.
        %ADD_CLIENT lv_cl_next_id.
  
      WHEN 'PR'.
        DATA(lv_pr_next_id) = REDUCE int2( INIT max_id = 0
                                  FOR wa_pr IN gt_products
                                  NEXT max_id = COND #(
                                       WHEN wa_pr-PROD_ID > max_id
                                            THEN wa_pr-PROD_ID
                                       ELSE max_id )
                              ) + 1.
        %ADD_PRODUCT lv_pr_next_id.
  
      WHEN 'CO'.
        DATA(lv_co_next_id) = REDUCE int2( INIT max_id = 0
                                  FOR wa_co IN gt_corders
                                  NEXT max_id = COND #(
                                       WHEN wa_co-ORDER_ID > max_id
                                            THEN wa_co-ORDER_ID
                                       ELSE max_id )
                              ) + 1.
        %ADD_ORDER lv_co_next_id.
  
      WHEN 'OP'.
        %ADD_ORDPRODUCT.
  
    ENDCASE.
  ENDFORM.
  
  " Subroutine that deletes selected row/s in correspondent Db Table.
  FORM delete_row.
    CLEAR: gv_answer, gv_delete, gt_sel_rows.
    "_________________________________________________________________
    " Get the selected rows and confirms the users intention
    go_grid->get_selected_rows(
      IMPORTING
        et_index_rows = gt_sel_rows
    ).
                            " Confirmation Pop-Up Window
    DATA(lv_delete_question) = SWITCH string( gv_langu
                                WHEN 'KR' THEN TEXT-Q03
                                ELSE TEXT-Q04 ).
    %POP_UP lv_delete_question.
    CHECK gv_answer = 1.
  
    "_________________________________________________________________
    " Loop through correspondent Table making deletions and updates
    CASE gv_tab.
      WHEN 'CL'.                             " Clients
        LOOP AT gt_sel_rows ASSIGNING FIELD-SYMBOL(<fs_sel_client>).
          " Delete that client
          DATA(lv_cl_tbd) = gt_clients[ <fs_sel_client>-INDEX ].
          DELETE FROM zclients WHERE CLIENT_ID = lv_cl_tbd-CLIENT_ID.
  
          LOOP AT gt_corders
            ASSIGNING FIELD-SYMBOL(<fs_c_corder_tbd>).
            " Delete that client order order products
            LOOP AT gt_ordproducts
              ASSIGNING FIELD-SYMBOL(<fs_c_ordproduct_tbd>).
              DELETE FROM zordproducts
                WHERE ORDER_ID = <fs_c_corder_tbd>-ORDER_ID.
            ENDLOOP.
  
            " Delete that client order
            DELETE FROM zcorders
              WHERE ORDER_CLIENT = lv_cl_tbd-CLIENT_ID.
          ENDLOOP.
  
        ENDLOOP.
  
      WHEN 'PR'.                             " Products
        LOOP AT gt_sel_rows ASSIGNING FIELD-SYMBOL(<fs_sel_product>).
          " Delete that product
          DATA(lv_pr_tbd) = gt_products[ <fs_sel_product>-INDEX ].
          DELETE FROM zproducts WHERE PROD_ID = lv_pr_tbd-PROD_ID.
  
        ENDLOOP.
  
      WHEN 'OR'.                             " Closed Orders
        LOOP AT gt_sel_rows ASSIGNING FIELD-SYMBOL(<fs_sel_corder>).
          " Delete that Order
          DATA(lv_co_tbd) = gt_corders[ <fs_sel_corder>-INDEX ].
          DELETE FROM zcorders WHERE ORDER_ID = lv_co_tbd-ORDER_ID.
  
          " Delete that Order products
          LOOP AT gt_ordproducts
            ASSIGNING FIELD-SYMBOL(<fs_o_ordproduct_tbd>).
            DELETE FROM zordproducts
            WHERE ORDER_ID = lv_co_tbd-ORDER_ID.
          ENDLOOP.
  
        ENDLOOP.
  
      WHEN 'OP'.                             " Order Products
        DATA lv_total_tbu TYPE int2 VALUE 0.
  
        LOOP AT gt_sel_rows
          ASSIGNING FIELD-SYMBOL(<fs_sel_ordproduct>).
          " Get that product order
          DATA(lv_op_tbd) =
            gt_ordproducts[ <fs_sel_ordproduct>-INDEX ].
  
          " Update that order Total
          " Check the total for FW events
          LOOP AT gt_ordproducts
            ASSIGNING FIELD-SYMBOL(<fs_op_ordproduct_tbu>)
            WHERE ORDER_ID = lv_op_tbd-ORDER_ID.
            lv_total_tbu = lv_total_tbu +
              ( <fs_op_ordproduct_tbu>-PROD_QUANTITY *
              gt_products[ PROD_ID =
                <fs_op_ordproduct_tbu>-PROD_ID ]-PROD_PRICE ).
          ENDLOOP.
  
          " If total coincides, then just updates the Total
          IF lv_total_tbu =
            gt_corders[ ORDER_ID = lv_op_tbd-ORDER_ID ]-TOTAL.
            " Calcules new Total
            lv_total_tbu = lv_total_tbu - ( lv_op_tbd-PROD_QUANTITY *
            gt_products[ PROD_ID = lv_op_tbd-PROD_ID ]-PROD_PRICE ).
  
            " Updates Total
            UPDATE zcorders SET TOTAL = lv_total_tbu
              WHERE ORDER_ID = lv_op_tbd-ORDER_ID.
  
          ELSE. " The order had a 50% Discount on it
            " Calcules new Total
            lv_total_tbu = lv_total_tbu - ( lv_op_tbd-PROD_QUANTITY *
            gt_products[ PROD_ID = lv_op_tbd-PROD_ID ]-PROD_PRICE ).
  
            " We redo the 50%discount and Update Total
            lv_total_tbu = lv_total_tbu / 2.
            UPDATE zcorders SET TOTAL = lv_total_tbu
              WHERE ORDER_ID = lv_op_tbd-ORDER_ID.
          ENDIF.
  
          " Delete that Order Product
          DELETE FROM zordproducts WHERE ORDER_ID = lv_op_tbd-ORDER_ID
                                    AND  PROD_ID  = lv_op_tbd-PROD_ID.
        ENDLOOP.
  
    ENDCASE.
    "_________________________________________________________________
      " Given any error, rollback.
    IF gv_delete = 'E'.
      ROLLBACK WORK.
      MESSAGE TEXT-E09 TYPE 'E'.
    ELSE.
        DATA(lv_delete_msg) = SWITCH string( gv_langu
                                  WHEN 'KR' THEN TEXT-S01
                                  ELSE TEXT-S02 ).
        MESSAGE lv_delete_msg TYPE 'S'.
    ENDIF.
  ENDFORM.
  
  " Subroutine that check any input values for new rows prior to
  " save those changes in the DB tables.
  FORM validate_check.
    CLEAR: gv_answer,gv_check.
    "_________________________________________________________________
    " Check for changed values and apply them to results table
    go_grid->check_changed_data(
      IMPORTING
        e_valid = DATA(lv_valid)
    ).
                            " Confirmation Pop-Up Window
    DATA(lv_save_question) = SWITCH string( gv_langu
                              WHEN 'KR' THEN TEXT-Q05
                              ELSE TEXT-Q06 ).
    %POP_UP lv_save_question.
    CHECK gv_answer = 1.
  
    "_________________________________________________________________
    " Loop through results performing input validation
    CASE gv_tab.
      WHEN 'CL'.
        LOOP AT gt_clients ASSIGNING FIELD-SYMBOL(<fs_cl_chk>)
          WHERE flag_NEW = 'X' OR flag_CHG = 'X'.
          " Check Client name / Last name
          IF <fs_cl_chk>-CLIENT_NAME IS INITIAL OR
             <fs_cl_chk>-CLIENT_LAST_NAME IS INITIAL.
            gv_check = 'E'.
            MESSAGE TEXT-E11 TYPE 'E'. EXIT.
  
          " Check positive order count
          ELSEIF <fs_cl_chk>-ORDER_COUNT IS INITIAL OR
                 <fs_cl_chk>-ORDER_COUNT < 0.
            gv_check = 'E'.
            MESSAGE TEXT-E12 TYPE 'E'. EXIT.
          ENDIF.
        ENDLOOP.
  
      WHEN 'PR'.
        LOOP AT gt_products ASSIGNING FIELD-SYMBOL(<fs_pr_chk>)
          WHERE flag_NEW = 'X' OR flag_CHG = 'X'.
          " Check product name
          IF <fs_pr_chk>-PROD_NAME IS INITIAL.
            gv_check = 'E'.
            MESSAGE TEXT-E13 TYPE 'E'. EXIT.
  
          " Check price and stock
          ELSEIF <fs_pr_chk>-PROD_PRICE IS INITIAL    OR
                 <fs_pr_chk>-PROD_PRICE < 0           OR
                 <fs_pr_chk>-PROD_QUANTITY IS INITIAL OR
                 <fs_pr_chk>-PROD_QUANTITY < 0.
            gv_check = 'E'.
            MESSAGE TEXT-E14 TYPE 'E'. EXIT.
          ENDIF.
        ENDLOOP.
  
      WHEN 'CO'.
        LOOP AT gt_corders ASSIGNING FIELD-SYMBOL(<fs_co_chk>)
          WHERE flag_NEW = 'X' OR flag_CHG = 'X'.
          " Check date / time / Payment method
          IF <fs_co_chk>-ORDER_DATE     IS INITIAL OR
             <fs_co_chk>-ORDER_TIME     IS INITIAL OR
             <fs_co_chk>-PAYMENT_METHOD IS INITIAL.
            gv_check = 'E'.
            MESSAGE TEXT-E15 TYPE 'E'. EXIT.
  
          " Check total
          ELSEIF <fs_co_chk>-TOTAL IS INITIAL        OR
                 <fs_co_chk>-TOTAL < 0               OR
                 <fs_co_chk>-ORDER_CLIENT IS INITIAL OR
                 <fs_co_chk>-ORDER_CLIENT < 0.
            gv_check = 'E'.
            MESSAGE TEXT-E16 TYPE 'E'. EXIT.
  
          " Check if client exists
          ELSEIF NOT line_exists( gt_clients[ CLIENT_ID =
            <fs_co_chk>-ORDER_CLIENT ] ).
            gv_check = 'E'.
            MESSAGE TEXT-E17 TYPE 'E'. EXIT.
          ENDIF.
        ENDLOOP.
  
      WHEN 'OP'.
        LOOP AT gt_ordproducts ASSIGNING FIELD-SYMBOL(<fs_op_chk>)
          WHERE flag_NEW = 'X' OR flag_CHG = 'X'.
          " Check if Order exists
          IF NOT line_exists( gt_corders[ ORDER_ID =
            <fs_op_chk>-ORDER_ID ] ).
            gv_check = 'E'.
            MESSAGE TEXT-E18 TYPE 'E'. EXIT.
  
          " Check if Product exists
          ELSEIF NOT line_exists( gt_products[ PROD_ID =
            <fs_op_chk>-PROD_ID ] ).
            gv_check = 'E'.
            MESSAGE TEXT-E19 TYPE 'E'. EXIT.
  
          " Check quantity
          ELSEIF <fs_op_chk>-PROD_QUANTITY IS INITIAL OR
                 <fs_op_chk>-PROD_QUANTITY < 0.
            gv_check = 'E'.
            MESSAGE TEXT-E20 TYPE 'E'. EXIT.
          ENDIF.
        ENDLOOP.
  
    ENDCASE.
  ENDFORM.
  
  " Subroutine that save changes into the Internal and DB table.
  FORM save_changes.
    CLEAR: gv_save.
    "_________________________________________________________________
    " Validates that every change is compliant with DB consistency
    PERFORM validate_check.
    CHECK gv_check IS NOT INITIAL.
  
    "_________________________________________________________________
    " Loop through correspondent Table making insertions and updates
    CASE gv_tab.
      WHEN 'CL'.
        " Insert NEW Clients
        FIELD-SYMBOLS: <fs_cl_tbi> TYPE ty_client.
        DATA(lt_cl_tbi) = VALUE zclients(
                             FOR  <fs_cl_tbi> IN gt_clients
                             WHERE ( flag_NEW = 'X' )
                             ( CORRESPONDING zclients( <fs_cl_tbi> ) )
                          ).
        IF lt_cl_tbi IS NOT INITIAL.
          INSERT zclients FROM TABLE @lt_cl_tbi.
          IF sy-subrc <> 0.
            gv_save = 'E'.
            EXIT.
          ENDIF.
        ENDIF.
  
        " Update CHANGED Clients
        FIELD-SYMBOLS: <fs_cl_tbc> TYPE ty_client.
        DATA(lt_cl_tbc) = VALUE zclients(
                             FOR  <fs_cl_tbc> IN gt_clients
                             WHERE ( flag_CHG = 'X' )
                             ( CORRESPONDING zclients( <fs_cl_tbc> ) )
                          ).
        IF lt_cl_tbc IS NOT INITIAL.
  
          IF sy-subrc <> 0.
            UPDATE zclients FROM TABLE @lt_cl_tbc.
            gv_save = 'E'.
            EXIT.
          ENDIF.
        ENDIF.
  
      WHEN 'PR'.
  
  
      WHEN 'CO'.
  
  
      WHEN 'OP'.
  
  
    ENDCASE.
    "_________________________________________________________________
      " Given any error , rollback.
      IF gv_save = 'E'.
        ROLLBACK WORK.
        MESSAGE TEXT-E10 TYPE 'E'.
      ELSE.
        COMMIT WORK AND WAIT.
        DATA(lv_save_msg) = SWITCH string( gv_langu
                                  WHEN 'KR' THEN TEXT-S03
                                  ELSE TEXT-S04 ).
        MESSAGE lv_save_msg TYPE 'S'.
      ENDIF.
  ENDFORM.