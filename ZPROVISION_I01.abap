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
      PERFORM add_row.

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
  CLEAR: gv_code, gv_answer.
  gv_code = ok_code.
  CLEAR ok_code.

  CASE gv_code.
    WHEN 'BACK' OR 'CANCEL'.
      PERFORM clearing.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.             " Confirmation Pop-Up Window
      DATA(lv_exit_question) = SWITCH string( gv_langu
                                  WHEN 'KR' THEN TEXT-Q01
                                  ELSE TEXT-Q02 ).
      %POP_UP lv_exit_question.

      IF gv_answer = '1'.
        PERFORM clearing.
        LEAVE PROGRAM.
      ELSEIF gv_answer = '2' OR gv_answer = 'A'.
        RETURN.
      ENDIF.

  ENDCASE.
ENDMODULE.