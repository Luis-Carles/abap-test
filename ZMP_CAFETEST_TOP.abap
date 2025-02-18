*&---------------------------------------------------------------------*
*&  Include           ZMP_CAFETEST_TOP
*&---------------------------------------------------------------------*

INCLUDE ZMAIN_TOP.
INCLUDE ZMAIN_CLS.

" Screen Variables Declaration
DATA: wa_sclient TYPE ty_client,
      wa_sproduct TYPE ty_product,
      gv_button_enabled TYPE char1.