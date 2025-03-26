*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_F02
*&---------------------------------------------------------------------*

"___________________________________________________________________
"________________GET & MAKE DATA SUBROUTINES________________________
"_________________________OUTER JOIN________________________________
"___________________________________________________________________

" Subroutine that retrieves the data from the database tables
" both non-dynamic and dynamic conditions approaches using OUTER JOIN
FORM get_data_outer.
    CLEAR: gt_results, gs_result,gt_master_clients,gt_master_products.
  
    CASE gv_approach.
      WHEN 'ND'. " NON DYNAMIC CONDITIONS APPROACH
  *     ___________STEP 1________________________________________________________
        SELECT a~ORDER_ID, b~ORDER_CLIENT, b~ORDER_DATE, b~ORDER_TIME,
               b~TOTAL, b~PAYMENT_METHOD, a~PROD_ID, a~PROD_QUANTITY,
               a~MEINS, b~WAERS
          INTO CORRESPONDING FIELDS OF TABLE @gt_results
          FROM ZORDPRODUCTS AS a LEFT OUTER JOIN ZCORDERS AS b
          ON a~ORDER_ID = b~ORDER_ID
          WHERE a~ORDER_ID       IN @s_ORDID AND
                b~ORDER_CLIENT   IN @s_CLID  AND
                b~ORDER_DATE     IN @s_ODATE AND
                b~ORDER_TIME     IN @s_OTIME AND
                b~TOTAL          IN @s_TOTAL AND
                b~PAYMENT_METHOD IN @s_PAYM  AND
                a~PROD_ID        IN @s_PROID AND
                a~PROD_QUANTITY  IN @s_PQUAN.
  
  *     ___________STEP 2________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_clients
          FROM ZCLIENTS
          WHERE CLIENT_NAME      IN @s_CNAME  AND
                CLIENT_LAST_NAME IN @s_CLNAME AND
                ORDER_COUNT      IN @s_OCOUNT.
        SORT gt_master_clients BY CLIENT_ID.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY, PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_products
          FROM ZPRODUCTS
          WHERE PROD_NAME     IN @s_PNAME  AND
                PROD_QUANTITY IN @s_PSTOCK AND
                PROD_PRICE    IN @s_PPRICE.
        SORT gt_master_products BY PROD_ID.
  
      WHEN 'DY'.
        PERFORM dynamic_conditions.
  
        "________STEP 1___________________________________________________________
        SELECT a~ORDER_ID, b~ORDER_CLIENT, b~ORDER_DATE, b~ORDER_TIME,
               b~TOTAL, b~PAYMENT_METHOD, a~PROD_ID, a~PROD_QUANTITY,
               a~MEINS, b~WAERS
          INTO CORRESPONDING FIELDS OF TABLE @gt_results
          FROM ZORDPRODUCTS AS a LEFT OUTER JOIN ZCORDERS AS b
          ON a~ORDER_ID = b~ORDER_ID
          WHERE (gv_where).
  
        "________STEP 2___________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_clients
          FROM ZCLIENTS
          WHERE (gv_where_cl).
        SORT gt_master_clients BY CLIENT_ID.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY,PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_products
          FROM ZPRODUCTS
          WHERE (gv_where_pr).
        SORT gt_master_products BY PROD_ID.
  
    ENDCASE.
  ENDFORM.
  
  "___________________________________________________________________
  "________________GET & MAKE DATA SUBROUTINES________________________
  "_____________________ZREDU1XX APPROACH_____________________________
  "___________________________________________________________________
  
  *FIELD-SYMBOLS: <fs_bkpf> TYPE ty_bkpf,
  *               <fs_bseg> TYPE ty_bseg.    " POINTER STRUCTURE
  *
  *DATA: lv_tabix TYPE sy-tabix.             " INDEX
  
  
  * SELECT .......... FROM BKPF INTO gt_bkpf  " INDIVIDUAL SELECT FOR ONE TABLE
  *   WHERE .........
  * SORT gt_bkpf BY .........                 " SORT table
  
  * SELECT .......... FROM BSEG INTO gt_bseg  " INDIVIDUAL SELECT FOR THE OTHER
  *   WHERE .........
  * SORT gt_bseg BY .........                 " SORT table
  
  
  *LOOP AT gt_bkpf ASSIGNING <fs_bkpf>.      " LOOP THROUGH ONE TABLE
  *
  *  MOVE-CORRESPONDING <fs_bkpf> TO gs_disp. " TAKE THAT TABLE FIELDS
  *
  *  READ TABLE gt_bseg ASSIGNING <fs_bseg>   " BINARY SEARCH IN THE SECOND TABLE
  *                     WITH KEY bukrs = <fs_bkpf>-bukrs
  *                              belnr = <fs_bkpf>-belnr
  *                              gjahr = <fs_bkpf>-gjahr
  *                     BINARY SEARCH.
  *
  *  IF sy-subrc = 0.
  *    lv_tabix = sy-tabix.   " IF FOUND, KEEP THE INDEX
  *  ELSE.
  *    IF lv_outer_join = abap_true.     " IF NOT FOUND AND OUTER OPTION IS ACTIVATED
  *      APPEND gs_result TO gt_results. " APPEND THE ROW AS IT IS NOW.
  *    ENDIF.
  *    CONTINUE.   " IF NOT FOUND JUST END THIS ITERATION
  *  ENDIF.
  *
  *  LOOP AT gt_bseg ASSIGNING <fs_bseg>  " LOOP THROUGH THE SECOND TABLE WITH WHERE
  *       FROM lv_tabix                   " CONDITIONS AND THE STORED INDEX
  *       WHERE bukrs = <fs_bkpf>-bukrs
  *         AND belnr = <fs_bkpf>-belnr
  *         AND gjahr = <fs_bkpf>-gjahr.
  *
  *    " Copy selected fields from BSEG
  *    MOVE: <fs_bseg>-buzei TO gs_result-buzei, " TAKE THE SECOND TABLE FIELDS TOO
  *          <fs_bseg>-augdt TO gs_result-augdt,
  *          <fs_bseg>-augb  TO gs_result-augb,
  *          <fs_bseg>-gsber TO gs_result-gsber,
  *          <fs_bseg>-hkont TO gs_result-hkont,
  *          <fs_bseg>-dmbtr TO gs_result-dmbtr,
  *          <fs_bseg>-sgtxt TO gs_result-sgtxt.
  *
  *    " Append to display table
  *    APPEND gs_result TO gt_results.              " APPEND MATCH ROW TO RESULTS
  *  ENDLOOP.
  *ENDLOOP.
  
  " Subroutine that retrieves the data from the database tables
  " both non-dynamic and dynamic conditions approaches using TYPE as global variables
  FORM get_data_type.
  *___________________________________________________________________________________
  * TYPES DECLARATION
  
    " TO avoid problems with prior code, gt_results dont have HEADER LINE, gs_result
    " has been used instead.
  
    TYPES: BEGIN OF ty_corder,
             ORDER_ID         LIKE zcorders-ORDER_ID,
             PAYMENT_METHOD   LIKE zcorders-PAYMENT_METHOD,
             TOTAL            LIKE zcorders-TOTAL,
             WAERS            LIKE zcorders-WAERS,
             ORDER_DATE       LIKE zcorders-ORDER_DATE,
             ORDER_TIME       LIKE zcorders-ORDER_TIME,
             ORDER_CLIENT     LIKE zcorders-ORDER_CLIENT,
           END OF ty_corder.
    TYPES: tt_corders TYPE TABLE OF ty_corder.
  
    TYPES: BEGIN OF ty_ordproduct,
             ORDER_ID         LIKE zordproducts-ORDER_ID,
             PROD_ID          LIKE zordproducts-PROD_ID,
             PROD_QUANTITY    LIKE zordproducts-PROD_QUANTITY,
             MEINS            LIKE zordproducts-MEINS,
           END OF ty_ordproduct.
    TYPES: tt_ordproducts TYPE TABLE OF ty_ordproduct.
  
    TYPES: BEGIN OF ty_master_client,  " Master Equipment for Clients
            CLIENT_ID          LIKE ZCLIENTS-CLIENT_ID,
            CLIENT_NAME        LIKE ZCLIENTS-CLIENT_NAME,
            CLIENT_LAST_NAME   LIKE ZCLIENTS-CLIENT_LAST_NAME,
            ORDER_COUNT        LIKE ZCLIENTS-ORDER_COUNT,
           END OF ty_master_client.
    TYPES: tt_master_clients TYPE TABLE OF ty_master_client.
  
    TYPES: BEGIN OF ty_master_product, " Master Equipment for Products
            PROD_ID          LIKE ZPRODUCTS-PROD_ID,
            PROD_NAME        LIKE ZPRODUCTS-PROD_NAME,
            PROD_QUANTITY    LIKE ZPRODUCTS-PROD_QUANTITY,
            PROD_PRICE       LIKE ZPRODUCTS-PROD_PRICE,
           END OF ty_master_product.
    TYPES: tt_master_products TYPE TABLE OF ty_master_product.
  
    DATA: lt_corders         TYPE tt_corders WITH HEADER LINE,
          lt_ordproducts     TYPE tt_ordproducts WITH HEADER LINE,
          lt_master_clients  TYPE tt_master_clients WITH HEADER LINE,
          lt_master_products TYPE tt_master_products WITH HEADER LINE,
          lv_tabix           TYPE sy-tabix.
  
    DATA: lv_where_co    TYPE string,
          lv_where_op    TYPE string.
    CLEAR: gt_results,gs_result,gt_master_clients,gt_master_products.
  *_____________________________________________________________________________________
  
    CASE gv_approach.
      WHEN 'ND'. " NON DYNAMIC CONDITIONS APPROACH
  * ____________________________________________________________________________________
  * INDIVIDUAL SELECT QUERIES FOR BOTH TABLES
        SELECT ORDER_ID, ORDER_CLIENT, ORDER_DATE, ORDER_TIME,
               TOTAL, PAYMENT_METHOD, WAERS
          INTO CORRESPONDING FIELDS OF TABLE @lt_corders
          FROM ZCORDERS
          WHERE ORDER_ID       IN @s_ORDID AND
                ORDER_CLIENT   IN @s_CLID  AND
                ORDER_DATE     IN @s_ODATE AND
                ORDER_TIME     IN @s_OTIME AND
                TOTAL          IN @s_TOTAL AND
                PAYMENT_METHOD IN @s_PAYM.
        SORT lt_corders BY ORDER_ID.
  
        SELECT ORDER_ID, PROD_ID, PROD_QUANTITY, MEINS
          INTO CORRESPONDING FIELDS OF TABLE @lt_ordproducts
          FROM ZORDPRODUCTS
          WHERE ORDER_ID       IN @s_ORDID AND
                PROD_ID        IN @s_PROID AND
                PROD_QUANTITY  IN @s_PQUAN.
        SORT lt_ordproducts BY ORDER_ID PROD_ID.
  * ____________________________________________________________________________________
  * LOOP THROUGH ONE OF THEM
        LOOP AT lt_corders.
  *        MOVE-CORRESPONDING lt_corders TO gt_results.
          MOVE-CORRESPONDING lt_corders TO gs_result. " TAKE THAT TABLE FIELDS
  
          CLEAR: lv_tabix.
          READ TABLE lt_ordproducts WITH KEY ORDER_ID = lt_corders-ORDER_ID
            TRANSPORTING NO FIELDS                    " BINARY SEARCH OVER THE OTHER
            BINARY SEARCH.
          IF sy-subrc = 0.                            " MATCH -> KEEP INDEX
            lv_tabix = sy-tabix.
          ELSE.                                       " NO RESULT:
            IF gv_join = 'O'.                         " IF OUTER OPTION IS ENABLED
  *            APPEND gt_results.
              APPEND gs_result TO gt_results.         " APPEND THE ROW AS IT IS
            ENDIF.
            CONTINUE.                                 " LEAVE ITERATION
          ENDIF.
  
  * ____________________________________________________________________________________
  * LOOP THROUGH THE OTHER WITH STORED INDEX AND MATCHING FIELD
          LOOP AT lt_ordproducts FROM lv_tabix
            WHERE ORDER_ID = lt_corders-ORDER_ID.
  
  *          MOVE-CORRESPONDING lt_ordproducts TO gt_results.
            MOVE-CORRESPONDING lt_ordproducts TO gs_result.   " TAKE OTHER TABLE FIELDS TOO
  *          APPEND gt_results.
            APPEND gs_result TO gt_results.                   " APPEND ROW TO RESULTS TABLE
          ENDLOOP.
  
        ENDLOOP.
  
  * ____________________________________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_clients
          FROM ZCLIENTS
          WHERE CLIENT_NAME      IN @s_CNAME  AND
                CLIENT_LAST_NAME IN @s_CLNAME AND
                ORDER_COUNT      IN @s_OCOUNT.
        SORT gt_master_clients BY CLIENT_ID.
        APPEND LINES OF lt_master_clients TO gt_master_clients.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY, PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_products
          FROM ZPRODUCTS
          WHERE PROD_NAME     IN @s_PNAME  AND
                PROD_QUANTITY IN @s_PSTOCK AND
                PROD_PRICE    IN @s_PPRICE.
        SORT gt_master_products BY PROD_ID.
        APPEND LINES OF lt_master_products TO gt_master_products.
  
      WHEN 'DY'.
        PERFORM dynamic_conditions_indv CHANGING lv_where_co lv_where_op.
  * ____________________________________________________________________________________
  * INDIVIDUAL SELECT QUERIES FOR BOTH TABLES
        SELECT ORDER_ID, ORDER_CLIENT, ORDER_DATE, ORDER_TIME,
               TOTAL, PAYMENT_METHOD, WAERS
          INTO CORRESPONDING FIELDS OF TABLE @lt_corders
          FROM ZCORDERS
          WHERE (lv_where_co).
        SORT lt_corders BY ORDER_ID.
  
        SELECT ORDER_ID, PROD_ID, PROD_QUANTITY, MEINS
          INTO CORRESPONDING FIELDS OF TABLE @lt_ordproducts
          FROM ZORDPRODUCTS
          WHERE (lv_where_op).
        SORT lt_ordproducts BY ORDER_ID PROD_ID.
  * ____________________________________________________________________________________
  * LOOP THROUGH ONE OF THEM
        LOOP AT lt_corders.
  *        MOVE-CORRESPONDING lt_corders TO gt_results.
          MOVE-CORRESPONDING lt_corders TO gs_result. " TAKE THAT TABLE FIELDS
  
          CLEAR: lv_tabix.
          READ TABLE lt_ordproducts WITH KEY ORDER_ID = lt_corders-ORDER_ID
            TRANSPORTING NO FIELDS                    " BINARY SEARCH OVER THE OTHER
            BINARY SEARCH.
          IF sy-subrc = 0.                            " MATCH -> KEEP INDEX
            lv_tabix = sy-tabix.
          ELSE.                                       " NO RESULT:
            IF gv_join = 'O'.                         " IF OUTER OPTION IS ENABLED
  *            APPEND gt_results.
              APPEND gs_result TO gt_results.         " APPEND THE ROW AS IT IS
            ENDIF.
            CONTINUE.                                 " LEAVE ITERATION
          ENDIF.
  
  * ____________________________________________________________________________________
  * LOOP THROUGH THE OTHER WITH STORED INDEX AND MATCHING FIELD
          LOOP AT lt_ordproducts FROM lv_tabix
            WHERE ORDER_ID = lt_corders-ORDER_ID.
  
  *          MOVE-CORRESPONDING lt_ordproducts TO gt_results.
            MOVE-CORRESPONDING lt_ordproducts TO gs_result.   " TAKE OTHER TABLE FIELDS TOO
  *          APPEND gt_results.
            APPEND gs_result TO gt_results.                   " APPEND ROW TO RESULTS TABLE
          ENDLOOP.
  
        ENDLOOP.
  
  * ____________________________________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @lt_master_clients
          FROM ZCLIENTS
          WHERE (gv_where_cl).
        SORT lt_master_clients BY CLIENT_ID.
        APPEND LINES OF lt_master_clients TO gt_master_clients.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY,PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @lt_master_products
          FROM ZPRODUCTS
          WHERE (gv_where_pr).
        SORT lt_master_products BY PROD_ID.
        APPEND LINES OF lt_master_products TO gt_master_products.
  
    ENDCASE.
  ENDFORM.
  
  " Subroutine that retrieves the data from the database tables
  " both non-dynamic and dynamic conditions approaches using TYPE as global variables
  " and intermediate Line variables gs_result, ls_corder, ls_ordproduct.
  FORM get_data_line.
  *___________________________________________________________________________________
  * TYPES DECLARATION
    TYPES: BEGIN OF ty_corder,
             ORDER_ID         LIKE zcorders-ORDER_ID,
             PAYMENT_METHOD   LIKE zcorders-PAYMENT_METHOD,
             TOTAL            LIKE zcorders-TOTAL,
             WAERS            LIKE zcorders-WAERS,
             ORDER_DATE       LIKE zcorders-ORDER_DATE,
             ORDER_TIME       LIKE zcorders-ORDER_TIME,
             ORDER_CLIENT     LIKE zcorders-ORDER_CLIENT,
           END OF ty_corder.
    TYPES: tt_corders TYPE TABLE OF ty_corder.
  
    TYPES: BEGIN OF ty_ordproduct,
             ORDER_ID         LIKE zordproducts-ORDER_ID,
             PROD_ID          LIKE zordproducts-PROD_ID,
             PROD_QUANTITY    LIKE zordproducts-PROD_QUANTITY,
             MEINS            LIKE zordproducts-MEINS,
           END OF ty_ordproduct.
    TYPES: tt_ordproducts TYPE TABLE OF ty_ordproduct.
  
    TYPES: BEGIN OF ty_master_client,  " Master Equipment for Clients
            CLIENT_ID          LIKE ZCLIENTS-CLIENT_ID,
            CLIENT_NAME        LIKE ZCLIENTS-CLIENT_NAME,
            CLIENT_LAST_NAME   LIKE ZCLIENTS-CLIENT_LAST_NAME,
            ORDER_COUNT        LIKE ZCLIENTS-ORDER_COUNT,
           END OF ty_master_client.
    TYPES: tt_master_clients TYPE TABLE OF ty_master_client.
  
    TYPES: BEGIN OF ty_master_product, " Master Equipment for Products
            PROD_ID          LIKE ZPRODUCTS-PROD_ID,
            PROD_NAME        LIKE ZPRODUCTS-PROD_NAME,
            PROD_QUANTITY    LIKE ZPRODUCTS-PROD_QUANTITY,
            PROD_PRICE       LIKE ZPRODUCTS-PROD_PRICE,
           END OF ty_master_product.
    TYPES: tt_master_products TYPE TABLE OF ty_master_product.
  
    DATA: lt_corders     TYPE tt_corders,
          ls_corder      TYPE ty_corder,
          lt_ordproducts TYPE tt_ordproducts,
          ls_ordproduct  TYPE ty_ordproduct,
          lt_master_clients  TYPE tt_master_clients,
          ls_master_client   TYPE ty_master_client,
          lt_master_products TYPE tt_master_products,
          ls_master_product  TYPE ty_master_product,
          lv_tabix       TYPE sy-tabix.
  
    DATA: lv_where_co    TYPE string,
          lv_where_op    TYPE string.
    CLEAR: gt_results,gs_result,gt_master_clients,gt_master_products.
  *_____________________________________________________________________________________
  
    CASE gv_approach.
      WHEN 'ND'. " NON DYNAMIC CONDITIONS APPROACH
  * ____________________________________________________________________________________
  * INDIVIDUAL SELECT QUERIES FOR BOTH TABLES
        SELECT ORDER_ID, ORDER_CLIENT, ORDER_DATE, ORDER_TIME,
               TOTAL, PAYMENT_METHOD, WAERS
          INTO CORRESPONDING FIELDS OF TABLE @lt_corders
          FROM ZCORDERS
          WHERE ORDER_ID       IN @s_ORDID AND
                ORDER_CLIENT   IN @s_CLID  AND
                ORDER_DATE     IN @s_ODATE AND
                ORDER_TIME     IN @s_OTIME AND
                TOTAL          IN @s_TOTAL AND
                PAYMENT_METHOD IN @s_PAYM.
        SORT lt_corders BY ORDER_ID.
  
        SELECT ORDER_ID, PROD_ID, PROD_QUANTITY, MEINS
          INTO CORRESPONDING FIELDS OF TABLE @lt_ordproducts
          FROM ZORDPRODUCTS
          WHERE ORDER_ID       IN @s_ORDID AND
                PROD_ID        IN @s_PROID AND
                PROD_QUANTITY  IN @s_PQUAN.
        SORT lt_ordproducts BY ORDER_ID PROD_ID.
  * ____________________________________________________________________________________
  * LOOP THROUGH ONE OF THEM
        LOOP AT lt_corders INTO ls_corder.
          MOVE-CORRESPONDING ls_corder TO gs_result. " TAKE THAT TABLE FIELDS
  
          CLEAR: lv_tabix.
          READ TABLE lt_ordproducts WITH KEY ORDER_ID = ls_corder-ORDER_ID
            INTO ls_ordproduct
            TRANSPORTING NO FIELDS                    " BINARY SEARCH OVER THE OTHER
            BINARY SEARCH.
          IF sy-subrc = 0.                            " MATCH -> KEEP INDEX
            lv_tabix = sy-tabix.
          ELSE.                                       " NO RESULT:
            IF gv_join = 'O'.                         " IF OUTER OPTION IS ENABLED
              APPEND gs_result TO gt_results.         " APPEND THE ROW AS IT IS
            ENDIF.
            CLEAR gs_result.
            CONTINUE.                                 " LEAVE ITERATION
          ENDIF.
  
  * ____________________________________________________________________________________
  * LOOP THROUGH THE OTHER WITH STORED INDEX AND MATCHING FIELD
          LOOP AT lt_ordproducts FROM lv_tabix
            INTO ls_ordproduct
            WHERE ORDER_ID = gs_result-ORDER_ID.
  
            MOVE-CORRESPONDING ls_ordproduct TO gs_result.    " TAKE OTHER TABLE FIELDS TOO
            APPEND gs_result TO gt_results.                   " APPEND ROW TO RESULTS TABLE
            CLEAR gs_result.
          ENDLOOP.
  
        ENDLOOP.
  
  * ____________________________________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_clients
          FROM ZCLIENTS
          WHERE CLIENT_NAME      IN @s_CNAME  AND
                CLIENT_LAST_NAME IN @s_CLNAME AND
                ORDER_COUNT      IN @s_OCOUNT.
        SORT gt_master_clients BY CLIENT_ID.
        APPEND LINES OF lt_master_clients TO gt_master_clients.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY, PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_products
          FROM ZPRODUCTS
          WHERE PROD_NAME     IN @s_PNAME  AND
                PROD_QUANTITY IN @s_PSTOCK AND
                PROD_PRICE    IN @s_PPRICE.
        SORT gt_master_products BY PROD_ID.
        APPEND LINES OF lt_master_products TO gt_master_products.
  
      WHEN 'DY'.
        PERFORM dynamic_conditions_indv CHANGING lv_where_co lv_where_op.
  * ____________________________________________________________________________________
  * INDIVIDUAL SELECT QUERIES FOR BOTH TABLES
        SELECT ORDER_ID, ORDER_CLIENT, ORDER_DATE, ORDER_TIME,
               TOTAL, PAYMENT_METHOD, WAERS
          INTO CORRESPONDING FIELDS OF TABLE @lt_corders
          FROM ZCORDERS
          WHERE (lv_where_co).
        SORT lt_corders BY ORDER_ID.
  
        SELECT ORDER_ID, PROD_ID, PROD_QUANTITY, MEINS
          INTO CORRESPONDING FIELDS OF TABLE @lt_ordproducts
          FROM ZORDPRODUCTS
          WHERE (lv_where_op).
        SORT lt_ordproducts BY ORDER_ID PROD_ID.
  * ____________________________________________________________________________________
  * LOOP THROUGH ONE OF THEM
        LOOP AT lt_corders INTO ls_corder.
          MOVE-CORRESPONDING ls_corder TO gs_result. " TAKE THAT TABLE FIELDS
  
          CLEAR: lv_tabix.
          READ TABLE lt_ordproducts WITH KEY ORDER_ID = ls_corder-ORDER_ID
            INTO ls_ordproduct
            TRANSPORTING NO FIELDS                    " BINARY SEARCH OVER THE OTHER
            BINARY SEARCH.
          IF sy-subrc = 0.                            " MATCH -> KEEP INDEX
            lv_tabix = sy-tabix.
          ELSE.                                       " NO RESULT:
            IF gv_join = 'O'.                         " IF OUTER OPTION IS ENABLED
              APPEND gs_result TO gt_results.         " APPEND THE ROW AS IT IS
            ENDIF.
            CLEAR gs_result.
            CONTINUE.                                 " LEAVE ITERATION
          ENDIF.
  
  * ____________________________________________________________________________________
  * LOOP THROUGH THE OTHER WITH STORED INDEX AND MATCHING FIELD
          LOOP AT lt_ordproducts FROM lv_tabix
            INTO ls_ordproduct
            WHERE ORDER_ID = gs_result-ORDER_ID.
  
            MOVE-CORRESPONDING ls_ordproduct TO gs_result.   " TAKE OTHER TABLE FIELDS TOO
            APPEND gs_result TO gt_results.                  " APPEND ROW TO RESULTS TABLE
          ENDLOOP.
  
        ENDLOOP.
  
  * ____________________________________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @lt_master_clients
          FROM ZCLIENTS
          WHERE (gv_where_cl).
        SORT lt_master_clients BY CLIENT_ID.
        APPEND LINES OF lt_master_clients TO gt_master_clients.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY,PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @lt_master_products
          FROM ZPRODUCTS
          WHERE (gv_where_pr).
        SORT lt_master_products BY PROD_ID.
        APPEND LINES OF lt_master_products TO gt_master_products.
  
    ENDCASE.
  ENDFORM.
  
  " Subroutine that retrieves the data from the database tables
  " both non-dynamic and dynamic conditions approaches using <FIELD SYMBOLS>
  FORM get_data_fsym.
  *___________________________________________________________________________________
  * TYPES DECLARATION
    TYPES: BEGIN OF ty_corder,
             ORDER_ID         LIKE zcorders-ORDER_ID,
             PAYMENT_METHOD   LIKE zcorders-PAYMENT_METHOD,
             TOTAL            LIKE zcorders-TOTAL,
             WAERS            LIKE zcorders-WAERS,
             ORDER_DATE       LIKE zcorders-ORDER_DATE,
             ORDER_TIME       LIKE zcorders-ORDER_TIME,
             ORDER_CLIENT     LIKE zcorders-ORDER_CLIENT,
           END OF ty_corder.
    TYPES: tt_corders TYPE TABLE OF ty_corder.
  
    TYPES: BEGIN OF ty_ordproduct,
             ORDER_ID         LIKE zordproducts-ORDER_ID,
             PROD_ID          LIKE zordproducts-PROD_ID,
             PROD_QUANTITY    LIKE zordproducts-PROD_QUANTITY,
             MEINS            LIKE zordproducts-MEINS,
           END OF ty_ordproduct.
    TYPES: tt_ordproducts TYPE TABLE OF ty_ordproduct.
  
    TYPES: BEGIN OF ty_master_client,  " Master Equipment for Clients
            CLIENT_ID          LIKE ZCLIENTS-CLIENT_ID,
            CLIENT_NAME        LIKE ZCLIENTS-CLIENT_NAME,
            CLIENT_LAST_NAME   LIKE ZCLIENTS-CLIENT_LAST_NAME,
            ORDER_COUNT        LIKE ZCLIENTS-ORDER_COUNT,
           END OF ty_master_client.
    TYPES: tt_master_clients TYPE TABLE OF ty_master_client.
  
    TYPES: BEGIN OF ty_master_product, " Master Equipment for Products
            PROD_ID          LIKE ZPRODUCTS-PROD_ID,
            PROD_NAME        LIKE ZPRODUCTS-PROD_NAME,
            PROD_QUANTITY    LIKE ZPRODUCTS-PROD_QUANTITY,
            PROD_PRICE       LIKE ZPRODUCTS-PROD_PRICE,
           END OF ty_master_product.
    TYPES: tt_master_products TYPE TABLE OF ty_master_product.
  
    DATA: lt_corders     TYPE tt_corders,
          ls_corder      TYPE ty_corder,
          lt_ordproducts TYPE tt_ordproducts,
          ls_ordproduct  TYPE ty_ordproduct,
          lt_master_clients  TYPE tt_master_clients,
          ls_master_client   TYPE ty_master_client,
          lt_master_products TYPE tt_master_products,
          ls_master_product  TYPE ty_master_product,
          lv_tabix       TYPE sy-tabix.
  
    DATA: lv_where_co    TYPE string,
          lv_where_op    TYPE string.
  
    FIELD-SYMBOLS: <FS_CORDER>     STRUCTURE ls_corder DEFAULT ls_corder,
                   <FS_ORDPRODUCT> TYPE ty_ordproduct.
  
    CLEAR: gt_results,gs_result,gt_master_clients,gt_master_products.
  *_____________________________________________________________________________________
  
    CASE gv_approach.
      WHEN 'ND'. " NON DYNAMIC CONDITIONS APPROACH
  * ____________________________________________________________________________________
  * INDIVIDUAL SELECT QUERIES FOR BOTH TABLES
        SELECT ORDER_ID, ORDER_CLIENT, ORDER_DATE, ORDER_TIME,
               TOTAL, PAYMENT_METHOD, WAERS
          INTO CORRESPONDING FIELDS OF TABLE @lt_corders
          FROM ZCORDERS
          WHERE ORDER_ID       IN @s_ORDID AND
                ORDER_CLIENT   IN @s_CLID  AND
                ORDER_DATE     IN @s_ODATE AND
                ORDER_TIME     IN @s_OTIME AND
                TOTAL          IN @s_TOTAL AND
                PAYMENT_METHOD IN @s_PAYM.
        SORT lt_corders BY ORDER_ID.
  
        SELECT ORDER_ID, PROD_ID, PROD_QUANTITY, MEINS
          INTO CORRESPONDING FIELDS OF TABLE @lt_ordproducts
          FROM ZORDPRODUCTS
          WHERE ORDER_ID       IN @s_ORDID AND
                PROD_ID        IN @s_PROID AND
                PROD_QUANTITY  IN @s_PQUAN.
        SORT lt_ordproducts BY ORDER_ID PROD_ID.
  * ____________________________________________________________________________________
  * LOOP THROUGH ONE OF THEM
        LOOP AT lt_corders ASSIGNING <FS_CORDER>.
          MOVE-CORRESPONDING <FS_CORDER> TO gs_result. " TAKE THAT TABLE FIELDS
  
          CLEAR: lv_tabix.
          READ TABLE lt_ordproducts WITH KEY ORDER_ID = <FS_CORDER>-ORDER_ID
            ASSIGNING <FS_ORDPRODUCT>                 " BINARY SEARCH OVER THE OTHER
            BINARY SEARCH.
          IF sy-subrc = 0.                            " MATCH -> KEEP INDEX
            lv_tabix = sy-tabix.
          ELSE.                                       " NO RESULT:
            IF gv_join = 'O'.                         " IF OUTER OPTION IS ENABLED
              APPEND gs_result TO gt_results.         " APPEND THE ROW AS IT IS
            ENDIF.
            CLEAR gs_result.
            CONTINUE.                                 " LEAVE ITERATION
          ENDIF.
  
  * ____________________________________________________________________________________
  * LOOP THROUGH THE OTHER WITH STORED INDEX AND MATCHING FIELD
          LOOP AT lt_ordproducts FROM lv_tabix
            ASSIGNING <FS_ORDPRODUCT>
            WHERE ORDER_ID = <FS_CORDER>-ORDER_ID.
  
            MOVE-CORRESPONDING <FS_ORDPRODUCT> TO gs_result. " TAKE OTHER TABLE FIELDS TOO
            APPEND gs_result TO gt_results.                  " APPEND ROW TO RESULTS TABLE
            CLEAR gs_result.
          ENDLOOP.
  
        ENDLOOP.
  
  * ____________________________________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_clients
          FROM ZCLIENTS
          WHERE CLIENT_NAME      IN @s_CNAME  AND
                CLIENT_LAST_NAME IN @s_CLNAME AND
                ORDER_COUNT      IN @s_OCOUNT.
        SORT gt_master_clients BY CLIENT_ID.
        APPEND LINES OF lt_master_clients TO gt_master_clients.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY, PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_products
          FROM ZPRODUCTS
          WHERE PROD_NAME     IN @s_PNAME  AND
                PROD_QUANTITY IN @s_PSTOCK AND
                PROD_PRICE    IN @s_PPRICE.
        SORT gt_master_products BY PROD_ID.
        APPEND LINES OF lt_master_products TO gt_master_products.
  
      WHEN 'DY'.
        PERFORM dynamic_conditions_indv CHANGING lv_where_co lv_where_op.
  * ____________________________________________________________________________________
  * INDIVIDUAL SELECT QUERIES FOR BOTH TABLES
        SELECT ORDER_ID, ORDER_CLIENT, ORDER_DATE, ORDER_TIME,
               TOTAL, PAYMENT_METHOD, WAERS
          INTO CORRESPONDING FIELDS OF TABLE @lt_corders
          FROM ZCORDERS
          WHERE (lv_where_co).
        SORT lt_corders BY ORDER_ID.
  
        SELECT ORDER_ID, PROD_ID, PROD_QUANTITY, MEINS
          INTO CORRESPONDING FIELDS OF TABLE @lt_ordproducts
          FROM ZORDPRODUCTS
          WHERE (lv_where_op).
        SORT lt_ordproducts BY ORDER_ID PROD_ID.
  * ____________________________________________________________________________________
  * LOOP THROUGH ONE OF THEM
        LOOP AT lt_corders ASSIGNING <FS_CORDER>.
          MOVE-CORRESPONDING <FS_CORDER> TO gs_result. " TAKE THAT TABLE FIELDS
  
          CLEAR: lv_tabix.
          READ TABLE lt_ordproducts WITH KEY ORDER_ID = <FS_CORDER>-ORDER_ID
            ASSIGNING <FS_ORDPRODUCT>                 " BINARY SEARCH OVER THE OTHER
            BINARY SEARCH.
          IF sy-subrc = 0.                            " MATCH -> KEEP INDEX
            lv_tabix = sy-tabix.
          ELSE.                                       " NO RESULT:
            IF gv_join = 'O'.                         " IF OUTER OPTION IS ENABLED
              APPEND gs_result TO gt_results.         " APPEND THE ROW AS IT IS
            ENDIF.
            CLEAR gs_result.
            CONTINUE.                                 " LEAVE ITERATION
          ENDIF.
  
  * ____________________________________________________________________________________
  * LOOP THROUGH THE OTHER WITH STORED INDEX AND MATCHING FIELD
          LOOP AT lt_ordproducts FROM lv_tabix
            ASSIGNING <FS_ORDPRODUCT>
            WHERE ORDER_ID = <FS_CORDER>-ORDER_ID.
  
            MOVE-CORRESPONDING <FS_ORDPRODUCT> TO gs_result. " TAKE OTHER TABLE FIELDS TOO
            APPEND gs_result TO gt_results.                  " APPEND ROW TO RESULTS TABLE
          ENDLOOP.
  
        ENDLOOP.
  
  * ____________________________________________________________________________________
        " Retrieve Master Data from ZCLIENTS
        SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME, ORDER_COUNT
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_clients
          FROM ZCLIENTS
          WHERE (gv_where_cl).
        SORT gt_master_clients BY CLIENT_ID.
        APPEND LINES OF lt_master_clients TO gt_master_clients.
  
        " Retrieve Master Data from ZPRODUCTS
        SELECT PROD_ID, PROD_NAME, PROD_QUANTITY,PROD_PRICE
          INTO CORRESPONDING FIELDS OF TABLE @gt_master_products
          FROM ZPRODUCTS
          WHERE (gv_where_pr).
        SORT gt_master_products BY PROD_ID.
        APPEND LINES OF lt_master_products TO gt_master_products.
  
    ENDCASE.
  ENDFORM.
  
  " Subroutine that calcules the WHERE conditions dynamically
  FORM dynamic_conditions_indv CHANGING cv_where_co TYPE string
                                        cv_where_op TYPE string.
    cv_where_co = ' '.
    cv_where_op = ' '.
    gv_where_cl = ' '.
    gv_where_pr = ' '.
  
    IF s_ORDID IS NOT INITIAL.
      IF cv_where_co = ' '.
        CONCATENATE cv_where_co 'ORDER_ID IN @s_ORDID ' INTO cv_where_co SEPARATED BY space.
      ELSE.
        CONCATENATE cv_where_co 'AND ORDER_ID IN @s_ORDID ' INTO cv_where_co SEPARATED BY space.
      ENDIF.
      IF cv_where_op = ' '.
        CONCATENATE cv_where_op 'ORDER_ID IN @s_ORDID ' INTO cv_where_op SEPARATED BY space.
      ELSE.
        CONCATENATE cv_where_op 'AND ORDER_ID IN @s_ORDID ' INTO cv_where_op SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_CLID IS NOT INITIAL.
      IF cv_where_co = ' '.
        CONCATENATE cv_where_co 'ORDER_CLIENT IN @s_CLID  ' INTO cv_where_co SEPARATED BY space.
      ELSE.
        CONCATENATE cv_where_co 'AND ORDER_CLIENT IN @s_CLID  ' INTO cv_where_co SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_CNAME IS NOT INITIAL.
      IF gv_where_cl = ' '.
        CONCATENATE gv_where_cl 'CLIENT_NAME IN @s_CNAME ' INTO gv_where_cl SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_cl 'AND CLIENT_NAME IN @s_CNAME ' INTO gv_where_cl SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_CLNAME IS NOT INITIAL.
      IF gv_where_cl = ' '.
        CONCATENATE gv_where_cl 'CLIENT_LAST_NAME IN @s_CLNAME ' INTO gv_where_cl SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_cl 'AND CLIENT_LAST_NAME IN @s_CLNAME ' INTO gv_where_cl SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_OCOUNT IS NOT INITIAL.
      IF gv_where_cl = ' '.
        CONCATENATE gv_where_cl 'ORDER_COUNT IN @s_OCOUNT ' INTO gv_where_cl SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_cl 'ORDER_COUNT IN @s_OCOUNT ' INTO gv_where_cl SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_ODATE IS NOT INITIAL.
      IF cv_where_co = ' '.
        CONCATENATE cv_where_co 'ORDER_DATE IN @s_ODATE ' INTO cv_where_co SEPARATED BY space.
      ELSE.
        CONCATENATE cv_where_co 'AND ORDER_DATE IN @s_ODATE ' INTO cv_where_co SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_OTIME IS NOT INITIAL.
      IF cv_where_co = ' '.
        CONCATENATE cv_where_co 'ORDER_TIME IN @s_OTIME ' INTO cv_where_co SEPARATED BY space.
      ELSE.
        CONCATENATE cv_where_co 'AND ORDER_TIME IN @s_OTIME ' INTO cv_where_co SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_TOTAL IS NOT INITIAL.
      IF cv_where_co = ' '.
        CONCATENATE cv_where_co 'TOTAL IN @s_TOTAL ' INTO cv_where_co SEPARATED BY space.
      ELSE.
        CONCATENATE cv_where_co 'AND TOTAL IN @s_TOTAL ' INTO cv_where_co SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PAYM IS NOT INITIAL.
      IF cv_where_co = ' '.
        CONCATENATE cv_where_co 'PAYMENT_METHOD IN @s_PAYM ' INTO cv_where_co SEPARATED BY space.
      ELSE.
        CONCATENATE cv_where_co 'AND PAYMENT_METHOD IN @s_PAYM ' INTO cv_where_co SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PROID IS NOT INITIAL.
      IF cv_where_op = ' '.
        CONCATENATE cv_where_op 'PROD_ID IN @s_PROID ' INTO cv_where_op SEPARATED BY space.
      ELSE.
        CONCATENATE cv_where_op 'AND PROD_ID IN @s_PROID ' INTO cv_where_op SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PNAME IS NOT INITIAL.
      IF gv_where_pr = ' '.
        CONCATENATE gv_where_pr 'PROD_NAME IN @s_PNAME ' INTO gv_where_pr SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_pr 'AND PROD_NAME IN @s_PNAME ' INTO gv_where_pr SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PPRICE IS NOT INITIAL.
      IF gv_where_pr = ' '.
        CONCATENATE gv_where_pr 'PROD_PRICE IN @s_PPRICE ' INTO gv_where_pr SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_pr 'AND PROD_PRICE IN @s_PPRICE ' INTO gv_where_pr SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PSTOCK IS NOT INITIAL.
      IF gv_where_pr = ' '.
        CONCATENATE gv_where_pr 'PROD_QUANTITY IN @s_PSTOCK ' INTO gv_where_pr SEPARATED BY space.
      ELSE.
        CONCATENATE gv_where_pr 'AND PROD_QUANTITY IN @s_PSTOCK ' INTO gv_where_pr SEPARATED BY space.
      ENDIF.
    ENDIF.
  
    IF s_PQUAN IS NOT INITIAL.
      IF cv_where_op = ' '.
        CONCATENATE cv_where_op 'PROD_QUANTITY IN @s_PQUAN ' INTO cv_where_op SEPARATED BY space.
      ELSE.
        CONCATENATE cv_where_op 'AND PROD_QUANTITY IN @s_PQUAN ' INTO cv_where_op SEPARATED BY space.
      ENDIF.
    ENDIF.
  ENDFORM.
  
  " Subroutine that is called from outside and is in charge of the calls to retrieve data from DB,
  " if any extra search condition was chosen in Selection-screen.
  " (NOTE: The READ TABLE sentences of make_data dont extend the variables approach )
  FORM search_order_list_ext.
    DATA: lv_client_mlines  TYPE i,
          lv_product_mlines TYPE i.
  
    CASE gv_variables.
      WHEN 'DA'.
        IF gv_join = 'I'.
          PERFORM search_order_list.
        ELSE.
          PERFORM get_data_outer.
  
          lv_client_mlines  = LINES( gt_master_clients ).
          lv_product_mlines = LINES( gt_master_products ).
  
          IF lv_client_mlines  > 0 AND
             lv_product_mlines > 0.
            PERFORM custom_colors.
            PERFORM make_data.
          ENDIF.
        ENDIF.
  
      WHEN 'TY'.
        PERFORM get_data_type.
  
        lv_client_mlines  = LINES( gt_master_clients ).
        lv_product_mlines = LINES( gt_master_products ).
  
        IF lv_client_mlines  > 0 AND
           lv_product_mlines > 0.
          PERFORM custom_colors.
          PERFORM make_data.
        ENDIF.
  
      WHEN 'LI'.
        PERFORM get_data_line.
  
        lv_client_mlines  = LINES( gt_master_clients ).
        lv_product_mlines = LINES( gt_master_products ).
  
        IF lv_client_mlines  > 0 AND
           lv_product_mlines > 0.
          PERFORM custom_colors.
          PERFORM make_data.
        ENDIF.
  
      WHEN 'FS'.
        PERFORM get_data_fsym.
  
        lv_client_mlines  = LINES( gt_master_clients ).
        lv_product_mlines = LINES( gt_master_products ).
  
        IF lv_client_mlines  > 0 AND
           lv_product_mlines > 0.
          PERFORM custom_colors.
          PERFORM make_data.
        ENDIF.
  
    ENDCASE.
  ENDFORM.