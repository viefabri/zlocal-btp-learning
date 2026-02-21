CLASS zcl_generate_yyyymm_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    " 生成する年数を定数で定義
    CONSTANTS lc_generate_years TYPE i VALUE 10.
ENDCLASS.

CLASS zcl_generate_yyyymm_001 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_yyyymm TYPE TABLE OF ztyyyymm_001,
          ls_yyyymm TYPE ztyyyymm_001,
          lv_year   TYPE n LENGTH 4,
          lv_month  TYPE n LENGTH 2.

    " 1. 既存データを全削除（洗い替え）
    DELETE FROM ztyyyymm_001.

    " 2. 現在のシステム日付から開始年を取得
    DATA(lv_current_date) = cl_abap_context_info=>get_system_date( ).
    lv_year = lv_current_date(4).

    " 3. 指定年数分 (年 x 12ヶ月) のデータ生成
    DO lc_generate_years TIMES.
      DO 12 TIMES.
        lv_month = sy-index.
        " YYYYMM形式 (例: 202604) で組み立て
        ls_yyyymm-yyyymm = |{ lv_year }{ lv_month }|.
        APPEND ls_yyyymm TO lt_yyyymm.
      ENDDO.
      " 次の年へ
      lv_year += 1.
    ENDDO.

    " 4. データベースへ一括登録
    INSERT ztyyyymm_001 FROM TABLE @lt_yyyymm.

    " 5. 実行結果のコンソール出力
    out->write( |Cleared table and inserted { sy-dbcnt } entries into ZYYYYMM_001.| ).
  ENDMETHOD.
ENDCLASS.
