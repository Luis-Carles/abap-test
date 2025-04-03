*&---------------------------------------------------------------------*
*&  Include           ZOVERALL_O01
*&---------------------------------------------------------------------*

"___________________________________________________________
"_________TREE DISPLAY VIEW_________________________________
"___________________________________________________________
MODULE status_100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR  'S100'.
ENDMODULE.

MODULE write_tree OUTPUT.
  PERFORM write_tree.
ENDMODULE.

"___________________________________________________________
"_________DETAILS DISPLAY VIEW______________________________
"___________________________________________________________
MODULE status_900 OUTPUT.
  SET PF-STATUS 'S900'.
  SET TITLEBAR  'S900'.
ENDMODULE.

MODULE write_details OUTPUT.
  PERFORM write_details.
ENDMODULE.