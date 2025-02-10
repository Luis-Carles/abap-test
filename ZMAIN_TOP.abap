*&---------------------------------------------------------------------*
*&  Include           ZMAIN_TOP
*&---------------------------------------------------------------------*
" DEFINITIONS AND INITIALIZATIONS
" Tables
TABLES: zclients,
        zcorders,
        zordproducts,
        products.

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

DATA: it_products TYPE SORTED TABLE OF ty_product
                    WITH UNIQUE KEY prod_id,
      it_clients TYPE SORTED TABLE OF ty_client
                    WITH UNIQUE KEY client_id.