CLASS zcl_generate_dept_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_generate_dept_001 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_departments TYPE TABLE OF zdepartment_001.

    " 1. 既存データをクリア
    DELETE FROM zdepartment_001.

    " 2. データ生成
    lt_departments = VALUE #(
      ( dept_id = 'D01' dept_name = 'Sales Dept (営業部)' )
      ( dept_id = 'D02' dept_name = 'Dev Dept (開発部)' )
      ( dept_id = 'D03' dept_name = 'HR Dept (人事部)' )
      ( dept_id = 'D04' dept_name = 'Acct Dept (経理部)' )
    ).

    " 3. DBへ挿入
    INSERT zdepartment_001 FROM TABLE @lt_departments.

    " 4. 結果出力
    out->write( |Inserted { sy-dbcnt } entries into ZDEPARTMENT_001| ).
  ENDMETHOD.
ENDCLASS.
