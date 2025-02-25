*&---------------------------------------------------------------------*
*&  Include           ZMP_CAFETEST_O01
*&---------------------------------------------------------------------*

MODULE status_100 OUTPUT.
  SET PF-STATUS 'INITIAL_MENU'.
ENDMODULE.

MODULE status_200 OUTPUT.
  SET PF-STATUS 'CLIENT_IDENT'.
ENDMODULE.

MODULE status_210 OUTPUT.
  SET PF-STATUS 'REGISTER_CLIENT'.
ENDMODULE.

MODULE status_215 OUTPUT.
  SET PF-STATUS 'WELCOME'.
ENDMODULE.

MODULE status_220 OUTPUT.
  SET PF-STATUS 'LOG_IN'.
ENDMODULE.

MODULE status_225 OUTPUT.
  SET PF-STATUS 'WELCOME'.
ENDMODULE.

MODULE status_230 OUTPUT.
  SET PF-STATUS 'CLIENT_MENU'.
ENDMODULE.

MODULE create_order_230 OUTPUT.
  IF lo_order IS INITIAL.
    lo_order = NEW lcl_order( iv_payment_method = gv_payment_method
                              iv_o_client       = lo_client_fan ).

    lo_handler = NEW lcl_fourth_wing_handler( ).

    " Link event possible raiser to the handler
    SET HANDLER lo_handler->on_fourth_wing FOR lo_order.
  ENDIF.
ENDMODULE.

MODULE status_290 OUTPUT.
  SET PF-STATUS 'FINAL-GREETINGS'.
ENDMODULE.

MODULE status_300 OUTPUT.
  SET PF-STATUS 'EMPLOYEE_MENU'.
ENDMODULE.

MODULE status_310 OUTPUT.
  SET PF-STATUS 'EMPLOYEE_USTOCK'.
ENDMODULE.

MODULE status_315 OUTPUT.
  SET PF-STATUS 'FINAL-GREETINGS'.
ENDMODULE.

MODULE status_320 OUTPUT.
  SET PF-STATUS 'EMPLOYEE_ADDPROD'.
ENDMODULE.

MODULE status_325 OUTPUT.
  SET PF-STATUS 'FINAL-GREETINGS'.
ENDMODULE.

MODULE status_330 OUTPUT.
  SET PF-STATUS 'EMPLOYEE_STATS'.
ENDMODULE.

MODULE retrieve_client OUTPUT.
  wa_sclient-name = lo_client_fan->get_client_name( ).
  wa_sclient-last_name = lo_client_fan->get_client_last_name( ).
  wa_sclient-client_id = lo_client_fan->get_client_id( ).
  wa_sclient-order_count = lo_client_fan->get_order_count( ).
ENDMODULE.

MODULE retrieve_lorder_date OUTPUT.
  PERFORM search_most_recent_order USING wa_sclient-client_id
                                   CHANGING wa_lorder_date.
ENDMODULE.

MODULE retrieve_product_315 OUTPUT.
  DATA: ls_updated_product TYPE ty_product,
        lv_id_int TYPE int2.
  lv_id_int = wa_eproduct-prod_id.

  PERFORM search_product USING lv_id_int
                         CHANGING ls_updated_product.

  wa_eproduct-prod_id = ls_updated_product-prod_id.
  wa_eproduct-prod_name = ls_updated_product-prod_name.
  wa_eproduct-prod_quantity = ls_updated_product-prod_quantity.
  wa_eproduct-prod_price = ls_updated_product-prod_price.
ENDMODULE.

MODULE retrieve_product_325 OUTPUT.
  DATA: ls_new_product TYPE ty_product,
        lv_name_string TYPE string.
  lv_name_string = wa_nproduct-prod_name.

  PERFORM search_product_by_name USING lv_name_string
                                 CHANGING ls_new_product.

  wa_nproduct-prod_id = ls_new_product-prod_id.
  wa_nproduct-prod_name = ls_new_product-prod_name.
  wa_nproduct-prod_quantity = ls_new_product-prod_quantity.
  wa_nproduct-prod_price = ls_new_product-prod_price.
ENDMODULE.

MODULE retrieve_stats OUTPUT.
  " Statistics Retrieving aditional import
  DATA: ls_stats TYPE ZST_STATS.

  "------ RETRIEVE STATISTICS --------
  PERFORM calcule_unitary_stats CHANGING ls_stats.

  IF sy-subrc = 0.
    gs_stats = ls_stats.
    PERFORM search_product USING gs_stats-BEST_SELLER
          CHANGING wa_eproduct.
    gv_best_seller = wa_eproduct-prod_name.

    PERFORM search_product USING gs_stats-WORST_SELLER
          CHANGING wa_eproduct.
    gv_worst_seller = wa_eproduct-prod_name.
  ELSE.
    MESSAGE 'Error when trying to retrieve statistics.' TYPE 'E'.
  ENDIF.
ENDMODULE.