CLASS zcl_check_nro_interval DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    " 定数定義: 登録クラスと完全に一致させる
    CONSTANTS lc_generate_years TYPE i      VALUE 10.
    CONSTANTS lc_start_ym       TYPE string VALUE '202601'.
ENDCLASS.

CLASS zcl_check_nro_interval IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_interval TYPE cl_numberrange_intervals=>nr_interval,
          lv_year     TYPE n LENGTH 4,
          lv_month    TYPE n LENGTH 2,
          lv_subobj   TYPE string,
          lv_count    TYPE i VALUE 0.

    " 開始年を取得
    lv_year = lc_start_ym(4).

    out->write( |--- NRO Interval List (All Registered) ---| ).

    DO lc_generate_years TIMES.
      DO 12 TIMES.
        lv_month = sy-index.
        " サブオブジェクト (YYYYMM) を組み立て
        lv_subobj = |{ lv_year }{ lv_month }|.

        TRY.
            " サブオブジェクト単位でReadを実行
            CLEAR lt_interval.
            cl_numberrange_intervals=>read(
              EXPORTING
                object    = 'ZNR_EMP001'
                subobject = CONV #( lv_subobj )
              IMPORTING
                interval  = lt_interval
            ).

            " 取得できた場合のみコンソールへ出力
            IF lt_interval IS NOT INITIAL.
              LOOP AT lt_interval INTO DATA(ls_interval).
                out->write( |Subobj: { ls_interval-subobject } , Range: { ls_interval-nrrangenr } [ { ls_interval-fromnumber } - { ls_interval-tonumber } ]| ).
                lv_count += 1.
              ENDLOOP.
            ENDIF.

          CATCH cx_number_ranges INTO DATA(lx_number_ranges).
            out->write( |Exception for { lv_subobj }: { lx_number_ranges->get_text( ) }| ).
        ENDTRY.
      ENDDO.
      " 1年進める
      lv_year += 1.
    ENDDO.

    out->write( |------------------------------------------| ).
    out->write( |Total Intervals Found: { lv_count }| ).
  ENDMETHOD.
ENDCLASS.
