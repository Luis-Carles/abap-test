*&---------------------------------------------------------------------*
*&  Include           ZMAIN_F03
*&---------------------------------------------------------------------*

" Screen 230 PAI Subroutines
FORM find_prod_id_230 USING iv_name TYPE string CHANGING rv_found_id TYPE i.

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

  cv_order->add_product( iv_prod_id = ov_prod_id iv_quantity = ov_prod_quantity ).
  cv_order->calculate_total( ).
ENDFORM.

" Screen 310 PAI Subroutines
FORM find_product_310 CHANGING rv_desired TYPE ty_product.

  DATA: wa_desired TYPE ty_product.
  PERFORM search_product_by_name USING rv_desired-prod_name
                            CHANGING wa_desired.
  rv_desired-prod_id = wa_desired-prod_id.
  rv_desired-prod_quantity = wa_desired-prod_quantity.
  rv_desired-prod_price = wa_desired-prod_price.
ENDFORM.

FORM update_stock_310 USING iv_stocked TYPE ty_product
                            iv_changed TYPE ty_product.
  DATA: lv_product TYPE zproducts.
        lv_product-prod_id = iv_stocked-prod_id.
        lv_product-prod_name = iv_stocked-prod_name.
        lv_product-prod_quantity = iv_stocked-prod_quantity.
        lv_product-prod_price = iv_stocked-prod_price.

  "------ UPDATE STOCK (Update product name/price/quantity)------
  IF iv_changed-prod_name IS NOT INITIAL.
    lv_product-prod_name = iv_changed-prod_name.
    PERFORM update_product USING lv_product.
  ENDIF.
  IF iv_changed-prod_price IS NOT INITIAL.
    lv_product-prod_price = iv_changed-prod_price.
    PERFORM update_product USING lv_product.
  ENDIF.
  IF iv_changed-prod_quantity IS NOT INITIAL.
    lv_product-prod_quantity = iv_changed-prod_quantity.
    PERFORM update_product USING lv_product.
  ENDIF.
ENDFORM.

" Screen 320 PAI Subroutines
FORM add_product_320 USING iv_new_prod TYPE ty_product.

  DATA: ov_name_char TYPE zproducts-prod_name,
        ov_quantity_quan TYPE zproducts-prod_quantity,
        ov_price_dec TYPE zproducts-prod_price.
  ov_name_char = iv_new_prod-prod_name.
  ov_quantity_quan = iv_new_prod-prod_quantity.
  ov_price_dec = iv_new_prod-prod_price.

  PERFORM add_new_product USING ov_name_char ov_quantity_quan ov_price_dec.
ENDFORM.

" Screen 315 PBO Subroutines
FORM collect_product_315 CHANGING rv_stocked TYPE ty_product.

  DATA: ls_updated_product TYPE ty_product,
        lv_id_int TYPE int2.
  lv_id_int = rv_stocked-prod_id.

  PERFORM search_product USING lv_id_int
                         CHANGING ls_updated_product.

  rv_stocked-prod_id = ls_updated_product-prod_id.
  rv_stocked-prod_name = ls_updated_product-prod_name.
  rv_stocked-prod_quantity = ls_updated_product-prod_quantity.
  rv_stocked-prod_price = ls_updated_product-prod_price.
ENDFORM.

" Screen 325 PBO Subroutines
FORM collect_product_325 CHANGING rv_changed TYPE ty_product.
  DATA: ls_new_product TYPE ty_product,
        lv_name_string TYPE string.
  lv_name_string = rv_changed-prod_name.

  PERFORM search_product_by_name USING lv_name_string
                                 CHANGING ls_new_product.

  rv_changed-prod_id = ls_new_product-prod_id.
  rv_changed-prod_name = ls_new_product-prod_name.
  rv_changed-prod_quantity = ls_new_product-prod_quantity.
  rv_changed-prod_price = ls_new_product-prod_price.
ENDFORM.

" Screen 330 PBO Subroutines
FORM collect_stats_330 CHANGING rv_stats TYPE ZST_STATS
                                rv_user  TYPE sy-uname
                                rv_date  TYPE DATS
                                rv_time  TYPE TIMS.
  DATA: ls_stats TYPE ZST_STATS.

  "------ RETRIEVE STATISTICS --------
  PERFORM calcule_unitary_stats CHANGING ls_stats.

  IF sy-subrc = 0.
    rv_stats-AVG_ORDER_T = ls_stats-AVG_ORDER_T.
    rv_stats-AVG_PROD_ORD = ls_stats-AVG_PROD_ORD.
    rv_stats-AVG_ORD_CL = ls_stats-AVG_ORD_CL.
    rv_stats-COUNT_FW = ls_stats-COUNT_FW.
    rv_stats-COUNT_G = ls_stats-COUNT_G.
    "rv_stats-AVG_CS = ls_stats-AVG_CS.
    rv_stats-BEST_SELLER = ls_stats-BEST_SELLER.
    rv_stats-WORST_SELLER = ls_stats-WORST_SELLER.

    rv_user = sy-uname.
    rv_date = sy-datum.
    rv_time = sy-uzeit.
  ELSE.
    MESSAGE 'Error when trying to retrieve statistics.' TYPE 'E'.
  ENDIF.
ENDFORM.