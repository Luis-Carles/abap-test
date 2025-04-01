*&---------------------------------------------------------------------*
*&  Include           ZOVERALL_I01
*&---------------------------------------------------------------------*

"___________________________________________________________
"_________TREE DISPLAY VIEW_________________________________
"___________________________________________________________
MODULE user_command_100 INPUT.
  CLEAR gv_code.
  gv_code = ok_code.

  CASE gv_code.
    WHEN 'ZREFRESH'.
      PERFORM refresh_tree.

  ENDCASE.
ENDMODULE.

MODULE exit_command_100 INPUT.
  DATA: lv_answer(1).

  CLEAR gv_code.
  gv_code = ok_code.
  CLEAR ok_code.

  CASE gv_code.
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
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

      IF lv_answer = '1'.
        PERFORM clearing.
        LEAVE PROGRAM.
      ELSEIF lv_answer = '2' OR lv_answer = 'A'.
        RETURN.
      ENDIF.

  ENDCASE.
ENDMODULE.