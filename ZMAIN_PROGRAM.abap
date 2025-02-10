*&---------------------------------------------------------------------*
*& Report  ZMAIN_PROGRAM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZMAIN_PROGRAM.

INCLUDE ZMAIN_CLASSES.

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