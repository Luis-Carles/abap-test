*&---------------------------------------------------------------------*
*&  Include           ZMP_CAFETEST_O01
*&---------------------------------------------------------------------*

MODULE status_100 OUTPUT.
  SET PF-STATUS 'INITIAL_MENU'.
ENDMODULE.

MODULE status_200 OUTPUT.
  SET PF-STATUS 'CLIENT_MENU'.
ENDMODULE.

MODULE status_210 OUTPUT.
  SET PF-STATUS 'NEW_CLIENT'.
ENDMODULE.

MODULE status_300 OUTPUT.
  SET PF-STATUS 'EMPLOYEE_MENU'.
ENDMODULE.

MODULE control_button OUTPUT.
  " Enable button only if all fields are filled
  IF wa_sclient-client_name IS NOT INITIAL AND
     wa_sclient-client_last_name IS NOT INITIAL.
    gv_button_enabled = '1'.
  ELSE.
    gv_button_enabled = '0'.
  ENDIF.

  LOOP AT SCREEN.
    IF screen-name = 'REGISTER_CLIENT'.
      IF gv_button_enabled = '1'.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.