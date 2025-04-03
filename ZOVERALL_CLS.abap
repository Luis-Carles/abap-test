*&---------------------------------------------------------------------*
*&  Include           ZOVERALL_CLS
*&---------------------------------------------------------------------*

"_________________________________________________
" Application Class
CLASS lcl_application DEFINITION.
  PUBLIC SECTION.

    METHODS:
      when_node_double_click
        FOR EVENT node_double_click OF cl_gui_column_tree
        IMPORTING node_key,

      when_item_double_click
        FOR EVENT item_double_click OF cl_gui_column_tree
        IMPORTING node_key item_name.

*      when_expand_no_children
*        FOR EVENT expand_no_children OF cl_gui_column_tree
*        IMPORTING node_key,
*
*      when_button_click
*        FOR EVENT button_click OF cl_gui_column_tree
*        IMPORTING node_key item_name.

ENDCLASS.

CLASS lcl_application IMPLEMENTATION.
  METHOD when_node_double_click.
    PERFORM when_double_click USING 'N'.
  ENDMETHOD.

  METHOD when_item_double_click.
    PERFORM when_double_click USING 'I'.
  ENDMETHOD.
*  METHOD when_expand_no_children.
*    PERFORM when_expand_no_children.
*  ENDMETHOD.
*
*  METHOD when_button_click.
*    PERFORM when_button_click.
*  ENDMETHOD.

ENDCLASS.