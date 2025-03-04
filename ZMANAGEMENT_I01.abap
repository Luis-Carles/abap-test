*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_I01
*&---------------------------------------------------------------------*

MODULE user_command_100 INPUT.
  CASE sy-ucomm.
    WHEN 'DELETE'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'UPDATE'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'REFRESH'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'EXIT'.
      " DOING!
      PERFORM refresh_grid.
  ENDCASE.
ENDMODULE.

MODULE user_command_200 INPUT.
  CASE sy-ucomm.
    WHEN 'DELETE'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'UPDATE'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'REFRESH'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'EXIT'.
      " DOING!
      PERFORM refresh_grid.
  ENDCASE.
ENDMODULE.