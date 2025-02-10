*&---------------------------------------------------------------------*
*& Report  ZVALIDATE_QUANTITIES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZVALIDATE_QUANTITIES.

" DEFINITIONS AND INITIALIZATIONS
" Tables
TABLES: zclients,
        zcorders,
        zordproducts,
        products.

" Global variable for monthly gains
DATA: gv_monthly_gains TYPE p DECIMALS 2 VALUE 0.

" Define the product structure and table
TYPES: BEGIN OF ty_product,
         prod_id        TYPE i,
         prod_name      TYPE string,
         prod_quantity  TYPE i,
         prod_price     TYPE p DECIMALS 2,
       END OF ty_product.

" Define the aditional table for storing clients persistently
TYPES: BEGIN OF ty_client,
         client_id   TYPE i,
         name        TYPE string,
         last_name   TYPE string,
         order_count TYPE i,
       END OF ty_client.

TYPES: ty_price TYPE p DECIMALS 2.

DATA: it_products TYPE SORTED TABLE OF ty_product
                    WITH UNIQUE KEY prod_id,
      it_clients TYPE SORTED TABLE OF ty_client
                    WITH UNIQUE KEY client_id.

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

" Class definition for client
CLASS lcl_client DEFINITION.
  PUBLIC SECTION.
    METHODS:  constructor IMPORTING iv_name      TYPE string
                                    iv_last_name TYPE string,
              comeback    IMPORTING iv_client_id TYPE i,
              update_order_count,
              display_client,
              reset_order_count,
              get_client_id   RETURNING VALUE(rv_client_id) TYPE i,
              get_order_count RETURNING VALUE(rv_order_count) TYPE i.

  PRIVATE SECTION.
    DATA: client_id TYPE i,
          name TYPE string,
          last_name TYPE string,
          order_count TYPE i.
ENDCLASS.

TYPES: BEGIN OF ty_order,
         o_client       TYPE REF TO lcl_client,
         payment_method TYPE string,
         total          TYPE p DECIMALS 2,
         it_order_products TYPE STANDARD TABLE OF ty_product,
         order_date     TYPE DATS,
         order_time     TYPE TIMS,
         order_id       TYPE i,
       END OF ty_order.

" Class definition for order
CLASS lcl_order DEFINITION.
  PUBLIC SECTION.
    EVENTS:  fourth_wing EXPORTING VALUE(sender_ref) TYPE REF TO lcl_order. " The fourth order is 50% limited up to 45eur
    METHODS: constructor IMPORTING iv_o_client  TYPE REF TO lcl_client
                                   iv_payment_method TYPE string,
             add_product IMPORTING iv_prod_id TYPE i
                                   iv_quantity TYPE i,
             calculate_total,
             update_monthly_gains,
             display_order,
             close_order IMPORTING iv_o_client  TYPE REF TO lcl_client,
             set_total IMPORTING iv_new_total TYPE ty_price,
             get_total RETURNING VALUE(rv_total) TYPE ty_price,
             get_o_client RETURNING VALUE(rv_o_client) TYPE REF TO lcl_client.

  PRIVATE SECTION.
    DATA: o_client       TYPE REF TO lcl_client,
          payment_method TYPE string,
          total          TYPE p DECIMALS 2,
          it_order_products TYPE STANDARD TABLE OF ty_product,
          order_date     TYPE DATS,
          order_time     TYPE TIMS,
          order_id       TYPE i.
ENDCLASS.

" Handler definition for event Forth Wing
CLASS lcl_fourth_wing_handler DEFINITION.
  PUBLIC SECTION.
    METHODS: on_fourth_wing FOR EVENT fourth_wing OF lcl_order
                            IMPORTING sender_ref.
ENDCLASS.

" Class implementation for client
CLASS lcl_client IMPLEMENTATION.
  METHOD constructor.
    DATA: wa_client TYPE ty_client,
          lv_iv_name TYPE string,
          lv_iv_last_name TYPE string,
          ls_client TYPE zclients.

    IF iv_name IS INITIAL.
      WRITE: / 'The name cannot be empty'.
      RETURN.
    ENDIF.

    lv_iv_name = iv_name.
    lv_iv_last_name = iv_last_name.
    PERFORM first_to_upper USING iv_name
                           CHANGING lv_iv_name.
    PERFORM first_to_upper USING iv_last_name
                           CHANGING lv_iv_last_name.

    "Store it also in the table"
    PERFORM next_id USING 'clients'
                    CHANGING wa_client-client_id.

    wa_client-name = lv_iv_name.
    wa_client-last_name = lv_iv_last_name.
    wa_client-order_count = 0.
    APPEND wa_client TO it_clients.

    me->client_id = wa_client-client_id.
    me->name = lv_iv_name.
    me->last_name = lv_iv_last_name.
    me->order_count = 0.

    " Store in Database Table
    ls_client-client_id = wa_client-client_id.
    ls_client-client_name = wa_client-name.
    ls_client-client_last_name = wa_client-last_name.
    ls_client-order_count = wa_client-order_count.
    INSERT INTO zclients VALUES ls_client.
  ENDMETHOD.

  METHOD update_order_count.
    me->order_count = me->order_count + 1.
    " Update in Database table
    DATA: lv_order_count TYPE zclients-order_count.

    SELECT order_count FROM zclients
      INTO lv_order_count
      WHERE client_id = me->client_id.
    lv_order_count = lv_order_count + 1.

    UPDATE zclients SET order_count = lv_order_count
    WHERE client_id = me->client_id.
  ENDMETHOD.

  METHOD comeback.
    DATA: wa_client TYPE ty_client.

    PERFORM search_client USING iv_client_id
                          CHANGING wa_client.
    IF sy-subrc = 0.
      me->client_id = wa_client-client_id.
      me->client_name = wa_client-client_name.
      me->client_last_name = wa_client-client_last_name.
      me->order_count = wa_client-order_count.
    ELSE.
      WRITE: / 'Client not found with that id. ', /.
    ENDIF.
  ENDMETHOD.

  METHOD display_client.
    WRITE: / 'Client Name:', me->name, me->last_name.
    WRITE: / 'N* Orders:', me->order_count, /.
  ENDMETHOD.

  METHOD get_order_count.
    rv_order_count = me->order_count.
  ENDMETHOD.

  METHOD reset_order_count.
    me->order_count = 0.
    " UPDATE in Database table
    UPDATE zclients SET order_count = '0'
    WHERE client_id = me->client_id.
  ENDMETHOD.

  METHOD get_client_id.
    rv_client_id = me->client_id.
  ENDMETHOD.
ENDCLASS.

" Class implementation for order
CLASS lcl_order IMPLEMENTATION.
  METHOD constructor.
    DATA: ls_order TYPE zcorders.

    PERFORM next_id USING 'corders'
                    CHANGING me->order_id.

    me->payment_method = iv_payment_method.
    CLEAR me->it_order_products.
    me->o_client = iv_o_client.
    me->total = 0.

    " Store in Database table
    ls_order-order_id = me->order_id.
    ls_order-order_id = iv_o_client->get_client_id( ).
    ls_order-payment_method = me->payment_method.
    INSERT INTO zcorders VALUES ls_order.

  ENDMETHOD.

  METHOD add_product.
    DATA: wa_new_product TYPE ty_product,
          wa_stored_product TYPE ty_product,
          wa_stored-ordproduct TYPE ty_product,
          ls_ordproduct TYPE zordproducts,
          lv_stock TYPE i.

    " READ TABLE it_products INTO wa_new_product WITH KEY prod_id = iv_prod_id.
    PERFORM search_product USING iv_prod_id
                           CHANGING wa_new_product.
    IF sy-subrc = 0.
      " READ TABLE it_products INTO wa_stored_product WITH KEY prod_id = iv_prod_id.
      PERFORM search_product USING iv_prod_id
                             CHANGING wa_stored_product.

      DATA: lv_status TYPE abap_bool.

      PERFORM validate_quantity USING iv_quantity
                                CHANGING lv_status.

      IF lv_status = abap_true AND iv_quantity <= wa_stored_product-prod_quantity.
        " Set product quantity in the order
        wa_new_product-prod_quantity = iv_quantity.
        APPEND wa_new_product TO me->it_order_products.

        " Store also in the database table.
        PERFORM search_unique_product_list USING me->order_id iv_prod_id
                                           CHANGING wa_stored_ordproduct.
        IF sy-subrc = 0.
          wa_stored_ordproduct-prod_quantity = wa_stored_ordproduct-prod_quantity + iv_quantity.
          UPDATE zordproducts SET prod_quantity = wa_stored_ordproduct-prod_quantity
            WHERE order_id = me->order_id AND prod_id = iv_prod_id.
        ELSE.
          ls_ordproduct-order_id = me->order_id.
          ls_ordproduct-prod_id = iv_prod_id.
          ls_ordproduct-prod_quantity = iv_quantity.
          INSERT INTO zordproducts VALUES ls_ordproduct.
        ENDIF.

        " Modify existences of that product in the stock
        wa_stored_product-prod_quantity = wa_stored_product-prod_quantity - iv_quantity.
        MODIFY it_products FROM wa_stored_product INDEX sy-tabix.

        " Modify also the stock in Database Table
        SELECT prod_quantity FROM zproducts
          INTO lv_stock WHERE prod_id = wa_stored_product-prod_id.

        UPDATE zproducts SET prod_quantity =  lv_stock - iv_quantity
          WHERE prod_id = wa_stored_product-prod_id.

      ELSE.
        WRITE: / 'Invalid quantity for product:', wa_new_product-prod_name.
      ENDIF.
    ELSE.
      WRITE: / 'Product not found with ID:', iv_prod_id.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_total.
    DATA: lv_product TYPE ty_product,
          lv_total   TYPE p DECIMALS 2.
    lv_total = 0.
    LOOP AT me->it_order_products INTO lv_product.
      lv_total = lv_total + ( lv_product-prod_quantity * lv_product-prod_price ).
    ENDLOOP.
    me->total = lv_total.

    " Store also in Database table
    UPDATE zcorders SET total = me->total
      WHERE order_id = me->order_id.

  ENDMETHOD.

  METHOD update_monthly_gains.
    gv_monthly_gains = gv_monthly_gains + total.
    " WRITE: / 'Monthly gains updated: ', gv_monthly_gains, /.
  ENDMETHOD.

  METHOD get_o_client.
    rv_o_client = me->o_client.
  ENDMETHOD.

  METHOD set_total.
    me->total = iv_new_total.

    " Update too in the Database table
    UPDATE zcorders SET total = iv_new_total
      WHERE order_id = me->order_id.
  ENDMETHOD.

  METHOD get_total.
    rv_total = me->total.
  ENDMETHOD.

  METHOD close_order.
    DATA: lv_order_count TYPE i,
          lo_o_client TYPE REF TO lcl_client.

    lo_o_client = iv_o_client.
    lv_order_count = lo_o_client->get_order_count( ).

    " If the client already got 3 orders, the event Fourth Wing is triggered
    IF lv_order_count MOD 3 = 0.
       RAISE EVENT fourth_wing EXPORTING sender_ref = me.
    ENDIF.
    " We date and close the order
    lo_o_client->update_order_count( ).
    me->order_date = sy-datum.
    me->order_time = sy-uzeit.

    " UPDATE also in Database table
    UPDATE zcorders SET order_date = me->order_date order_time = me->order_time
      WHERE order_id = me->order_id.

  ENDMETHOD.

  " Method for displaying the order
  METHOD display_order.
    DATA: lv_product TYPE ty_product.

    WRITE: / '-------> Order Details:'.
    LOOP AT me->it_order_products INTO lv_product.
      WRITE: / lv_product-prod_name, 20 lv_product-prod_quantity, 40 lv_product-prod_price.
    ENDLOOP.
    WRITE: / 'Total:', me->total, /.
    me->o_client->display_client( ).
    WRITE: / 'Date:', me->order_date, '  ', me->order_time, /, /.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_fourth_wing_handler IMPLEMENTATION.
    METHOD on_fourth_wing.
      DATA: lv_order_ref_total TYPE p DECIMALS 2,
            lo_o_client  TYPE REF TO lcl_client,
            lo_order_ref TYPE REF TO lcl_order.

      lo_order_ref ?= sender_ref.
      lo_o_client = lo_order_ref->get_o_client( ).

      lv_order_ref_total = lo_order_ref->get_total( ).

        IF lv_order_ref_total < 45.
          " 50% Discount applied
          lv_order_ref_total = lv_order_ref_total / 2.
          lo_order_ref->set_total( iv_new_total = lv_order_ref_total ).
          WRITE: / 'FOURTH WING!! 50% discount applied.', /.
        ENDIF.
    ENDMETHOD.

ENDCLASS.

" Main Program Execution
START-OF-SELECTION.

  " Create a client / order / handler instance
  DATA: lo_client_fan TYPE REF TO lcl_client,
        lo_order TYPE REF TO lcl_order,
        lo_handler TYPE REF TO lcl_fourth_wing_handler.

  lo_client_fan = NEW lcl_client( iv_name = 'John'
                                       iv_last_name = 'Cena' ).
  lo_handler = NEW lcl_fourth_wing_handler( ).

  " Create stock
  PERFORM init_products.
  PERFORM display_stock.

  "order
  DO 5 TIMES.
     " Create orders
    lo_order = NEW lcl_order( iv_payment_method = 'Credit card'
                                 iv_o_client = lo_client_fan ).

    " Link event possible raiser to the handler
    SET HANDLER lo_handler->on_fourth_wing FOR lo_order.

    " Add products
    lo_order->add_product( iv_prod_id = 1 iv_quantity = 3 ).
    lo_order->add_product( iv_prod_id = 2 iv_quantity = 2 ).
    lo_order->calculate_total( ).
    " Close order
    lo_order->close_order( iv_o_client = lo_order->get_o_client( ) ).
    lo_order->update_monthly_gains( ).
    lo_order->display_order( ).
  ENDDO.

  " Check remaining stock and monthly gains
  PERFORM display_stock.
  WRITE: / 'Final gains:', gv_monthly_gains.