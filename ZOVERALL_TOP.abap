*&---------------------------------------------------------------------*
*&  Include           ZOVERALL_TOP
*&---------------------------------------------------------------------*

" Datatables import
TABLES: zclients,     " Master DB Table that stores
                      " Clients information

        zcorders,     " DB Table that stores
                      " Closed Orders information

        zordproducts, " DB Table that stores
                      " List of Products in an order

        zproducts.    " Master DB Table that stores
                      " Products information

"___________________________________________________________
" Global Variables Declaration

  " GLobal flag to know if every internal table was filled
  DATA: gv_filled TYPE abap_bool VALUE abap_false.

  " Global variables to avoid
  " messing with sy-ucomm
  DATA: gv_code       TYPE sy-ucomm,
        ok_code       TYPE sy-ucomm.
"___________________________________________________________
" Internal tables and Structures Declaration

" Closed Order internal Table Line Type
TYPES: BEGIN OF ty_corder,
           ORDER_ID         LIKE zcorders-ORDER_ID,
           PAYMENT_METHOD   LIKE zcorders-PAYMENT_METHOD,
           TOTAL            LIKE zcorders-TOTAL,
           WAERS            LIKE zcorders-WAERS,
           ORDER_DATE       LIKE zcorders-ORDER_DATE,
           ORDER_TIME       LIKE zcorders-ORDER_TIME,
           ORDER_CLIENT     LIKE zcorders-ORDER_CLIENT,
       END OF ty_corder.
" Closed Order internal Table Type
TYPES: tt_corders TYPE TABLE OF ty_corder.

" List of Products Internal Table Line Type
TYPES: BEGIN OF ty_ordproduct,
           ORDER_ID         LIKE zordproducts-ORDER_ID,
           PROD_ID          LIKE zordproducts-PROD_ID,
           PROD_QUANTITY    LIKE zordproducts-PROD_QUANTITY,
           MEINS            LIKE zordproducts-MEINS,
       END OF ty_ordproduct.
" List of Products Internal Table Type
TYPES: tt_ordproducts TYPE TABLE OF ty_ordproduct.

" Detail List for Double Click Table Line Type
*TYPES: BEGIN OF ty_detail,
*        ORDER_CLIENT        TYPE CHAR10,
*        CLIENT_NAME         TYPE CHAR40,
*        CLIENT_LAST_NAME    TYPE CHAR40,
*        ORDER_COUNT         TYPE CHAR5,
*        REG_STATUS          TYPE CHAR20,
*        ORDER_ID            TYPE CHAR10,
*        ORDER_DATE          TYPE CHAR10,
*        ORDER_TIME          TYPE CHAR10,
*        TOTAL               TYPE CHAR10,
*        WAERS               TYPE CHAR5,
*        PAYMENT_METHOD      TYPE CHAR15,
*        PROD_ID             TYPE CHAR10,
*        PROD_NAME           TYPE CHAR40,
*        PROD_PRICE          TYPE CHAR10,
*        PROD_QUANTITY       TYPE CHAR10,
*        PROD_STOCK          TYPE CHAR10,
*        MEINS               TYPE CHAR3,
*      END OF ty_detail.
" Detail List for Double Click Table Type
*TYPES: tt_details TYPE TABLE OF ty_detail.

" Non-master Internal Data Tables
DATA: gt_corders     TYPE tt_corders,
      gs_corder      TYPE ty_corder,
      gt_ordproducts TYPE tt_ordproducts,
      gs_ordproduct  TYPE ty_ordproduct.

" Details Result Internal Table.
DATA: gt_results     TYPE TABLE OF ZST_RESULT,
      gs_result      TYPE ZST_RESULT.

"__________________________________________________________
" Master Data Internal Tables

" Master Equipment for Clients
DATA: BEGIN OF gt_master_clients OCCURS 0,
        CLIENT_ID          LIKE ZCLIENTS-CLIENT_ID,
        CLIENT_NAME        LIKE ZCLIENTS-CLIENT_NAME,
        CLIENT_LAST_NAME   LIKE ZCLIENTS-CLIENT_LAST_NAME,
        ORDER_COUNT        LIKE ZCLIENTS-ORDER_COUNT,
      END OF gt_master_clients.

" Master Equipment for Products
DATA: BEGIN OF gt_master_products OCCURS 0,
        PROD_ID          LIKE ZPRODUCTS-PROD_ID,
        PROD_NAME        LIKE ZPRODUCTS-PROD_NAME,
        PROD_QUANTITY    LIKE ZPRODUCTS-PROD_QUANTITY,
        PROD_PRICE       LIKE ZPRODUCTS-PROD_PRICE,
      END OF gt_master_products.

"__________________________________________________________
" Object Instances
CLASS lcl_application  DEFINITION DEFERRED.
DATA: go_application   TYPE REF TO lcl_application,
      go_ccontainer    TYPE REF TO cl_gui_custom_container,
      go_tree          TYPE REF TO cl_gui_column_tree.

"__________________________________________________________
" SAP Column Tree Variables
DATA: hierarchy_header TYPE TREEV_HHDR,
      gt_node_table    TYPE treev_ntab, "mtreesnode
      gs_node          TYPE treev_node,
      gt_item_table    TYPE TABLE OF MTREEITM,
      gs_item          TYPE MTREEITM.