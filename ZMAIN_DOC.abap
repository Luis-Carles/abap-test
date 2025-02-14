*&---------------------------------------------------------------------*
*& Report  ZMAIN_DOC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZMAIN_DOC.

START-OF-SELECTION.

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
  FORMAT COLOR OFF.

  WRITE: / '  +------------------+'.
  WRITE: / '  |   ZCLIENTS       |'.
  WRITE: / '  +------------------+'.
  FORMAT COLOR 1.
  WRITE: / '  | CLIENT_ID (PK)   |'.
  FORMAT COLOR OFF.
  WRITE: / '  | CLIENT_NAME      |'.
  WRITE: / '  | CLIENT_LAST_NAME |'.
  WRITE: / '  | ORDER_COUNT      |'.
  WRITE: / '  +------------------+'.

  WRITE: / '        |1'.
  FORMAT COLOR 2.
  WRITE: / '        |'.
  WRITE: / '        | n'.
  FORMAT COLOR OFF.
  WRITE: / '  +------------------+'.
  WRITE: / '  |   ZCORDERS       |'.
  WRITE: / '  +------------------+'.
  FORMAT COLOR 1.
  WRITE: / '  | ORDER_ID (PK)    |'.
  FORMAT COLOR OFF.
  WRITE: / '  | TOTAL            |'.
  WRITE: / '  | ORDER_DATE       |'.
  WRITE: / '  | ORDER_CLIENT (FK)|'.
  WRITE: / '  +------------------+'.

  WRITE: / '        |1'.
  FORMAT COLOR 2.
  WRITE: / '        |'.
  WRITE: / '        | n'.
  FORMAT COLOR OFF.
  WRITE: / '  +------------------+'.
  WRITE: / '  | ZORDPRODUCTS     |'.
  WRITE: / '  +------------------+'.
  FORMAT COLOR 1.
  WRITE: / '  | ORDER_ID (FK)    |'.
  WRITE: / '  | PROD_ID (FK)     |'.
  FORMAT COLOR OFF.
  WRITE: / '  | PROD_QUANTITY    |'.
  WRITE: / '  +------------------+'.

  WRITE: / '        |n'.
  FORMAT COLOR 2.
  WRITE: / '        |'.
  WRITE: / '        | m'.
  FORMAT COLOR OFF.
  WRITE: / '  +------------------+'.
  WRITE: / '  |   ZPRODUCTS      |'.
  WRITE: / '  +------------------+'.
  FORMAT COLOR 1.
  WRITE: / '  | PROD_ID (PK)     |'.
  FORMAT COLOR OFF.
  WRITE: / '  | PROD_NAME        |'.
  WRITE: / '  | PROD_QUANTITY    |'.
  WRITE: / '  | PROD_PRICE       |'.
  WRITE: / '  +------------------+'.

  FORMAT COLOR OFF.

  " Classes + Event OOP
  " Soubroutines
  " Functions

  " Future of the TEST Project