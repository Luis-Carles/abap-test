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
INCLUDE ZMAIN_F03.

" Screen Variables Declaration
DATA: wa_sclient TYPE ty_client,
      wa_sproduct TYPE ty_product,
      wa_eproduct TYPE ty_product,
      wa_nproduct TYPE ty_product,
      gv_payment_method TYPE string VALUE 'Credit Card',
      wa_lorder_date TYPE zcorders-order_date,
      gt_aproducts  TYPE TABLE OF ty_product,
      gt_order_products TYPE TABLE OF ty_product,
      gs_stats TYPE ZST_STATS,
      gv_best_seller TYPE zproducts-prod_name,
      gv_worst_seller TYPE zproducts-prod_name,
      gv_user TYPE sy-uname,
      gv_date TYPE DATS,
      gv_time TYPE TIMS.

" Create a client / order / handler instance
DATA: lo_client_fan TYPE REF TO lcl_client,
      lo_order TYPE REF TO lcl_order,
      lo_handler TYPE REF TO lcl_fourth_wing_handler.