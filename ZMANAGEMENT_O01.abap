*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_O01
*&---------------------------------------------------------------------*

MODULE status_100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'S100' WITH 'Display View'.
ENDMODULE.

MODULE alv_write_100 OUTPUT.
  PERFORM alv_write.
ENDMODULE.

MODULE status_200 OUTPUT.
  SET PF-STATUS 'S200'.
  SET TITLEBAR 'S100' WITH 'Management View'.
ENDMODULE.

MODULE alv_write_200 OUTPUT.
  PERFORM alv_write.
ENDMODULE.