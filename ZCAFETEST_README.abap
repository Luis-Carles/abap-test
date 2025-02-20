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
* version 1.0
*

* -----------Abstract:
* Educational project to practice SAP ABAP or Arcquiving concepts
* learned during formation at DBDS. Cafeteria Test is ostensibly
* a cafe project that stores information regarding clients/orders
* and product stock. This readme differentiate between client and
* employee roles and their respective actions.

* -----------ABAP DICTIONARY

* -----Structures, Domains and Data Elements:

* -----Database Tables:

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

* -----Programs (except this)

* - ZMAIN_PROGRAM:
* Report program for CAFETEST. It includes ZMAIN_F01
*                                          ZMAIN_CLS

* Default Approach -------> SCREEN-SELECTION for input parameters.
* Optional Approaches:      MANUAL INTRODUCTION of every action.
*                           CALL TRANSACTION zmp_cafetest.

*   .....................

* - ZMP_CAFETEST:
* Screen Module program for CAFETEST. It includes ZMP_CAFETEST_TOP
*                                                 ZMP_CAFETEST_O01
*                                                 ZMP_CAFETEST_I01

*
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
*              0320: Modify Inventory (Add New Product)
*              0330: (Retrieve Statistics)

*   .....................

* - ZVALIDATE_QUANTITIES:
* Legacy and alpha version of CAFETEST.
* It includes code snippets of versions 0.0.0 to 0.0.9 without any
* modularization or frontend variations. The name was kept out of
* respect and nostalgia.
*   .....................

* -----Includes and Modularization:

* -----Classes and Event Handling CLS:

* -----Soubroutines FXX:

* -----Function Groups:

* -ZFG MAIN_STATS -----> ZMAIN_MONTHLY_STATS