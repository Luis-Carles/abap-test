FUNCTION ZMAIN_MONTHLY_STATS .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(CP_STATS) TYPE  ZST_STATS
*"----------------------------------------------------------------------
  INCLUDE ZFG_MAIN_STATS_FO1.

  DATA: ls_stats TYPE CP_STATS.

  "Average Total for orders
  PERFORM average_ototal  CHANGING ls_stats-AVG_ORDER_T.
  "Average products for orders
  PERFORM average_prodo   CHANGING ls_stats-AVG_PROD_ORD.
  "Average orders for clients
  PERFORM average_oclient CHANGING ls_stats-AVG_ORD_CL.
  "Average Client satisfaction
  PERFORM average_csatis  CHANGING ls_stats-AVG_CS.
  "Fourth Wings Count + Gains count + Best seller + Worst Seller
  PERFORM calcule_counts  CHANGING ls_stats-BEST_SELLER
                                   ls_stats-WORST_SELLER.

ENDFUNCTION.