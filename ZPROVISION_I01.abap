*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_I01
*&---------------------------------------------------------------------*

"____________________________________________________________________
"______________MANAGEMENT VIEWS INPUT MODULES________________________
"____________________________________________________________________
MODULE user_command INPUT.
  CLEAR gv_code.
  gv_code = ok_code.

  CASE gv_code.
    WHEN 'ZREFRESH'.
      PERFORM refresh_grid USING 'X'.

    WHEN 'ZADD'.
      PERFORM insert_row.

      PERFORM refresh_grid USING ''.

    WHEN 'ZDELETE'.
      PERFORM delete_row.

      PERFORM refresh_grid USING 'X'.

    WHEN 'ZSAVE'.
      PERFORM save_changes.

      PERFORM refresh_grid USING 'X'.
  ENDCASE.

ENDMODULE.

MODULE exit_command INPUT.
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
        ANSWER         = gv_answer
      EXCEPTIONS
        TEXT_NOT_FOUND = 1
        OTHERS         = 2.

      IF gv_answer = '1'.
        PERFORM clearing.
        LEAVE PROGRAM.
      ELSEIF gv_answer = '2' OR gv_answer = 'A'.
        RETURN.
      ENDIF.

  ENDCASE.
ENDMODULE.