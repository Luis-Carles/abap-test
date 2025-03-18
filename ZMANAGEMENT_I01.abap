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
    WHEN 'ZREFRESH'.
      PERFORM refresh_grid USING 'X'. " refind = 'X'

  ENDCASE.
ENDMODULE.

MODULE exit_command_100 INPUT.
  DATA: lv_answer(1).

  CLEAR gv_code.
  gv_code = ok_code.
  CLEAR ok_code.

  CASE gv_code.
    WHEN 'BACK' OR 'CANCEL'.
      PERFORM clearing.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TEXT_QUESTION  = 'Do you want to exit?'
        TEXT_BUTTON_1  = 'Yes'
        TEXT_BUTTON_2  = 'No'
      IMPORTING
        ANSWER         = lv_answer
      EXCEPTIONS
        TEXT_NOT_FOUND = 1
        OTHERS         = 2.

      CHECK lv_answer = 1.
      PERFORM clearing.
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
    WHEN 'ZREFRESH'.
      PERFORM refresh_grid USING ''.

    WHEN 'ZADD'.
      PERFORM insert_row.

      PERFORM refresh_grid USING ''.

    WHEN 'ZDELETE'.
      PERFORM delete_row.

      PERFORM refresh_grid USING ''.

    WHEN 'ZSAVE'.
      PERFORM save_changes.

      PERFORM refresh_grid USING ''.
  ENDCASE.

ENDMODULE.

MODULE exit_command_200 INPUT.
  CLEAR gv_code.
  gv_code = ok_code.
  CLEAR ok_code.

  CASE gv_code.
    WHEN 'BACK' OR 'CANCEL'.
      PERFORM clearing.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      PERFORM clearing.
      LEAVE PROGRAM.

  ENDCASE.
ENDMODULE.