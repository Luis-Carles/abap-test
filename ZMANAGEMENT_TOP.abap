*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_TOP
*&---------------------------------------------------------------------*

" Datatables import
TABLES: zclients,
        zcorders,
        zordproducts,
        zproducts.

TABLES: SSCRFIELDS.

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
      ok_code       TYPE sy-ucomm,         " messing with sy-ucomm
      gv_check      TYPE STA_TEXT,         " Check input flag
      gv_save       TYPE STA_TEXT,
      gv_delete     TYPE STA_TEXT.

"_______________________________________________________________________
" Internal tables and Structures Declaration
DATA: gt_results      TYPE TABLE OF ZST_RESULT, " Results structure
      gs_result       TYPE ZST_RESULT,          " Results line
*      gt_zclients     TYPE TABLE OF zclients,
      gs_zclient      TYPE zclients,
*      gt_zproducts    TYPE TABLE OF zproducts,
      gs_zproduct     TYPE zproducts,
*      gt_zcorders     TYPE TABLE OF zcorders,
      gs_zcorder      TYPE zcorders,
*      gt_zordproducts TYPE TABLE OF zordproducts,
      gs_zordproduct  TYPE zordproducts.

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

"_______________________________________________________________________
" Excel Downloading and Uploading Variables
*DATA: gs_key          LIKE WWWDATATAB,
*      gs_funcdown     TYPE SMP_DYNTXT.

*DATA: gv_d_dir       TYPE string,
*      gv_d_init_dir  TYPE string,
*      gv_d_file      LIKE RLGRAP-FILENAME.

DATA: gv_u_path       TYPE string,
      gv_u_rc         TYPE i      VALUE 1,
      gv_win_title    TYPE string VALUE 'OPEN',
      gv_u_files      TYPE FILETABLE,
      gv_u_filename   TYPE string,
      gv_u_check_file TYPE string,
      gv_u_check_flag TYPE abap_bool.

DATA: gt_excel  TYPE TABLE OF alsmex_tabline,
      gs_excel  TYPE alsmex_tabline.