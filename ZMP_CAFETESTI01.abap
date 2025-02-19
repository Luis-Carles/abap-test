*&---------------------------------------------------------------------*
*&  Include           ZMP_CAFETEST_I01
*&---------------------------------------------------------------------*

" PAI for screen_100 INITIAL MENU
MODULE user_command_100 INPUT.
  CASE sy-ucomm.
    WHEN 'CLIENT_ACT'.
      CALL SCREEN 200.
    WHEN 'EMPLOYEE_ACT'.
      CALL SCREEN 300.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.

" PAI for screen_200 CLIENT ACTIONS MENU
MODULE user_command_200 INPUT.
  CASE sy-ucomm.
    WHEN 'NEW_CLIENT'.
      CALL SCREEN 210.   "Register -> New Client
    WHEN 'COMEBACK'.
      CALL SCREEN 220.   "LOG IN  -> Comeback
    WHEN 'BACK'.
      CALL SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.

" PAI for screen_210 SIGN IN -> NEW CLIENT
MODULE user_command_210 INPUT.
  CASE sy-ucomm.
    WHEN 'CANCEL'.
      CALL SCREEN 200.
    WHEN 'REGISTER'.
      IF wa_sclient-name IS NOT INITIAL AND wa_sclient-last_name IS NOT INITIAL.
         " -------NEW CLIENT -----------
         lo_client_fan = NEW lcl_client( iv_name = wa_sclient-name
                                         iv_last_name = wa_sclient-last_name
                                         iv_mode = 'new'
                                         iv_client_id = '0' ).

         CALL SCREEN 215. "Welcome Screen.
      ENDIF.
  ENDCASE.
ENDMODULE.

" PAI for screen_215 CLIENT WELCOME
MODULE user_command_215 INPUT.
  CASE sy-ucomm.
    WHEN 'ORDER'.
      CALL SCREEN 230.   "Client Menu --> Ordering
  ENDCASE.
ENDMODULE.

" PAI for screen_300 EMPLOYEE ACTIONS MENU
MODULE user_command_300 INPUT.
  CASE sy-ucomm.
    WHEN 'UPDATE_STOCK'. " -> Update Stock
      CALL SCREEN 310.
    WHEN 'ADD_NEW_PROD'. " -> Add new Product
      CALL SCREEN 320.
    WHEN 'STATS'.        " -> Retrieve Statistics
      CALL SCREEN 330.
    WHEN 'BACK'.
      CALL SCREEN 100.
  ENDCASE.
ENDMODULE.