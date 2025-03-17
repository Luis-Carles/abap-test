*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_I01
*&---------------------------------------------------------------------*

"____________________________________________________________________
"_________DISPLAY VIEW____________________________________________
"____________________________________________________________________
MODULE user_command_100 INPUT.
  CLEAR gv_code.
  gv_code = ok_code.

  CASE gv_code.
    WHEN 'DELETE'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'UPDATE'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'REFRESH'.
      " DOING!
      PERFORM refresh_grid.

  ENDCASE.
ENDMODULE.

MODULE exit_command_100 INPUT.
  CLEAR gv_code.
  gv_code = ok_code.
  CLEAR ok_code.

  CASE gv_code.
    WHEN 'BACK' OR 'CANCEL'.
      " DOING!!
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      " DOING!
      LEAVE PROGRAM.

  ENDCASE.
ENDMODULE.

"____________________________________________________________________
"_________MANAGEMENT VIEW____________________________________________
"____________________________________________________________________
MODULE user_command_200 INPUT.
  CLEAR gv_code.
  gv_code = ok_code.

  CASE gv_code.
    WHEN 'DELETE'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'UPDATE'.
      " DOING!
      PERFORM refresh_grid.
    WHEN 'REFRESH'.
      " DOING!
      PERFORM refresh_grid.

  ENDCASE.
ENDMODULE.

MODULE exit_command_200 INPUT.
  CLEAR gv_code.
  gv_code = ok_code.
  CLEAR ok_code.

  CASE gv_code.
    WHEN 'BACK' OR 'CANCEL'.
      " DOING!!
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      " DOING!
      LEAVE PROGRAM.

  ENDCASE.
ENDMODULE.