*&---------------------------------------------------------------------*
*&  Include           ZFG_MAIN_F02
*&---------------------------------------------------------------------*

FORM average_ototal CHANGING cv_avg_order_t TYPE zst_stats-AVG_ORDER_T.
  SELECT AVG( total ) INTO cv_avg_order_t
    FROM zcorders.
    " Later limit this by date
ENDFORM.

FORM average_prodo CHANGING cv_avg_prod_ord TYPE zst_stats-AVG_PROD_ORD.
  DATA: lv_count TYPE  i,
        ov_avg TYPE p DECIMALS 2,
        lv_x TYPE i VALUE '0',
        lv_var TYPE i,
        lv_total TYPE i.

  SELECT COUNT( * ) INTO lv_count
    FROM zcorders.

  IF lv_count > 0.
    DO lv_count TIMES.
      lv_x = lv_x + 1.
      SELECT SUM( prod_quantity ) INTO lv_var
        FROM zordproducts
        WHERE prod_id = lv_x.

      lv_total = lv_total + lv_var.
    ENDDO.
    ov_avg = lv_total / lv_count.
  ELSE.
    ov_avg = 0.
  ENDIF.

  cv_avg_prod_ord = ov_avg.
ENDFORM.

FORM average_oclient CHANGING cv_avg_ord_cl TYPE zst_stats-AVG_ORD_CL.
  SELECT AVG( ORDER_COUNT ) INTO cv_avg_ord_cl
    FROM zclients.
    " Later limit this by date
ENDFORM.

FORM average_csatis CHANGING cv_avg_cs TYPE zst_stats-AVG_CS.
*  SELECT AVG( AVG_CS ) INTO cv_avg_cs
*    FROM zcorders.

*    " DOING !!
*    " Later limit this by date
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
          prod_name      TYPE string,
          prod_quantity  TYPE zordproducts-prod_quantity,
         END OF ty_count_prod.

  DATA: lv_result TYPE p DECIMALS 2,
        lv_n      TYPE i,
        lv_i      TYPE i VALUE '0',
        lv_fwcount TYPE i,
        ls_corder TYPE zcorders,
        ls_zordp  TYPE TABLE OF zordproducts,
        lt_fw     TYPE SORTED TABLE OF ty_count_fw
                  WITH UNIQUE KEY client_id,
        lt_prod   TYPE SORTED TABLE OF ty_count_prod
                  WITH UNIQUE KEY prod_id,
        wa_row    TYPE ty_count_fw,
        wa_row2   TYPE ty_count_prod,
        wa_zordp  TYPE zordproducts,
        wa_zprod  TYPE ty_product,
        lv_best_seller TYPE zst_stats-BEST_SELLER,
        lv_worst_seller TYPE zst_stats-WORST_SELLER,
        lv_max_quantity          TYPE zordproducts-prod_quantity VALUE 0,
        lv_min_quantity          TYPE zordproducts-prod_quantity VALUE 100000.

  " FOR EACH ORDER
  SELECT COUNT(*) INTO lv_n
    FROM zcorders.

  DO lv_n TIMES.
     lv_i = lv_i + 1.
     CLEAR ls_corder.
     SELECT * INTO ls_corder
        FROM zcorders
        WHERE order_id = lv_i.
     ENDSELECT.

     IF ls_corder IS NOT INITIAL.
       " Adds the total
       lv_result = lv_result + ls_corder-total.

       READ TABLE lt_fw WITH TABLE KEY client_id = ls_corder-order_client
                        INTO wa_row.
       IF sy-subrc <> 0.
         wa_row-client_id = ls_corder-order_client.
         wa_row-n_orders = '1'.
         wa_row-n_fw = '0'.
         INSERT wa_row INTO TABLE lt_fw.
       ELSE.
         wa_row-n_orders = wa_row-n_orders + 1.
         IF wa_row-n_orders MOD 3 = 0 AND ls_corder-total < 50.
            wa_row-n_fw = wa_row-n_fw + 1.

            " Adds the FW event
            lv_fwcount = lv_fwcount + 1.
         ENDIF.
         MODIFY lt_fw FROM wa_row INDEX wa_row-client_id.
       ENDIF.
     ENDIF.
  ENDDO.

  " FOR EACH ORDPRODUCT
  SELECT * INTO TABLE ls_zordp
    FROM zordproducts.

  LOOP AT ls_zordp INTO wa_zordp.

     READ TABLE lt_prod WITH TABLE KEY prod_id = wa_zordp-prod_id
                      INTO wa_row2.
     IF sy-subrc <> 0.
       wa_row2-prod_id = wa_zordp-prod_id.
       wa_row2-prod_quantity = wa_zordp-prod_quantity.

       PERFORM search_product USING wa_row2-prod_id
                              CHANGING wa_zprod.
       wa_row2-prod_name = wa_zprod-prod_name.

       INSERT wa_row2 INTO TABLE lt_prod.
     ELSE.
       wa_row2-prod_quantity = wa_row2-prod_quantity + wa_zordp-prod_quantity.
       MODIFY lt_prod FROM wa_row2 INDEX wa_row2-prod_id.
     ENDIF.
     IF wa_row2-prod_quantity > lv_max_quantity.
       lv_best_seller = wa_row2-prod_name.
       lv_max_quantity = wa_row2-prod_quantity.
     ENDIF.
     IF wa_row2-prod_quantity < lv_min_quantity.
       lv_worst_seller = wa_row2-prod_name.
       lv_min_quantity = wa_row2-prod_quantity.
     ENDIF.
  ENDLOOP.

  cv_count_fw = lv_fwcount.
  cv_count_g  = lv_result.
  cv_best_seller = lv_best_seller.
  cv_worst_seller = lv_worst_seller.
ENDFORM.

FORM calcule_unitary_stats CHANGING rv_stats TYPE ZST_STATS.
  DATA: ls_stats TYPE ZST_STATS.

  "Average Total for orders
  PERFORM average_ototal  CHANGING ls_stats-AVG_ORDER_T.
  "Average products for orders
  PERFORM average_prodo   CHANGING ls_stats-AVG_PROD_ORD.
  "Average orders for clients
  PERFORM average_oclient CHANGING ls_stats-AVG_ORD_CL.

  "Average Client satisfaction
  "PERFORM average_csatis  CHANGING ls_stats-AVG_CS.

  "Fourth Wings Count + Gains count + Best seller + Worst Seller
  PERFORM calcule_counts  CHANGING ls_stats-COUNT_FW
                                   ls_stats-COUNT_G
                                   ls_stats-BEST_SELLER
                                   ls_stats-WORST_SELLER.

  rv_stats = ls_stats.
ENDFORM.