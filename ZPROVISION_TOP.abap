*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_TOP
*&---------------------------------------------------------------------*

" Datatables import
TABLES: zclients,     " Master DB Table that stores Clients information
        zcorders,     " DB Table that stores Closed Orders information
        zordproducts, " DB Table that stores List of Products in an order
        zproducts.    " Master DB Table that stores Products information

*TABLES: SSCRFIELDS.   " Selection-Screen Fields Table

"_______________________________________________________________________
" Global variables
DATA(gv_tab)    =  CONV CHAR2( 'CL' ).  " Chosen DB table
DATA(gv_filled) =  abap_false.          " Is there Data to display?

DATA: gv_code       TYPE sy-ucomm,      " Global variables to avoid
      ok_code       TYPE sy-ucomm,      " messing with sy-ucomm
      gv_answer(1),                     " Pop-Up Window answer
      gv_check      TYPE STA_TEXT.      " Check input flag


"_______________________________________________________________________
" Internal tables and Structures Declaration

DATA: gs_zclient           TYPE zclients,    " Persistence Rows used
      gs_zproduct          TYPE zproducts,   " when saving to avoid
      gs_zcorder           TYPE zcorders,    " compatibility issues
      gs_zordproduct       TYPE zordproducts.

TYPES: BEGIN OF ty_corder,     " Closed Orders type + Table Type
         ORDER_ID          LIKE zcorders-ORDER_ID,
         PAYMENT_METHOD    LIKE zcorders-PAYMENT_METHOD,
         TOTAL             LIKE zcorders-TOTAL,
         WAERS             LIKE zcorders-WAERS,
         ORDER_DATE        LIKE zcorders-ORDER_DATE,
         ORDER_TIME        LIKE zcorders-ORDER_TIME,
         ORDER_CLIENT      LIKE zcorders-ORDER_CLIENT,
         COLOR             TYPE LVC_T_SCOL,
         FLAG_NEW          TYPE CHAR1,
         FLAG_CHG          TYPE CHAR1,
       END OF ty_corder.
TYPES: tt_corders TYPE TABLE OF ty_corder.

TYPES: BEGIN OF ty_ordproduct, " Order Product type + Table Type
         ORDER_ID          LIKE zordproducts-ORDER_ID,
         PROD_ID           LIKE zordproducts-PROD_ID,
         PROD_QUANTITY     LIKE zordproducts-PROD_QUANTITY,
         MEINS             LIKE zordproducts-MEINS,
         COLOR             TYPE LVC_T_SCOL,
         FLAG_NEW          TYPE CHAR1,
         FLAG_CHG          TYPE CHAR1,
       END OF ty_ordproduct.
TYPES: tt_ordproducts TYPE TABLE OF ty_ordproduct.

TYPES: BEGIN OF ty_client,     " Client type + Table Type
        CLIENT_ID          LIKE ZCLIENTS-CLIENT_ID,
        CLIENT_NAME        LIKE ZCLIENTS-CLIENT_NAME,
        CLIENT_LAST_NAME   LIKE ZCLIENTS-CLIENT_LAST_NAME,
        ORDER_COUNT        LIKE ZCLIENTS-ORDER_COUNT,
        COLOR              TYPE LVC_T_SCOL,
        FLAG_NEW           TYPE CHAR1,
        FLAG_CHG           TYPE CHAR1,
       END OF ty_client.
TYPES: tt_clients TYPE TABLE OF ty_client.

TYPES: BEGIN OF ty_product,   " Product type + Table Type
        PROD_ID            LIKE ZPRODUCTS-PROD_ID,
        PROD_NAME          LIKE ZPRODUCTS-PROD_NAME,
        PROD_QUANTITY      LIKE ZPRODUCTS-PROD_QUANTITY,
        PROD_PRICE         LIKE ZPRODUCTS-PROD_PRICE,
        COLOR              TYPE LVC_T_SCOL,
        FLAG_NEW           TYPE CHAR1,
        FLAG_CHG           TYPE CHAR1,
       END OF ty_product.
TYPES: tt_products TYPE TABLE OF ty_product.

DATA: gt_corders     TYPE tt_corders,     " Closed Orders Table
      gt_ordproducts TYPE tt_ordproducts, " Order Products Table
      gt_clients     TYPE tt_clients,     " Clients Table
      gt_products    TYPE tt_products.    " Products Table

DATA: gs_chg_row     TYPE lvc_s_modi.     " Modified Results Row