*&---------------------------------------------------------------------*
*& Subroutine Pool   ZMAIN_FORMS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
PROGRAM ZMAIN_FORMS.

INCLUDE ZMAIN_TOP.

" Validation Subroutine
FORM validate_quantity USING lv_quant TYPE i
                       CHANGING lv_status TYPE abap_bool.
  IF lv_quant < 0.
    lv_status = abap_false.
  ELSE.
    lv_status = abap_true.
  ENDIF.
ENDFORM.

FORM display_stock.
  DATA: lv_product_stock TYPE ty_product.

  " Display header for product list
  WRITE: / '-----------------------------------------------------------'.
  WRITE: / 'Product', 20 'Quantity', 40 'Price'.

  LOOP AT it_products INTO lv_product_stock.
    WRITE: / lv_product_stock-prod_name, 20 lv_product_stock-prod_quantity, 40 lv_product_stock-prod_price.
  ENDLOOP.
  WRITE: / '-----------------------------------------------------------', /.
ENDFORM.

" Capital letter Subroutine
FORM first_to_upper USING iv_input_string TYPE string
                    CHANGING cv_output_string TYPE string.
  DATA: lv_first_letter TYPE char1,
        lv_rest         TYPE string.

  lv_first_letter = iv_input_string(1).
  TRANSLATE lv_first_letter TO UPPER CASE.
  lv_rest = iv_input_string+1.
  TRANSLATE lv_rest TO LOWER CASE.

  CONCATENATE lv_first_letter lv_rest INTO cv_output_string.
ENDFORM.

" Search for the next available ID Subroutine
FORM next_id USING iv_input_table TYPE string
             CHANGING iv_output_id TYPE i.
  IF iv_input_table = 'clients'.
    SELECT COUNT(*) FROM zclients
      INTO iv_output_id.
  ENDIF.
  IF iv_input_table = 'products'.
    SELECT COUNT(*) FROM zproducts
      INTO iv_output_id.
  ENDIF.
  IF iv_input_table = 'corders'.
    SELECT COUNT(*) FROM zcorders
      INTO iv_output_id.
  ENDIF.
  iv_output_id = iv_output_id + 1.
ENDFORM.

" Subroutine for initializing the products
FORM init_products.
  DATA: wa_product TYPE ty_product,
        lv_status TYPE abap_bool,
        ls_product TYPE zproducts.

  " Initialize product data
  " Store into internal table
  PERFORM next_id USING 'products'
                  CHANGING wa_product-prod_id.
  wa_product-prod_name = 'Cafe'.
  wa_product-prod_quantity = 100.
  wa_product-prod_price = '2.50'.
  INSERT wa_product INTO TABLE it_products.

  " Store into database table
  ls_product-prod_id = wa_product-prod_id.
  ls_product-prod_name = wa_product-prod_name.
  ls_product-prod_quantity = wa_product-prod_quantity.
  ls_product-prod_price = wa_product-prod_price.
  INSERT INTO zproducts VALUES ls_product.

  " x2
  PERFORM next_id USING 'products'
                  CHANGING wa_product-prod_id.
  wa_product-prod_name = 'Iced Tea'.
  wa_product-prod_quantity = 100.
  wa_product-prod_price = '3.00'.
  INSERT wa_product INTO TABLE it_products.

  ls_product-prod_id = wa_product-prod_id.
  ls_product-prod_name = wa_product-prod_name.
  ls_product-prod_quantity = wa_product-prod_quantity.
  ls_product-prod_price = wa_product-prod_price.
  INSERT INTO zproducts VALUES ls_product.

  " x3
  PERFORM next_id USING 'products'
                  CHANGING wa_product-prod_id.

  " Trying invalid quantity input
  wa_product-prod_name = 'Tarta'.
  wa_product-prod_quantity = -7.
  wa_product-prod_price = '5.00'.
  PERFORM validate_quantity USING wa_product-prod_quantity
                            CHANGING lv_status.
  IF lv_status = abap_true.
    INSERT wa_product INTO TABLE it_products.

    ls_product-prod_id = wa_product-prod_id.
    ls_product-prod_name = wa_product-prod_name.
    ls_product-prod_quantity = wa_product-prod_quantity.
    ls_product-prod_price = wa_product-prod_price.
    INSERT INTO zproducts VALUES ls_product.
  ENDIF.

ENDFORM.

" Subroutine for searching a client in ZCLIENTS by given id
FORM search_client USING iv_input_id TYPE int2
                   CHANGING rv_found TYPE ty_client.

  DATA: ls_client TYPE zclients.

    SELECT SINGLE * INTO ls_client
      FROM zclients
      WHERE client_id = iv_input_id.

    IF sy-subrc = 0.
      WRITE: / 'Client found!', ls_client-name.
      rv_found-client_id = ls_client-client_id.
      rv_found-name = ls_client-client_name.
      rv_found-last_name = ls_client-client_last_name.
      rv_found-order_count = ls_client-order_count.
    ELSE.
       WRITE: / 'Error during searching. ', /.
    ENDIF.

ENDFORM.

" Subroutine for searching a product in ZPRODUCTS by given id
FORM search_product USING iv_input_id TYPE int2
                   CHANGING rv_found TYPE ty_product.

  DATA: ls_product TYPE zproducts.

    SELECT SINGLE * INTO ls_product
      FROM zproducts
      WHERE prod_id = iv_input_id.

    IF sy-subrc = 0.
      WRITE: / 'Product found!', ls_product-prod_name.
      rv_found-prod_id = ls_product-prod_id.
      rv_found-prod_name = ls_product-prod_name.
      rv_found-prod_price = ls_product-prod_price.
      rv_found-prod_quantity = ls_product-prod_quantity.

    ELSE.
      WRITE: / 'Error during searching. ', /.
    ENDIF.

ENDFORM.

" Subroutine for searching a unique product  in a list of products by given order id / prod_id
FORM search_unique_product_list USING iv_input_order_id
                                      iv_input_prod_id
                         CHANGING rv_found TYPE ty_product.

  DATA: ls_ordproduct TYPE zordproducts.

    SELECT  SINGLE * FROM zordproducts
      INTO ls_ordproduct
      WHERE order_id = iv_input_id AND prod_id = iv_input_prod_id.

    IF sy-subrc = 0.
      WRITE: / 'unique product in product list found!'.
        rv_found-order_id = ls_ordproduct-order_id.
        rv_found-prod_id = ls_ordproduct-prod_id.
        rv_found-prod_quantity = ls_ordproduct-prod_quantity.
    ELSE.
      WRITE: / 'Error during searching.', /.
    ENDIF.
ENDFORM.

" Subroutine for searching a list of products in ZORDPRODUCTS by given order id
FORM search_product_list USING iv_input_order_id
                         CHANGING rv_found TYPE STANDARD TABLE OF ty_product.

  DATA: it_product_list TYPE TABLE OF zordproducts,
        wa_product      TYPE ty_product.

    SELECT  * FROM zordproducts
      INTO it_product_list
      WHERE order_id = iv_input_id.

    IF sy-subrc = 0.
      WRITE: / 'product list found!'.
      LOOP AT it_product_list INTO DATA(ls_product).
        PERFORM search_product USING ls_product-prod_id
                               CHANGING wa_product.

        wa_product-prod_quantity = ls_product-prod_quantity.
        APPEND wa_product TO rv_found.
      ENDLOOP.
    ELSE.
      WRITE: / 'Error during searching.', /.
    ENDIF.

ENDFORM.

" Subroutine for searching a closed order in ZCORDERS by given id
FORM search_corder USING iv_input_id TYPE int2
                   CHANGING rv_found TYPE ty_order.

  DATA: ls_order TYPE zcorders.

    SELECT SINGLE * INTO ls_order
      FROM zcorders
      WHERE order_id = iv_input_id.

    IF sy-subrc = 0.
      WRITE: / 'Order found!'.
      rv_found-order_id = ls_order-order_id.
      rv_found-o_client = ls_order-order_client.
      rv_found-payment_method = ls_order-payment_method.
      rv_found-total = ls_order-total.
      rv_found-order_date = ls_order-order_date.
      rv_found-order_time = ls_order-order_time.
      PERFORM search_product_list USING ls_order-order_id
                                  CHANGING rv_found-it_order_products.
    ELSE.
      WRITE: / 'Error during searching. ', /.
    ENDIF.

ENDFORM.