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
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_200 CLIENT IDENTIFICATION
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
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_210 REGISTER -> NEW CLIENT
MODULE retrieve_input_values_210 INPUT.
  MOVE: wa_sclient-name TO wa_sclient-name,
        wa_sclient-last_name TO wa_sclient-last_name.
ENDMODULE.

MODULE user_command_210 INPUT.
  CASE sy-ucomm.
    WHEN 'CANCEL'.
      CLEAR wa_sclient.
      CALL SCREEN 200.
    WHEN 'REGISTER_CLIENT'.
      IF wa_sclient-name IS NOT INITIAL AND wa_sclient-last_name IS NOT INITIAL.
         " -------NEW CLIENT -----------
         lo_client_fan = NEW lcl_client( iv_name = wa_sclient-name
                                         iv_last_name = wa_sclient-last_name
                                         iv_mode = 'new'
                                         iv_client_id = '0' ).

         MOVE: wa_sclient-client_id TO wa_sclient-client_id.
         CALL SCREEN 215. " TO Welcome Screen.
      ELSE.
        MESSAGE 'Error: name and lastname cannot be null.' TYPE 'E'.
      ENDIF.
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_215 CLIENT WELCOME
MODULE user_command_215 INPUT.
  CASE sy-ucomm.
    WHEN 'ORDER'.
      CALL SCREEN 230.   "Client Menu --> Ordering
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_220 lOG IN -> COMEBACK
MODULE user_command_220 INPUT.
  CASE sy-ucomm.
    WHEN 'CANCEL'.
      CLEAR wa_sclient.
      CALL SCREEN 200.
    WHEN 'REGISTER'.
      IF wa_sclient-client_id IS NOT INITIAL.
         " -------OLD CLIENT -----------
         lo_client_fan = NEW lcl_client( iv_name = wa_sclient-name
                                         iv_last_name = wa_sclient-last_name
                                         iv_mode = 'comeback'
                                         iv_client_id = wa_sclient-client_id ).
         CALL SCREEN 225.
      ELSE.
         MESSAGE 'Error: Client ID cannot be null.' TYPE 'E'.
      ENDIF.
    ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_225 OLD CLIENT WELCOME
MODULE user_command_225 INPUT.
  CASE sy-ucomm.
    WHEN 'ORDER'.
      CALL SCREEN 230.   "Client Menu --> Ordering
  ENDCASE.
  CLEAR sy-ucomm.
ENDMODULE.

" PAI for screen_230 CLIENT ACTIONS MENU
MODULE user_command_230 INPUT.
  CASE sy-ucomm.
    WHEN 'ADD-PRODUCT'.
      LEAVE PROGRAM.
    WHEN 'ONEW_ORDER'.
      LEAVE PROGRAM.
    WHEN 'LOG_OUT'.
      IF lo_client_fan IS NOT INITIAL.
        FREE lo_client_fan.
      ENDIF.
      CLEAR wa_sclient.
      CLEAR wa_lorder_date.

      LEAVE PROGRAM.
  ENDCASE.
  CLEAR sy-ucomm.
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
  CLEAR sy-ucomm.
ENDMODULE.