*&---------------------------------------------------------------------*
*&  Include           ZMAIN_SCR
*&---------------------------------------------------------------------*

" Parameters initialization
DATA: gv_flag TYPE abap_bool VALUE abap_false,
      lt_p_products TYPE SORTED TABLE OF ty_product
                    WITH UNIQUE KEY prod_name,
      ls_p_product  TYPE ty_product,
      wa_p_product  TYPE ty_product.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
   PARAMETERS: e_name TYPE zproducts-prod_name,
               e_quan TYPE zproducts-prod_quantity,
               e_price TYPE zproducts-prod_price,
               e_oldp AS CHECKBOX,
               e_pid TYPE zproducts-prod_id,
               e_stats AS CHECKBOX.
SELECTION-SCREEN: END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
  PARAMETERS: p_name TYPE zclients-client_name,
              p_lname TYPE zclients-client_last_name,
              p_oldc AS CHECKBOX,
              p_cid TYPE zclients-client_id.
SELECTION-SCREEN: END OF BLOCK b2.

SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
  PARAMETERS: p_paym TYPE zcorders-payment_method DEFAULT 'Credit Card'.
  SELECT-OPTIONS: s_prod FOR zproducts-prod_name.
  PARAMETERS: p_quan TYPE zproducts-prod_quantity.
  SELECTION-SCREEN PUSHBUTTON /55(15) p_caddp USER-COMMAND add_prod.
SELECTION-SCREEN: END OF BLOCK b3.

"SELECTION-SCREEN: BEGIN OF BLOCK b4 WITH FRAME.
"  PARAMETERS: p_proc TYPE char1.
"SELECTION-SCREEN: END OF BLOCK b4.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN PUSHBUTTON /10(20) p_exec USER-COMMAND start_exec.