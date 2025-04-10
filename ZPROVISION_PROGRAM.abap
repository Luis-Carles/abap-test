*&---------------------------------------------------------------------*
*& Report  ZPROVISION_PROGRAM
*&
*&---------------------------------------------------------------------*
*& only feasible and functional in S/4 HANA Systems >7.50   !!
*&
*&---------------------------------------------------------------------*
REPORT ZPROVISION_PROGRAM.

" ALV class import
INCLUDE <CL_ALV_CONTROL>.

" DB. Tables, global structures, internal tables import
INCLUDE ZPROVISION_TOP.

" AlV custom Control variables import
INCLUDE ZPROVISION_ALV.

" Classes for Event Handling
INCLUDE ZPROVISION_CLS.

" Screen-Selection input parameters import
INCLUDE ZPROVISION_SCR.

" Macros import
INCLUDE ZPROVISION_MAC.

" Soubroutines import
INCLUDE ZPROVISION_F01.

" PBO Modules import
INCLUDE ZPROVISION_O01.

" PAI Modules import
INCLUDE ZPROVISION_I01.

*INITIALIZATION.

*AT SELECTION-SCREEN OUTPUT.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_.

AT SELECTION-SCREEN.
      IF r_cli = 'X'.             " Desired DB
    gv_tab = 'CL'.
  ELSEIF r_pro = 'X'.
    gv_tab = 'PR'.
  ELSEIF r_ord = 'X'.
    gv_tab = 'CO'.
  ELSEIF r_opr = 'X'.
    gv_tab = 'OP'.
  ENDIF.

START-OF-SELECTION.
  PERFORM search_data.            " Get & Make Data

END-OF-SELECTION.
  IF gv_filled = abap_true.
    CASE gv_tab.
      WHEN 'CL'.
          CALL SCREEN 100.        "ZClients
      WHEN 'PR'.
          CALL SCREEN 200.        "ZProducts
      WHEN 'CO'.
          CALL SCREEN 300.        "ZCorders
      WHEN 'OP'.
          CALL SCREEN 400.        "ZOrdproducts
    ENDCASE.

  ELSE.
    MESSAGE TEXT-E05 TYPE 'E'.
  ENDIF.