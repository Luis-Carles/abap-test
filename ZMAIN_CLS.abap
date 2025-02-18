*&---------------------------------------------------------------------*
*&  Include           ZMAIN_CLS
*&---------------------------------------------------------------------*
INCLUDE ZMAIN_F01.

" Class definition for client
CLASS lcl_client DEFINITION.
  PUBLIC SECTION.
    METHODS:  constructor IMPORTING iv_name      TYPE string
                                    iv_last_name TYPE string
                                    iv_mode      TYPE string
                                    iv_client_id TYPE i,
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
             add_product IMPORTING iv_prod_id TYPE int2
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

    IF iv_mode = 'new'.
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
    ENDIF.
    IF iv_mode = 'comeback'.
      PERFORM search_client USING iv_client_id
                          CHANGING wa_client.
      IF sy-subrc = 0.
        me->client_id = wa_client-client_id.
        me->name = wa_client-name.
        me->last_name = wa_client-last_name.
        me->order_count = wa_client-order_count.
      ELSE.
        WRITE: / 'Client not found with that id. ', /.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD update_order_count.
    me->order_count = me->order_count + 1.
    " Update in Database table
    DATA: ls_client TYPE zclients.

    SELECT * FROM zclients INTO ls_client
       WHERE client_id = me->client_id.

    ls_client-order_count = ls_client-order_count + 1.

    UPDATE zclients SET order_count = ls_client-order_count
      WHERE client_id = me->client_id.
    ENDSELECT.
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
    ls_order-order_client = iv_o_client->get_client_id( ).
    ls_order-payment_method = me->payment_method.
    INSERT INTO zcorders VALUES ls_order.

  ENDMETHOD.

  METHOD add_product.
    DATA: wa_new_product TYPE ty_product,
          wa_stored_product TYPE ty_product,
          wa_stored_ordproduct TYPE ty_product,
          ls_ordproduct TYPE zordproducts,
          lv_stock TYPE i.

    " READ TABLE it_products INTO wa_new_product WITH KEY prod_id = iv_prod_id.
    PERFORM search_product USING iv_prod_id
                           CHANGING wa_new_product.
    IF sy-subrc = 0.
      " READ TABLE it_products INTO wa_stored_product WITH KEY prod_id = iv_prod_id.
      PERFORM search_product USING iv_prod_id
                             CHANGING wa_stored_product.

      DATA: lv_status TYPE abap_bool,
            lv_status2 TYPE abap_bool.

      PERFORM validate_quantity USING iv_quantity
                                CHANGING lv_status.

      IF lv_status = abap_true AND iv_quantity <= wa_stored_product-prod_quantity.
        lv_status2 = abap_true.
      ELSE.
        lv_status2 = abap_false.
      ENDIF.

      IF lv_status2 = abap_false.
        WRITE: / 'Invalid quantity for product:', wa_new_product-prod_name.
      ELSE.
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
        ENDSELECT.

        lv_stock = lv_stock - iv_quantity.
        UPDATE zproducts SET prod_quantity =  lv_stock
            WHERE prod_id = wa_stored_product-prod_id.
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