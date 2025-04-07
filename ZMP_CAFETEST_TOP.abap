*&---------------------------------------------------------------------*
*&  Include           ZMP_CAFETEST_TOP
*&---------------------------------------------------------------------*

" Tables & Data import
INCLUDE ZMAIN_TOP.

" Classes & Soubroutines (ZMAIN_F01) import
INCLUDE ZMAIN_CLS.

" Statistics Retrieving Subroutines import
INCLUDE ZMAIN_F02.

" PBO/PAI Soubroutines import
INCLUDE ZMP_CAFETEST_F01.

" Screen Variables Declaration
DATA: wa_sclient TYPE ty_client,
      wa_sproduct TYPE ty_product,
      wa_eproduct TYPE ty_product,
      wa_nproduct TYPE ty_product,
      gv_payment_method TYPE string VALUE 'Credit Card',
      wa_lorder_date TYPE zcorders-order_date,
      gv_order_total TYPE ty_price,
      gs_stats TYPE ZST_STATS,
      gv_user TYPE sy-uname,
      gv_date TYPE DATS,
      gv_time TYPE TIMS.

" Create a client / order / handler instance
DATA: lo_client_fan TYPE REF TO lcl_client,
      lo_order TYPE REF TO lcl_order,
      lo_handler TYPE REF TO lcl_fourth_wing_handler.

" Screen 230 Order Product List Variables Declaration
DATA: gt_order_products TYPE TABLE OF ty_product,
      wa_order_product  TYPE ty_product.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_ORDER_PRODS' ITSELF
CONTROLS: TC_ORDER_PRODS TYPE TABLEVIEW USING SCREEN 0230.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_ORDER_PRODS'
DATA:     G_TC_ORDER_PRODS_LINES  LIKE SY-LOOPC.

DATA:     OK_CODE LIKE SY-UCOMM.

" -Change wa---->gs
" DOING!!