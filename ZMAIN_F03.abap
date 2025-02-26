*&---------------------------------------------------------------------*
*&  Include           ZMAIN_F03
*&---------------------------------------------------------------------*

" Screen 230 PAI Subroutines
FORM find_prod_id_230 USING iv_name TYPE CHANGING rv_found_id TYPE i.
    DATA: wa_desired_product TYPE ty_product.
    PERFORM search_product_by_name USING iv_name
                              CHANGING wa_desired_product.
  
          rv_found_id = wa_desired_product-prod_id.
  ENDFORM.
  
  FORM add_product_230 USING iv_product TYPE ty_product
                       CHANGING cv_order TYPE REF TO lcl_order.
    DATA: ov_prod_id TYPE int2,
          ov_prod_quantity TYPE i.
          ov_prod_id = iv_product-prod_id.
          ov_prod_quantity = iv_product-prod_quantity.
  
    lo_order->add_product( iv_prod_id = ov_prod_id iv_quantity = ov_prod_quantity ).
  ENDFORM.
  
  " Screen 310 PAI Subroutines
  FORM find_product_310.
    DATA: wa_desired TYPE ty_product.
    PERFORM search_product_by_name USING wa_eproduct-prod_name
                              CHANGING wa_desired.
    wa_eproduct-prod_id = wa_desired-prod_id.
    wa_eproduct-prod_quantity = wa_desired-prod_quantity.
    wa_eproduct-prod_price = wa_desired-prod_price.
  ENDFORM.
  
  FORM update_stock_310.
    DATA: lv_product TYPE zproducts.
          lv_product-prod_id = wa_eproduct-prod_id.
          lv_product-prod_name = wa_eproduct-prod_name.
          lv_product-prod_quantity = wa_eproduct-prod_quantity.
          lv_product-prod_price = wa_eproduct-prod_price.
  
    "------ UPDATE STOCK (Update product name/price/quantity)------
    IF wa_nproduct-prod_name IS NOT INITIAL.
      lv_product-prod_name = wa_nproduct-prod_name.
      PERFORM update_product USING lv_product.
    ENDIF.
    IF wa_nproduct-prod_price IS NOT INITIAL.
      lv_product-prod_price = wa_nproduct-prod_price.
      PERFORM update_product USING lv_product.
    ENDIF.
    IF wa_nproduct-prod_quantity IS NOT INITIAL.
      lv_product-prod_quantity = wa_nproduct-prod_quantity.
      PERFORM update_product USING lv_product.
    ENDIF.
  ENDFORM.
  
  " Screen 320 PAI Subroutines
  FORM add_product_320.
    DATA: ov_name_char TYPE zproducts-prod_name,
          ov_quantity_quan TYPE zproducts-prod_quantity,
          ov_price_dec TYPE zproducts-prod_price.
    ov_name_char = wa_nproduct-prod_name.
    ov_quantity_quan = wa_nproduct-prod_quantity.
    ov_price_dec = wa_nproduct-prod_price.
  
    PERFORM add_new_product USING ov_name_char ov_quantity_quan ov_price_dec.
  ENDFORM.
  
  " Screen 315 PBO Subroutines
  FORM collect_product_315.
    DATA: ls_updated_product TYPE ty_product,
          lv_id_int TYPE int2.
    lv_id_int = wa_eproduct-prod_id.
  
    PERFORM search_product USING lv_id_int
                           CHANGING ls_updated_product.
  
    wa_eproduct-prod_id = ls_updated_product-prod_id.
    wa_eproduct-prod_name = ls_updated_product-prod_name.
    wa_eproduct-prod_quantity = ls_updated_product-prod_quantity.
    wa_eproduct-prod_price = ls_updated_product-prod_price.
  ENDFORM.
  
  " Screen 325 PBO Subroutines
  FORM collect_product_325.
    DATA: ls_new_product TYPE ty_product,
          lv_name_string TYPE string.
    lv_name_string = wa_nproduct-prod_name.
  
    PERFORM search_product_by_name USING lv_name_string
                                   CHANGING ls_new_product.
  
    wa_nproduct-prod_id = ls_new_product-prod_id.
    wa_nproduct-prod_name = ls_new_product-prod_name.
    wa_nproduct-prod_quantity = ls_new_product-prod_quantity.
    wa_nproduct-prod_price = ls_new_product-prod_price.
  ENDFORM.
  
  " Screen 330 PBO Subroutines
  FORM collect_stats_330.
    DATA: ls_stats TYPE ZST_STATS.
  
    "------ RETRIEVE STATISTICS --------
    PERFORM calcule_unitary_stats CHANGING ls_stats.
  
    IF sy-subrc = 0.
      gs_stats-AVG_ORDER_T = ls_stats-AVG_ORDER_T.
      gs_stats-AVG_PROD_ORD = ls_stats-AVG_PROD_ORD.
      gs_stats-AVG_ORD_CL = ls_stats-AVG_ORD_CL.
      gs_stats-COUNT_FW = ls_stats-COUNT_FW.
      gs_stats-COUNT_G = ls_stats-COUNT_G.
      "gs_stats-AVG_CS = ls_stats-AVG_CS.
      gs_stats-BEST_SELLER = ls_stats-BEST_SELLER.
      gs_stats-WORST_SELLER = ls_stats-WORST_SELLER.
  
      gv_user = sy-uname.
      gv_date = sy-datum.
      gv_time = sy-uzeit.
    ELSE.
      MESSAGE 'Error when trying to retrieve statistics.' TYPE 'E'.
    ENDIF.
  ENDFORM.