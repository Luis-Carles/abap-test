*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_CLS
*&---------------------------------------------------------------------*

"_________________________________________________
" Event Handler
CLASS lcl_handler DEFINITION.
    PUBLIC SECTION.
  
      METHODS:
         when_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
          IMPORTING er_data_changed.
  
  ENDCLASS.
  
  CLASS lcl_handler IMPLEMENTATION.
    METHOD when_data_changed.
      CASE gv_tab.
        WHEN 'CL'.
          LOOP AT er_data_changed->mt_good_cells INTO gs_chg_row.
            ASSIGN gt_clients[ gs_chg_row-row_id ] TO FIELD-SYMBOL(<fs_client>).
            IF <fs_client> IS ASSIGNED.
               <fs_client>-FLAG_CHG = 'X'.
            ENDIF.
          ENDLOOP.
  
        WHEN 'PR'.
          LOOP AT er_data_changed->mt_good_cells INTO gs_chg_row.
            ASSIGN gt_products[ gs_chg_row-row_id ] TO FIELD-SYMBOL(<fs_product>).
            IF <fs_product> IS ASSIGNED.
               <fs_product>-FLAG_CHG = 'X'.
            ENDIF.
          ENDLOOP.
  
        WHEN 'CO'.
          LOOP AT er_data_changed->mt_good_cells INTO gs_chg_row.
            ASSIGN gt_clients[ gs_chg_row-row_id ] TO FIELD-SYMBOL(<fs_corder>).
            IF <fs_corder> IS ASSIGNED.
               <fs_corder>-FLAG_CHG = 'X'.
            ENDIF.
          ENDLOOP.
  
        WHEN 'PO'.
          LOOP AT er_data_changed->mt_good_cells INTO gs_chg_row.
            ASSIGN gt_clients[ gs_chg_row-row_id ] TO FIELD-SYMBOL(<fs_ordproduct>).
            IF <fs_ordproduct> IS ASSIGNED.
               <fs_ordproduct>-FLAG_CHG = 'X'.
            ENDIF.
          ENDLOOP.
  
      ENDCASE.
    ENDMETHOD.
  
  ENDCLASS.