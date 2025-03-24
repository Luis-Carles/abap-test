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