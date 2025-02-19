*&---------------------------------------------------------------------*
*&  Module Pool          ZFMP_CAFETEST
*&---------------------------------------------------------------------*

PROGRAM ZMP_CAFETEST.

INCLUDE ZMP_CAFETEST_TOP.
INCLUDE ZMP_CAFETEST_O01.
INCLUDE ZMp_CAFETEST_I01.

START-OF-SELECTION.
  " Before needed actions
  lo_handler = NEW lcl_fourth_wing_handler( ).

  " First Screen
  CALL SCREEN 100.