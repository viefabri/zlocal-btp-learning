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
    DATA:
      lt_employees TYPE TABLE OF zemployee_001,
      lf_ts        TYPE zemployee_001-last_changed_at,
      lf_user      TYPE zemployee_001-created_by. " 作成者項目の型に合わせる

    " 0. 共通変数の準備 (現在日時と実行ユーザー)
    GET TIME STAMP FIELD lf_ts.
    lf_user = sy-uname.

    " 1. 既存データをクリア
    DELETE FROM zemployee_001.
    DELETE FROM zemployee_d_001.

    " 2. データ生成 (新規項目 emp_grade を追加)
    " ※Gradeは給与額に応じた仮の値を設定しています (A:高, B:中, C:低)
    lt_employees = VALUE #(
      ( emp_id = '100001' first_name = '一郎' last_name = '鈴木' email = 'suzuki@test.com' join_date = '20150401' salary = '4000.00' currency_code = 'JPY' dept_id = 'D01'
        emp_grade = 'A' status = 'A'
        created_by = lf_user created_at = lf_ts last_changed_by = lf_user local_last_changed_at = lf_ts last_changed_at = lf_ts )

      ( emp_id = '100002' first_name = '太郎' last_name = '山田' email = 'taro@test.com'   join_date = '20201001' salary = '5000.00' currency_code = 'JPY' dept_id = 'D02'
        emp_grade = 'B' status = 'A'
        created_by = lf_user created_at = lf_ts last_changed_by = lf_user local_last_changed_at = lf_ts last_changed_at = lf_ts )

      ( emp_id = '100003' first_name = '花子' last_name = '佐藤' email = 'hana@test.com'   join_date = '20230401' salary = '3000.00' currency_code = 'JPY' dept_id = 'D01'
        emp_grade = 'B' status = 'A'
        created_by = lf_user created_at = lf_ts last_changed_by = lf_user local_last_changed_at = lf_ts last_changed_at = lf_ts )
    ).

    " 3. DBへ挿入
    INSERT zemployee_001 FROM TABLE @lt_employees.

    " 4. 結果出力
    out->write( |Inserted { sy-dbcnt } entries into ZEMPLOYEE_001| ).
  ENDMETHOD.
ENDCLASS.
