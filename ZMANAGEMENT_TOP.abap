*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_TOP
*&---------------------------------------------------------------------*

"_______________________________________________________________________
" Global variables
" VIEW MODE:        D: Display
"                   M: Management

" INITIAL TABLE:    OV: Overall
"                   CL: zClients
"                   CO: zCorders
"                   PR: zProducts
"                   OP: zOrdproducts

" SEARCH APPROACH:  ND: Non-Dynamic Conditions
"                   DY: Dynamic Conditions
DATA: gv_mode       TYPE CHAR1 VALUE 'D',  " View Mode
*      gv_init_tab   TYPE CHAR2 VALUE 'OV', " Initial table
      gv_approach   TYPE CHAR2 VALUE 'ND', " Search data approach
      gv_where      TYPE string,           " Dynamic Conditions strings
      gv_where_cl   TYPE string,
      gv_where_pr   TYPE string,
      gv_code       TYPE sy-ucomm,         " Global variables to avoid
      ok_code       TYPE sy-ucomm.         " messing with sy-ucomm

"_______________________________________________________________________
" Internal tables and Structures Declaration
DATA: gt_results      TYPE TABLE OF ZST_RESULT, " Results structure
      gs_result       TYPE ZST_RESULT.          " Results line
*      gt_zclients     TYPE TABLE OF zclients,
*      gs_zclients     TYPE zclients,
*      gt_zproducts    TYPE TABLE OF zproducts,
*      gs_zproducts    TYPE zproducts,
*      gt_zcorders     TYPE TABLE OF zcorders,
*      gs_zcorders     TYPE zcorders,
*      gt_zordproducts TYPE TABLE OF zordproducts,
*      gs_zordproducts TYPE zordproducts.
"_______________________________________________________________________
" Master Data tables
DATA: BEGIN OF gt_master_clients OCCURS 0,  " Master Equipment for Clients
        CLIENT_ID          LIKE ZCLIENTS-CLIENT_ID,
        CLIENT_NAME        LIKE ZCLIENTS-CLIENT_NAME,
        CLIENT_LAST_NAME   LIKE ZCLIENTS-CLIENT_LAST_NAME,
        ORDER_COUNT        LIKE ZCLIENTS-ORDER_COUNT,
       END OF gt_master_clients.

DATA: BEGIN OF gt_master_products OCCURS 0, " Master Equipment for Products
        PROD_ID          LIKE ZPRODUCTS-PROD_ID,
        PROD_NAME        LIKE ZPRODUCTS-PROD_NAME,
        PROD_QUANTITY    LIKE ZPRODUCTS-PROD_QUANTITY,
        PROD_PRICE       LIKE ZPRODUCTS-PROD_PRICE,
       END OF gt_master_products.