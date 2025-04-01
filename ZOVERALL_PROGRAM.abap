*&---------------------------------------------------------------------*
*& Report  ZOVERALL_PROGRAM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZOVERALL_PROGRAM.

" ALV class import
INCLUDE <CL_ALV_CONTROL>.

" DB. Tables, global structures, internal tables import
INCLUDE ZOVERALL_TOP.

" Classes for Event Handling
INCLUDE ZOVERALL_CLS.

" Macros Import for ALV GRID
INCLUDE ZOVERALL_MAC.

" Soubroutines import
INCLUDE ZOVERALL_F01.

" PBO Modules import
INCLUDE ZOVERALL_O01.

" PAI Modules import
INCLUDE ZOVERALL_I01.

*INITIALIZATION.

*AT SELECTION-SCREEN OUTPUT.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_.
*
*AT SELECTION-SCREEN.


START-OF-SELECTION.
  PERFORM get_data.

END-OF-SELECTION.
  IF gv_filled = abap_true.
    CALL SCREEN 100.
  ELSE.
    MESSAGE 'There is no data to display' TYPE 'E'.
  ENDIF.