CLASS zcl_test_eml_currency_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_test_eml_currency_001 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " 既存の社員レコード(100001)の通貨を 'USD' に更新するようAPI(EML)経由で要求する
    MODIFY ENTITIES OF zr_employee_001
      ENTITY Employee
      UPDATE FIELDS ( CurrencyCode )
      WITH VALUE #( ( EmployeeId = '100001' CurrencyCode = 'USD' ) )
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    " 結果の判定
    IF ls_failed IS NOT INITIAL.
      out->write( '【成功】バックエンド防御が機能しました。更新は拒絶されました。' ).

      " フレームワークが自動生成したエラーメッセージを出力
      LOOP AT ls_reported-employee INTO DATA(ls_msg).
        out->write( |理由: { ls_msg-%msg->if_message~get_text(  ) }| ).
      ENDLOOP.
    ELSE.
      out->write( '【警告】更新が成功してしまいました。Layer2の設定を見直してください。' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
