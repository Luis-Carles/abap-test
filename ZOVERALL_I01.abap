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

"___________________________________________________________
"_________DETAILS DISPLAY VIEW______________________________
"___________________________________________________________

MODULE user_command_900 INPUT.
  CLEAR gv_code.
  gv_code = ok_code.

  CASE gv_code.
    WHEN 'ZREFRESH'.
      PERFORM refresh_details.

  ENDCASE.
ENDMODULE.

MODULE exit_command_900 INPUT.
  DATA: lv_det_answer(1).

  CLEAR gv_code.
  gv_code = ok_code.
  CLEAR ok_code.

  CASE gv_code.
    WHEN 'BACK' OR 'CANCEL'.
      PERFORM clearing_details.
      LEAVE TO SCREEN 100.

    WHEN 'EXIT'.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TEXT_QUESTION  = 'Do you want to exit?'
        TEXT_BUTTON_1  = 'Yes'
        TEXT_BUTTON_2  = 'No'
      IMPORTING
        ANSWER         = lv_det_answer
      EXCEPTIONS
        TEXT_NOT_FOUND = 1
        OTHERS         = 2.

      IF lv_det_answer = '1'.
        PERFORM clearing.
        PERFORM clearing_details.
        LEAVE PROGRAM.
      ELSEIF lv_det_answer = '2' OR lv_det_answer = 'A'.
        RETURN.
      ENDIF.

  ENDCASE.
ENDMODULE.