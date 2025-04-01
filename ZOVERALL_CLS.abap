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
  
        when_expand_no_children
          FOR EVENT expand_no_children OF cl_gui_column_tree
          IMPORTING node_key,
  
        when_button_click
          FOR EVENT button_click OF cl_gui_column_tree
          IMPORTING node_key item_name.
  
  ENDCLASS.
  
  CLASS lcl_application IMPLEMENTATION.
    METHOD when_node_double_click.
      " DOING!!
    ENDMETHOD.
  
    METHOD when_expand_no_children.
      " DOING!!
    ENDMETHOD.
  
    METHOD when_button_click.
      " DOING!!
    ENDMETHOD.
  
  ENDCLASS.
  
  "_________________________________________________
  " Event Handler
  CLASS lcl_handler DEFINITION.
    PUBLIC SECTION.
  
      METHODS:
         when_data_changed
          FOR EVENT data_changed OF cl_gui_alv_grid
          IMPORTING er_data_changed.
  
  *      when_user_command
  *        FOR EVENT user_command OF cl_gui_alv_grid
  *        IMPORTING e_ucomm,
  *
  *      when_toolbar
  *        FOR EVENT toolbar OF cl_gui_alv_grid
  *        IMPORTING e_object e_interactive.
  ENDCLASS.
  
  CLASS lcl_handler IMPLEMENTATION.
       METHOD when_data_changed.
         DATA: lt_chg_rows TYPE TABLE OF lvc_s_modi,
               ls_chg_row TYPE lvc_s_modi.
  
         LOOP AT er_data_changed->mt_good_cells
           INTO ls_chg_row.
  
  
           IF sy-subrc = 0.
  
           ENDIF.
         ENDLOOP.
  
       ENDMETHOD.
  *    METHOD when_toolbar.
  *      DATA: ls_btn TYPE stb_button.
  *
  *      " Clear existing buttons
  *      CLEAR e_object->mt_toolbar[].
  *
  *      " Refresh Button
  *      CLEAR ls_btn.
  *      ls_btn-function  = 'ZREFRESH'.
  *      ls_btn-icon      = icon_refresh.
  *      ls_btn-quickinfo = 'Refresh Grid'.
  *      ls_btn-butn_type = 0.
  *      APPEND ls_btn TO e_object->mt_toolbar.
  *    ENDMETHOD.
  
  ENDCLASS.