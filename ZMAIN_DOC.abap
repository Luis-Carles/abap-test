*&---------------------------------------------------------------------*
*& Report  ZMAIN_DOC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZMAIN_DOC.

START-OF-SELECTION.
  FORMAT COLOR OFF.
  
  FORMAT COLOR 2.
  WRITE: / 'CAFETERIA TEST PROJECT'.
  WRITE: / 'by Luis Carles Dura'.
  WRITE: / 'at DBDS 2/14/2025', /.
  WRITE: / 'https://github.com/Luis-Carles/abap-test'.
  WRITE: / 'version 1.0', /, /, /.

  " Package Information

  " ABAP DICTIONARY:
  " Programs
  " Includes + Modularization Explained
  " Structures, Domains and Data elements

  " Database Tables
  WRITE: / 'ER Model for Database Tables:', /.

  WRITE: / '  +------------------+'.
  WRITE: / '  |   ZCLIENTS       |'.
  WRITE: / '  +------------------+'.
  FORMAT COLOR 4.
  WRITE: / '  | CLIENT_ID (PK)   |'.
  FORMAT COLOR 2.
  WRITE: / '  | CLIENT_NAME      |'.
  WRITE: / '  | CLIENT_LAST_NAME |'.
  WRITE: / '  | ORDER_COUNT      |'.
  WRITE: / '  +------------------+'.

  FORMAT COLOR 3.
  WRITE: / '        |1'.
  WRITE: / '        |'.
  WRITE: / '        | n'.
  FORMAT COLOR 2.
  WRITE: / '  +------------------+'.
  WRITE: / '  |   ZCORDERS       |'.
  WRITE: / '  +------------------+'.
  FORMAT COLOR 4.
  WRITE: / '  | ORDER_ID (PK)    |'.
  FORMAT COLOR 2.
  WRITE: / '  | TOTAL            |'.
  WRITE: / '  | ORDER_DATE       |'.
  FORMAT COLOR 4.
  WRITE: / '  | ORDER_CLIENT (FK)|'.
  FORMAT COLOR 2.
  WRITE: / '  +------------------+'.

  FORMAT COLOR 3.
  WRITE: / '        |1'.
  WRITE: / '        |'.
  WRITE: / '        | n'.
  FORMAT COLOR 2.
  WRITE: / '  +------------------+'.
  WRITE: / '  | ZORDPRODUCTS     |'.
  WRITE: / '  +------------------+'.
  FORMAT COLOR 4.
  WRITE: / '  | ORDER_ID (FK)    |'.
  WRITE: / '  | PROD_ID (FK)     |'.
  FORMAT COLOR 2.
  WRITE: / '  | PROD_QUANTITY    |'.
  WRITE: / '  +------------------+'.

  FORMAT COLOR 3.
  WRITE: / '        |n'.
  WRITE: / '        |'.
  WRITE: / '        | m'.
  FORMAT COLOR 2.
  WRITE: / '  +------------------+'.
  WRITE: / '  |   ZPRODUCTS      |'.
  WRITE: / '  +------------------+'.
  FORMAT COLOR 4.
  WRITE: / '  | PROD_ID (PK)     |'.
  FORMAT COLOR 2.
  WRITE: / '  | PROD_NAME        |'.
  WRITE: / '  | PROD_QUANTITY    |'.
  WRITE: / '  | PROD_PRICE       |'.
  WRITE: / '  +------------------+'.

  FORMAT COLOR OFF.

  " Classes + Event OOP
  " Soubroutines
  " Functions

  " Future of the TEST Project