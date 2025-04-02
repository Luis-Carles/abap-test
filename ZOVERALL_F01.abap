*&---------------------------------------------------------------------*
*&  Include           ZOVERALL_F01
*&---------------------------------------------------------------------*

"___________________________________________________________
"________________Get & Make Data Subrouytines_______________
"___________________________________________________________

FORM get_data.
*___________STEP 1_____________________________________
   " Retrieve non-Master Data from ZCORDERS
  SELECT ORDER_ID, ORDER_CLIENT, ORDER_DATE, ORDER_TIME,
         TOTAL, PAYMENT_METHOD, WAERS
    INTO CORRESPONDING FIELDS OF TABLE @gt_corders
    FROM  ZCORDERS.
  SORT gt_corders BY ORDER_CLIENT ORDER_ID.

   " Retrieve non-Master Data from ZORDPRODUCTS
  SELECT ORDER_ID, PROD_ID, PROD_QUANTITY, MEINS
    INTO CORRESPONDING FIELDS OF TABLE @gt_ordproducts
    FROM  ZORDPRODUCTS.
  SORT gt_ordproducts BY ORDER_ID PROD_ID.

*___________STEP 2_____________________________________
  " Retrieve Master Data from ZCLIENTS
  SELECT CLIENT_ID, CLIENT_NAME, CLIENT_LAST_NAME,
         ORDER_COUNT
    INTO CORRESPONDING FIELDS OF TABLE @gt_master_clients
    FROM ZCLIENTS.
  SORT gt_master_clients BY CLIENT_ID.

  " Retrieve Master Data from ZPRODUCTS
  SELECT PROD_ID, PROD_NAME, PROD_QUANTITY, PROD_PRICE
    INTO CORRESPONDING FIELDS OF TABLE @gt_master_products
    FROM ZPRODUCTS.
  SORT gt_master_products BY PROD_ID.

*___________CHECK _____________________________________
  IF    LINES( gt_corders )         = 0
    OR  LINES( gt_ordproducts )     = 0
    OR  LINES( gt_master_clients )  = 0
    OR  LINES( gt_master_products ) = 0.

    gv_filled = abap_false.
  ELSE.
    gv_filled = abap_true.
  ENDIF.

ENDFORM.



"___________________________________________________________
"________________SAP Column TREE Subroutines________________
"___________________________________________________________

" Subroutine Create custom cntainer that will hold Column
" Tree. Similar to the docking container for the grid.
FORM create_tree.
  hierarchy_header-heading = 'Hierarchy Header'.
  hierarchy_header-width   = 30.

  IF go_tree IS NOT BOUND.
    CREATE OBJECT go_ccontainer
      EXPORTING
        container_name = 'TREE_CONTAINER'.

    CREATE OBJECT go_tree
      EXPORTING
        parent = go_ccontainer
        node_selection_mode =
          cl_gui_column_tree=>node_sel_mode_single
        item_selection = 'X'
        hierarchy_column_name = 'HIERARCHY'
        hierarchy_header = hierarchy_header.
  ENDIF.

ENDFORM.

" Subroutine that defines the columns for displayable
" data in the Column tree.
FORM define_columns.
  %ADD_COLUMN 'CLIENT_ID' 'Client ID' 5.

  %ADD_COLUMN 'CLIENT_NAME' 'Client Name' 15.

  %ADD_COLUMN 'CLIENT_LNAME' 'Client Last Name' 15.

  %ADD_COLUMN 'ORDER_COUNT' 'Client Order Counter' 3.

  %ADD_COLUMN 'ORDER_ID' 'Order ID' 5.

  %ADD_COLUMN 'ORDER_DATE' 'Order Date' 12.

  %ADD_COLUMN 'ORDER_TIME' 'Order Time' 12.

  %ADD_COLUMN 'TOTAL' 'Order Total' 8.

  %ADD_COLUMN 'WAERS' 'Currency' 5.

  %ADD_COLUMN 'PAYMENT_M' 'Payment Method' 15.

  %ADD_COLUMN 'PROD_ID' 'Product ID' 5.

  %ADD_COLUMN 'PROD_NAME' 'Product Name' 15.

  %ADD_COLUMN 'PROD_PRICE' 'Product Price' 8.

  %ADD_COLUMN 'PROD_QUAN' 'Product Ordered Quantity' 8.

  %ADD_COLUMN 'PROD_STOCK' 'Product Current Stock' 8.

  %ADD_COLUMN 'MEINS' 'Unit' 3.
ENDFORM.

" Subroutine that adds one Item per column in each
" subnode.
FORM add_items USING
               iv_node_key TYPE string
               is_client   LIKE LINE OF gt_master_clients
               is_product  LIKE LINE OF gt_master_products.

  DATA: lt_item_names TYPE TABLE OF string,
        lv_name_aux   TYPE string,
        lt_item_texts TYPE TABLE OF string,
        lv_text_aux   TYPE string,
        lv_x          TYPE i VALUE 0.
.

  lt_item_names = VALUE #(
      ( |HIERARCHY| )    ( |CLIENT_ID| )   ( |CLIENT_NAME| )
      ( |CLIENT_LNAME| ) ( |ORDER_COUNT| ) ( |ORDER_ID| )
      ( |ORDER_DATE| )   ( |ORDER_TIME| )  ( |TOTAL| )
      ( |WAERS| )        ( |PAYMENT_M| )   ( |PROD_ID| )
      ( |PROD_NAME| )    ( |PROD_PRICE| )  ( |PROD_QUAN| )
      ( |PROD_STOCK| )   ( |MEINS| ) ).

  lt_item_texts = VALUE #(
      ( iv_node_key )
      ( conv string( is_client-CLIENT_ID ) )
      ( conv string( is_client-CLIENT_NAME ) )
      ( conv string( is_client-CLIENT_LAST_NAME ) )
      ( conv string( is_client-ORDER_COUNT ) )
      ( conv string( gs_corder-ORDER_ID    ) )
      ( conv string( gs_corder-ORDER_DATE ) )
      ( conv string( gs_corder-ORDER_TIME ) )
      ( conv string( gs_corder-TOTAL      ) )
      ( conv string( gs_corder-WAERS      ) )
      ( conv string( gs_corder-PAYMENT_METHOD ) )
      ( conv string( gs_ordproduct-PROD_ID ) )
      ( conv string( is_product-PROD_NAME ) )
      ( conv string( is_product-PROD_PRICE ) )
      ( conv string( gs_ordproduct-PROD_QUANTITY ) )
      ( conv string( is_product-PROD_QUANTITY ) )
      ( conv string( gs_ordproduct-MEINS ) ) ).

  DO LINES( lt_item_names )  TIMES.
    lv_x = lv_x + 1.
    CLEAR: gs_item, lv_name_aux, lv_text_aux.

    READ TABLE lt_item_names INTO lv_name_aux INDEX lv_x.
    READ TABLE lt_item_texts INTO lv_text_aux INDEX lv_x.

    %ADD_ITEM iv_node_key lv_name_aux lv_text_aux.

  ENDDO.
ENDFORM.

" Subroutine that builds and append the Column
" Tree Nodes and Items
FORM build_node_and_item_tables.
  DATA: lv_key         TYPE string,
        lv_order_key   TYPE string,
        lv_prod_key    TYPE string,
        lv_o_tabix     TYPE sy-tabix,
        lv_p_tabix     TYPE sy-tabix.

  CLEAR: gt_node_table, gt_item_table.

*___________STEP 1_____________________________________
   " Loop through clients I.Table to append Root Nodes

  LOOP AT gt_master_clients INTO DATA(ls_client).

    " Append that Root node
    CLEAR: gs_node.

    lv_key = ls_client-CLIENT_NAME && '_' &&
             ls_client-CLIENT_LAST_NAME.
    %ADD_NODE lv_key space.

    " Append Hierarchy Header Information Item
    CLEAR: gs_item.

    %ADD_ITEM lv_key 'HIERARCHY' lv_key.

*___________STEP 2_____________________________________
   " Loop through orders I.Table to append Child Nodes

    " Look for the first match in gt_corders
    READ TABLE gt_corders INTO gs_corder
      WITH KEY ORDER_CLIENT = ls_client-CLIENT_ID
      BINARY SEARCH.
    IF sy-subrc = 0.
      lv_o_tabix = sy-tabix.

      DO.
        " Look for a match with the ID
        READ TABLE gt_corders INTO gs_corder
          INDEX lv_o_tabix.
        IF sy-subrc <> 0 OR
           gs_corder-ORDER_CLIENT <> ls_client-CLIENT_ID.
          EXIT.
        ENDIF.

        " If match append that Child Node
        CLEAR: gs_node.

        lv_order_key = 'Order_' &&
                       gs_corder-ORDER_ID.
        %ADD_NODE lv_order_key lv_key.

        " Append Hierarchy Header Information Item
        CLEAR: gs_item.

        %ADD_ITEM lv_order_key 'HIERARCHY' lv_order_key.

*___________STEP 3_____________________________________
   " Loop through ordproducts I.Table to append G.Child Nodes

        " Look for the first match in gt_corders
        READ TABLE gt_ordproducts INTO gs_ordproduct
          WITH KEY ORDER_ID = gs_corder-ORDER_ID
          BINARY SEARCH.
        IF sy-subrc = 0.
          lv_p_tabix = sy-tabix.

          DO.
            " Look for a match with the ID
            READ TABLE gt_ordproducts INTO gs_ordproduct
              INDEX lv_p_tabix.
            IF sy-subrc <> 0 OR
               gs_ordproduct-ORDER_ID <> gs_corder-ORDER_ID.
              EXIT.
            ENDIF.

            " Look for the rest of Product Info
            READ TABLE gt_master_products
              INTO DATA(ls_product)
              WITH KEY PROD_ID = gs_ordproduct-PROD_ID
              BINARY SEARCH.

            " If match append that Grandchild Node
            CLEAR: gs_node.

            lv_prod_key =  gs_ordproduct-ORDER_ID && '_' &&
                           ls_product-PROD_NAME.
            %ADD_NODE lv_prod_key lv_order_key.

*___________STEP 4_____________________________________
   " Add an Item per field / Column + Header Info (16)

            " If match append items to the G.Child node
            PERFORM add_items USING lv_prod_key
                                    ls_client
                                    ls_product.

            " Next Product
            lv_p_tabix = lv_p_tabix + 1.
          ENDDO.
        ENDIF.

        " Next Order
        lv_o_tabix = lv_o_tabix + 1.
      ENDDO.
    ENDIF.

  ENDLOOP.

ENDFORM.

" Subroutine that fills the column tree
FORM fill_tree.
  PERFORM define_columns.
  PERFORM build_node_and_item_tables.

  CALL METHOD go_tree->add_nodes_and_items
    EXPORTING
      node_table    = gt_node_table
      item_table    = gt_item_table
      item_table_structure_name =
        'MTREEITM'
    EXCEPTIONS
      failed                         = 1
      OTHERS                         = 2.

ENDFORM.

" Subroutine that displays the built Column Tree.
FORM display_tree.
  CALL METHOD go_tree->expand_root_nodes
    EXPORTING
      expand_subtree = 'X'.

  cl_gui_cfw=>flush( ).
ENDFORM.

" Subroutine Column Tree Events
FORM set_tree_events.
  DATA: lt_events TYPE CNTL_SIMPLE_EVENTS.
  DATA: lv_event  TYPE CNTL_SIMPLE_EVENT.

  lv_event-EVENTID = cl_gui_column_tree=>EVENTID_NODE_DOUBLE_CLICK.
  lv_event-APPL_EVENT = 'X'.
  APPEND lv_event TO lt_events.

*  lv_event-EVENTID = cl_gui_column_tree=>EVENTID_EXPAND_NO_CHILDREN.
*  lv_event-APPL_EVENT = 'X'.
*  APPEND lv_event TO lt_events.
*
*  lv_event-EVENTID = cl_gui_column_tree=>EVENTID_BUTTON_CLICK.
*  lv_event-APPL_EVENT = 'X'.
*  APPEND lv_event TO lt_events.

  CALL METHOD go_tree->set_registered_events
    EXPORTING
      events                   = lt_events
    EXCEPTIONS
      cntl_error                 = 1
      cntl_system_error          = 2
      illegal_event_combination  = 3.

  CREATE OBJECT go_application.
  SET HANDLER go_application->when_node_double_click  FOR go_tree.
*  SET HANDLER go_application->when_expand_no_children FOR go_tree.
*  SET HANDLER go_application->when_button_click       FOR go_tree.
ENDFORM.

" Subroutine that refreshes the Column Tree.
FORM refresh_tree.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.

"Subroutine that is called from outside and is responsible of
" making the calls to the forms in order, to create the tree.
FORM write_tree.
  IF go_tree IS NOT BOUND.
    PERFORM create_tree.
    PERFORM fill_tree.
    PERFORM display_tree.
    PERFORM set_tree_events.

  ELSE.
    PERFORM refresh_tree.
  ENDIF.
ENDFORM.

" Subroutine that clears global variables and liberates
" memory if there wont be any more use.
FORM clearing.
  " Clear internal tables and Line variables.
  CLEAR: gt_corders, gs_corder, gt_ordproducts,
         gs_ordproduct, gs_ordproduct,
         gt_master_clients, gt_master_products,
         gt_node_table, gt_item_table.

  " Clear object Instances
  IF go_application IS NOT INITIAL.
    CLEAR go_application.
  ENDIF.

  CALL METHOD go_tree->free.
  CLEAR: go_tree.
  CALL METHOD go_ccontainer->free.
  CLEAR: go_ccontainer.

  " Clear Global variables
  CLEAR: hierarchy_header, gv_filled.

ENDFORM.

"___________________________________________________________
"________________EVENT HANDLING SUBROUTINES_________________
"___________________________________________________________

" Subroutine that appends a new Details Result Row
FORM fill_result.
  CASE gs_item-ITEM_NAME.
    WHEN 'HIERARCHY'.
      RETURN.

    WHEN 'CLIENT_ID'.
      gs_result-ORDER_CLIENT     = gs_item-TEXT.

    WHEN 'CLIENT_NAME'.
      gs_result-CLIENT_NAME      = gs_item-TEXT.

    WHEN 'CLIENT_LNAME'.
      gs_result-CLIENT_LAST_NAME = gs_item-TEXT.

    WHEN 'ORDER_COUNT'.
      gs_result-ORDER_COUNT      = gs_item-TEXT.

    WHEN 'ORDER_ID'.
      gs_result-ORDER_ID         = gs_item-TEXT.

    WHEN 'ORDER_DATE'.
      gs_result-ORDER_DATE       = gs_item-TEXT.

    WHEN 'ORDER_TIME'.
      gs_result-ORDER_TIME       = gs_item-TEXT.

    WHEN 'TOTAL'.
      gs_result-TOTAL            = gs_item-TEXT.

    WHEN 'WAERS'.
      gs_result-WAERS            = gs_item-TEXT.

    WHEN 'PAYMENT_M'.
      gs_result-PAYMENT_METHOD   = gs_item-TEXT.

    WHEN 'PROD_ID'.
      gs_result-PROD_ID          = gs_item-TEXT.

    WHEN 'PROD_NAME'.
      gs_result-PROD_NAME        = gs_item-TEXT.

    WHEN 'PROD_PRICE'.
      gs_result-PROD_PRICE       = gs_item-TEXT.

    WHEN 'PROD_QUAN'.
      gs_result-PROD_QUANTITY    = gs_item-TEXT.

    WHEN 'PROD_STOCK'.
      gs_result-PROD_STOCK       = gs_item-TEXT.

    WHEN 'MEINS'.
      gs_result-MEINS            = gs_item-TEXT.

    WHEN OTHERS.
      RETURN.
  ENDCASE.

ENDFORM.

" Subroutine that handles the event double click for the Tree
FORM when_double_click.
  DATA: lv_key_parent TYPE string,
        lv_key_itself TYPE string,
        lv_i_count    TYPE i VALUE 0,
        lv_index_now  TYPE sy-tabix.

  CLEAR: gs_node, gs_item.

  CALL METHOD go_tree->get_selected_node
    IMPORTING node_key = gs_node-NODE_KEY.

  IF sy-subrc = 0.
    READ TABLE gt_node_table INTO gs_node
      WITH KEY NODE_KEY = gs_node-NODE_KEY.
    IF sy-subrc = 0.
      SPLIT gs_node-NODE_KEY AT '_'
        INTO lv_key_parent lv_key_itself.
      FIND REGEX '^-?\d+$' IN lv_key_parent.

      IF sy-subrc = 0.
        " PRODUCT ROW
        MESSAGE 'ITEM CLICKED!!' TYPE 'S'.

      ELSEIF lv_key_parent = 'Order'.
        " ORDER-> PRODUCTS ROWS
        LOOP AT gt_item_table INTO gs_item
          WHERE NODE_KEY CP lv_key_itself && '_*'.

          " Keeps the index of currently checked Item
          READ TABLE gt_item_table TRANSPORTING NO FIELDS
            WITH KEY NODE_KEY = gs_item-NODE_KEY
                     TEXT     = gs_item-TEXT.
          lv_index_now = sy-tabix.

          " Add the results row
          PERFORM fill_result.

          " Next Item
          lv_i_count = lv_i_count + 1.

          " After 17 items, there wont be more
          " matching items for this product
          IF lv_i_count = 17.
            " Append Row to gt_results
            IF gs_result-ORDER_COUNT > 5.
              gs_result-REG_STATUS = 'Regular Client'.
            ELSE.
              gs_result-REG_STATUS = 'Sporadic Client'.
            ENDIF.
            APPEND gs_result TO gt_results.
            CLEAR gs_result.

            " Check the next Item
            READ TABLE gt_item_table INTO DATA(ls_item)
              INDEX lv_index_now + 1.
            IF sy-subrc = 0.
              IF ls_item-NODE_KEY
                 CP lv_key_itself && '_*'.

                " Next Item is also a matching Product
                lv_i_count = 0.
              ELSE.
                " Next Item is not a match
                EXIT.
              ENDIF.
            ENDIF.

          ENDIF.
        ENDLOOP.

      ELSE.
        " CLIENT->ORDERS->PRODUCTS ROWS
        MESSAGE 'CLIENT CLICKED!!' TYPE 'S'.

      ENDIF.

      IF gt_results IS INITIAL.
        MESSAGE 'This Node is empty, No details to Display'
          TYPE 'S'.
      ELSE.
        " Display Details Internal Table
        CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
          EXPORTING
            endpos_col  = '60'
            endpos_row  = '20'
            startpos_col = '10'
            startpos_row = '5'
            titletext   = 'Details'
          TABLES
            valuetab    = gt_results.
      ENDIF.
    ENDIF.

  ELSE.
*    CALL METHOD go_tree->get_selected_item
*      IMPORTING node_key = gs_item-NODE_KEY
*                item_name = gs_item-ITEM_NAME.
*    IF sy-subrc = 0.
*      MESSAGE conv string( sy-subrc ) TYPE 'S'.
*    ENDIF.

  ENDIF.
ENDFORM.

" Macro that handles the event button click for the Tree
*FORM when_button_click.
*  CALL METHOD go_tree->get_selected_button
*    RECEIVING button_info = gs_button.
*
*  IF sy-subrc = 0.
*    " DOING!
*  ENDIF.
*ENDFORM.

" Macro that handles the even expand_no_children
*FORM when_expand_no_children.
*    IF sy-subrc = 0.
*    " DOING!
*  ENDIF.
*ENDFORM.

"___________________________________________________________
"________________ALV DETAILS SUBROUTINES____________________
"___________________________________________________________

" Subroutine that creates the custom container for details
FORM create_det_ccontainer.
  CREATE OBJECT go_det_ccontainer
    EXPORTING
      container_name = 'DETAILS_CONTAINER'.

ENDFORM.

" Subroutine that creates the grid for details
FORM create_det_grid.
  CREATE OBJECT go_det_grid
    EXPORTING
      i_parent = go_det_ccontainer.
ENDFORM.

" Subroutine that creates and custom the layout for details
FORM create_det_layout.
  " DOING!!
ENDFORM.

" Subroutine that creates and customize the Fieldcat
FORM create_det_fieldcat.
  " DOING!!
ENDFORM.

FORM display_det_grid.
  "DOING!!
ENDFORM.

" Subroutine that is triggered from PBO Modules and call in
" precise order every alv form necessary display details.
FORM alv_det_write.
  IF go_ccontainer IS NOT BOUND.
    PERFORM create_det_ccontainer.
    PERFORM create_det_grid.
    PERFORM create_det_layout.
    PERFORM create_det_fieldcat.
    PERFORM display_det_grid.
  ENDIF.

ENDFORM.