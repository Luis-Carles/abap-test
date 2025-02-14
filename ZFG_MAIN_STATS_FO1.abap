*&---------------------------------------------------------------------*
*&  Include           ZFG_MAIN_STATS_FO1
*&---------------------------------------------------------------------*

FORM average_ototal CHANGING cv_avg_order_t TYPE zst_stats-AVG_ORDER_T.
    SELECT AVG( total ) INTO cv_avg_order_t
      FROM zcorders.
      " Later limit this by date
  
  ENDFORM.
  
  FORM average_prodo CHANGING cv_avg_prod_ord TYPE zst_stats-AVG_PROD_ORD.
    SELECT AVG( prod_ord ) INTO cv_avg_prod_ord
      FROM zcorders.
      " Later limit this by date
  ENDFORM.
  
  FORM average_oclient CHANGING cv_avg_ord_cl TYPE zst_stats-AVG_ORD_CL.
    SELECT AVG( AVG_ORD_CL ) INTO cv_avg_ord_cl
      FROM zcorders.
      " Later limit this by date
  ENDFORM.
  
  FORM average_csatis CHANGING cv_avg_cs TYPE zst_stats-AVG_CS.
    SELECT AVG( AVG_CS ) INTO cv_avg_cs
      FROM zcorders.
      " Later limit this by date
  ENDFORM.
  
  FORM calcule_counts CHANGING cv_count_fw TYPE zst_stats-COUNT_FW
                               cv_count_g  TYPE zst_stats-COUNT_G
                               cv_best_seller TYPE zst_stats-BEST_SELLER
                               cv_worst_seller TYPE zst_stats-WORST_SELLER.
  
    TYPES: BEGIN OF ty_count_fw,
            client_id      TYPE zcorders-order_client,
            n_orders       TYPE i,
            n_fw           TYPE i,
           END OF ty_count_fw.
  
    TYPES: BEGIN OF ty_count_prod,
            prod_id        TYPE zordproducts-prod_id,
            prod_quantity  TYPE zordproducts-prod_quantity,
           END OF ty_count_prod.
  
    DATA: lv_result TYPE p DECIMALS 2,
          lv_n      TYPE i,
          lv_i      TYPE i VALUE '0',
          lv_fwcont TYPE i,
          ls_corder TYPE zcorders,
          ls_zordp  TYPE TABLE OF zordproducts,
          lt_fw     TYPE SORTED TABLE OF ty_count_fw
                    WITH UNIQUE KEY client_id,
          lt_prod   TYPE SORTED TABLE OF ty_count_prod
                    WITH UNIQUE KEY prod_id,
          wa_row    TYPE ty_count_fw,
          wa_row2   TYPE ty_count_prod,
          wa_zordp  TYPE zordproducts,
          lv_best_seller TYPE zst_stats-BEST_SELLER,
          lv_worst_seller TYPE zst_stats-WORST_SELLER,
          lv_max_quantity          TYPE zordproducts-prod_quantity VALUE 100000,
          lv_min_quantity          TYPE zordproducts-prod_quantity VALUE 0.
  
    " FOR EACH ORDER
    SELECT COUNT(*) INTO lv_n
      FROM zcorders.
  
    DO lv_n TIMES.
       lv_i = lv_i + 1.
       SELECT * INTO ls_corder
          FROM zcorders
          WHERE order_id = lv_i.
  
       " Adds the total
       lv_result = lv_result + ls_corder-total.
  
       READ TABLE lt_fw WITH TABLE KEY client_id = ls_corder-order_client
                        INTO wa_row.
       IF sy-subrc <> 0.
         wa_row-client_id = zcorders-order_client.
         wa_row-n_orders = '1'.
         wa_row-n_fw = '0'.
         INSERT wa_row INTO lt_fw.
       ELSE.
         wa_row-n_orders = wa_row-n_orders + 1.
         IF wa_row-n_orders MOD 3 = 0 AND ls_corder-total < 50.
            wa_row-n_fw = wa_row-n_fw + 1.
  
            " Adds the FW event
            lv_fwcount = lv_fwcount + 1.
         ENDIF.
         MODIFY lt_fw FROM wa_row.
       ENDIF.
    ENDDO.
  
    " FOR EACH ORDPRODUCT
    SELECT * INTO ls_zordp
      FROM zordproducts.
  
    LOOP AT ls_zordp INTO wa_zordp.
  
       READ TABLE lt_prod WITH TABLE KEY prod_id = wa_zordp-prod_id
                        INTO wa_row2.
       IF sy-subrc <> 0.
         wa_row2-prod_id = wa_zordp-prod_id.
         wa_row2-prod_quantity = wa_zordp-prod_quantity.
         INSERT wa_row2 INTO lt_prod.
       ELSE.
         wa_row2-prod_quantity = wa_row2-prod_quantity + wa_zordp-prod_quantity.
         MODIFY lt_prod FROM wa_row2.
       ENDIF.
       IF wa_row2-prod_quantity > lv_max_quantity.
         lv_best_seller = wa_row2-prod_id.
       ENDIF.
       IF wa_row2-prod_quantity < lv_min_quantity.
         lv_worst_seller = wa_row2-prod_id.
       ENDIF.
    ENDLOOP.
  
    cv_count_fw = lv_fw.
    cv_count_g  = lv_result.
    cv_best_seller = lv_best_seller.
    cv_worst_seller = lv_worst_seller.
  ENDFORM.