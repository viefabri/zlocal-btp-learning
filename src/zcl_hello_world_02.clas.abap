CLASS zcl_hello_world_02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HELLO_WORLD_02 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    " コンソールへの出力
    out->write( 'Hello World from SAP BTP!' ).
  ENDMETHOD.
ENDCLASS.
