*&---------------------------------------------------------------------*
*&  Include           ZMANAGEMENT_F01
*&---------------------------------------------------------------------*

FORM refresh_grid.
    CALL METHOD go_grid->refresh_table_display.
  ENDFORM.
  
  FORM initialize_listboxs.
    DATA: lt_values TYPE vrm_values,
          ls_value  TYPE vrm_value.
  
    "_____Desired Table Listbox_______________
    CLEAR lt_values.
  
    ls_value-key   = 'ZORDERS'.
    ls_value-text  = 'Orders Table'.
    APPEND ls_value TO lt_values.
  
    ls_value-key   = 'ZPRODUCTS'.
    ls_value-text  = 'Products Table'.
    APPEND ls_value TO lt_values.
  
    ls_value-key   = 'ZCLIENTS'.
    ls_value-text  = 'Clients Table'.
    APPEND ls_value TO lt_values.
  
    ls_value-key   = 'ZORDPRODUCTS'.
    ls_value-text  = 'Orders & Products'.
    APPEND ls_value TO lt_values.
  
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = 'P_TABLE'   " Name of the selection-screen parameter
        values = lt_values.
  
    "_____Desired Mode Listbox_______________
    CLEAR lt_values.
  
    ls_value-key  = 'DISP'.
    ls_value-text = 'Display Mode'.
    APPEND ls_value TO lt_values.
  
    ls_value-key  = 'MNG'.
    ls_value-text = 'Management Mode'.
    APPEND ls_value TO lt_values.
  
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = 'P_MODE'
        values = lt_values.
  
  ENDFORM.
  
  FORM get_clients.
    "DOING!!
  ENDFORM.
  
  FORM get_products.
    "DOING!!
  ENDFORM.
  
  FORM get_corders.
    "DOING!!
  ENDFORM.
  
  FORM get_ordproducts.
    "DOING!!
  ENDFORM.
  
  FORM alv_write_100.
    "DOING!!
  ENDFORM.
  
  FORM alv_write_200.
    "DOING!!
  ENDFORM.