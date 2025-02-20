*&---------------------------------------------------------------------*
*&  Include           ZMP_CAFETEST_TOP
*&---------------------------------------------------------------------*

INCLUDE ZMAIN_TOP.
INCLUDE ZMAIN_CLS.

" Screen Variables Declaration
DATA: wa_sclient TYPE ty_client,
      wa_sproduct TYPE ty_product,
      lv_payment_method TYPE zcorders-payment_method,
      wa_lorder_date TYPE zcorders-order_date.


" Create a client / order / handler instance
DATA: lo_client_fan TYPE REF TO lcl_client,
      lo_order TYPE REF TO lcl_order,
      lo_handler TYPE REF TO lcl_fourth_wing_handler,
      ls_product  TYPE zproducts.