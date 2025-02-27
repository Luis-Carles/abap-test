*&---------------------------------------------------------------------*
*&  Include           ZMP_CAFETEST_I01
*&---------------------------------------------------------------------*

" PAI for screen_100 INITIAL MENU
MODULE user_command_100 INPUT.
  CASE sy-ucomm.
    WHEN 'CLIENT_ACT'.
      CALL SCREEN 200.
    WHEN 'EMPLOYEE_ACT'.
      CALL SCREEN 300.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_200 CLIENT IDENTIFICATION
MODULE user_command_200 INPUT.
  CASE sy-ucomm.
    WHEN 'NEW_CLIENT'.
      CALL SCREEN 210.   "Register -> New Client
    WHEN 'COMEBACK'.
      CALL SCREEN 220.   "LOG IN  -> Comeback
    WHEN 'BACK'.
      CALL SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_210 REGISTER -> NEW CLIENT
MODULE retrieve_input_values_210 INPUT.
  MOVE: wa_sclient-name TO wa_sclient-name,
        wa_sclient-last_name TO wa_sclient-last_name.
ENDMODULE.

MODULE user_command_210 INPUT.
  CASE sy-ucomm.
    WHEN 'CANCEL'.
      CLEAR wa_sclient.
      CALL SCREEN 200.
    WHEN 'REGISTER_CLIENT'.
      IF wa_sclient-name IS NOT INITIAL AND wa_sclient-last_name IS NOT INITIAL.
         " -------NEW CLIENT -----------
         lo_client_fan = NEW lcl_client( iv_name = wa_sclient-name
                                         iv_last_name = wa_sclient-last_name
                                         iv_mode = 'new'
                                         iv_client_id = '0' ).

         MOVE: wa_sclient-client_id TO wa_sclient-client_id.
         CALL SCREEN 215. " TO Welcome Screen.
      ELSE.
        MESSAGE 'Error: name and lastname cannot be null.' TYPE 'E'.
      ENDIF.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_215 CLIENT WELCOME
MODULE user_command_215 INPUT.
  CASE sy-ucomm.
    WHEN 'ORDER'.
      CALL SCREEN 230.   "Client Menu --> Ordering
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_220 lOG IN -> COMEBACK
MODULE retrieve_input_values_220 INPUT.
  MOVE: wa_sclient-name TO wa_sclient-name,
        wa_sclient-last_name TO wa_sclient-last_name,
        wa_sclient-client_id TO wa_sclient-client_id.
ENDMODULE.

MODULE user_command_220 INPUT.
  CASE sy-ucomm.
    WHEN 'CANCEL'.
      CLEAR wa_sclient.
      CALL SCREEN 200.
    WHEN 'LOGIN'.
      IF wa_sclient-client_id IS NOT INITIAL.
         " -------OLD CLIENT -----------
         lo_client_fan = NEW lcl_client( iv_name = wa_sclient-name
                                         iv_last_name = wa_sclient-last_name
                                         iv_mode = 'comeback'
                                         iv_client_id = wa_sclient-client_id ).
         CALL SCREEN 225.
      ELSE.
         MESSAGE 'Error: Client ID cannot be null.' TYPE 'E'.
      ENDIF.
    ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_225 OLD CLIENT WELCOME
MODULE user_command_225 INPUT.
  CASE sy-ucomm.
    WHEN 'ORDER'.
      CALL SCREEN 230.   "Client Menu --> Ordering
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_230 CLIENT ACTIONS MENU
MODULE retrieve_input_values_230 INPUT.
  MOVE: wa_sproduct-prod_name TO wa_sproduct-prod_name,
        wa_sproduct-prod_quantity TO wa_sproduct-prod_quantity,
        gv_payment_method TO gv_payment_method,
        gv_order_total TO gv_order_total.

*  DATA: wa_desired_product TYPE ty_product.
*  PERFORM search_product_by_name USING wa_sproduct-prod_name
*                            CHANGING wa_desired_product.
*        wa_sproduct-prod_id = wa_desired_product-prod_id.
  PERFORM find_prod_id_230 USING wa_sproduct-prod_name
                           CHANGING wa_sproduct-prod_id.

  MOVE: wa_sproduct-prod_id TO wa_sproduct-prod_id.
ENDMODULE.

MODULE user_command_230 INPUT.
  CASE sy-ucomm.
    WHEN 'ADD_PRODUCT'.
      "-----ORDERING (Adding products to order)--------
      IF wa_sproduct-prod_id IS NOT INITIAL.
*        DATA: ov_prod_id TYPE int2,
*              ov_prod_quantity TYPE i.
*        ov_prod_id = wa_sproduct-prod_id.
*        ov_prod_quantity = wa_sproduct-prod_quantity.
*
*        lo_order->add_product( iv_prod_id = ov_prod_id iv_quantity = ov_prod_quantity ).
*        lo_order->calculate_total( ).
        PERFORM add_product_230 USING wa_sproduct
                                CHANGING lo_order.

        gv_order_total = lo_order->get_total( ).
        APPEND wa_sproduct TO gt_order_products.
        CLEAR wa_sproduct.
      ELSE.
        MESSAGE 'Error: please select a valid available product.' TYPE 'E'.
      ENDIF.
    WHEN 'ONEW_ORDER'.
      "-----ORDERING (Close order)--------
      lo_order->close_order( iv_o_client = lo_order->get_o_client( ) ).
      lo_order->update_monthly_gains( ).

      CALL SCREEN 290.
    WHEN 'LOG_OUT'.
      CALL SCREEN 290.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_290 GOODBYE MESSAGE
MODULE user_command_290 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      IF lo_client_fan IS NOT INITIAL.
        FREE lo_client_fan.
      ENDIF.
      IF lo_order IS NOT INITIAL.
        FREE lo_order.
      ENDIF.
      IF lo_handler IS NOT INITIAL.
        FREE lo_handler.
      ENDIF.
      CLEAR wa_sclient.
      CLEAR wa_lorder_date.
      gv_payment_method = 'Credit Card'.
      CLEAR wa_sproduct.
      CLEAR gv_order_total.
      CLEAR gt_order_products.

      CALL SCREEN 100.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_300 EMPLOYEE ACTIONS MENU
MODULE user_command_300 INPUT.
  CASE sy-ucomm.
    WHEN 'UPDATE_STOCK'. " -> Update Stock
      CALL SCREEN 310.
    WHEN 'ADD_NEW_PROD'. " -> Add new Product
      CALL SCREEN 320.
    WHEN 'STATS'.        " -> Retrieve Statistics
      CALL SCREEN 330.
    WHEN 'BACK'.
      CALL SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_310 EMPLOYEE UPDATE STOCK
MODULE retrieve_input_values_310 INPUT.
  " Current values of the product
  MOVE: wa_eproduct-prod_name TO wa_eproduct-prod_name.

*  DATA: wa_desired TYPE ty_product.
*  PERFORM search_product_by_name USING wa_eproduct-prod_name
*                            CHANGING wa_desired.
*  wa_eproduct-prod_id = wa_desired-prod_id.
*  wa_eproduct-prod_quantity = wa_desired-prod_quantity.
*  wa_eproduct-prod_price = wa_desired-prod_price.
  PERFORM find_product_310 CHANGING wa_eproduct.

  MOVE: wa_eproduct-prod_id TO wa_eproduct-prod_id,
        wa_eproduct-prod_quantity TO wa_eproduct-prod_quantity,
        wa_eproduct-prod_price TO wa_eproduct-prod_price.

  " New values for the product
        wa_nproduct-prod_id = wa_eproduct-prod_id.
  MOVE: wa_nproduct-prod_name TO wa_nproduct-prod_name,
        wa_nproduct-prod_price TO wa_nproduct-prod_price,
        wa_nproduct-prod_quantity TO wa_nproduct-prod_quantity.

ENDMODULE.

MODULE user_command_310 INPUT.
  CASE sy-ucomm.
    WHEN 'UPDATE_STOCK'.
      IF wa_eproduct-prod_name IS NOT INITIAL.
*        DATA: lv_product TYPE zproducts.
*        lv_product-prod_id = wa_eproduct-prod_id.
*        lv_product-prod_name = wa_eproduct-prod_name.
*        lv_product-prod_quantity = wa_eproduct-prod_quantity.
*        lv_product-prod_price = wa_eproduct-prod_price.
*
*      "------ UPDATE STOCK (Update product name/price/quantity)------
*        IF wa_nproduct-prod_name IS NOT INITIAL.
*          lv_product-prod_name = wa_nproduct-prod_name.
*          PERFORM update_product USING lv_product.
*        ENDIF.
*        IF wa_nproduct-prod_price IS NOT INITIAL.
*          lv_product-prod_price = wa_nproduct-prod_price.
*          PERFORM update_product USING lv_product.
*        ENDIF.
*        IF wa_nproduct-prod_quantity IS NOT INITIAL.
*          lv_product-prod_quantity = wa_nproduct-prod_quantity.
*          PERFORM update_product USING lv_product.
*        ENDIF.
        PERFORM update_stock_310 USING wa_eproduct wa_nproduct.

        CALL SCREEN 315. " Employee Correct Update Screen
      ELSE.
        MESSAGE 'Error: Please select an available product first.' TYPE 'E'.
      ENDIF.
    WHEN 'CANCEL'.
      CLEAR wa_eproduct.
      CLEAR wa_nproduct.
      CALL SCREEN 300.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_315 EMPLOYEE SUCCESFULL UPDATE
MODULE user_command_315 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR wa_eproduct.
      CLEAR wa_nproduct.

      CALL SCREEN 300.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_320 EMPLOYEE ADD NEW PRODUCT
MODULE retrieve_input_values_320 INPUT.
  MOVE: wa_nproduct-prod_name TO wa_nproduct-prod_name,
        wa_nproduct-prod_quantity TO wa_nproduct-prod_quantity,
        wa_nproduct-prod_price TO wa_nproduct-prod_price.
ENDMODULE.

MODULE user_command_320 INPUT.
  CASE sy-ucomm.
    WHEN 'ADD_PROD'.
      "------ NEW STOCK (ADD NEW PRODUCT)----------
      IF wa_nproduct-prod_name IS NOT INITIAL AND
         wa_nproduct-prod_quantity IS NOT INITIAL AND
         wa_nproduct-prod_price IS NOT INITIAL.

*        DATA: ov_name_char TYPE zproducts-prod_name,
*              ov_quantity_quan TYPE zproducts-prod_quantity,
*              ov_price_dec TYPE zproducts-prod_price.
*        ov_name_char = wa_nproduct-prod_name.
*        ov_quantity_quan = wa_nproduct-prod_quantity.
*        ov_price_dec = wa_nproduct-prod_price.
*
*        PERFORM add_new_product USING ov_name_char ov_quantity_quan ov_price_dec.
        PERFORM add_product_320 USING wa_nproduct.

        CALL SCREEN 325. " Employee Correct Addition Screen
      ELSE.
        MESSAGE: 'Error: The three fields are mandatory for the new product.' TYPE 'E'.
      ENDIF.
    WHEN 'BACK'.
      CLEAR wa_nproduct.
      CALL SCREEN 300.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_325 EMPLOYEE SUCCESFULL ADDED PRODUCt
MODULE user_command_325 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR wa_nproduct.

      CALL SCREEN 300.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_330 EMPLOYEE RETRIEVE STATISTICS
MODULE user_command_330 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR gs_stats.
      CALL SCREEN 300.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.