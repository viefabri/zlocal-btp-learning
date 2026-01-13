CLASS zcl_generate_data_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_generate_data_001 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
      DATA: lt_employees TYPE TABLE OF zemployee_001.

    " 1. 既存データをクリア
    DELETE FROM zemployee_001.

    " 2. データ生成 (コンストラクタ式 VALUE #)
    lt_employees = VALUE #(
      ( emp_id = '100001' first_name = '一郎' last_name = '鈴木'   email = 'suzuki@test.com' join_date = '20150401' salary = '8000000' currency_code = 'JPY' )
      ( emp_id = '100002' first_name = '太郎'    last_name = '山田' email = 'taro@test.com' join_date = '20201001' salary = '5000000' currency_code = 'JPY' )
      ( emp_id = '100003' first_name = '花子'  last_name = '佐藤'   email = 'hana@test.com' join_date = '20230401' salary = '4500000' currency_code = 'JPY' )
    ).

    " 3. DBへ挿入
    INSERT zemployee_001 FROM TABLE @lt_employees.

    " 4. 結果出力
    out->write( |Inserted { sy-dbcnt } entries into ZEMPLOYEE_001| ).
  ENDMETHOD.
ENDCLASS.
