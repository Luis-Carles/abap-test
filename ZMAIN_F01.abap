*&---------------------------------------------------------------------*
*&  Include           ZMAIN_F01
*&---------------------------------------------------------------------*

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
  DATA: ls_product TYPE zproducts,
        lv_cont          TYPE i,
        lv_x             TYPE i.

  " Display header for product list
  WRITE: / '-----------------------------------------------------------'.
  WRITE: / 'Product', 20 'Quantity', 40 'Price'.

  SELECT COUNT(*) FROM zproducts INTO lv_cont.
  lv_x = 0.

  DO lv_cont TIMES.
    lv_x = lv_x + 1.
    SELECT * FROM zproducts INTO ls_product
      WHERE prod_id = lv_x.
    IF sy-subrc = 0.
      WRITE: / ls_product-prod_name, 20 ls_product-prod_quantity, 40 ls_product-prod_price, /.
    ENDIF.
    ENDSELECT.
  ENDDO.

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
" WILL FAIL IF THOSE PRODUCTS ARE ALREADY IN Database Table!!!!!
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
FORM search_client USING iv_input_id TYPE i
                   CHANGING rv_found TYPE ty_client.

  DATA: ls_client TYPE zclients.

    SELECT SINGLE * INTO ls_client
      FROM zclients
      WHERE client_id = iv_input_id.

    IF sy-subrc = 0.
      " WRITE: / 'Client found!', ls_client-client_name.
      rv_found-client_id = ls_client-client_id.
      rv_found-name = ls_client-client_name.
      rv_found-last_name = ls_client-client_last_name.
      rv_found-order_count = ls_client-order_count.
    ELSE.
       WRITE: / 'Error during searching a client. ', /.
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
      " WRITE: / 'Product found!', ls_product-prod_name.
      rv_found-prod_id = ls_product-prod_id.
      rv_found-prod_name = ls_product-prod_name.
      rv_found-prod_price = ls_product-prod_price.
      rv_found-prod_quantity = ls_product-prod_quantity.

    ELSE.
      WRITE: / 'Error during searching a product. ', /.
    ENDIF.

ENDFORM.

" Subroutine for searching a product ID in ZPRODUCTS by product name
FORM search_product_by_name USING iv_input_prod_name TYPE string
                   CHANGING rv_found TYPE ty_product.

  DATA: ls_product TYPE zproducts.

    SELECT SINGLE * INTO ls_product
      FROM zproducts
      WHERE prod_name = iv_input_prod_name.

    IF sy-subrc = 0.
      " WRITE: / 'Product ID found!', ls_product-prod_id.
      rv_found-prod_name = ls_product-prod_name.
      rv_found-prod_id = ls_product-prod_id.
      rv_found-prod_quantity = ls_product-prod_quantity.
      rv_found-prod_price = ls_product-prod_price.
    ELSE.
      WRITE: / 'Error during searching a product by name. ', /.
    ENDIF.
ENDFORM.

" Subroutine for searching a unique product in a list of products by given order id / prod_id
FORM search_unique_product_list USING iv_input_order_id
                                      iv_input_prod_id
                         CHANGING rv_found TYPE ty_product.

  DATA: ls_ordproduct TYPE zordproducts,
        wa_product   TYPE ty_product.

  PERFORM search_product USING iv_input_prod_id
                         CHANGING wa_product.

  SELECT  SINGLE * FROM zordproducts
     INTO ls_ordproduct
     WHERE order_id = iv_input_order_id AND prod_id = iv_input_prod_id.

  IF sy-subrc = 0.
     " WRITE: / 'unique product in product list found!'.
     rv_found-prod_name = wa_product-prod_name.
     rv_found-prod_id = wa_product-prod_id.
     rv_found-prod_quantity = ls_ordproduct-prod_quantity.
     rv_found-prod_price = wa_product-prod_price.
  ELSE.
      WRITE: / 'Error during searching a product inside an order. ', /.
  ENDIF.
ENDFORM.

" Subroutine for searching a list of products in ZORDPRODUCTS by given order id
FORM search_product_list USING iv_input_order_id
                         CHANGING rv_found TYPE STANDARD TABLE OF ty_product.

  DATA: wa_product      TYPE ty_product,
        it_product_list TYPE TABLE OF zordproducts.

    SELECT  * FROM zordproducts
      INTO TABLE it_product_list
      WHERE order_id = iv_input_order_id.

    IF sy-subrc = 0.
      " WRITE: / 'product list found!'.
      LOOP AT it_product_list INTO DATA(ls_product).
        PERFORM search_product USING ls_product-prod_id
                               CHANGING wa_product.

        wa_product-prod_quantity = ls_product-prod_quantity.
        APPEND wa_product TO rv_found.
      ENDLOOP.
    ELSE.
      WRITE: / 'Error during searching a product list.', /.
    ENDIF.

ENDFORM.

FORM search_most_recent_order USING iv_input_client_id
                              CHANGING rv_found TYPE DATS.
  DATA: wa_date TYPE DATS.

  SELECT MAX( order_date )
    INTO wa_date
    FROM zcorders
    WHERE order_client = iv_input_client_id.

  IF sy-subrc = 0.
    rv_found = wa_date.
  ELSE.
    WRITE: / 'Error during searching the last order date.', /.
  ENDIF.
ENDFORM.

FORM search_available_products CHANGING rv_found TYPE STANDARD TABLE OF ty_product.
  DATA: it_aproducts TYPE TABLE OF zproducts,
        wa_prod      TYPE ty_product.
  SELECT * FROM zproducts
    INTO TABLE it_aproducts
    WHERE prod_quantity > 0.

  IF sy-subrc = 0.
    LOOP AT it_aproducts INTO DATA(ls_aproduct).
      wa_prod-prod_id = ls_aproduct-prod_id.
      wa_prod-prod_name = ls_aproduct-prod_name.
      wa_prod-prod_quantity = ls_aproduct-prod_quantity.
      wa_prod-prod_price = ls_aproduct-prod_price.
      APPEND wa_prod TO rv_found.
    ENDLOOP.
  ELSE.
    WRITE: / 'Error during searching available products.', /.
  ENDIF.
ENDFORM.

" UE Subroutine to add a new product to the table.
FORM add_new_product USING iv_input_name TYPE zproducts-prod_name
                           iv_input_quantity TYPE zproducts-prod_quantity
                           iv_input_price TYPE zproducts-prod_price.

    DATA: wa_product TYPE ty_product,
          ls_product TYPE zproducts.

    PERFORM next_id USING 'products'
                  CHANGING wa_product-prod_id.

    wa_product-prod_name = iv_input_name.
    wa_product-prod_quantity = iv_input_quantity.
    wa_product-prod_price = iv_input_price.
    " Store into database table
    ls_product-MEINS = 'EA'.
    ls_product-WAERS = 'EUR'.
    ls_product-prod_id = wa_product-prod_id.
    ls_product-prod_name = wa_product-prod_name.
    ls_product-prod_quantity = wa_product-prod_quantity.
    ls_product-prod_price = wa_product-prod_price.
    INSERT INTO zproducts VALUES ls_product.
ENDFORM.

" UE Subroutine that increases the stock of a product given a quantity
FORM update_stock USING iv_prod_id TYPE zproducts-prod_id
                        iv_prod_quantity TYPE zproducts-prod_quantity.

    DATA: wa_product TYPE ty_product,
          ls_product TYPE zproducts.

    PERFORM search_product USING iv_prod_id
                           CHANGING wa_product.

    ls_product-prod_quantity = wa_product-prod_quantity + iv_prod_quantity.

    UPDATE zproducts SET prod_quantity =  ls_product-prod_quantity
      WHERE prod_id = iv_prod_id.
ENDFORM.

" UE Subroutine that changes the name/ price of a given product
FORM update_product USING iv_new_product TYPE zproducts.

  DATA: wa_product TYPE ty_product,
        lv_id_int  TYPE int2.

  lv_id_int = iv_new_product-prod_id.
  PERFORM search_product USING lv_id_int
                         CHANGING wa_product.
  IF sy-subrc = 0.
    UPDATE zproducts SET prod_name = iv_new_product-prod_name
                         prod_price = iv_new_product-prod_price
                         prod_quantity = prod_quantity + iv_new_product-prod_quantity
           WHERE prod_id = iv_new_product-prod_id.
  ENDIF.
ENDFORM.

" manually override the parameter introduction
FORM manual_interaction.

*    " Create a client / order / handler instance
*    DATA: lo_client_fan TYPE REF TO lcl_client,
*          lo_order TYPE REF TO lcl_order,
*          lo_handler TYPE REF TO lcl_fourth_wing_handler,
*          wa_product  TYPE ty_product,
*          ls_product  TYPE zproducts.
*
*
*    lo_handler = NEW lcl_fourth_wing_handler( ).
*
*  " -------NEW CLIENT -----------
*    "lo_client_fan = NEW lcl_client( iv_name = 'javier'
*    "                                iv_last_name = 'Oliveira'
*    "                                iv_mode = 'new'
*    "                                iv_client_id = '1' ).
*
*
*  " -------OLD CLIENT -----------
*    lo_client_fan = NEW lcl_client( iv_name = 'Ismael'
*                                    iv_last_name = 'Rivera'
*                                    iv_mode = 'comeback'
*                                    iv_client_id = '2' ).
*
*
*    "------ NEW STOCK ----------
*
*    "DATA: p_prod_name TYPE zproducts-prod_name,
*    "      p_prod_quantity TYPE zproducts-prod_quantity,
*    "      p_prod_price TYPE zproducts-prod_price.
*
*    "p_prod_name = 'Tiramisu'.
*    "p_prod_quantity = 1000.
*    "p_prod_price = '4.00'.
*    "PERFORM add_new_product USING p_prod_name
*    "                              p_prod_quantity
*    "                              p_prod_price.
*
*
*    "------ UPDATE STOCK --------
*    PERFORM update_stock USING '1' 10.
*
*
*    PERFORM display_stock.
*
*
*    "-----ORDERING --------
*    DO 3 TIMES.
*       " Create orders
*      lo_order = NEW lcl_order( iv_payment_method = 'Credit card'
*                                iv_o_client       = lo_client_fan ).
*
*      " Link event possible raiser to the handler
*      SET HANDLER lo_handler->on_fourth_wing FOR lo_order.
*
*      " Add products
*      lo_order->add_product( iv_prod_id = 1 iv_quantity = 3 ).
*      lo_order->add_product( iv_prod_id = 2 iv_quantity = 2 ).
*      lo_order->calculate_total( ).
*      " Close order
*      lo_order->close_order( iv_o_client = lo_order->get_o_client( ) ).
*      lo_order->update_monthly_gains( ).
*      lo_order->display_order( ).
*    ENDDO.
ENDFORM.