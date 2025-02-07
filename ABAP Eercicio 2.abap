*&---------------------------------------------------------------------*
*& Report  ZVALIDATE_QUANTITIES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZVALIDATE_QUANTITIES.

" DEFINITIONS AND INITIALIZATIONS
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
    DESCRIBE TABLE it_clients LINES iv_output_id.
  ENDIF.
  IF iv_input_table = 'products'.
    DESCRIBE TABLE it_products LINES iv_output_id.
  ENDIF.
  iv_output_id = iv_output_id + 1.
ENDFORM.

" Subroutine for initializing the products
FORM init_products.
  DATA: wa_product TYPE ty_product,
        lv_status TYPE abap_bool.
  " Initialize product data
  PERFORM next_id USING 'products'
                  CHANGING wa_product-prod_id.
  wa_product-prod_name = 'Cafe'.
  wa_product-prod_quantity = 100.
  wa_product-prod_price = '2.50'.
  INSERT wa_product INTO TABLE it_products.

  PERFORM next_id USING 'products'
                  CHANGING wa_product-prod_id.
  wa_product-prod_name = 'Iced Tea'.
  wa_product-prod_quantity = 100.
  wa_product-prod_price = '3.00'.
  INSERT wa_product INTO TABLE it_products.

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
  ENDIF.
ENDFORM.

" Class definition for client
CLASS lcl_client DEFINITION.
  PUBLIC SECTION.
    METHODS:  constructor IMPORTING iv_name      TYPE string
                                    iv_last_name TYPE string,
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
          order_time     TYPE TIMS.
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
          lv_iv_last_name TYPE string.

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
  ENDMETHOD.

  METHOD update_order_count.
    me->order_count = me->order_count + 1.
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
  ENDMETHOD.

  METHOD get_client_id.
    rv_client_id = me->client_id.
  ENDMETHOD.
ENDCLASS.

" Class implementation for order
CLASS lcl_order IMPLEMENTATION.
  METHOD constructor.
    me->payment_method = iv_payment_method.
    CLEAR me->it_order_products.
    me->o_client = iv_o_client.
    me->total = 0.
  ENDMETHOD.

  METHOD add_product.
    DATA: wa_new_product TYPE ty_product,
          wa_stored_product TYPE ty_product.
    READ TABLE it_products INTO wa_new_product WITH KEY prod_id = iv_prod_id.
    IF sy-subrc = 0.
      READ TABLE it_products INTO wa_stored_product WITH KEY prod_id = iv_prod_id.
      DATA: lv_status TYPE abap_bool.
      
      PERFORM validate_quantity USING iv_quantity
                                CHANGING lv_status.
      IF lv_status = abap_true AND iv_quantity <= wa_stored_product-prod_quantity.
        " Set product quantity in the order
        wa_new_product-prod_quantity = iv_quantity.
        APPEND wa_new_product TO me->it_order_products.
        
        " Modify existences of that product in the stock
        wa_stored_product-prod_quantity = wa_stored_product-prod_quantity - iv_quantity.
        MODIFY it_products FROM wa_stored_product INDEX sy-tabix.
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
    IF lv_order_count = 3.
       RAISE EVENT fourth_wing EXPORTING sender_ref = me.
    ELSE.
       lo_o_client->update_order_count( ).
    ENDIF.
    " We date and close the order
      me->order_date = sy-datum.
      me->order_time = sy-uzeit.
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

          "now client order number is 0
          lo_o_client->reset_order_count( ).

        ELSE.
          lo_o_client->update_order_count( ).
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