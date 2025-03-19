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
*                                      It includes ZMAIN_TOP
*                                                  ZMAIN_CLS
*                                                  ZMANAGEMENT_O01
*                                                  ZMANAGEMENT_TOP
*                                                  ZMANAGEMENT_ALV
*                                                  ZMANAGEMENT_SCR
*                                                  ZMANAGEMENT_F01
*                                                  ZMANAGEMENT_O01
*                                                  ZMANAGEMENT_I01

* Screen 100 ------> Display View
* Screen 200 ------> Management View

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
* |                         |                       }____|_______|
* |__ZMANAGEMENT_ALV        |__ZMAIN_CLS            }    |
* |                         |    |                  }    |
* |__ZMANAGEMENT_SCR        |    |__ZMAIN_F01       }    |__ZMAIN_F03
* |                         |                       }    |
* |__ZMANAGEMENT_F01        |__ZMAIN_F02           _}    |
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


* __________________PBO and PAI Logic:____________________________

* -ZMP_CAFETEST_O01: Contains every module for ZMP_CAFETEST that is
* lauched automatically everytime a screen is loaded. All of them
* either windows setup or collecting method for output fields.

* -Reading by abstraction help:
*    |   ----------------------------------------------------
*    |                [Status modules]
*    |
*    |_Lines [5-59]: Screens 100-330 status stup modules. They link
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
*    |                [Block 2]
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