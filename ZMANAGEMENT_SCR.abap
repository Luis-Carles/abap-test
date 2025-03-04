*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-004.
  PARAMETERS: p_table TYPE tabname AS LISTBOX VISIBLE LENGTH 20.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-005.
  PARAMETERS: p_mode TYPE CHAR15 AS LISTBOX VISIBLE LENGTH 15.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN PUSHBUTTON /10(20) p_exec USER-COMMAND start_exec.