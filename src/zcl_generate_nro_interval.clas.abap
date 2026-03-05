CLASS zcl_generate_nro_interval DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    " 定数定義: 生成年数と開始年月
    CONSTANTS lc_generate_years TYPE i      VALUE 10.
    CONSTANTS lc_start_ym       TYPE string VALUE '202601'.
ENDCLASS.

CLASS zcl_generate_nro_interval IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_interval TYPE cl_numberrange_intervals=>nr_interval,
          ls_interval LIKE LINE OF lt_interval,
          lv_year     TYPE n LENGTH 4,
          lv_month    TYPE n LENGTH 2,
          lv_subobj   TYPE string,
          lv_success  TYPE i VALUE 0,
          lv_exist    TYPE i VALUE 0.

    " 開始年を取得
    lv_year = lc_start_ym(4).

    DO lc_generate_years TIMES.
      DO 12 TIMES.
        lv_month = sy-index.
        " サブオブジェクト (YYYYMM) を組み立て
        lv_subobj = |{ lv_year }{ lv_month }|.

        " インターバル情報のセット (月ごとにクリアして設定)
        CLEAR lt_interval.
        ls_interval-subobject  = lv_subobj.
        ls_interval-nrrangenr  = '01'.
        ls_interval-fromnumber = '0001'.
        ls_interval-tonumber   = '9999'.
        ls_interval-procind    = 'I'. " I = Insert (登録)
        APPEND ls_interval TO lt_interval.

        TRY.
            " API呼び出し
            cl_numberrange_intervals=>create(
              EXPORTING
                interval  = lt_interval
                object    = 'ZNR_EMP001'
                subobject = CONV #( lv_subobj )
              IMPORTING
                error     = DATA(lv_error)
            ).

            " エラー判定 (既に存在する場合はエラーフラグが立つためスキップ)
            IF lv_error IS INITIAL.
              lv_success += 1.
            ELSE.
              lv_exist += 1.
            ENDIF.

          CATCH cx_number_ranges INTO DATA(lx_number_ranges).
            out->write( |Exception for { lv_subobj }: { lx_number_ranges->get_text( ) }| ).
            lv_exist += 1.
        ENDTRY.
      ENDDO.
      " 1年進める
      lv_year += 1.
    ENDDO.

    " 最終結果の出力
    out->write( |--- NRO Interval Bulk Generation ---| ).
    out->write( |Successfully created : { lv_success }| ).
    out->write( |Skipped (Already exists/Error): { lv_exist }| ).
    out->write( |Total processed      : { lv_success + lv_exist }| ).
  ENDMETHOD.
ENDCLASS.
