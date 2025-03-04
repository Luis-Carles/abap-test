*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_O01
*&---------------------------------------------------------------------*

MODULE status_100 OUTPUT.
  SET PF-STATUS 'S100'.
ENDMODULE.

MODULE alv_write_100 OUTPUT.
  PERFORM alv_write_100.
ENDMODULE.

MODULE status_200 OUTPUT.
  SET PF-STATUS 'S200'.
ENDMODULE.

MODULE alv_write_200 OUTPUT.
  PERFORM alv_write_200.
ENDMODULE.

MODULE retrieve_clients OUTPUT.

  SELECT * FROM zclients INTO TABLE gt_clients.

ENDMODULE.

MODULE create_alv_grid OUTPUT.
*  IF gr_grid IS INITIAL.
*    CREATE OBJECT gr_grid
*      EXPORTING i_parent = cl_gui_container=>screen0.
*
*    CALL METHOD gr_grid->set_table_for_first_display
*      EXPORTING is_layout       = gs_layout
*                i_structure_name = 'ZYOUR_TABLE'
*                "DOING!!
*
*      CHANGING  it_outtab        = gt_data.
*  ENDIF.
ENDMODULE.