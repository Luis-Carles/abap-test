*&---------------------------------------------------------------------*
*& Report  ZCAFETEST_README
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZCAFETEST_README.
*
* -----------CAFETERIA TEST PROJECT--------------
* by Luis Carles Dura
* at DBDS 2/14/2025'
* https://github.com/Luis-Carles/abap-test
* version 1.1.0
*

* -----------Abstract:
* Educational project to practice SAP ABAP or Arcquiving concepts
* learned during formation at DBDS. Cafeteria Test is ostensibly
* a cafe project that stores information regarding clients/orders
* and product stock. This readme differentiate between client and
* employee roles and their respective actions.

* -----------ABAP DICTIONARY

* ___________________Database Tables:______________________________

* -ER Model for DB:

* +------------------+   +------------------+   +------------------+
* |   ZCLIENTS       |   |   ZCORDERS       |   |   ZPRODUCTS      |
* +------------------+   +------------------+   +------------------+
* | CLIENT_ID (PK)   |   | ORDER_ID (PK)    |   | PROD_ID (PK)     |
* | CLIENT_NAME      |   | TOTAL            |   | PROD_NAME        |
* | CLIENT_LAST_NAME |   | ORDER_DATE       |   | PROD_QUANTITY    |
* | ORDER_COUNT      |   | ORDER_CLIENT (FK)|   | PROD_PRICE       |
* |                  |   |       . . .      |   |                  |
* +------------------+   +------------------+   +------------------+
*           |                  |   |                      |
*           |________1 : n_____|   |                      |
*                                  |                      |
*                                1 : n                  n : m
* +------------------+             |                      |
* | ZORDPRODUCTS     |             |                      |
* +------------------+             |                      |
* | ORDER_ID (FK)    | ____________|                      |
* | PROD_ID (FK)     | ___________________________________|
* | PROD_QUANTITY    |
* +------------------+

* ______________Domains, Data Elements and Structures:______________

* -Domains & derived Data elements:  >>> (**)"Future"
*      | DOMAIN   | D.ELEMENT   |    DB.TABLE Attribute  |
*      |----------|-------------|------------------------|

*       ZDM_AMMO: Domain for quantities (QUAN 8 0)
*            |_____ZDE_PQUAN: Product quantity in stock
*            |             |________
*            |
*            |_____ZDE_ORDPQUAN: Product quantity in order
*                          |________

*       ZDM_COUN: Domain for counters (INT1 3 0)
*            |_____ZDE_CCOUNT: # Order counter for a client
*            |             |________
*            |
*            |_____ZDE_COUNFW: # FourthWing event counter
*                          |________

*       ZDM_ID: Domain for ids  (INT2 5 0)
*            |_____ZDE_CLIENTID: Client unique Identifier
*            |             |________
*            |
*            |_____ZDE_PRODID: Product unique Identifier
*            |             |________
*            |
*            |_____ZDE_ORDERID: Order unique Identifier
*            |             |________
*            |
*            |_____**ZDE_FBID: Feedback unique Identifier
*                          |________

*       ZDM_NUMP: Domain for high integers with decimals (DEC 8 2)
*            |_____ZDE_PPRICE: Product selling Price
*            |             |________
*            |
*            |_____ZDE_AVGOC: Average #Order/Client stat
*            |             |________
*            |
*            |_____ZDE_AVGOTOT: Average Total for an order stat
*            |             |________
*            |
*            |_____ZDE_AVGPO: Average #Product/Order stat
*            |             |________
*            |
*            |_____ZDE_COUNG: Total monthly gains stat
*                          |________

*       ZDM_ODAT: Domain for dates (DATS YYYYMMDD)
*            |_____ZDE_ODATE: Order closing Date
*            |             |________
*            |
*            |_____**ZDE_FDATE: Feedback Date
*                          |________

*       ZDM_OTIM: Domain for order times (TIMS HHMMSS)
*            |_____ZDE_OTIME: Order closing time
*                          |________

*       ZDM_PAYM: Domain for Payment Methods (CHAR 15)
*            |_____ZDE_OPAYM: Order chosen payment method
*                          |________

*       ZDM_SLN: Test domain for naming (CHAR 40)
*            |_____ZDE_CNAME: Client name
*            |             |________
*            |
*            |_____ZDE_CLNAME: Client Lastname
*            |             |________
*            |
*            |_____ZDE_PNAME: Product name
*                          |________


*       **ZDM_NUMR: Domain for low integers with decimals (DEC 5 3)
*            |_____ZDE_AVGCS: Average Client Satisfaction stat
*       **ZDM_RATING: Domain for feedback rating (NUMC 1)
*            |_____ZDE_FBRAT: Feedback ratings

*       **ZDM_EXTEXT: Domain for extended texts (CHAR 250)
*            |_____ZDE_FBCOMM: Feedback extended comments

* -Structures:
*      ZST_STATS: Structure for storing the statistics of ZCAFETEST
*

* -----------Programs (except this)

* ______________ZMAIN_PROGRAM:_____________________________________
* Report program for CAFETEST. It includes ZMAIN_F01
*                                          ZMAIN_CLS
*                                          ZMAIN_F02

* Default Approach -------> SCREEN-SELECTION for input parameters.
* Optional Approaches:      MANUAL INTRODUCTION of every action.
*                           CALL TRANSACTION zmp_cafetest.

*   .....................

* ______________ZMP_CAFETEST:______________________________________
* Screen Module program for CAFETEST. It includes ZMP_CAFETEST_TOP
*                                                 ZMP_CAFETEST_O01
*                                                 ZMP_CAFETEST_I01

* Screens [100-199] ------> Access Mode Screens
*              0100: Initial Menu Screen

* Screens [200-299] ------> Client Mode Actions
*              0200: Client Identification Menu
*              0210: Register (New Client)
*              0215: Welcome New Client
*              0220: Log in (Comeback)
*              0225: Welcome Old Client
*              0230: Client Menu (Ordering)
*              0290: Client Goodbye Screen

* Screens [300-399] ------> Employee Mode Actions
*              0300: Employee Menu
*              0310: (Update Stock)
*              0315: Successfull Update screen
*              0320: Modify Inventory (Add New Product)
*              0325: Successfull Modifications screen
*              0330: (Retrieve Statistics)

*   .....................

* _____________ZVALIDATE_QUANTITIES:______________________________
* Legacy and alpha version of CAFETEST.
* It includes code snippets of versions 0.0.0 to 0.0.9 without any
* modularization or frontend variations. The name was kept out of
* respect and nostalgia.


* -----Includes and Modularization:

* -----Classes and Event Handling CLS:

* -----Soubroutines FXX:

* -----Function Groups:

* -ZFG MAIN_STATS -----> ZMAIN_MONTHLY_STATS