FUNCTION ZMAIN_DISPLAY_USTATS .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IP_STATS) TYPE  ZST_STATS
*"----------------------------------------------------------------------

  DATA: lv_date TYPE DATS,
        lv_time TYPE TIMS,
        lv_user TYPE CHAR12.
  lv_date = sy-datum.
  lv_time = sy-uzeit.
  lv_user = sy-uname.

  " Header
  WRITE: / '========================================'.
  WRITE: / '      STATISTICS FOR ZCAFETEST         '.
  WRITE: / '========================================'.
  WRITE: / 'Retrieved on:', lv_date, '  ', lv_time.
  WRITE: / 'By:', lv_user.
  ULINE.

  " Unitary Stats
  WRITE: / 'Unitary Statistics and Markers:'.
  ULINE.

  WRITE: / '→ Average order total:             ', IP_STATS-AVG_ORDER_T.
  WRITE: / '→ Avg. # of products per order:    ', IP_STATS-AVG_PROD_ORD.
  WRITE: / '→ Avg. # of orders per client:     ', IP_STATS-AVG_ORD_CL.
*   WRITE: / '→ Average Client Satisfaction:    ', iv_stats-AVG_CS.
  ULINE.

  WRITE: / '→ Total gains:                     ', IP_STATS-COUNT_G.
  WRITE: / '→ Total Fourth Wing Discounts:     ', IP_STATS-COUNT_FW.
  WRITE: / '→ Best Seller:                     ', IP_STATS-BEST_SELLER.
  WRITE: / '→ Worst Seller:                    ', IP_STATS-WORST_SELLER.
  ULINE.
ENDFUNCTION.