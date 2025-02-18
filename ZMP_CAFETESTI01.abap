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
      CALL SCREEN 210.   "SIGN IN -> New Client
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
    WHEN 'EXIT'.
      LEAVE PROGRAM.
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
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.