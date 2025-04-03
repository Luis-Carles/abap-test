*&---------------------------------------------------------------------*
*&  Include           ZOVERALL_ALV
*&---------------------------------------------------------------------*

"___________________________________________________________
" ALV GRID Variables for Details when double click
DATA: gt_det_fcat_slis TYPE slis_t_fieldcat_alv.

DATA: go_det_grid       TYPE REF TO cl_gui_alv_grid,
      go_det_ccontainer TYPE REF TO cl_gui_custom_container,
      gt_det_fieldcat   TYPE lvc_t_fcat,
      gs_det_fieldcat   TYPE lvc_s_fcat,
      gs_det_layout     TYPE lvc_s_layo,
      gt_det_toolbar_ex TYPE ui_functions,
      gs_det_scroll     TYPE lvc_s_stbl,
      gt_det_colors     TYPE lvc_t_scol,
      gs_det_color      TYPE lvc_s_scol.