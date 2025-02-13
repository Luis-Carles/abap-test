*&---------------------------------------------------------------------*
*& Report  ZMAIN_PROGRAM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZMAIN_PROGRAM.

" Tables & Data import
INCLUDE ZMAIN_TOP.

" Classes & Soubroutines import
INCLUDE ZMAIN_CLS.

"---------------------> Main Program Execution
START-OF-SELECTION.

  " Create a client / order / handler instance
  DATA: lo_client_fan TYPE REF TO lcl_client,
        lo_order TYPE REF TO lcl_order,
        lo_handler TYPE REF TO lcl_fourth_wing_handler,
        wa_product  TYPE ty_product,
        ls_product  TYPE zproducts.


  lo_handler = NEW lcl_fourth_wing_handler( ).

" -------NEW CLIENT -----------
  "lo_client_fan = NEW lcl_client( iv_name = 'javier'
  "                                iv_last_name = 'Oliveira'
  "                                iv_mode = 'new'
  "                                iv_client_id = '1' ).


" -------OLD CLIENT -----------
  lo_client_fan = NEW lcl_client( iv_name = 'Luis'
                                  iv_last_name = 'Carles'
                                  iv_mode = 'comeback'
                                  iv_client_id = '1' ).


  "------ NEW STOCK ----------
  "DATA: p_prod_name TYPE zproducts-prod_name,
  "      p_prod_quantity TYPE zproducts-prod_quantity,
  "      p_prod_price TYPE zproducts-prod_price.

  "p_prod_name = 'Tiramisu'.
  "p_prod_quantity = 1000.
  "p_prod_price = '4.00'.
  "PERFORM add_new_product USING p_prod_name
  "                              p_prod_quantity
  "                              p_prod_price.


  "------ UPDATE STOCK --------
  PERFORM update_stock USING '1' 78.


  PERFORM display_stock.

  "-----ORDERING --------
  DO 3 TIMES.
     " Create orders
    lo_order = NEW lcl_order( iv_payment_method = 'Credit card'
                              iv_o_client       = lo_client_fan ).

    " Link event possible raiser to the handler
    SET HANDLER lo_handler->on_fourth_wing FOR lo_order.

    " Add products
    lo_order->add_product( iv_prod_id = 1 iv_quantity = 3 ).
    lo_order->add_product( iv_prod_id = 3 iv_quantity = 2 ).
    lo_order->calculate_total( ).
    " Close order
    lo_order->close_order( iv_o_client = lo_order->get_o_client( ) ).
    lo_order->update_monthly_gains( ).
    lo_order->display_order( ).
  ENDDO.

  " Check remaining stock and monthly gains
  PERFORM display_stock.
  WRITE: / 'Final gains:', gv_monthly_gains.