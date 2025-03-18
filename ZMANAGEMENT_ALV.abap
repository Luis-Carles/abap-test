*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_ALV
*&---------------------------------------------------------------------*

"_________________________________________________
" ALV Objects
DATA: go_dcontainer    TYPE REF TO cl_gui_docking_container,
      go_grid          TYPE REF TO cl_gui_alv_grid.

"_________________________________________________
" SLIS ALV Structures
DATA: gt_fieldcat_slis TYPE slis_t_fieldcat_alv.

"_________________________________________________
" LVC Structures
DATA: gs_scroll        TYPE lvc_s_stbl,
      gs_layout        TYPE lvc_s_layo,
      gt_fieldcat      TYPE lvc_t_fcat,
      gs_fieldcat      TYPE lvc_s_fcat,
      gt_toolbar_ex    TYPE ui_functions,
      gt_colors        TYPE lvc_t_scol,
      gs_color         TYPE lvc_s_scol.

"_________________________________________________
" Event Handler
*CLASS lcl_handler DEFINITION.
*  PUBLIC SECTION.
*
*    METHODS:
*      when_user_command FOR EVENT user_command OF cl_gui_alv_grid
*        IMPORTING e_ucomm,
*
*      when_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
*        IMPORTING e_object e_interactive.
*ENDCLASS.
*
*CLASS lcl_handler IMPLEMENTATION.
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
*
*      " Insert Button
*      CLEAR ls_btn.
*      ls_btn-function  = 'ZINSERT'.
*      ls_btn-icon      = icon_add_row.
*      ls_btn-quickinfo = 'Add new row'.
*      ls_btn-butn_type = 0.
*      APPEND ls_btn TO e_object->mt_toolbar.
*
*      " Delete Rows Button
*      CLEAR ls_btn.
*      ls_btn-function  = 'ZDELETE'.
*      ls_btn-icon      = icon_delete.
*      ls_btn-quickinfo = 'Delete selected rows'.
*      ls_btn-butn_type = 0.
*      APPEND ls_btn TO e_object->mt_toolbar.
*
*      " Save Button
*      CLEAR ls_btn.
*      ls_toolbar-function  = 'ZSAVE'.
*      ls_toolbar-icon      = icon_save.
*      ls_toolbar-quickinfo = 'Save changes'.
*      ls_toolbar-butn_type = 0.
*      APPEND ls_btn TO e_object->mt_toolbar.
*    ENDMETHOD.
*
*ENDCLASS.
*
*DATA: go_handler TYPE REF TO lcl_handler.