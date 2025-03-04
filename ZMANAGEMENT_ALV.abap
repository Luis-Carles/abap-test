*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_ALV
*&---------------------------------------------------------------------*

" Container and grid
DATA: go_dcon  TYPE REF TO cl_gui_docking_container,
      go_grid  TYPE REF TO cl_gui_alv_grid,
      gv_extension    TYPE I VALUE 2000.

" Function ALV custom layout and fieldcat
DATA : gs_layout    TYPE slis_layout_alv,
       gs_fieldcat  TYPE slis_fieldcat_alv.

" GRID (ALV) custom layyout and fieldcat
DATA : gs_lvc_layout  TYPE lvc_s_layo,
       gs_lvc_fcat    TYPE lvc_s_fcat,
       gt_lvc_fcat    TYPE lvc_t_fcat,
       gt_lvc_sort    TYPE lvc_t_sort,
       gs_lvc_sort       TYPE lvc_s_sort,
       gs_alv_cellstyle   TYPE lvc_s_styl,
       gs_alv_cellcol    TYPE lvc_s_scol.