*&---------------------------------------------------------------------*
*&  Include           ZMP_CAFETEST_O01
*&---------------------------------------------------------------------*

MODULE status_100 OUTPUT.
  SET PF-STATUS 'INITIAL_MENU'.
ENDMODULE.

MODULE status_200 OUTPUT.
  SET PF-STATUS 'CLIENT_IDENT'.
ENDMODULE.

MODULE status_210 OUTPUT.
  SET PF-STATUS 'REGISTER_CLIENT'.
ENDMODULE.

MODULE status_215 OUTPUT.
  SET PF-STATUS 'WELCOME'.
ENDMODULE.

MODULE status_220 OUTPUT.
  SET PF-STATUS 'LOG_IN'.
ENDMODULE.

MODULE status_225 OUTPUT.
  SET PF-STATUS 'WELCOME'.
ENDMODULE.

MODULE status_230 OUTPUT.
  SET PF-STATUS 'CLIENT_MENU'.
ENDMODULE.

MODULE status_290 OUTPUT.
  SET PF-STATUS 'FINAL-GREETINGS'.
ENDMODULE.

MODULE status_300 OUTPUT.
  SET PF-STATUS 'EMPLOYEE_MENU'.
ENDMODULE.

MODULE retrieve_client OUTPUT.
  wa_sclient-name = lo_client_fan->get_client_name( ).
  wa_sclient-last_name = lo_client_fan->get_client_last_name( ).
  wa_sclient-client_id = lo_client_fan->get_client_id( ).
  wa_sclient-order_count = lo_client_fan->get_order_count( ).
ENDMODULE.

MODULE retrieve_lorder_date OUTPUT.
  PERFORM search_most_recent_order USING wa_sclient-client_id
                                   CHANGING wa_lorder_date.
ENDMODULE.