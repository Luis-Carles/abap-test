*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_TOP
*&---------------------------------------------------------------------*

" Tables & Data import
INCLUDE ZMAIN_TOP.

" Classes & Soubroutines (ZMAIN_F01) import
INCLUDE ZMAIN_CLS.

" AlV custom Control variables import
INCLUDE ZMANAGEMENT_ALV.

" Soubroutines import
INCLUDE ZMANAGEMENT_F01.

" Internal tables and Structures Declaration
DATA: gt_products TYPE TABLE OF zproducts,
      gt_clients  TYPE TABLE OF zclients,
      gt_corders  TYPE TABLE OF zcorders,
      gt_ordprod  TYPE TABLE OF zordproducts,
      gs_products TYPE zproducts,
      gs_clients  TYPE zclients,
      gs_corders  TYPE zcorders,
      gs_ordprod  TYPE zordproducts,
      gv_table    TYPE tabname.