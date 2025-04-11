*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_SCR
*&---------------------------------------------------------------------*

"__________________________________________________________________________
" DATABASE SELECTION
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-B01.
   PARAMETERS:     r_cli  RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND cli,
                   r_pro  RADIOBUTTON GROUP grp1,
                   r_ord  RADIOBUTTON GROUP grp1,
                   r_opr  RADIOBUTTON GROUP grp1.
SELECTION-SCREEN: END OF BLOCK b1.