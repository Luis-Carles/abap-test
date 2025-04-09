*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_O01
*&---------------------------------------------------------------------*

"___________________________________________________________
"__________MANAGEMENT VIEWS STATUS MODULES__________________
"___________________________________________________________
MODULE status_100 OUTPUT.
  SET PF-STATUS 'MANAGEMENT'.
  SET TITLEBAR 'S100' WITH 'Clients'.
ENDMODULE.

MODULE status_200 OUTPUT.
  SET PF-STATUS 'MANAGEMENT'.
  SET TITLEBAR 'S100' WITH 'Products'.
ENDMODULE.

MODULE status_300 OUTPUT.
  SET PF-STATUS 'MANAGEMENT'.
  SET TITLEBAR 'S100' WITH 'Closed Orders'.
ENDMODULE.

MODULE status_400 OUTPUT.
  SET PF-STATUS 'MANAGEMENT'.
  SET TITLEBAR 'S100' WITH 'Order Products'.
ENDMODULE.

"___________________________________________________________
"__________MANAGEMENT VIEWS WRITE MODULE____________________
"___________________________________________________________
MODULE alv_write OUTPUT.
  PERFORM alv_write.
ENDMODULE.