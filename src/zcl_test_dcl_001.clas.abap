CLASS zcl_test_dcl_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_test_dcl_001 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " 1. 通常アクセス（DCLによる権限チェックが介入する）
    SELECT * FROM zi_employee_001
      INTO TABLE @DATA(lt_standard).

    " 2. 特権アクセス（DCLの権限チェックをバイパスする）
    SELECT * FROM zi_employee_001 WITH PRIVILEGED ACCESS
      INTO TABLE @DATA(lt_privileged).

    " 結果の出力
    out->write( '--- DCL Authorization Test ---' ).
    out->write( |1. Standard SELECT (Auth Checked) : { lines( lt_standard ) } records| ).
    out->write( |2. Privileged SELECT (Bypassed)   : { lines( lt_privileged ) } records| ).

  ENDMETHOD.

ENDCLASS.
