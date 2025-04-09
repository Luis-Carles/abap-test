*&---------------------------------------------------------------------*
*&  Include           ZPROVISION_MAC
*&---------------------------------------------------------------------*

" Macro that adds a color to the scheme receiving:
"   &1: FIELDNAME   &2: COLOR INTENSE ''/X
"   &3: COLOR N     &4: KEYCOLOR ''/X
DEFINE %CUSTOM_COLOR.
  CLEAR gs_color.
  gs_color-fname     = &1.
  gs_color-color-int = &2.
  gs_color-color-col = &3.
  gs_color-nokeycol  = &4.
  APPEND gs_color TO gt_colors.

END-OF-DEFINITION.

" Macro that loops through the Field catalog,
" customizing each field properties receiving:
"   &1: KEYFIELD ''/X       &2: LABEL/COL TEXT
"   &3: COLUMN POSITION N   &4: EDITABLE ''/X
"   &5: LOWERCASE  ''/X
DEFINE %CUSTOM_FIELD.
  gs_fieldcat-key        = &1.
  gs_fieldcat-reptext    = gs_fieldcat-scrtext_l =
  gs_fieldcat-scrtext_m  = gs_fieldcat-scrtext_s =
  gs_fieldcat-coltext    = &2.
  gs_fieldcat-col_pos    = &3.
  IF &4 = 'X'.
*    gs_fieldcat-edit = 'X'.
  ENDIF.
  IF &5 = 'X'.
*    gs_fieldcat-lowercase = 'X'.
  ENDIF.

END-OF-DEFINITION.