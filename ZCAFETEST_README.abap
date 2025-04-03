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
* version 1.2.2
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
* +------------------+   | PAYMENT_METHOD   |   | WAERS (Currency) |
*           |            | ORDER_TIME       |   | MEINS (Unit)     |
*           |            | WAERS (Currency) |   +------------------+
*           |            +------------------+             |
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

*   .....................

*      ZST_RESULTS: Structure for storing the results of the search
*           |       launched by ZMANAGEMENT_PROGRAM (ALV GRID display)
*  _________|_________________________________________________
* |                |                  |            |          |
* ORDER_ID       ORDER_CLIENT      PROD_ID       CLIENT_NAME  |
*(ZDE_ORDER_ID)  (ZDE_CLIENTID)   (ZDE_PRODID)  (ZDE_CNAME)   |
*                                                             |
*                                                             |
*  ___________________________________________________________|
* |                     |            |             |          |
* CLIENT_LAST_NAME    ORDER_COUNT   ORDER_DATE    ORDER_TIME  |
*(ZDE_CLNAME)        (ZDE_CCOUNT)  (ZDE_ODATE)   (ZDE_OTIME)  |
*                                                             |
*                                                             |
*  ___________________________________________________________|
* |            |              |          |                    |
* REG_STATUS   TOTAL          WAERS     PAYMENT_METHOD        |
*(CHAR 20 0)   (ZDE_OTOTAL)  (WAERS)   (ZDE_OPAYM)            |
*                                                             |
*                                                             |
*  ___________________________________________________________|
* |            |             |               |                |
* PROD_NAME    PROD_PRICE    PROD_QUANTITY   PROD_STOCK       |
*(ZDE_PNAME)  (ZDE_PPRICE)  (ZDE_ORDPQUAN)   (ZDE_PQUAN)      |
*                                                             |
*                                                             |
*  ___________________________________________________________|
* |        |             |                |
* MEINS    COLOR         FLAG_NEW         FLAG_OLD
*(MEINS)  (LVC_T_SCOL)  (CHAR 1 0)       (CHAR 1 0)


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

* (Note: the buttons, output/input fields and their disposition
* can be inferred through PBO/PAI modules further explanation)

*   .....................

* _____________ZMANAGEMENT_PROGRAM:______________________________
* GRID ALV based Screen Module program for CAFETEST.
*                                      It includes <CL_ALV_CONTROL>
*                                                  ZMANAGEMENT_TOP
*                                                  ZMANAGEMENT_ALV
*                                                  ZMANAGEMENT_CLS
*                                                  ZMANAGEMENT_SCR
*                                                  ZMANAGEMENT_F01
*                                                  ZMANAGEMENT_F02
*                                                  ZMANAGEMENT_O01
*                                                  ZMANAGEMENT_I01
* UPLOAD METHOD:    DB Search
*                   Excel File

* VIEW MODE:        D: Display
*                   M: Management

* SEARCH APPROACH:  ND: Non-Dynamic Conditions
*                   DY: Dynamic Conditions

* Screen 100 ------> Display View
* Screen 200 ------> Management View

* -Reading by abstraction help:
*    |_Lines [10-35]: Imports
*    |_Lines [37-38]: Initialization
*    |_Lines [40-41]: AT-SELECTION-SCREEN OUTPUT
*    |           |__Hide necessary parameters between different
*    |              Upload methods: DB Search and Excel Upload.
*    |
*    |_Lines [43-44]: AT-SELECTION-SCREEN ON VALUE_REQUEST
*    |           |__Pop-up browser to choose an uploading excel file.
*    |
*    |_Lines [46-84]: AT SELECTION SCREEN (parameter user input)
*    |     |_Lines [47-48]: Checking given Excel uploading filename.
*    |     |_Lines [53-58]: View Mode saved into global variable.
*    |     |_Lines [61-65]: Search Approach for DB Table embedded SQL.
*    |     |_Lines [68-76]: Variables Approach for extra Search approaches.
*    |     |_Lines [79-83]: SELECT JOIN Approach saved into global variable.
*    |
*    |_Lines [86-87]: START OF SELECTION (Main program data retrieval)
*    |
*    |_Lines [89-103]: END-OF-SELECTION (Main program execution)
*          |_Lines [91-93]: Display View from Excel file data.
*          |_Lines [95-96]: Display View from DB Table data.
*          |_Lines [97-98]: Management View from DB Table data.

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

* ZMANAGEMENT_PROGRAM       ZMAIN_PROGRAM                ZMP_CAFETEST
* |                         |                      _     |
* |__ZMANAGEMENT_TOP        |__ZMAIN_TOP            }    |__ZMP_CAFETEST_TOP
* |__ZMANAGEMENT_ALV        |                       }____|_______|
* |__ZMANAGEMENT_CLS        |__ZMAIN_CLS            }    |
* |__ZMANAGEMENT_SCR        |    |                  }    |
* |                         |    |__ZMAIN_F01       }    |__ZMAIN_F03
* |__ZMANAGEMENT_F01        |                       }    |
* |__ZMANAGEMENT_F02        |__ZMAIN_F02           _}    |
* |__ZMANAGEMENT_O01        |                            |__ZMP_CAFETEST_O01
* |__ZMANAGEMENT_I01        |__ZMAIN_SCR                 |__ZMP_CAFETEST_I01


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
*     |_Includes: ZMAIN_TOP, ZMAIN_CLS, ZMAIN_F02, ZMP_CAFETEST_F01
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

*   .....................

* -ZMANAGEMENT_TOP:
*     |
*     |_Includes: X
*     |
*     |_DB. Tables: zproducts, zclients, zcorders, zordproducts,
*     |             SSCRFIELDS (Selection-Screen Fields Table).
*     |
*     |_Types:
*     |   |_____ty_client_id
*     |   |          |_______CLIENT_ID    TYPE zclients-CLIENT_ID
*     |   |          |_______ORDER_COUNT  TYPE zclients-ORDER_COUNT
*     |   |
*     |   |_____ty_prod_id
*     |              |_______PROD_ID     TYPE zproducts-PROD_ID
*     |
*     |_Internal tables:
*     |   |__gt_results: standard table of ZST_RESULT to store
*     |   |              every fetched row to display (Filtered by conditions)
*     |   |
*     |   |__gt_master_clients: sorted table of clients master table
*     |   |          |          data information (Filtered by conditions)
*     |   |          |__CLIENT_ID        LIKE zclients-CLIENT_ID
*     |   |          |__CLIENT_NAME      LIKE zclients-CLIENT_NAME
*     |   |          |__CLIENT_LAST_NAME LIKE zclients-CLIENT_LAST_NAME
*     |   |          |__ORDER_COUNT      LIKE zclients-ORDER_COUNT
*     |   |
*     |   |__gt_master_clients: sorted table of products master table
*     |   |          |          data information (Filtered by conditions)
*     |   |          |__PROD_ID          LIKE zproducts-PROD_ID
*     |   |          |__PROD_NAME        LIKE zproducts-PROD_NAME
*     |   |          |__PROD_QUANTITY    LIKE zproducts-PROD_QUANTITY
*     |   |          |__PROD_PRICE       LIKE zproducts-PROD_PRICE
*     |   |
*     |   |__gt_client_ids: hashed table of clients master table ID and
*     |   |          |      order counter when checking in saving changes.
*     |   |          |_______CLIENT_ID    TYPE zclients-CLIENT_ID
*     |   |          |_______ORDER_COUNT  TYPE zclients-ORDER_COUNT
*     |   |
*     |   |__gt_prod_ids: hashed table of products master table ID
*     |   |          |    when checking existence in saving changes.
*     |   |          |_______PROD_ID    TYPE zclients-CLIENT_ID
*     |   |
*     |   |__gt_excel: standard table of alsmex_tabline to store
*     |                raw data extracted from excel file
*     |
*     |_Arquetypical variables:
*     |   |_____gv_mode     TYPE CHAR1   ALV GRID View Mode
*     |   |
*     |   |_____gv_approach TYPE CHAR2   Data Search Approach
*     |   |
*     |   |_____gv_variables TYPE CHAR2   Variables Approach for extra Searches
*     |   |
*     |   |_____gv_join     TYPE CHAR1   SELECT JOIN Approach for extra Searches
*     |   |
*     |   |_____gv_where    TYPE string  dynamic conditions string
*     |   |
*     |   |_____gv_where_cl TYPE string  master clients d.cond string
*     |   |
*     |   |_____gv_where_pr TYPE string  master product d.cond string
*     |   |
*     |   |_____gv_code     TYPE sy-ucomm  stores sy-ucomm (standard)
*     |   |
*     |   |_____ok_code     TYPE sy-ucomm  checks sy-ucomm (standard)
*     |   |
*     |   |_____gv_check    TYPE STA_TEXT  Check Input flag
*     |   |
*     |   |_____gv_save     TYPE STA_TEXT  Save flag
*     |   |
*     |   |_____gv_delete   TYPE STA_TEXT  Delete flag
*     |   |
*     |   |_____gv_high_clid  TYPE i       Highest Client ID in DB Table
*     |   |
*     |   |_____gv_high_prid  TYPE i       Highest Product ID in DB Table
*     |   |
*     |   |_____gv_high_orid  TYPE i       Highest Order ID in DB Table
*     |
*     |_Object Instances: X

*   .....................

* -ZMANAGEMENT_ALV:
*     |
*     |_Includes: X
*     |
*     |_DB. Tables: X
*     |
*     |_Types: X
*     |
*     |_Internal tables: X
*     |
*     |_Arquetypical variables:
*     |   |_____gt_fieldcat_slis  TYPE slis_t_fieldcat_alv  slis Field Catalog
*     |   |
*     |   |_____gt_fieldcat   TYPE lvc_t_fcat    LVC Field Catalog
*     |   |_____gs_fieldcat   TYPE lvc_s_fcat    LVC Field Catalog Line
*     |   |_____gs_scroll     TYPE lvc_t_stbl    LVC Stable refresh variable
*     |   |_____gs_layout     TYPE lvc_s_layo    LVC Layout
*     |   |_____gt_toolbar_ex  TYPE ui_functions  Toolbar Exempted Functions
*     |   |_____gt_colors     TYPE lvc_t_scol    LVC Table of Colors
*     |   |_____gs_color      TYPE lvc_s_scol    LVC Colors Line
*     |
*     |_Object Instances:
*         |_____go_dcontainer TYPE REF TO cl_gui_docking_container
*         |
*         |_____go_grid       TYPE REF TO cl_gui_alv_grid


* ___________Classes and Event Handling CLS:_____________________

* -ZMAIN_CLS: OOP classes for client/order and the FourthWing
* handler class. Inside constructor or public methods the logic
* for storing/updating data from internal and database tables.
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
*
* -FourthWing Event: It happens everytime a client makes 3 orders, if
* the third order total does not exceed a specific price it receives
* a 50% discount. The subyacent idea was to train event raising and
* handling consequent actions within OOP in SAP ABAP.

*   .....................

* -ZMANAGEMENT_CLS: OOP classes for ZMANAGEMENT GRID ALV handler class
*     |
*     |_Includes: X
*     |
*     |_Instances: go_handler TYPE REF TO lcl_handler
*     |
*     |_Classes:
*          |
*         _|_
*  UML Class Diagram with expanded method/attribute explanations:

*   +-----------------------------+
*   |   lcl_handler               |
*   +-----------------------------+
*   | + when_data_changed         | (Changed data Dormain Demon)
*   +-----------------------------+


* __________________Soubroutines FXX:____________________________

* -ZMAIN_F01: Contains every subroutine related with handling and
* operating with ZCAFETEST client and employee operations until
* version 1.1.0. Contains subroutines related to store data both
* internally and in the DB tables with the mandatory object
* creation and update based logic. Also offers the searching
* methods and the manual approach subroutine for ZMAIN_PROGRAM.

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [General methods]
*    |
*    |_Lines [6-13]: validate_quantity(q): checks for <0 quantities
*    |_Lines [15-38]: display_stock(): display products in stock
*    |_Lines [41-52]: first_to_upper(str): make the first letter of
*    |                   a string upper case and lower case the rest
*    |
*    |_Lines [55-70]: next_id(table): Counts records in a given table
*    |                   and returns the next available identifier.
*    |
*    |_Lines [74-129]: init_products(): Add some products to stock
*    |                   in case it is empty. Will fail otherwise.
*    |   ----------------------------------------------------
*    |                [Search methods]
*    |
*    |_Lines [132-151]: search_client(id): given an id as parameter.
*    |
*    |_Lines [154-175]: search_product(id): given an id as parameter.
*    |
*    |_Lines [177-195]: search_product_by_name(str): given a name.
*    |
*    |_Lines [198-221]: search_unique_product_list(orderid prodid):
*    |                  given an order and product, search that
*    |                  product in the order product_list.
*    |
*    |_Lines [224-247]: search_product_list(id): given an order id
*    |                  returns the list of products of that order.
*    |
*    |_Lines [249-263]: search_most_recent_order(id) given a client
*    |                  returns that client most recent order date.
*    |
*    |
*    |_Lines [265-283]: search_available_products(): returns every
*    |                  product available (quantity>0) in stock.
*    |   ----------------------------------------------------
*    |                [Insert/Update methods]
*    |
*    |_Lines [286-307]: add_new_product(str quan p): given the
*    |                  necessary parameters apart from the id of
*    |                  a new product, it inserts it in zproducts.
*    |
*    |_Lines [310-323]: update_stock(id quan): given one product id
*    |                  a quantity, it updates the ammount of that
*    |                  prod in stock by adding that quantity.
*    |
*    |_Lines [326-340]: update_product(ty_product): given a new
*    |                  product, it updates every attribute of it
*    |                  in the stock. Will fail if doesnt exist.
*    |   ----------------------------------------------------
*    |
*    |_Lines [343-408]: manual_interaction(): manually overrides
*                       approaches 1,2 and make operations by
*                       coding directly with subroutines calling.
*                       Non-recommended without any knowledge of
*                       ZCAFETEST workflow.

*   .....................

* -ZMAIN_F02: Contains every necessary subroutine for employee
* action retrieving statistics, apart from displaying the
* statistics, which is coded and handled inside the function
* ZMAIN_DISPLAY_USTATS. As of version 1.1.0, only the calcule
* methods for unitary statistics have been developed.

* (Note: Filtering by date condition is still developing.)

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [Average stats]
*    |
*    |_Lines [5-9]: average_ototal(): returns the average total
*    |              for the closed orders.
*    |
*    |_Lines [11-36]: average_prodo(): returns the average number
*    |                of products in the closed orders.
*    |
*    |_Lines [38-42]: average_oclient(): returns the average
*    |                number of closed orders done by a client.
*    |
*    |_Lines [55-70]: **average_csatis(): returns the average
*    |                client satisfaction rating.
*    |   ----------------------------------------------------
*    |                [Count stats]
*    |
*    |_Lines [52-159]: calcule_counts():
*    |     |
*    |     |_Types:
*    |     |    |_____ty_count_fw
*    |     |    |     |_______client_id      TYPE int 2
*    |     |    |     |_______n_orders       TYPE i
*    |     |    |     |_______n_fw           TYPE i
*    |     |    |
*    |     |    |_____ty_count_prod
*    |     |          |_______prod_id        TYPE int 2
*    |     |          |_______prod_name      TYPE ZDE_SLN
*    |     |          |_______prod_quantity  TYPE QUAN
*    |     |
*    |     |_Lines [69-86]: Data Initialization for stats
*    |     |                calculation process artifacts.
*    |     |
*    |     |_Lines [88-122]: for each order, take into account
*    |     |                 the total (for total gains counter),
*    |     |                 and the client (for the total FW
*    |     |                 raised events counter).
*    |     |
*    |     |_Lines [125-159]: looping through zodproducts table,
*    |                        take into account the quantity of
*    |                        each ordered product in every
*    |                        product list of every order (for
*    |                        the best and worst sellers)
*    |   ----------------------------------------------------
*    |
*    |_Lines [161-181]: calcule_unitary_stats(): makes the calls
*                       for the other methods in order. Is supossed
*                       to be the function called from outside when
*                       the need to calcule unitary stats arises.

*   .....................

* -ZMP_CAFETEST_F01: Contains every subroutine related to solve the
* global variable's naming within PBO/PAI include programs in the
* screen module program ZMP_CAFETEST. SAP considers every declared
* variablein those includes as a global variable as if they were in
* the TOPinclude program. For taking care of this matter, every method
* that creates new data or structures has been stored in a subroutine
* inside ZMAIN_F03. Nonetheless, the majority of these declarations
* were mandatory in the first place either to handle typing problems
* or to avoid changing the global variables directly.

* (Note: as of version 1.1.0 the original code has been commented
* yet not deleted from the PBO or PAI.)

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [PAI Subroutines]
*    |
*    |_Lines [6-13]: find_prod_id_230(id): given a product name
*    |               returns that product id (Screen 230)
*    |
*    |_Lines [15-24]: add_product_230(ty_product): inserts the new
*    |                product in the product list of the current
*    |                order. (Screen 230 - Client ordering action).
*    |
*    |_Lines [27-35]: find_prod_310(ty_product): given a product
*    |               name, returns its attributes (Screen 310).
*    |
*    |_Lines [37-58]: update_stock_310(ty_product x2): given an
*    |               existent product in stock and the updating
*    |               values, makes those updates in the DB.table.
*    |               (Screen 310 - Employee update stock action).
*    |
*    |_Lines [61-71]: add_product_320(ty_product): inserts the new
*    |                product in zproducts table. (Screen 2320 -
*    |                employee add new product to stock action).
*    |   ----------------------------------------------------
*    |                [PBO Subroutines]
*    |
*    |_Lines [74-87]: collect_product_315(ty-product): collects the
*    |              data to display a existent product.(Screen 315)
*    |
*    |_Lines [90-102]: collect_product_325(ty-product): collects the
*    |              data to display the changed product.(Screen 325)
*    |
*    |_Lines [105-130]: collect_product_330(ZST_STATS TIMS DATS):
*                   collets the data to display the retrieved stats,
*                   and also save the date and time. (Screen 330)

*   .....................

* -ZMANAGEMENT_F01: Contains every necessary subroutine for getting
* and making the data from both DB Tables and Excel Files. Every
* action related to Display, refresh, clearing and DB persistance
* for GRID ALV is also stored here.

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [Program Sections]
*    |
*    |_Lines [11-22]: initialize: file name header at selection-screen
*    |                and adding toolbar buttons functionality.
*    |
*    |_Lines [26-42]: selection_screen_output: Hide parameters and
*    |                search conditions at selection-screen depending
*    |                of chosen Upload method (Excel or DB Tables).
*    |
*    |_Lines [45-65]: get_u_filename: Pop-up browser to get the input
*    |                uploading excel file from the user.
*    |
*    |_Lines [68-86]: check_u_file: Aditional subroutine that verifies
*    |                the existence of the given excel filename and path.
*    |   ----------------------------------------------------
*    |                [GET & MAKE data subroutines]
*    |
*    |_Lines [94-162]: get_data: Retrieves data from DB Tables.
*    |     |
*    |     |_Lines [98-113]: Non-dynamic conditions Approach select queries
*    |     |                for non-master. Join of zcorders and zordproducts
*    |     |
*    |     |_Lines [117-132]: Non-dynamic conditions Approach select queries
*    |     |                 for master data.
*    |     |
*    |     |_Lines [134-135]: Call to prepare the dynamic conditions strings.
*    |     |
*    |     |_Lines [138-144]: Dynamic conditions Approach select queries
*    |     |                 for non-master. Join of zcorders and zordproducts
*    |     |
*    |     |_Lines [148-159]: Dynamic conditions Approach select queries
*    |                        for master data.
*    |
*    |_Lines [166-211]: make_data: With the retrieved rows as starting point,
*    |     |           loops through the results table filling empty fields
*    |     |           that required extra proccesing or where derivated from
*    |     |           DB tables data instead of being present in them.
*    |     |
*    |     |_Lines [172-181]: Looking for a coincidence in clients master
*    |     |                internal table and subsequent adding client fields.
*    |     |
*    |     |_Lines [183-194]: Looking for a coincidence in products master
*    |     |                internal table and subsequent adding product fields.
*    |     |
*    |     |_Lines [196-208]: Derivated fields, color scheme and modify sentence
*    |                        for that particular row up to results table.
*    |
*    |_Lines [214-330]: dynamic_conditions: With the inputs parameters from the,
*    |                 user as starting point, creates dynamically the WHERE
*    |                 conditions clausule for dynamic search approach.
*    |
*    |_Lines [333-366]: get_data_excel: Retrieves data from excel file.
*    |     |
*    |     |_Lines [342-359]: Call to external function that extracts raw data
*    |                       from excel file and store it inside an internal table.
*    |
*    |_Lines [369-501]: make_data_excel: With the raw data internal table result of
*    |     |                            previous method as starting point, transfer
*    |     |                            each field to results table. Reformat if needed.
*    |     |
*    |     |_Lines [370-382]: Local variables declaration and color scheme charge call.
*    |     |
*    |     |_Lines [385-393]: Detects a new row instead of a field for the previous one,
*    |     |                 appending the finished one and preparing for the next.
*    |     |
*    |     |_Lines [395-412]: Transfer to results table of Key & client fields as they are.
*    |     |
*    |     |_Lines [414-459]: Transfer to results table of DATE and TIME fields. Here
*    |     |                  reformating to YYYYMMDD / HHMMSS may be necessary.
*    |     |
*    |     |_Lines [461-494]: Transfer to results table of derivated & order & product
*    |                        fields. In QUAN fields ',' must be removed.
*    |
*    |_Lines [505-528]: search_order_list: Subroutine that makes the calls to the
*    |     |                            necessary get&make data forms and is called from
*    |     |                            outside.
*    |     |
*    |     |_Lines [507-510]: Excel get & make data methods calls.
*    |     |
*    |     |_Lines [513-527]: Get & make data method calls for default DB Table search.
*    |   ----------------------------------------------------
*    |                [ALV GRID SUBROUTINES]
*    |
*    |_Lines [534-549]: create_dcontainer: ALV GRID docking container creation.
*    |
*    |_Lines [552-567]: create_grid: ALV GRID grid creation.
*    |
*    |_Lines [650-668]: create_layout: ALV GRID layout creation. Zebra pattern, optimize
*    |                                 column width and column/row selection. Edit enabled
*    |                                 only in Management View.
*    |
*    |_Lines [671-809]: custom_colors: LVC colors table preparation. Blue for Key fields,
*    |                                 Red for Client fields, Yellow for Order fields,
*    |                                 Green for product fields and Orange for currency/unit.
*    |
*    |_Lines [812-981]: custom_fieldcat: LVC Fieldcatalog preparation. Order_ID, Order_count
*    |                                 Reg_status, Waers and Meins are not editable.
*    |
*    |_Lines [984-1017]: create_fieldcat: SLIS Fieldcatalog creation and subsequent conversion
*    |                                 to LVC FieldCatalog.
*    |
*    |_Lines [1020-1031]: custom_toolbar: Exclude non-used functions from ALV GRID toolbar.
*    |
*    |_Lines [1034-1046]: display_grid: Call for external method that display data in the grid
*    |                                  for the first time.
*    |
*    |_Lines [1050-1066]: refresh_grid: Refresh the ALV GRID.
*    |     |
*    |     |_Lines [1051-1054]: Hard Refresh, re-retrive data from DB Tables.
*    |     |
*    |     |_Lines [1057-1065]: Call for external function to refresh grid and flush.
*    |
*    |_Lines [1070-1091]: alv_write: Subroutine that displays information in ALV GRID.
*    |     |
*    |     |_Lines [1071-1077]: Displays for the first Time -> Creates every ALV Object.
*    |     |
*    |     |_Lines [1080-1085]: Display View hard and soft refresh calls.
*    |     |
*    |     |_Lines [1087-1090]: Management View soft refresh call.
*    |   ----------------------------------------------------
*    |                [DB TABLES PERSISTANCE SUBROUTINES]
*    |
*    |_Lines [1097-1120]: insert_row: New row insertion in DB Tables. It also prepares
*    |                                every field not up to be edited from the ALV GRID.
*    |
*    |_Lines [1122-1172]: delete_row: Delete Management View selected rows in DB Tables.
*    |     |
*    |     |_Lines [1123-1126]: Local variables for selected rows in ALV GRID.
*    |     |
*    |     |_Lines [1129-1130]: Call to external function to get selected rows in ALV GRID.
*    |     |
*    |     |_Lines [1132-1143]: Call to external function to confirm by Pop-up the deletion.
*    |     |
*    |     |_Lines [1145-1161]: Deletions sentences over DB Tables.
*    |     |_Lines [1169-1171]: Deletions sentences over Internal Results table.
*    |
*    |_Lines [1176-1249]: validate_check: Check given values prior to any saving method in DB.
*    |     |
*    |     |_Lines [1177-1182]: Local variables validation check.
*    |     |
*    |     |_Lines [1186-1188]: Call to external function to recollect any changes and apply
*    |     |                    them to results table before saving.
*    |     |
*    |     |_Lines [1190-1201]: Call to external function to confirm by Pop-up the saving.
*    |     |
*    |     |_Lines [1210-1217]: Loops through new or changed rows in results table checking
*    |     |                    input product data.
*    |     |
*    |     |_Lines [1220-1226]: Loops through new or changed rows in results table checking
*    |     |                    input client data.
*    |     |
*    |     |_Lines [1229-1246]: Loops through new or changed rows in results table checking
*    |                          input product data.
*    |
*    |_Lines [1252-1388]: save_changes: Save Management View changes into DB Tables.
*    |     |
*    |     |_Lines [1255-1256]: Call to previous input validation check subroutine.
*    |     |
*    |     |_Lines [1268-1277]: Changes on ZCLIENTS: Old client order_count update.
*    |     |
*    |     |_Lines [1280-1290]: Changes on ZCLIENTS: New client id calculation and insert.
*    |     |
*    |     |_Lines [1297-1308]: Changes on ZPRODUCTS: Old product details update.
*    |     |
*    |     |_Lines [1310-1324]: Changes on ZPRODUCTS: New product id calculation and insert.
*    |     |
*    |     |_Lines [1328-1338]: Changes on ZCORDERS:  New Closed Order data insert.
*    |     |
*    |     |_Lines [1342-1355]: Changes on ZORDPRODUCTS: New Order Product row insert and
*    |     |                                             disable changed and new flags.
*    |     |
*    |     |_Lines [1363-1376]: Changes on ZPRODUCTS: Old Order product details update and
*    |                                                disable changed and new flags.
*    |
*    |_Lines [1391-1408]: clearing: Clear Global variables and liberate memory space.

*   .....................

* -ZMANAGEMENT_F02: Contains every extra subroutine for getting
* and making the data from DB Tables with extra Search options derivated
* from adding the option to choose variables and SELECT JOIN approches.

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |           [GET & MAKE (DATA / OUTER) Subroutines]
*    |
*    |_Lines [12-80]: get_data_outer: Retrieves data from DB Tables. Variables-> DATA
*    |     |                                                       SELECT JOIN-> OUTER
*    |     |
*    |     |_Lines [18-31]: Non-dynamic conditions Approach select queries
*    |     |              for non-master. LEFT OUTER Join of zcorders and zordproducts
*    |     |
*    |     |_Lines [35-50]: Non-dynamic conditions Approach select queries
*    |     |                 for master data.
*    |     |
*    |     |_Lines [52-53]: Call to prepare the dynamic conditions strings.
*    |     |
*    |     |_Lines [56-62]: Dynamic conditions Approach select queries
*    |     |              for non-master. LEFT OUTER Join of zcorders and zordproducts
*    |     |
*    |     |_Lines [66-77]: Dynamic conditions Approach select queries
*    |                       for master data.
*    |   ----------------------------------------------------
*    |           [GET & MAKE (ZREDU1XX APPROACH) Subroutines]
*    |
*    |_Lines [87-139]: "ZREDU1XX Search Method Explanation"
*    |
*    |_Lines [143-340]: get_data_type: Retrieves data from DB Tables. Variables-> TYPE
*    |     |                                                        SELECT JOIN-> INNER/OUTER
*    |     |
*    |     |_Lines [150-193]: Local Types and Variable Declaration
*    |     |     |
*    |     |     |_Types:   ty_corder , ty_ordproduct, ty_master_client, ty_master_product
*    |     |     |_T.Types: tt_corders, tt_ordproducts, tt_master_clients, tt_master_products
*    |     |     |
*    |     |     |_Internal Tables:
*    |     |     |       |__lt_corders         TYPE tt_corders  WITH HEADER LINE (Line Row embedded)
*    |     |     |       |__lt_ordproducts     TYPE tt_ordproducts WITH HEADER LINE (Line Row embedded)
*    |     |     |       |__lt_master_clients  TYPE tt_master_clients WITH HEADER LINE (Line Row embedded)
*    |     |     |       |__lt_master_products TYPE tt_master_products WITH HEADER LINE (Line Row embedded)
*    |     |     |
*    |     |     |_Arquetypical Variables:
*    |     |             |__lv_tabix           TYPE sy-tabix    Index for the found match row
*    |     |             |__lv_where_co        TYPE string      dynamic conditions string for lt_corders
*    |     |             |__lv_where_op        TYPE string      dynamic conditions string for lt_ordproducts
*    |     |     
*    |     |_Lines [197-218]: Non-Dynamic-> Individual SELECT queries for both zcorders and zordproducts
*    |     |
*    |     |_Lines [221-250]: Non-Dynamic->While looping through one of the internal tables(INTO HEADER LINE):
*    |     |     |
*    |     |     |_Lines [222-223]: take displayable fields (couldnt be done directly over gt_results)
*    |     |     |_Lines [225-228]: Binary search for a match in the other internal table. If match, keep
*    |     |     |                  the index, if not and OUTER option is enabled, append the row anyways.
*    |     |     | 
*    |     |     |_Lines [241-250]: Loop through the other table from the saved index. Taking displayable
*    |     |                        fields present in the second table and appending the Row to results.
*    |     |
*    |     |_Lines [254-271]: Non-dynamic conditions Approach select queries
*    |     |                 for master data.         
*    |     |
*    |     |_Lines [273-274]: Call to prepare the dynamic conditions strings (different from DATA Approach)
*    |     |     
*    |     |_Lines [277-288]: Dynamic-> Individual SELECT queries for both zcorders and zordproducts
*    |     |
*    |     |_Lines [291-320]: Dynamic->While looping through one of the internal tables(INTO HEADER LINE):
*    |     |     |
*    |     |     |_Lines [292-293]: take displayable fields (couldnt be done directly over gt_results)
*    |     |     |_Lines [295-298]: Binary search for a match in the other internal table. If match, keep
*    |     |     |                  the index, if not and OUTER option is enabled, append the row anyways.
*    |     |     | 
*    |     |     |_Lines [311-318]: Loop through the other table from the saved index. Taking displayable
*    |     |                        fields present in the second table and appending the Row to results.
*    |     |
*    |     |_Lines [324-337]: Dynamic conditions Approach select queries
*    |                        for master data.         
*    |     
*    |_Lines [345-541]: get_data_line: Retrieves data from DB Tables. Variables-> TYPE + Line Var.
*    |     |                                                        SELECT JOIN-> INNER/OUTER
*    |     |
*    |     |_Lines [348-395]: Local Types and Variable Declaration
*    |     |     |
*    |     |     |_Types:   ty_corder , ty_ordproduct, ty_master_client, ty_master_product
*    |     |     |_T.Types: tt_corders, tt_ordproducts, tt_master_clients, tt_master_products
*    |     |     |
*    |     |     |_Internal Tables:
*    |     |     |       |__lt_corders         TYPE tt_corders  
*    |     |     |       |__lt_ordproducts     TYPE tt_ordproducts
*    |     |     |       |__lt_master_clients  TYPE tt_master_clients 
*    |     |     |       |__lt_master_products TYPE tt_master_products 
*    |     |     |
*    |     |     |_Arquetypical Variables:
*    |     |             |__lv_tabix           TYPE sy-tabix    Index for the found match row
*    |     |             |__lv_where_co        TYPE string      dynamic conditions string for lt_corders
*    |     |             |__lv_where_op        TYPE string      dynamic conditions string for lt_ordproducts
*    |     |             |__ls_corder          TYPE ty_corder          Orders Local Internal Table Line
*    |     |             |__ls_ordproduct      TYPE ty_ordproduct      Ordproducts Local Internal Table Line
*    |     |             |__ls_master_client   TYPE ty_master_client   Clients Local Internal Table Line
*    |     |             |__ls_master_product  TYPE ty_master_product  Products Local Internal Table Line
*    |     |     
*    |     |_Lines [402-420]: Non-Dynamic-> Individual SELECT queries for both zcorders and zordproducts
*    |     |
*    |     |_Lines [423-452]: Non-Dynamic->While looping through one of the internal tables INTO Line Var. :
*    |     |     |
*    |     |     |_Line  [424]:     Take displayable fields to gs_result
*    |     |     |_Lines [427-430]: Binary search for a match in the other internal table. If match, keep
*    |     |     |                  the index, if not and OUTER option is enabled, append the row anyways.
*    |     |     | 
*    |     |     |_Lines [443-450]: Loop through the other table from the saved index. Taking displayable
*    |     |                        fields present in the second table and appending the Row to results.
*    |     |
*    |     |_Lines [456-473]: Non-dynamic conditions Approach select queries
*    |     |                 for master data.         
*    |     |
*    |     |_Lines [475-476]: Call to prepare the dynamic conditions strings (different from DATA Approach)
*    |     |     
*    |     |_Lines [479-490]: Dynamic-> Individual SELECT queries for both zcorders and zordproducts
*    |     |
*    |     |_Lines [493-521]: Dynamic->While looping through one of the internal tables INTO Line Var. :
*    |     |     |
*    |     |     |_Line  [494]:     Take displayable fields to gs_result
*    |     |     |_Lines [496-500]: Binary search for a match in the other internal table. If match, keep
*    |     |     |                  the index, if not and OUTER option is enabled, append the row anyways.
*    |     |     | 
*    |     |     |_Lines [513-519]: Loop through the other table from the saved index. Taking displayable
*    |     |                        fields present in the second table and appending the Row to results.
*    |     |
*    |     |_Lines [525-538]: Dynamic conditions Approach select queries
*    |                        for master data.         
*    |
*    |_Lines [545-743]: get_data_fsym: Retrieves data from DB Tables. Variables-> <FIELD-SYMBOLS>.
*    |     |                                                        SELECT JOIN-> INNER/OUTER
*    |     |
*    |     |_Lines [548-599]: Local Types and Variable Declaration
*    |     |     |
*    |     |     |_Types:   ty_corder , ty_ordproduct, ty_master_client, ty_master_product
*    |     |     |_T.Types: tt_corders, tt_ordproducts, tt_master_clients, tt_master_products
*    |     |     |
*    |     |     |_Internal Tables:
*    |     |     |       |__lt_corders         TYPE tt_corders  
*    |     |     |       |__lt_ordproducts     TYPE tt_ordproducts
*    |     |     |       |__lt_master_clients  TYPE tt_master_clients 
*    |     |     |       |__lt_master_products TYPE tt_master_products 
*    |     |     |
*    |     |     |_Arquetypical Variables:
*    |     |     |       |__lv_tabix           TYPE sy-tabix    Index for the found match row
*    |     |     |       |__lv_where_co        TYPE string      dynamic conditions string for lt_corders
*    |     |     |       |__lv_where_op        TYPE string      dynamic conditions string for lt_ordproducts
*    |     |     |       |__ls_corder          TYPE ty_corder          Orders Local Internal Table Line
*    |     |     |       |__ls_ordproduct      TYPE ty_ordproduct      Ordproducts Local Internal Table Line
*    |     |     |       |__ls_master_client   TYPE ty_master_client   Clients Local Internal Table Line
*    |     |     |       |__ls_master_product  TYPE ty_master_product  Products Local Internal Table Line
*    |     |     |
*    |     |     |_Field Symbols:
*    |     |             |__<FS_CORDER>        STRUCTURE ls_corder    FieldSymbol Pointer for Order Table  
*    |     |             |__lt_ordproducts     TYPE ty_ordproduct   FieldSymbol Pointer for Ordproducts Table
*    |     |     
*    |     |_Lines [606-624]: Non-Dynamic-> Individual SELECT queries for both zcorders and zordproducts
*    |     |
*    |     |_Lines [627-655]: Non-Dynamic->While looping through one of the internal tables Assigning Pointers
*    |     |     |
*    |     |     |_Line  [628]:     Take displayable fields to gs_result from the Pointer 
*    |     |     |_Lines [630-633]: Binary search for a match in the other internal table. If match, keep
*    |     |     |                  the index, if not and OUTER option is enabled, append the row anyways.
*    |     |     | 
*    |     |     |_Lines [646-653]: Loop through the other table from the saved index. Taking displayable
*    |     |                        fields present in the second table and appending the Row to results.
*    |     |
*    |     |_Lines [659-676]: Non-dynamic conditions Approach select queries
*    |     |                 for master data.         
*    |     |
*    |     |_Lines [678-679]: Call to prepare the dynamic conditions strings (different from DATA Approach)
*    |     |     
*    |     |_Lines [682-693]: Dynamic-> Individual SELECT queries for both zcorders and zordproducts
*    |     |
*    |     |_Lines [696-723]: Dynamic->While looping through one of the internal table Assigning Pointers:
*    |     |     |
*    |     |     |_Line  [697]:     Take displayable fields to gs_result from Pointer
*    |     |     |_Lines [699-702]: Binary search for a match in the other internal table. If match, keep
*    |     |     |                  the index, if not and OUTER option is enabled, append the row anyways.
*    |     |     | 
*    |     |     |_Lines [715-721]: Loop through the other table from the saved index. Taking displayable
*    |     |                        fields present in the second table and appending the Row to results.
*    |     |
*    |     |_Lines [727-740]: Dynamic conditions Approach select queries
*    |                        for master data.         
*    | 
*    |_Lines [746-869]: dynamic_conditions_indv (where_co, where_op): Calcules WHERE conditions dynamically
*    | 
*    |_Lines [873-898]: all_ids: Aditional SELECT queries to store hashed internal tables of every product
*    |                          and client in DB, even if the user input search filters. Used to check 
*    |                          for existence and the next available id when saving changes in Management V.
*    |
*    |_Lines [903-976]: search_order_list_ext: Subroutine that makes the calls to the
*          |                            necessary get&make data forms and is called from
*          |                            outside. Also Calls its homonym in F01.
*          |
*          |_Lines [908-928]: VARIABLES = DATA Approach
*          |     |
*          |     |_Line  [909-913]: SELECT JOIN = INNER -> Version 1.2.0 search_order_list form
*          |     |                                         + Extra SELECT queries for Management View
*          |     |
*          |     |_Line  [914-928]: SELECT JOIN = OUTER -> get_data_outer Call
*          |                                               + Extra SELECT queries for Management View
*          |                                               + Version 1.2.0 Color Scheme and make_data
*          |
*          |_Lines [930-943]: VARIABLES = TYPE Approach
*          |     |
*          |     |_Line  [931]:     SELECT JOIN = BOTH  -> get_data_type Call
*          |                                               + Extra SELECT queries for Management View
*          |                                               + Version 1.2.0 Color Scheme and make_data
*          |
*          |_Lines [945-958]: VARIABLES = TYPE + Line var. Approach
*          |     |
*          |     |_Line  [931]:     SELECT JOIN = BOTH  -> get_data_line Call
*          |                                               + Extra SELECT queries for Management View
*          |                                               + Version 1.2.0 Color Scheme and make_data
*          |_Lines [960-973]: VARIABLES = <FIELD-SYMBOLS>  Approach
*                |
*                |_Line  [931]:     SELECT JOIN = BOTH  -> get_data_fsym Call
*                                                          + Extra SELECT queries for Management View
*                                                          + Version 1.2.0 Color Scheme and make_data


* __________________PBO and PAI Logic:____________________________

* -ZMP_CAFETEST_O01: Contains every module for ZMP_CAFETEST that is
* lauched automatically everytime a screen is loaded. All of them
* either windows setup or collecting method for output fields.

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [Status modules]
*    |
*    |_Lines [5-59]: Screens 100-330 status setup modules. They link
*    |               every window with its specific status.
*    |
*    |_Lines [61-71]: create_order_230(): creates an order from
*    |                scratch. (Screen 230 - Client Ordering action)
*    |   ----------------------------------------------------
*    |                [Retrieve modules]
*    |
*    |_Lines [73-138]: retrieve methods for output fields. Calls for
*                      collecting methods in ZMAIN_F03.

*   .....................

* -ZMP_CAFETEST_I01: Contains every module for ZMP_CAFETEST that is
* launched automatically after any button press from the user. Both
* the modules for handling each button option and later retrieval of
* the introduced values in the output/input fields.

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [Initial Screen]         Action:
*    |
*    |_Lines [6-16]: user_command_100:
*    |                   |_____CLIENT_ACT      Go to Client Area
*    |                   |_____EMPLOYEE_ACT    Go to Employee Area
*    |                   |_____EXIT            Exit Program
*    |   ----------------------------------------------------
*    |                [Client Screens]         Action:
*    |
*    |_Lines [19-31]: user_command_200:
*    |                   |_____NEW_CLIENT      Go to Register screen
*    |                   |_____COMEBACK        Go to Log in screen
*    |                   |_____BACK            Return to Initial M.
*    |                   |_____EXIT            Exit Program
*    |
*    |_Lines [34-37]: retrieve_input_values_210: Shows the chosen
*    |                name/lastname for registering layout.
*    |
*    |_Lines [39-59]: user_command_210:
*    |                   |_____CANCEL           Return to Client M.
*    |                   |_____REGISTER_CLIENT  ->Register Client
*    |
*    |_Lines [62-68]: user_command_215:
*    |                   |_____ORDER           Go to Ordering screen
*    |
*    |_Lines [71-75]: retrieve_input_values_220: Shows chosen name/
*    |               lastname/ID. Retrieving for login layout.
*    |
*    |_Lines [77-95]: user_command_220:
*    |                   |_____CANCEL         Return to Client M.
*    |                   |_____LOGIN          ->Login old Client
*    |
*    |_Lines [97-104]: user_command_225:
*    |                   |_____ORDER           Go to Ordering screen
*    |
*    |_Lines [107-121]: retrieve_input_values_230: Shows chosen prod
*    |               information and payment method/current total for
*    |               the order. Retrieving for ordering layout.
*    |
*    |_Lines [123-154]: user_command_230:
*    |                   |_____ADD_PRODUCT    ->Add product to order
*    |                   |_____ONEW_ORDER     ->Close Order
*    |                   |_____LOG_OUT        Go to Log Out screen
*    |
*    |_Lines [157-179]: user_command_290:
*    |                   |_____BACK           Return to Initial M.
*    |                                        + Clear global var.
*    |   ----------------------------------------------------
*    |                [Employee Screens]       Action:
*    |
*    |_Lines [182-196]: user_command_300:
*    |                   |_____UPDATE_STOCK    Go to UpdateS screen
*    |                   |_____ADD_NEW_PROD    Go to Add new screen
*    |                   |_____STATS           Go to stats screen
*    |                   |_____BACK            Return to Initial M.
*    |                   |_____EXIT            Exit Program
*    |
*    |_Lines [199-221]: retrieve_input_values_310: Shows existent
*    |               and new values for the product in AddP layout.
*    |
*    |_Lines [223-258]: user_command_310:
*    |                   |_____UPDATE_STOCK   ->Update product info
*    |                   |_____CANCEL         Return to Employee M.
*    |                                        + Clear global var.
*    |
*    |_Lines [261-270]: user_command_315:
*    |                   |_____BACK           Return to Employee M.
*    |                                        + Clear global var.
*    |
*    |_Lines [273-277]: retrieve_input_values_320: Shows product
*    |                values for Add product to stock layout.
*    |
*    |_Lines [279-306]: user_command_320:
*    |                   |_____ADD_PROD       ->Add prod to stock
*    |                   |_____CANCEL         Return to Employee M.
*    |                                        + Clear global var.
*    |
*    |_Lines [309-317]: user_command_325:
*    |                   |_____BACK           Return to Employee M.
*    |                                        + Clear global var.
*    |
*    |_Lines [320-327]: user_command_330:
*                        |_____BACK           Return to Employee M.
*                                             + Clear global var.

*   .....................

* -ZMANAGEMENT_O01: Contains every module for ZMANAGEMENT that is
* lauched automatically everytime a screen is loaded. All of them
* either windows setup or ALV Write methods.

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [Status modules]
*    |
*    |_Lines [5-8]: status_100: Screen 100 status setup modules. They link
*    |               it with its specific GUI status and GUI Title.
*    |
*    |_Lines [14-17]: status_200: Screen 200 status setup modules. They link
*    |               it with its specific GUI status and GUI Title.
*    |   ----------------------------------------------------
*    |                [Write modules]
*    |
*    |_Lines [10-12]: alv_write_100: Screen 100 display grid initial call to
*    |               ALV GRID write subroutine in ZMANAGEMENT_F01.
*    |
*    |_Lines [19-21]: alv_write_200: Screen 200 display grid initial call to
*                    ALV GRID write subroutine in ZMANAGEMENT_F01.

*   .....................

* -ZMANAGEMENT_I01: Contains every module for ZMANAGEMET that is
* launched automatically after any button press from the user, those
* are, the modules for handling each button option.

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [Initial Screen]         Action:
*    |
*    |_Lines [8-21]: user_command_100:
*    |                   |_____ZREFRESH      ->Refreshes the Grid
*    |
*    |_Lines [23-55]: exit_command_100:
*    |                   |_____BACK,CANCEL   Return to Selection-Screen
*    |                   |                   + Clear global var.
*    |                   |_____EXIT          Exit Program
*    |
*    |_Lines [60-84]: user_command_200:
*    |                   |_____ZREFRESH      ->Refreshes the Grid
*    |                   |_____ZADD          ->Append new Row
*    |                   |                   + Clear global var.
*    |                   |_____ZDELETE       ->Delete selected rows from DB
*    |                   |                   + Clear global var.
*    |                   |_____ZSAVE         ->Save changes into DB table
*    |                                       + Clear global var.
*    |
*    |_Lines [86-116]: exit_command_200:
*                        |_____BACK,CANCEL   Return to Selection-Screen
*                        |                   + Clear global var.
*                        |_____EXIT          Exit Program


* ___________Screen-Selection Input Logic SCR:____________________

* -ZMAIN_SCR: Contains input values for the screen-selection section
* of ZMAIN_PROGRAM. Taking the first approach, the creation/update
* chosen values or necessary initial parameters are correctly
* defined here.

* -Reading by abstraction help:
*    |
*    |_Lines [6-10]: Aditional flags, working areas to handle input
*    |               parameters selection and storage.
*    |   ----------------------------------------------------
*    |                [Block 1]
*    |
*    |_Lines [12-19]:
*    |            |___Parameters:
*    |                   |_____e_name     Product name
*    |                   |_____e_quan     Product Quantity
*    |                   |_____e_price    Product price
*    |                   |_____e_oldp     '': Add product to stock
*    |                   |                X: Update stock product
*    |                   |
*    |                   |_____e_pid      Existing Product ID
*    |                   |_____s_stats    '': Not retrieve stats
*    |                                    X: Retrieve stats
*    |   ----------------------------------------------------
*    |                [Block 2]
*    |
*    |_Lines [21-26]:
*    |            |___Parameters:
*    |                   |_____p_name     Client name
*    |                   |_____p_lname    Client lastname
*    |                   |_____p_oldc     '': New Client register
*    |                   |                X: Old client comeback
*    |                   |
*    |                   |_____p_cid      Existing Client ID
*    |   ----------------------------------------------------
*    |                [Block 3]
*    |
*    |_Lines [28-33]:
*    |            |___Parameters:
*    |            |      |_____p_paym     Order payment method
*    |            |      |_____p_quan     Order prod quantity
*    |            |
*    |            |___Select-options:
*    |            |      |_____s_prod     '': New Client register
*    |            |                       X: Old client comeback
*    |            |___Pushbuttons:
*    |                   |_____p_caddp    ->Add product to order
*    |   ----------------------------------------------------
*    |
*    |_Lines [39-40]:
*                 |___Parameters:
*                        |_____p_exec     ->Register new Client
*                                         ->Log in old Client
*                                         ->Close order
*                                         ->Add product to Stock
*                                         ->Update stock product
*                                         ->Retrieve Stats

*   .....................

* -ZMANAGEMENT_SCR: Contains input values for the screen-selection section
* of ZMANAGEMENT. Chosing the desired Upload Method, View Mode and Data
* Search Approach, as well with the search conditions if needed.

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [Block 1] (Always Visible)
*    |
*    |_Lines [7-10]:
*    |            |___Radiobuttons:
*    |                   |_____r_sear     DB Search Upload Method  (Default)
*    |                   |_____r_exce     Excel File upload Method
*    |
*    |   ----------------------------------------------------
*    |                [Block 2] (Visible if SearchDB)
*    |
*    |_Lines [14-29]:
*    |            |___Select-options:
*    |                   |_____s_ordid    Order Id
*    |                   |_____s_clid     Client Id
*    |                   |_____s_cname    Client Name
*    |                   |_____s_clname   Client Last Name
*    |                   |_____s_ocount   Client Order Count
*    |                   |_____s_odate    Order Date
*    |                   |_____s_otime    Order Time
*    |                   |_____s_total    Order Total
*    |                   |_____s_paym     Order Payment Method
*    |                   |_____s_proid    Product Id
*    |                   |_____s_pname    Product Name
*    |                   |_____s_pprice   Product Price
*    |                   |_____s_stock    Product Stock
*    |                   |_____s_pquan    Order Product Quantity
*    |
*    |   ----------------------------------------------------
*    |                [Block 3]  (Visible if SearchDB)
*    |
*    |_Lines [31-41]:
*    |            |___Radiobuttons:
*    |                   |_____r_dis      Display View (Default)
*    |                   |_____r_mng      Management View
*    |
*    |   ----------------------------------------------------
*    |                [*Block 4] (Visible if SearchDB)
*    |
*    |_Lines [43-68]:
*    |            |___Radiobuttons:
*    |                   |_____*r_ov      Overall  (Default)
*    |                   |_____*r_cl      Initial Table: zclients
*    |                   |_____*r_co      Initial Table: zcorders
*    |                   |_____*r_pr      Initial Table: zproducts
*    |                   |_____*r_op      Initial Table: zordproducts
*    |
*    |   ----------------------------------------------------
*    |                [Block 5]  (Visible if SearchDB)
*    |
*    |_Lines [70-73]:
*    |            |___Radiobuttons:
*    |                   |_____r_ndyn     Non-Dynamic Cond. Approach (Default)
*    |                   |_____r_dyn      Dynamic Conditions Approach
*    |
*    |   ----------------------------------------------------
*    |                [Block 6]  (Visible if Excel file Upload)
*    |
*    |_Lines [77-79]:
*    |            |___Parameters:
*    |                   |_____p_ufile    Uploading Excel File Path
*    |
*    |   ----------------------------------------------------
*    |                [Block 7]  (Visible if Search DB)
*    |
*    |_Lines [81-86]:
*    |            |___Radiobuttons:
*    |                   |_____r_data      DATA Variables approach  (Default)
*    |                   |_____r_type      TYPES Variables approach
*    |                   |_____r_line      TYPES + Line Variables approach
*    |                   |_____r_fsym      <FIELD-SYMBOLS> pointer approach
*    |
*    |    ----------------------------------------------------
*    |                [Block 8]  (Visible if Search DB)
*    |
*    |_Lines [88-91]:
*    |            |___Radiobuttons:
*    |                   |_____r_inner     INNER JOIN   (Default)
*    |                   |_____r_outer     LEFT OUTER JOIN
*    |
*    |    ----------------------------------------------------
*    |_Lines [93]: *Function Key 1: for additional toolbar buttons.