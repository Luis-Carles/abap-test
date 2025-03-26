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

" AlV custom Control variables import
INCLUDE ZMANAGEMENT_ALV.

" Classes for Event Handling
INCLUDE ZMANAGEMENT_CLS.

" Screen-Selection input parameters import
INCLUDE ZMANAGEMENT_SCR.

" Soubroutines import
INCLUDE ZMANAGEMENT_F01.

" Extra SELECT approaches
INCLUDE ZMANAGEMENT_F02.

" PBO Modules import
INCLUDE ZMANAGEMENT_O01.

" PAI Modules import
INCLUDE ZMANAGEMENT_I01.

INITIALIZATION.
  PERFORM initialize.

AT SELECTION-SCREEN OUTPUT.
  PERFORM selection_screen_OUTPUT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ufile.
  PERFORM get_ufilename USING p_ufile.

AT SELECTION-SCREEN.
  IF sy-ucomm = 'ONLI' AND r_exce = 'X'. " Excel Upload
    PERFORM check_u_file.
*  ELSEIF sy-ucomm = 'FC01'.
*    PERFORM dark_mode.                  " DARK MODE

  ELSE.                                  " DB Search
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

    " Variables approach Selection radiobutton
    IF r_data = 'X'.
      gv_variables = 'DA'.
    ELSEIF r_type = 'X'.
      gv_variables = 'TY'.
    ELSEIF r_line = 'X'.
      gv_variables = 'LI'.
    ELSEIF r_fsym = 'X'.
      gv_variables = 'FS'.
    ENDIF.

    " SELECT approach Selection radiobutton
    IF r_inner = 'X'.
      gv_join = 'I'.
    ELSEIF r_outer = 'X'.
      gv_join = 'O'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  PERFORM search_order_list_ext.  " Get & Make Data

END-OF-SELECTION.
  IF gt_results[] IS NOT INITIAL.
    IF r_exce = 'X'.
      CALL SCREEN 100.            "Display View from Excel
    ELSE.
      CASE gv_mode.
        WHEN 'D'.
          CALL SCREEN 100.        "Display View from DB
        WHEN 'M'.
          CALL SCREEN 200.        "Management View from DB
      ENDCASE.
    ENDIF.
  ELSE.
    MESSAGE 'There is no data to display.' TYPE 'E'.
  ENDIF.