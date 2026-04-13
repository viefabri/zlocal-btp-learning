CLASS zcl_test_bdef_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_test_bdef_001 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " 1. アクション実行対象となるレコードを1件取得
    SELECT SINGLE FROM zi_employee_001 WITH PRIVILEGED ACCESS
      FIELDS EmployeeId
      INTO @DATA(ldf_emp_id).

    IF sy-subrc <> 0.
      out->write( 'Test Data not found.' ).
      RETURN.
    ENDIF.

" 2. RaiseSalaryアクションの呼び出しパラメータを準備
    DATA ldt_keys TYPE TABLE FOR ACTION IMPORT zr_employee_001~RaiseSalary.
    ldt_keys = VALUE #( ( %tky-EmployeeId              = ldf_emp_id
                          %param-RaiseAmount           = 1000
                          %param-%control-RaiseAmount  = if_abap_behv=>mk-on " ←追加: 値を渡したことを宣言
                          %param-CurrencyCode          = 'JPY'
                          %param-%control-CurrencyCode = if_abap_behv=>mk-on " ←追加: 値を渡したことを宣言
                        ) ).

    " 3. EML (Entity Manipulation Language) を用いてアクションを実行
    " ※開発者ユーザーには 'ZAODPT_001' の ACTVT '16' が付与されていない前提
    MODIFY ENTITIES OF zr_employee_001
      ENTITY Employee
      EXECUTE RaiseSalary FROM ldt_keys
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

" 4. 結果の評価
    out->write( '--- BDEF Authorization Test (RaiseSalary) ---' ).
    IF ls_failed IS NOT INITIAL.
      out->write( 'Result: FAILED as expected.' ).

      " 修正箇所: if_message~ の修飾追加と、インスタンスの存在チェック
      IF ls_reported-employee IS NOT INITIAL AND ls_reported-employee[ 1 ]-%msg IS BOUND.
        out->write( |Reason: { ls_reported-employee[ 1 ]-%msg->if_message~get_text( ) }| ).
      ELSE.
        out->write( 'Reason: Authorization rejected by framework (No explicit message).' ).
      ENDIF.

    ELSE.
      out->write( 'Result: SUCCESS (Unexpected. Authorization bypass failed.)' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
