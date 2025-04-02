*&---------------------------------------------------------------------*
*&  Include           ZOVERALL_MAC
*&---------------------------------------------------------------------*

DEFINE %ADD_COLUMN.
  CALL METHOD go_tree->add_column
    EXPORTING
      name         = &1
      header_text  = &2
      width        = &3.

END-OF-DEFINITION.

DEFINE %ADD_NODE.
  gs_node-NODE_KEY = &1.
  gs_node-RELATKEY = &2.
  gs_node-ISFOLDER = 'X'.
  gs_node-EXPANDER = 'X'.
  "gs_node-TEXT     = &1.
  "CLEAR: gs_node-n_image.
  APPEND gs_node to gt_node_table.

END-OF-DEFINITION.

DEFINE %ADD_ITEM.
  gs_item-NODE_KEY  = &1.
  gs_item-ITEM_NAME = &2.
  gs_item-TEXT      = &3.
  APPEND gs_item to gt_item_table.

END-OF-DEFINITION.