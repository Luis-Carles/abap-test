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

" Tables & Data import
INCLUDE ZMAIN_TOP.

" Classes & Soubroutines (ZMAIN_F01) import
INCLUDE ZMAIN_CLS.

" DB. Tables, global structures, internal tables import
INCLUDE ZMANAGEMENT_TOP.

" AlV custom Control variables import
INCLUDE ZMANAGEMENT_ALV.

" Screen-Selection input parameters import
INCLUDE ZMANAGEMENT_SCR.

" Soubroutines import
INCLUDE ZMANAGEMENT_F01.

" PBO Modules import
INCLUDE ZMANAGEMENT_O01.

" PAI Modules import
INCLUDE ZMANAGEMENT_I01.

INITIALIZATION.

AT SELECTION-SCREEN OUTPUT.

AT SELECTION-SCREEN.
  " View mode Selection radiobutton
  IF r_dis = 'X'.
    gv_mode = 'D'.
  ELSEIF r_mng = 'X'.
    gv_mode = 'M'.
  ENDIF.

  " Search approach Selection radiobutton
  IF r_ndyn = 'X'.
    gv_approach = 'ND'.
  ELSEIF r_mng = 'X'.
    gv_approach = 'DY'.
  ENDIF.

START-OF-SELECTION.
  PERFORM search_order_list.

END-OF-SELECTION.
  CASE gv_mode.
    WHEN 'D'.
      CALL SCREEN 100.
    WHEN 'M'.
      CALL SCREEN 200.
  ENDCASE.