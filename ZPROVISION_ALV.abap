*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_ALV
*&---------------------------------------------------------------------*

"_________________________________________________
" ALV Objects
DATA: go_dcontainer    TYPE REF TO cl_gui_docking_container,
      go_grid          TYPE REF TO cl_gui_alv_grid.

"_________________________________________________
" LVC Structures
DATA: gs_layout        TYPE lvc_s_layo,   " Layout
      gt_fieldcat      TYPE lvc_t_fcat,   " Field Catalog
      gt_toolbar_ex    TYPE ui_functions, " Excluded Functions
      gt_colors        TYPE lvc_t_scol,   " Color Scheme
      gs_chg_row       TYPE lvc_s_modi,   " Modified Results Row
      gt_sel_rows      TYPE lvc_t_row.    " Selected Results Rows

"__________________________________________________________
" Object Instances
CLASS lcl_handler  DEFINITION DEFERRED.
DATA: go_handler TYPE REF TO lcl_handler. " Changed Data Demon