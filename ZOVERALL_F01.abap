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
    *  CALL METHOD go_tree->add_column
    *    EXPORTING
    *      name = 'HEADTEXT'
    *      header_text = 'Hierarchy'
    *      width    = 30.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'CLIENT_ID'
          header_text      = 'Client ID'
          width    = 5.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'CLIENT_NAME'
          header_text      = 'Client Name'
          width    = 15.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'CLIENT_LNAME'
          header_text      = 'Client Last Name'
          width    = 15.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'ORDER_COUNT'
          header_text      = 'Client Order Counter'
          width    = 3.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'ORDER_ID'
          header_text      = 'Order ID'
          width    = 5.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'ORDER_DATE'
          header_text      = 'Order Date'
          width    = 12.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'ORDER_TIME'
          header_text      = 'Order Time'
          width    = 12.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'TOTAL'
          header_text      = 'Order Total'
          width    = 8.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'WAERS'
          header_text      = 'Currency'
          width    = 5.
    
        CALL METHOD go_tree->add_column
        EXPORTING
          name = 'PAYMENT_M'
          header_text      = 'Payment Method'
          width    = 15.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'PROD_ID'
          header_text      = 'Product ID'
          width    = 5.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'PROD_NAME'
          header_text      = 'Product Name'
          width    = 15.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'PROD_PRICE'
          header_text      = 'Product Price'
          width    = 8.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'PROD_QUAN'
          header_text      = 'Product Ordered Quantity'
          width    = 8.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'PROD_STOCK'
          header_text      = 'Product Current Stock'
          width    = 8.
    
      CALL METHOD go_tree->add_column
        EXPORTING
          name = 'MEINS'
          header_text      = 'Unit'
          width    = 3.
    
    ENDFORM.
    
    " Subroutine that adds one Item per column in each
    " subnode.
    FORM add_items USING
                   iv_node_key TYPE string
                   is_client   LIKE LINE OF gt_master_clients
                   is_product  LIKE LINE OF gt_master_products.
    
      DATA: lt_item_names TYPE TABLE OF string,
            lt_item_texts TYPE TABLE OF string,
            lv_aux        TYPE string,
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
        CLEAR: gs_item, lv_aux.
    
        gs_item-NODE_KEY  = iv_node_key.
    
        READ TABLE lt_item_names INTO lv_aux INDEX lv_x.
        gs_item-ITEM_NAME = lv_aux.
    
        READ TABLE lt_item_texts INTO lv_aux INDEX lv_x.
        gs_item-TEXT      = lv_aux.
    
        APPEND gs_item to gt_item_table.
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
    
        lv_key = ls_client-CLIENT_NAME && ' ' &&
                 ls_client-CLIENT_LAST_NAME.
        gs_node-NODE_KEY = lv_key.
        gs_node-RELATKEY = space.
        gs_node-ISFOLDER = 'X'.
        gs_node-EXPANDER = 'X'.
        "gs_node-TEXT     = lv_key.
        "CLEAR: gs_node-n_image.
        APPEND gs_node to gt_node_table.
    
        " Append Hierarchy Header Information Item
        CLEAR: gs_item.
    
        gs_item-NODE_KEY  = lv_key.
        gs_item-ITEM_NAME = |HIERARCHY|.
        gs_item-TEXT      = lv_key.
        APPEND gs_item to gt_item_table.
    
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
    
            lv_order_key = 'ORDER_' &&
                           gs_corder-ORDER_CLIENT && '_' &&
                           gs_corder-ORDER_ID.
            gs_node-NODE_KEY = lv_order_key.
            gs_node-RELATKEY = lv_key.
            gs_node-ISFOLDER = 'X'.
            gs_node-EXPANDER = 'X'.
            "gs_node-TEXT     = lv_order_key.
            "CLEAR: gs_node-n_image.
            APPEND gs_node to gt_node_table.
    
            " Append Hierarchy Header Information Item
            CLEAR: gs_item.
    
            gs_item-NODE_KEY  = lv_order_key.
            gs_item-ITEM_NAME = |HIERARCHY|.
            gs_item-TEXT      = lv_order_key.
            APPEND gs_item to gt_item_table.
    
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
    
                " If match append that Grandchild Node
                CLEAR: gs_node.
    
                lv_prod_key =  'PRODUCT_' &&
                               gs_ordproduct-ORDER_ID && '_' &&
                               gs_ordproduct-PROD_ID.
                gs_node-NODE_KEY = lv_prod_key.
                gs_node-RELATKEY = lv_order_key.
                gs_node-ISFOLDER = 'X'.
                gs_node-EXPANDER = 'X'.
                "gs_node-TEXT     = lv_prod_key.
                "CLEAR: gs_node-n_image.
                APPEND gs_node to gt_node_table.
    
    *___________STEP 4_____________________________________
       " Look for product info and add an Item per Column
    
                " Look for the rest of Product Info
                READ TABLE gt_master_products
                  INTO DATA(ls_product)
                  WITH KEY PROD_ID = gs_ordproduct-PROD_ID
                  BINARY SEARCH.
    
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
    *  MESSAGE conv string( sy-subrc ) TYPE 'S'.
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
    
      lv_event-EVENTID = cl_gui_column_tree=>EVENTID_EXPAND_NO_CHILDREN.
      lv_event-APPL_EVENT = 'X'.
      APPEND lv_event TO lt_events.
    
      lv_event-EVENTID = cl_gui_column_tree=>EVENTID_BUTTON_CLICK.
      lv_event-APPL_EVENT = 'X'.
      APPEND lv_event TO lt_events.
    
      CALL METHOD go_tree->set_registered_events
        EXPORTING
          events                   = lt_events
        EXCEPTIONS
          cntl_error                = 1
          cntl_system_error         = 2
          illegal_event_combination  = 3.
    
      CREATE OBJECT go_application.
      SET HANDLER go_application->when_node_double_click  FOR go_tree.
      SET HANDLER go_application->when_expand_no_children FOR go_tree.
      SET HANDLER go_application->when_button_click       FOR go_tree.
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
      IF go_handler IS NOT INITIAL.
        CLEAR go_handler.
      ENDIF.
    
      CALL METHOD go_tree->free.
      CLEAR: go_tree.
      CALL METHOD go_ccontainer->free.
      CLEAR: go_ccontainer.
    
      " Clear Global variables
      CLEAR: hierarchy_header, gv_filled.
    
    ENDFORM.