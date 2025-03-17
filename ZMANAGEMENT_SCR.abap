*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-B01.
   SELECT-OPTIONS: s_ORDID  FOR ZCORDERS-ORDER_ID,
                   s_CLID   FOR ZCLIENTS-CLIENT_ID,
                   s_CNAME  FOR ZCLIENTS-CLIENT_NAME,
                   s_CLNAME FOR ZCLIENTS-CLIENT_LAST_NAME,
                   s_OCOUNT FOR ZCLIENTS-ORDER_COUNT,
                   s_ODATE  FOR ZCORDERS-ORDER_DATE,
                   s_OTIME  FOR ZCORDERS-ORDER_TIME,
                   s_TOTAL  FOR ZCORDERS-TOTAL,
                   s_PAYM   FOR ZCORDERS-PAYMENT_METHOD,
                   s_PROID  FOR ZPRODUCTS-PROD_ID,
                   s_PNAME  FOR ZPRODUCTS-PROD_NAME,
                   s_PPRICE FOR ZPRODUCTS-PROD_PRICE,
                   s_PSTOCK FOR ZPRODUCTS-PROD_QUANTITY,
                   s_PQUAN  FOR ZORDPRODUCTS-PROD_QUANTITY.
SELECTION-SCREEN: END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE text-B02.
   PARAMETERS:     r_dis   RADIOBUTTON GROUP grp1 DEFAULT 'X',
                   r_mng   RADIOBUTTON GROUP grp1.
SELECTION-SCREEN: END OF BLOCK b2.

SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE text-B03.
   PARAMETERS:     r_ndyn  RADIOBUTTON GROUP grp2 DEFAULT 'X',
                   r_dyn   RADIOBUTTON GROUP grp2.
SELECTION-SCREEN: END OF BLOCK b3.