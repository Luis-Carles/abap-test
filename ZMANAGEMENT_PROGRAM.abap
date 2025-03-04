*&---------------------------------------------------------------------*
*& Report  ZMANAGEMENT_PROGRAM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZMANAGEMENT_PROGRAM.

" ALV class import
INCLUDE <CL_ALV_CONTROL>.

" DB. Tables, global structures, internal tables import
INCLUDE ZMANAGEMENT_TOP.

" PBO Modules import
INCLUDE ZMANAGEMENT_O01.

" PAI Modules import
INCLUDE ZMANAGEMENT_I01.

" Screen-Selection input parameters import
INCLUDE ZMANAGEMENT_SCR.

INITIALIZATION.
  p_exec = 'Proceed'.

AT SELECTION-SCREEN OUTPUT.
  PERFORM initialize_listboxs.

AT SELECTION-SCREEN.
  " Table selection input check
  IF p_table IS INITIAL.
    MESSAGE 'Please select a Database table.' TYPE 'E'.
  ENDIF.

  " DISPLAY / MANAGEMENT mode input check
  IF p_mode IS INITIAL.
    MESSAGE 'Please select one access mode' TYPE 'E'.
  ENDIF.

  " Button actions logic
  CASE sy-ucomm.
    WHEN 'START_EXEC'.
         LEAVE TO SCREEN 0.
  ENDCASE.

START-OF-SELECTION.
  CASE p_table.
    WHEN 'ZCLIENTS'.
      PERFORM get_clients.
    WHEN 'ZPRODUCTS'.
      PERFORM get_products.
    WHEN 'ZCORDERS'.
      PERFORM get_corders.
    WHEN 'ZORDPRODUCTS'.
      PERFORM get_ordproducts.
  ENDCASE.

END-OF-SELECTION.
  CASE p_mode.
    WHEN 'DISP'.
      CALL SCREEN 100.
    WHEN 'MNG'.
      CALL SCREEN 200.
  ENDCASE.