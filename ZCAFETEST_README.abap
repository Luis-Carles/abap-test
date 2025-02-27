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
* Educational project to practice SAP ABAP or Arquiving concepts
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
*            |             |________PROD_QUANTITY (zproducts)
*            |
*            |_____ZDE_ORDPQUAN: Product quantity in order
*                          |________PROD_QUANTITY (zordproducts)

*       ZDM_COUN: Domain for counters (INT1 3 0)
*            |_____ZDE_CCOUNT: # Order counter for a client
*            |             |________ORDER_COUNT (zclients)
*            |
*            |_____ZDE_COUNFW: # FourthWing event counter

*       ZDM_ID: Domain for ids  (INT2 5 0)
*            |_____ZDE_CLIENTID: Client unique Identifier
*            |             |________CLIENT_ID
*            |
*            |_____ZDE_PRODID: Product unique Identifier
*            |             |________PROD_ID
*            |
*            |_____ZDE_ORDERID: Order unique Identifier
*            |             |________ORDER_ID
*            |
*            |_____**ZDE_FBID: Feedback unique Identifier

*       ZDM_NUMP: Domain for high integers with decimals (DEC 8 2)
*            |_____ZDE_PPRICE: Product selling Price
*            |             |________PROD_PRICE (zproducts)
*            |
*            |_____ZDE_AVGOC: Average #Order/Client stat
*            |
*            |_____ZDE_AVGOTOT: Average Total for an order stat
*            |
*            |_____ZDE_AVGPO: Average #Product/Order stat
*            |
*            |_____ZDE_COUNG: Total monthly gains stat

*       ZDM_ODAT: Domain for dates (DATS YYYYMMDD)
*            |_____ZDE_ODATE: Order closing Date
*            |             |________ORDER_DATE
*            |
*            |_____**ZDE_FDATE: Feedback Date

*       ZDM_OTIM: Domain for order times (TIMS HHMMSS)
*            |_____ZDE_OTIME: Order closing time
*                          |________ORDER_TIME

*       ZDM_PAYM: Domain for Payment Methods (CHAR 15)
*            |_____ZDE_OPAYM: Order chosen payment method
*                          |________PAYMENT_METHOD (zcorders)

*       ZDM_SLN: Test domain for naming (CHAR 40)
*            |_____ZDE_CNAME: Client name
*            |             |________CLIENT_NAME
*            |
*            |_____ZDE_CLNAME: Client Lastname
*            |             |________CLIENT_LAST_NAME
*            |
*            |_____ZDE_PNAME: Product name
*                          |________PROD_NAME

*       **ZDM_NUMR: Domain for low integers with decimals (DEC 5 3)
*            |_____ZDE_AVGCS: Average Client Satisfaction stat

*       **ZDM_RATING: Domain for feedback rating (NUMC 1)
*            |_____ZDE_FBRAT: Feedback ratings

*       **ZDM_EXTEXT: Domain for extended texts (CHAR 250)
*            |_____ZDE_FBCOMM: Feedback extended comments

* _____________________Structures:___________________________________

*      ZST_STATS: Structure for storing the statistics of ZCAFETEST
*  _________|___________________________________________
* |             |             |            |            |
* AVG_ORDER_T   AVG_PROD_ORD  AVG_ORD_CL   **AVG_CS     |
*(ZDE_AVGOTOT)  (ZDE_AVGPO)   (ZDE_AVGOC)  (ZDE_AVGCS)  |
*                                                       |
*                                                       |
*  _____________________________________________________|
* |            |            |             |
* COUNT_FW     COUNT_G      BEST_SELLER   WORST_SELLER
*(ZDE_COUNFW)  (ZDE_COUNG)  (ZDE_PNAME)   (ZDE_PNAME)

*   .....................

*      **ZST_FEEDB: Structure for storing the feedback of ZCAFETEST
*  ___________|___________________________________________
* |             |             |            |              |
* FB_ID        FB_DATE      FB_RATE      CLIENT_ID        FB_COMM
*(ZDE_FBID)   (ZDE_FDATE)  (ZDE_FBRAT)  (ZDE_CLIENTID)    (ZDE_FBCOMM)


* ________________Search Helps:_____________________________________

* ZSH_AVAILABLE_PRODUCTS: Search help when choosing between available
*          |              products in Module Program approach.
*          |
*          |______PROD_NAME (zproducts)


* -----------Programs (except this)

* ______________ZMAIN_PROGRAM:_____________________________________
* Report program for CAFETEST. It includes ZMAIN_TOP
*                                          ZMAIN_CLS
*                                          ZMAIN_F02
*                                          ZMAIN_SCR

* -Default Approach -------> SCREEN-SELECTION for input parameters.
* -Optional Approaches:      MANUAL INTRODUCTION of every action.
*                            CALL TRANSACTION zmp_cafetest.

* (Note: in ZMAIN_PROGRAM, modyfing existing products functionality
* is not added, just adding a new product to stock or retrieve stats)

* -Reading by abstraction help:
*    |_Lines [8-20]: Imports
*    |_Lines [22-24]: Initialization
*    |_Lines [26-78]: AT SELECTION SCREEN (parameter user input)
*    |     |_Lines [27-36]: Employee actions input check
*    |     |_Lines [38-47]: Client actions input check
*    |     |_Lines [51-54]: Execution Button logic
*    |     |_Lines [56-78]: Add product to order Button logic
*    |           |__Looping action that creates a list of added
*    |              products to the order as a client.
*    |
*    |_Lines [81-191]: START OF SELECTION (Main program start)
*          |_Lines [82-88]: Aditional client/order/handler instances
*          |_Lines [91-104]: Employee new product functionality
*          |_Lines [105-109]: Employee update product quantity func.
*          |_Lines [112-121]: Employee retrieve statistics func.
*          |     |__First statistics are calculed then displayed
*          |        using functions from ZFG_MAIN_STATS.
*          |
*          |_Lines [124-131]: Aditional data is declared to solve
*          |                  casting problems w/ different typing.
*          |_Lines [133-138]: New client creation functionality
*          |_Lines [139-146]: Old client comeback functionality
*          |_Lines [150-155]: Create new order functionality
*          |_Lines [157-174]: Add product to order from input list
*          |                  created during [56-78].
*          |_Lines [176-179]: Close order functionality.
*          |     |__First order is closed, then monthly gains are
*          |        updated and finnaly the order details are shown.
*          |
*          |_Lines [183-187]: Optional approaches area.
*          |_Lines [189-191]: Report final displaying methods.

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


* -----------Function Groups:

* _________________ZFG MAIN_STATS:_________________________________

* -ZMAIN_DISPLAY_USTATS: Function in charge of displaying retrieved
*                        after mentioned employee action properly
*                        calculed monthly statistics.

* (Note: as of now just the method for displaying unitary statistics
*  has been coded and is present in the function)


* -----------Includes and Modularization:

*  ZMAIN_PROGRAM                ZMP_CAFETEST
*     |                      _     |
*     |__ZMAIN_TOP            }    |__ZMP_CAFETEST_TOP
*     |                       }____|_______|
*     |__ZMAIN_CLS            }    |
*     |    |                  }    |
*     |    |__ZMAIN_F01       }    |__ZMAIN_F03
*     |                       }    |
*     |__ZMAIN_F02           _}    |
*     |                            |__ZMP_CAFETEST_O01
*     |__ZMAIN_SCR                 |__ZMP_CAFETEST_I01


* ________Global Variables and Type Declarations:________________

* -ZMAIN_TOP:
*     |
*     |_Includes: X
*     |
*     |_DB. Tables: zproducts, zclients, zcorders, zordproducts.
*     |
*     |_Types:
*     |   |_____ty_product
*     |   |          |_______prod_id        TYPE i
*     |   |          |_______prod_name      TYPE string
*     |   |          |_______prod_quantity  TYPE i
*     |   |          |_______prod_price     TYPE p DECIMALS 2
*     |   |
*     |   |
*     |   |_____ty_client
*     |   |          |_______client_id      TYPE i
*     |   |          |_______name           TYPE string
*     |   |          |_______last_name      TYPE string
*     |   |          |_______order_count    TYPE i
*     |   |
*     |   |_____ty_price  TYPE p DECIMALS 2
*     |
*     |
*     |_Internal tables:
*     |   |_____it_clients:  sorted table of ty_client
*     |   |                  (primary key on client_id)
*     |   |
*     |   |_____it_products: sorted table of ty_product
*     |                      (primary key on prod_id)
*     |
*     |_Arquetypical variables:
*     |   |_____gv_monthly_gains  TYPE p DECIMALS 2
*     |
*     |_Object Instances: X

*   .....................

* -ZMP_CAFETEST_TOP:
*     |
*     |_Includes: ZMAIN_TOP, ZMAIN_CLS, ZMAIN_F02, ZMAIN_F03
*     |
*     |_DB. Tables: X.
*     |
*     |_Types: X
*     |
*     |_Arquetypical variables:
*     |   |_____wa_sclient TYPE ty_client (Auxiliar ty_client to
*     |   |                                handle client actions)
*     |   |
*     |   |_____wa_sproduct TYPE ty_product (Auxiliar ty_product to
*     |   |                                 handle client actions)
*     |   |
*     |   |_____wa_eproduct TYPE ty_product (Stored product to
*     |   |                                handle employee actions)
*     |   |
*     |   |_____wa_nproduct TYPE ty_product (New product to handle
*     |   |                                 employee actions)
*     |   |
*     |   |_____gv_payment_method TYPE string
*     |   |
*     |   |_____wa_lorder_date TYPE DATS LastOrder date of a client
*     |   |
*     |   |_____gv_order_total TYPE ty_price
*     |   |
*     |   |_____gs_stats TYPE ZST_STATS  retrieved stats structure
*     |   |
*     |   |_____gv_user TYPE sy-uname    username storing variable
*     |   |
*     |   |_____gv_date TYPE DATS     date of statistics retrieval
*     |   |
*     |   |_____gv_time TYPE TIMS     time of statistics retrieval
*     |
*     |__Internal tables:
*     |   |___**gt_order_products: standard table of ty_product to
*     |   |                        store current order product list
*     |   |
*     |   |_____gt_order_products: sorted table of ty_product
*     |                           (primary key on prod_id)
*     |
*     |
*     |_Object Instances:
*         |_____lo_client_fan TYPE REF TO lcl_client
*         |
*         |_____lo_order      TYPE REF TO lcl_order
*         |
*         |_____lo_handler    TYPE REF TO lcl_fourth_wing_handler


* ___________Classes and Event Handling CLS:_____________________

* -ZMAIN_CLS:
*     |
*     |_Includes: ZMAIN_F01
*     |
*     |_Classes:
*          |
*         _|_
*  UML Class Diagram with expanded method/attribute explanations:

*   +-------------------+
*   |   lcl_client      |
*   +-------------------+
*   | - client_id       |    TYPE i        (~client PK)
*   | - name            |    TYPE string
*   | - last_name       |    TYPE string
*   | - order_count     |    TYPE i        (#Total closed orders)
*   +-------------------+
*   | + constructor     |    (Suports both new client and comeback)
*   | + display_client  |
*   | + update_order_count |  (Updates #Order count + 1)
*   | + reset_order_count  |  (Reset #Order count to '0')
*   | + get_client_id   |
*   | + get_order_count |
*   | + get_client_name |
*   | + get_client_last_name |
*   +-------------------+
*           ↑
*           |
*   +---------------------+
*   |   lcl_order         |
*   +---------------------+
*   | - order_id          |   TYPE i                  (~order PK)
*   | - o_client          |   TYPE REF TO lcl_client  (~client FK)
*   | - payment_method    |   TYPE string
*   | - total             |   TYPE p DECIMALS 2
*   | - it_order_products |   standard table of ty_product
*   | - order_date        |   TYPE DATS
*   | - order_time        |   TYPE TIMS
*   +---------------------+
*   | + constructor       |   (Creates a non closed order)
*   | + add_product       |
*   | + calculate_total   |   (Loops product list and calcules total)
*   | + update_monthly_gains |  (Closing total added to g. variable)
*   | + display_order     |
*   | + close_order       |   (Close and stores the order in DB)
*   | + set_total         |
*   | + get_total         |
*   | + get_o_client      |
*   +---------------------+
*           ↑
*           |
*   +-----------------------------+
*   |   lcl_fourth_wing_handler   |
*   +-----------------------------+
*   | + on_fourth_wing            | (Detailed actions after FW Event)
*   +-----------------------------+


* __________________Soubroutines FXX:____________________________

* -ZMAIN_F01:


* __________________PBO and PAI Logic:____________________________

* -ZMP_CAFETEST_O01:

* -ZMP_CAFETEST_I01:


* ___________Screen-Selection Input Logic SCR:____________________

* -ZMAIN_SCR: