*&---------------------------------------------------------------------*
*& Report  ZMAIN_PROGRAM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZMAIN_PROGRAM.

" Datatables import
TABLES: zclients,
        zcorders,
        zordproducts,
        zproducts.

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

" Variables Declaration
DATA: it_products TYPE SORTED TABLE OF ty_product
                    WITH UNIQUE KEY prod_id,
      it_clients TYPE SORTED TABLE OF ty_client
                    WITH UNIQUE KEY client_id.

" Classes & Soubroutines import
INCLUDE ZMAIN_CLASSES.

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
  lo_client_fan = NEW lcl_client( iv_name = 'javier'
                                      iv_last_name = 'Oliveira' ).


" -------OLD CLIENT -----------
  " lo_client_fan->comeback( iv_client_id = '1' ).


  "------STOCK ----------
  "PERFORM add_new_product USING 'Orange Juice'
  "                              1000
  "                          '3.50'.

  PERFORM display_stock.

  "-----ORDERING --------
  DO 3 TIMES.
     " Create orders
    lo_order = NEW lcl_order( iv_payment_method = 'Credit card'
                                 iv_o_client = lo_client_fan ).

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