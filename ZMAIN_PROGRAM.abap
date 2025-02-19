*&---------------------------------------------------------------------*
*& Report  ZMAIN_PROGRAM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZMAIN_PROGRAM.

" Tables & Data import
INCLUDE ZMAIN_TOP.

" Classes & Soubroutines import
INCLUDE ZMAIN_CLS.

" Parameters initialization
DATA: gv_flag TYPE abap_bool VALUE abap_false,
      lt_p_products TYPE SORTED TABLE OF ty_product
                    WITH UNIQUE KEY prod_name,
      ls_p_product  TYPE ty_product,
      wa_p_product  TYPE ty_product.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
   PARAMETERS: e_name TYPE zproducts-prod_name,
               e_quan TYPE zproducts-prod_quantity,
               e_price TYPE zproducts-prod_price,
               e_oldp AS CHECKBOX,
               e_pid TYPE zproducts-prod_id,
               e_stats AS CHECKBOX.
SELECTION-SCREEN: END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
  PARAMETERS: p_name TYPE zclients-client_name,
              p_lname TYPE zclients-client_last_name,
              p_oldc AS CHECKBOX,
              p_cid TYPE zclients-client_id.
SELECTION-SCREEN: END OF BLOCK b2.

SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
  PARAMETERS: p_paym TYPE zcorders-payment_method DEFAULT 'Credit Card'.
  SELECT-OPTIONS: s_prod FOR zproducts-prod_name.
  PARAMETERS: p_quan TYPE zproducts-prod_quantity.
  SELECTION-SCREEN PUSHBUTTON /55(15) p_caddp USER-COMMAND add_prod.
SELECTION-SCREEN: END OF BLOCK b3.

"SELECTION-SCREEN: BEGIN OF BLOCK b4 WITH FRAME.
"  PARAMETERS: p_proc TYPE char1.
"SELECTION-SCREEN: END OF BLOCK b4.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN PUSHBUTTON /10(20) p_exec USER-COMMAND start_exec.

INITIALIZATION.
  p_exec = 'Proceed'.
  p_caddp = 'Add product to order'.

AT SELECTION-SCREEN.
  " Employee actions input check
  IF e_name IS NOT INITIAL AND ( e_quan IS INITIAL OR e_price IS INITIAL ).
    MESSAGE 'Product name, quantity and price are required.' TYPE 'E'.
    gv_flag = abap_false.
  ELSEIF e_oldp = 'X' AND e_pid IS INITIAL.
    MESSAGE 'Product id is reuired for existing products.' TYPE 'E'.
    gv_flag = abap_false.
  ELSE.
    gv_flag = abap_true.
  ENDIF.

  " Client actiones input check
  IF p_name IS NOT INITIAL AND p_lname IS INITIAL.
    MESSAGE 'Client name and lastname are required.' TYPE 'E'.
    gv_flag = abap_false.
  ELSEIF p_oldc = 'X' AND ( p_cid IS INITIAL OR p_name IS INITIAL ).
    MESSAGE 'Client id is reuired for existing clients.' TYPE 'E'.
    gv_flag = abap_false.
  ELSE.
    gv_flag = abap_true.
  ENDIF.

  " Button actions logic
  CASE sy-ucomm.
    WHEN 'START_EXEC'.
       IF gv_flag = abap_true.
         LEAVE TO SCREEN 0.
       ENDIF.

    WHEN 'ADD_PROD'.
       IF lt_p_products IS NOT INITIAL AND p_name IS INITIAL.
         MESSAGE 'You must be singed in in order to make an order.' TYPE 'E'.
       ELSE.
         ls_p_product-prod_name = s_prod.
         ls_p_product-prod_quantity = p_quan.

         IF ls_p_product-prod_name <> '' AND ls_p_product-prod_quantity <> ''.
           READ TABLE lt_p_products WITH KEY prod_name = ls_p_product-prod_name
                 INTO wa_p_product.
           IF sy-subrc = 0.
             ls_p_product-prod_quantity = ls_p_product-prod_quantity + wa_p_product-prod_quantity.
             MODIFY lt_p_products FROM ls_p_product INDEX sy-tabix.
           ELSE.
             INSERT ls_p_product INTO TABLE lt_p_products.
           ENDIF.
         ENDIF.
         ls_p_product-prod_name = ''.
         ls_p_product-prod_quantity = ''.
         CLEAR s_prod.
         CLEAR p_quan.
       ENDIF.
  ENDCASE.

"---------------------> Main Program Execution
START-OF-SELECTION.
  " Create a client / order / handler instance
  DATA: lo_client_fan TYPE REF TO lcl_client,
        lo_order TYPE REF TO lcl_order,
        lo_handler TYPE REF TO lcl_fourth_wing_handler,
        ls_product  TYPE zproducts.

  lo_handler = NEW lcl_fourth_wing_handler( ).

  " 1 APPROACH: setting parameters with SCREEN-SELECTION
  IF e_name IS NOT INITIAL.
    IF e_oldp = ''.
      "------ NEW STOCK ----------

      DATA: p_prod_name TYPE zproducts-prod_name,
            p_prod_quantity TYPE zproducts-prod_quantity,
            p_prod_price TYPE zproducts-prod_price.

      p_prod_name = e_name.
      p_prod_quantity = e_quan.
      p_prod_price = e_price.
      PERFORM add_new_product USING p_prod_name
                                    p_prod_quantity
                                    p_prod_price.
    ELSE.
      "------ UPDATE STOCK --------
      PERFORM update_stock USING e_pid e_quan.
    ENDIF.
  ENDIF.

*  DATA: ls_stats TYPE ZST_STATS.
*  IF e_stats = 'X'.
     "------ RETRIEVE STATISTICS --------
*    PERFORM ZMAIN_MONTHLY_STATS CHANGING ls_stats.
*  ENDIF.

  PERFORM display_stock.

  IF p_name IS NOT INITIAL.
    DATA: p_name_string TYPE string,
          p_lname_string TYPE string,
          p_paym_string TYPE string,
          p_cid_i       TYPE i.
    CONCATENATE p_name '' INTO p_name_string.
    CONCATENATE p_lname '' INTO p_lname_string.
    CONCATENATE p_paym '' INTO p_paym_string.
    p_cid_i = p_cid.

    IF p_oldc = ''.
    " -------NEW CLIENT -----------
      lo_client_fan = NEW lcl_client( iv_name = p_name_string
                                      iv_last_name = p_lname_string
                                      iv_mode = 'new'
                                      iv_client_id = '0' ).
    ELSE.
    " -------OLD CLIENT -----------
      " Check existing client DOING!!

      lo_client_fan = NEW lcl_client( iv_name = p_name_string
                                      iv_last_name = p_lname_string
                                      iv_mode = 'comeback'
                                      iv_client_id = p_cid_i ).
    ENDIF.

    IF lt_p_products IS NOT INITIAL.
      "-----ORDERING --------
      lo_order = NEW lcl_order( iv_payment_method = p_paym_string
                                iv_o_client       = lo_client_fan ).

      " Link event possible raiser to the handler
      SET HANDLER lo_handler->on_fourth_wing FOR lo_order.

      " Add products
      LOOP AT lt_p_products INTO wa_p_product.
        " Check existing product
        SELECT prod_id FROM zproducts INTO wa_p_product-prod_id
          WHERE prod_name = wa_p_product-prod_name.
        ENDSELECT.
        IF sy-subrc = 0.
          DATA: e_pid_int2 TYPE int2,
                e_quan_i   TYPE i.
          e_pid_int2 = wa_p_product-prod_id.
          e_quan_i = wa_p_product-prod_quantity.

          lo_order->add_product( iv_prod_id = e_pid_int2 iv_quantity = e_quan_i ).
          lo_order->calculate_total( ).
        ELSE.
          WRITE: / 'The Product: ', wa_p_product-prod_name, ' does not exist.', /.
        ENDIF.
      ENDLOOP.

      " Close order
      lo_order->close_order( iv_o_client = lo_order->get_o_client( ) ).
      lo_order->update_monthly_gains( ).
      lo_order->display_order( ).
    ENDIF.
  ENDIF.

*  " 2 APPROACH: MANUAL INTERACTION
*  PERFORM manual_interaction.

*  " 3 APPROACH: TRANSACTION
*  CALL TRANSACTION 'ZCAFETEST'.

  " Check remaining stock and monthly gains
  PERFORM display_stock.
  WRITE: / 'Final gains:', gv_monthly_gains.