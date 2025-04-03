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

DEFINE %CUSTOM_FIELD.
  gs_det_fieldcat-key        = &1.
  gs_det_fieldcat-reptext    = gs_det_fieldcat-scrtext_l =
  gs_det_fieldcat-scrtext_m  = gs_det_fieldcat-scrtext_s =
  gs_det_fieldcat-coltext    = &2.
  gs_det_fieldcat-col_pos    = &3.
  IF gv_mode = 'M' AND &4 = 'X'.
*    gs_det_fieldcat-edit = 'X'.
  ENDIF.
  IF gv_mode = 'M' AND &5 = 'X'.
*    gs_det_fieldcat-lowercase = 'X'.
  ENDIF.

END-OF-DEFINITION.

DEFINE %CUSTOM_COLOR.
  CLEAR gs_det_color.
  gs_det_color-fname = &1.
  gs_det_color-color-int = &2.
  gs_det_color-color-col = &3.
  gs_det_color-nokeycol  = &4.
  APPEND gs_det_color TO gt_det_colors.

END-OF-DEFINITION.