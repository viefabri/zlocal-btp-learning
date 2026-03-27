CLASS lhc_Employee DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:
      ltt_result_employees  TYPE TABLE FOR READ RESULT zr_employee_001,
      lts_result_employees  TYPE LINE OF ltt_result_employees,
      ltt_reported_employee TYPE RESPONSE FOR REPORTED LATE zr_employee_001,
      lts_reported_employee TYPE STRUCTURE FOR REPORTED LATE zr_employee_001,
      ltt_failed_employee   TYPE RESPONSE FOR FAILED LATE zr_employee_001,
      lts_failed_employee   TYPE STRUCTURE FOR FAILED LATE zr_employee_001.

    CONSTANTS:
      BEGIN OF lcs_state_area,
        currency TYPE string VALUE 'VALIDATE_CURRENCY',
        salary   TYPE string VALUE 'VALIDATE_SALARY',
        joindate TYPE string VALUE 'VALIDATE_JOINDATE',
        status   TYPE string VALUE 'VALIDATE_STATUS',
      END   OF lcs_state_area,
      "! <p class="shorttext synchronized">デフォルト通貨コード</p>
      lcf_currency TYPE zemployee_001-currency_code VALUE 'JPY',
      "! ステータス.
      BEGIN OF lcs_status,
        Working TYPE zemployee_001-status VALUE 'A',
        OnLeave TYPE zemployee_001-status VALUE 'B',
        Retired TYPE zemployee_001-status VALUE 'C',
      END   OF lcs_status,
      "! 入社日チェック用.
      lcf_jd_limit      TYPE i VALUE 730,
      " --- ランク判定用の閾値と値 ---
      lcf_salary_low    TYPE zemployee_001-salary VALUE '2500.00',
      lcf_salary_middle TYPE zemployee_001-salary VALUE '3000.00',
      lcf_salary_high   TYPE zemployee_001-salary VALUE '4000.00',

      BEGIN OF lcs_grade,
        Expert TYPE zemployee_001-emp_grade VALUE 'A',
        Senior TYPE zemployee_001-emp_grade VALUE 'B',
        Middle TYPE zemployee_001-emp_grade VALUE 'C',
        Junior TYPE zemployee_001-emp_grade VALUE 'D',
      END OF lcs_grade.
* --- 権限チェック ---
    "! <p class="shorttext synchronized">権限チェック</p>
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Employee RESULT result.
* --- 初期値 ---
    "! <p class="shorttext synchronized">初期処理</p>
    METHODS setInitialValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Employee~setInitialValues.
* --- 入力値チェック:ステータス ---
    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Employee~validateStatus.
* --- 入力値チェック:給与 ---
    METHODS validateSalary FOR VALIDATE ON SAVE
      IMPORTING keys FOR Employee~validateSalary.
* --- 入力値チェック:入社日 ---
    METHODS validateJoinDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Employee~validateJoinDate.
* --- 入力値チェック:通貨コード ---
    METHODS validateCurrencyCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR Employee~validateCurrencyCode.
* --- 保存前処理 ---
    METHODS finalizeData FOR DETERMINE ON SAVE
      IMPORTING keys FOR Employee~finalizeData.
    " --- ランク計算メソッド ---
    METHODS calculateGrade FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Employee~calculateGrade.
* --- 動的機能制御 ---
    "! <p class="shorttext synchronized">動的機能制御</p>
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Employee RESULT result.
    METHODS raisesalary FOR MODIFY
      IMPORTING keys FOR ACTION employee~raisesalary RESULT result.
* --- 昇給パラメータ 初期値設定 ---
    "! <p class="shorttext synchronized">昇給パラメータ 初期値設定</p>
    METHODS getdefaultsforraisesalary FOR READ
      IMPORTING keys FOR FUNCTION employee~getdefaultsforraisesalary RESULT result.
    "! <p class="shorttext synchronized">昇給パラメータ チェック処理</p>
    METHODS precheck_raisesalary FOR PRECHECK
      IMPORTING keys FOR ACTION employee~raisesalary.
    "! <p class="shorttext synchronized">退職処理</p>
    METHODS resign FOR MODIFY
      IMPORTING keys FOR ACTION employee~resign RESULT result.
    "! <p class="shorttext synchronized">退職日 チェック処理</p>
    METHODS precheck_resign FOR PRECHECK
      IMPORTING keys FOR ACTION employee~resign.
    "! <p class="shorttext synchronized">ステータステキスト更新</p>
    METHODS updatestatustext FOR DETERMINE ON MODIFY
      IMPORTING keys FOR employee~updatestatustext.
*   メッセージクリア
    METHODS clear_state_message
      IMPORTING
        is_result     TYPE lts_result_employees
        if_state_area TYPE csequence
      CHANGING
        ct_reported   TYPE ltt_reported_employee.

*   エラー処理 (Failed設定)
    METHODS set_failed_err
      IMPORTING
        is_result TYPE lts_result_employees
      CHANGING
        ct_failed TYPE ltt_failed_employee.

*   メッセージ設定 (Reported設定)
    METHODS set_reported_msg
      IMPORTING
        is_result     TYPE lts_result_employees
        if_state_area TYPE csequence
        if_msgtyp     TYPE if_abap_behv_message=>t_severity
        if_msg        TYPE csequence
      CHANGING
        ct_reported   TYPE ltt_reported_employee.


ENDCLASS.

CLASS lhc_Employee IMPLEMENTATION.

  METHOD get_instance_authorizations.
* 権限チェックを実装しないためスキップ
  ENDMETHOD.

* --- Determination: ステータス初期値設定 ---
  METHOD setInitialValues.

    DATA:
      ldt_employees TYPE ltt_result_employees.

* 1. 対象データの読み込み (現在のステータスを確認)
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( Status CurrencyCode ) WITH CORRESPONDING #( keys )
      RESULT ldt_employees.

* 2. ステータスが空のデータのみを対象とする
    DELETE ldt_employees
     WHERE Status       IS NOT INITIAL
       AND CurrencyCode IS NOT INITIAL.

    IF ldt_employees IS INITIAL.
      RETURN.
    ENDIF.

* 3. 更新処理
    MODIFY ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
      UPDATE
      FIELDS ( Status CurrencyCode )
      WITH VALUE #( FOR employee IN ldt_employees
                    ( %tky         = employee-%tky
                     Status        = COND #( WHEN employee-Status IS INITIAL
                                             THEN lcs_status-working
                                             ELSE employee-Status )
                      CurrencyCode = COND #( WHEN employee-CurrencyCode IS INITIAL
                                             THEN lcf_currency
                                             ELSE employee-CurrencyCode ) ) ).
  ENDMETHOD.

* --- Validation: ステータス値検証 ---
  METHOD validateStatus.

    DATA:
      ldt_employees  TYPE ltt_result_employees,
      lds_employee   TYPE lts_result_employees,
      ldf_state_area TYPE string VALUE lcs_state_area-status.

* 1. 検証対象の読み込み
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT ldt_employees.

    LOOP AT ldt_employees INTO lds_employee.
* 2. 以前のエラーメッセージをクリア（State Message管理）
      clear_state_message(
        EXPORTING
          is_result     = lds_employee
          if_state_area = ldf_state_area
        CHANGING
          ct_reported     = reported
       ).

* 3. 値の検証 (A, B, C 以外はエラー)
      CASE lds_employee-Status.
        WHEN lcs_status-working OR lcs_status-onleave OR lcs_status-retired.
*       OK
        WHEN OTHERS.
* 4. エラー処理
          set_failed_err(
            EXPORTING
              is_result = lds_employee
            CHANGING
              ct_failed = failed
          ).
*         メッセージ出力
          set_reported_msg(
            EXPORTING
              is_result     = lds_employee
              if_msg        = TEXT-e03        "ステータスは A(在職中), B(休職中), C(退職) のいずれかを指定してください
              if_msgtyp     = if_abap_behv_message=>severity-error
              if_state_area = ldf_state_area
            CHANGING
              ct_reported   = reported
          ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

* --- Validation: 給与検証 ---
  METHOD validateSalary.

    DATA:
      ldt_employees  TYPE ltt_result_employees,
      lds_employee   TYPE lts_result_employees,
      ldf_state_area TYPE string VALUE lcs_state_area-salary.

* 1. 検証対象データの読み込み
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( Salary )  WITH CORRESPONDING #( keys )
      RESULT ldt_employees.

    LOOP AT ldt_employees INTO lds_employee.
* 2. 以前のエラーメッセージをクリア（State Message管理）
      clear_state_message(
        EXPORTING
          is_result     = lds_employee
          if_state_area = ldf_state_area
        CHANGING
          ct_reported     = reported
          ).

* 3. バリデーション：給与が0以下（またはマイナス）の場合
      IF lds_employee-Salary <= 0.
*       failed構造体にキーを登録（保存を阻止）
        set_failed_err(
          EXPORTING
            is_result = lds_employee
          CHANGING
            ct_failed = failed
        ).
*       メッセージ出力
        set_reported_msg(
          EXPORTING
            is_result     = lds_employee
            if_msg        = TEXT-e01        "給与には0より大きい値を入力してください
            if_msgtyp     = if_abap_behv_message=>severity-error
            if_state_area = ldf_state_area
          CHANGING
            ct_reported   = reported
            ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

* --- Validation: 入社日検証 ---
  METHOD validateJoinDate.

    DATA:
      ldt_employees  TYPE ltt_result_employees,
      lds_employee   TYPE lts_result_employees,
      ldf_state_area TYPE string VALUE lcs_state_area-joindate,
      ldf_chk_date   TYPE zemployee_001-join_date.

    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( JoinDate ) WITH CORRESPONDING #( keys )
      RESULT ldt_employees.

    LOOP AT ldt_employees INTO lds_employee.
*     以前のエラーメッセージをクリア（State Message管理）
      clear_state_message(
        EXPORTING
          is_result     = lds_employee
          if_state_area = ldf_state_area
        CHANGING
          ct_reported     = reported
          ).

*     入社日が未入力(Initial)の場合エラー
      IF lds_employee-JoinDate IS INITIAL.
*       failed構造体にキーを登録（保存を阻止）
        set_failed_err(
          EXPORTING
            is_result = lds_employee
          CHANGING
            ct_failed = failed
        ).
*       メッセージ出力
        set_reported_msg(
          EXPORTING
            is_result     = lds_employee
            if_msg        = TEXT-e02 " 入社日は必須入力です
            if_msgtyp     = if_abap_behv_message=>severity-error
            if_state_area = ldf_state_area
          CHANGING
            ct_reported   = reported
            ).

        CONTINUE.
      ENDIF.

*     入社日が想定より未来日の場合は警告を出力
      ldf_chk_date = cl_abap_context_info=>get_system_date( ) + lcf_jd_limit.
      IF lds_employee-JoinDate > ldf_chk_date.
*       メッセージ出力
        set_reported_msg(
          EXPORTING
            is_result     = lds_employee
            if_msg        = TEXT-w01 " 入社日が2年以上未来日です
            if_msgtyp     = if_abap_behv_message=>severity-warning
            if_state_area = ldf_state_area
          CHANGING
            ct_reported   = reported
            ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

* --- Validation: 通貨コード正当性チェック (フェイルセーフ) ---
  METHOD validateCurrencyCode.

    DATA:
      ldt_employees  TYPE ltt_result_employees,
      lds_employee   TYPE lts_result_employees,
      ldf_state_area TYPE string.

*   1. 更新対象データを読み込む
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( CurrencyCode ) WITH CORRESPONDING #( keys )
      RESULT ldt_employees.

    ldf_state_area = lcs_state_area-currency.

    LOOP AT ldt_employees INTO lds_employee.

*     以前のエラーメッセージをクリア（State Message管理）
      clear_state_message(
        EXPORTING
          is_result     = lds_employee
          if_state_area = ldf_state_area
        CHANGING
          ct_reported     = reported
          ).

*     通貨コードが固定通貨(JPY)以外の場合エラーとする
      IF lds_employee-CurrencyCode IS NOT INITIAL AND lds_employee-CurrencyCode <> lcf_currency.
*       エラーの設定
        set_failed_err(
          EXPORTING
            is_result = lds_employee
          CHANGING
            ct_failed = failed
         ).

*       エラーメッセージの作成と送信 (Reported)
        set_reported_msg(
          EXPORTING
            is_result     = lds_employee
            if_msg        = TEXT-e04  " 通貨コード:JPY以外は使用できません
            if_msgtyp     = if_abap_behv_message=>severity-error
            if_state_area = ldf_state_area
          CHANGING
            ct_reported   = reported
            ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

* --- Determination: 保存前処理 (Finalize) ---
  METHOD finalizeData.

    DATA: ldt_employees TYPE ltt_result_employees.

*   1. 更新対象のデータを読み込む (IDとEmail)
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( EmployeeId Email ) WITH CORRESPONDING #( keys )
      RESULT ldt_employees.

*   2. Emailが空のデータのみを対象とする
    DELETE ldt_employees WHERE Email IS NOT INITIAL.
    IF ldt_employees IS INITIAL.
      RETURN.
    ENDIF.

*   3. Emailを自動生成して更新 ( ID + example.com )
    MODIFY ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
      UPDATE
      FIELDS ( Email )
      WITH VALUE #( FOR employee IN ldt_employees
                    ( %tky = employee-%tky
                      Email = |{ employee-EmployeeId }@example.com| ) ).
  ENDMETHOD.

* --- Determination: 給与ランク自動判定 ---
  METHOD calculateGrade.

    DATA:
      ldt_update    TYPE TABLE FOR UPDATE zr_employee_001,
      lds_update    TYPE STRUCTURE FOR UPDATE zr_employee_001,
      ldt_employees TYPE ltt_result_employees,
      lds_employee  TYPE lts_result_employees,
      ldf_grade     TYPE zemployee_001-emp_grade,
      ldf_salary    TYPE zemployee_001-salary.

*   1. 対象データの読み込み (給与と現在のランクを取得)
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( Salary Grade AnnualSalary ) WITH CORRESPONDING #( keys )
      RESULT ldt_employees.

    LOOP AT ldt_employees INTO lds_employee.

      ldf_grade  = lds_employee-Grade.
      ldf_salary = lds_employee-Salary * 12.

*     2. 給与額に応じたランク判定ロジック
      IF lds_employee-Salary <= lcf_salary_low.        " 25万以下 -> D
        ldf_grade = lcs_grade-Junior.
      ELSEIF lds_employee-Salary <= lcf_salary_middle. " 30万以下 -> C
        ldf_grade = lcs_grade-Middle.
      ELSEIF lds_employee-Salary <= lcf_salary_high.   " 40万以下 -> B
        ldf_grade = lcs_grade-Senior.
      ELSE.                                        " それ以上 -> A
        ldf_grade = lcs_grade-Expert.
      ENDIF.

*     3. ランク、年収に変更がある場合のみ更新対象に追加
      IF ldf_grade <> lds_employee-Grade OR ldf_salary <> lds_employee-AnnualSalary.
        CLEAR lds_update.
        lds_update-%tky          = lds_employee-%tky.
        lds_update-Grade         = ldf_grade.
        lds_update-AnnualSalary  = ldf_salary.
        APPEND lds_update TO ldt_update.
      ENDIF.
    ENDLOOP.

*   4. データベース(バッファ)の更新実行
    IF ldt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_employee_001 IN LOCAL MODE
        ENTITY Employee
        UPDATE
        FIELDS ( Grade AnnualSalary ) WITH ldt_update.
    ENDIF.

  ENDMETHOD.
*--- メッセージ初期化 ---
  METHOD clear_state_message.

    DATA:
      lds_reported TYPE lts_reported_employee.

    lds_reported-%tky        = is_result-%tky.
    lds_reported-%state_area = if_state_area.
    APPEND lds_reported TO ct_reported-employee.

  ENDMETHOD.

*--- エラー処理 ---
  METHOD set_failed_err.

    DATA:
      lds_failed TYPE lts_failed_employee.

    lds_failed-%tky = is_result-%tky.
    APPEND lds_failed TO ct_failed-employee.

  ENDMETHOD.

*--- メッセージ設定 ---
  METHOD set_reported_msg.

    DATA:
      lds_reported TYPE lts_reported_employee.

    lds_reported-%tky        = is_result-%tky.
    lds_reported-%state_area = if_state_area.
    lds_reported-%msg
      = new_message_with_text(
          severity = if_msgtyp
          text     = if_msg
    ).

*   State Areaに応じた項目のハイライト
    CASE if_state_area.
      WHEN lcs_state_area-joindate.
        lds_reported-%element-joindate = if_abap_behv=>mk-on.
      WHEN lcs_state_area-salary.
        lds_reported-%element-salary   = if_abap_behv=>mk-on.
      WHEN lcs_state_area-status.
        lds_reported-%element-status   = if_abap_behv=>mk-on.
    ENDCASE.

    APPEND lds_reported  TO ct_reported-employee.

  ENDMETHOD.
* --- 動的機能制御 ---
  METHOD get_instance_features.
    DATA(ldt_keys) = keys.
    DATA ldt_employees TYPE ltt_result_employees.

*  通貨コードを読込専用に変更
    result
      = VALUE #(
        FOR key IN ldt_keys (
          %tky = key-%tky
          %field-CurrencyCode = if_abap_behv=>fc-f-read_only
         )
     ).

* --- 退職ボタンの制御 ---
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
        RESULT ldt_employees.

    LOOP AT ldt_employees INTO DATA(lds_employees).

      READ TABLE result ASSIGNING FIELD-SYMBOL(<lfs_result>)
        WITH KEY id
          COMPONENTS
            %tky = lds_employees-%tky.

      IF sy-subrc = 0.
*       退職の場合
        IF lds_employees-Status = lcs_status-retired.
          <lfs_result>-%action-Resign = if_abap_behv=>fc-o-disabled.
        ELSE.
          <lfs_result>-%action-Resign = if_abap_behv=>fc-o-enabled.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD RaiseSalary.

    DATA ldt_update TYPE TABLE FOR UPDATE zr_employee_001.

*   現在の給与額を取得
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
        FIELDS ( Salary ) WITH CORRESPONDING #( keys )
      RESULT DATA(ldt_employees).

*    入力パラメータ (昇給額) を加算して更新用の内部テーブルを作成
    LOOP AT ldt_employees INTO DATA(lds_employee).

      READ TABLE keys INTO DATA(lds_key) WITH KEY id
        COMPONENTS %tky = lds_employee-%tky.

      IF sy-subrc = 0 AND lds_key-%param-RaiseAmount > 0.
        APPEND VALUE #( %tky   = lds_employee-%tky
                        Salary = lds_employee-Salary + lds_key-%param-RaiseAmount ) TO ldt_update.
      ENDIF.
    ENDLOOP.

*   データベース(バッファ)の更新
    IF ldt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_employee_001 IN LOCAL MODE
        ENTITY Employee
          UPDATE FIELDS ( Salary ) WITH ldt_update
        FAILED failed
        REPORTED reported.
    ENDIF.

*   最新の状態を読み込み直し、UIに返却する (必須処理)
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(ldt_employees_updated).

    result = VALUE #( FOR employee IN ldt_employees_updated
                      ( %tky   = employee-%tky
                        %param = employee ) ).
  ENDMETHOD.

* 昇給パラメータ 通貨コードの初期値設定
  METHOD GetDefaultsForRaiseSalary.
*  データ取得
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
        FIELDS ( CurrencyCode ) WITH CORRESPONDING #( keys )
        RESULT DATA(ldt_employees).

    LOOP AT ldt_employees ASSIGNING FIELD-SYMBOL(<lfs_keys>).
*     初期化
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).

*     マッピング
      <lfs_result>-%tky = <lfs_keys>-%tky.

*     該当データの読み込み
      READ TABLE ldt_employees ASSIGNING FIELD-SYMBOL(<lfs_employees>)
        WITH KEY id
        COMPONENTS
          %tky = <lfs_keys>-%tky.
      IF sy-subrc = 0.
        <lfs_result>-%param-CurrencyCode = <lfs_employees>-CurrencyCode.
      ENDIF.


    ENDLOOP.
  ENDMETHOD.

* 昇給パラメータチェック処理
  METHOD precheck_RaiseSalary.

    DATA:
      lds_reported   TYPE STRUCTURE FOR REPORTED EARLY zr_employee_001.

*   社員データの取得
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
        FIELDS ( CurrencyCode ) WITH CORRESPONDING #( keys )
      RESULT DATA(ldt_employees).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).

      IF <lfs_keys>-%param-RaiseAmount <= 0.
        APPEND VALUE #(  %tky = <lfs_keys>-%tky ) TO failed-employee.
        CLEAR lds_reported.
        lds_reported-%tky = <lfs_keys>-%tky.
        lds_reported-%msg
          = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = TEXT-e06 ). "昇給額には0より大きい値を入力してください
        lds_reported-%action-RaiseSalary = if_abap_behv=>mk-on.
        APPEND lds_reported TO reported-employee.
        CONTINUE. "次レコードへ
      ENDIF.

*     社員データの読み込み
      READ TABLE ldt_employees ASSIGNING FIELD-SYMBOL(<lfs_employees>)
        WITH KEY id
        COMPONENTS
          %tky = <lfs_keys>-%tky.

      IF sy-subrc = 0.
        IF <lfs_keys>-%param-CurrencyCode <> <lfs_employees>-CurrencyCode.
*         failed構造体にキーを登録（保存を阻止）
          APPEND VALUE #( %tky = <lfs_keys>-%tky ) TO failed-employee.

*         メッセージ出力
          CLEAR lds_reported.
          lds_reported-%tky        = <lfs_keys>-%tky.
          lds_reported-%msg
            = new_message_with_text(
                severity = if_abap_behv_message=>severity-error
                text     = TEXT-e05
          ).
          lds_reported-%action-RaiseSalary = if_abap_behv=>mk-on.
          APPEND lds_reported TO reported-employee.
          CONTINUE. "次レコードへ
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD Resign.
    DATA:
      ldt_update TYPE TABLE FOR UPDATE zr_employee_001,
      lds_update TYPE STRUCTURE FOR UPDATE zr_employee_001.

    LOOP AT keys INTO DATA(lds_keys).
      CLEAR lds_update.
      lds_update-%tky = lds_keys-%tky.
      lds_update-ResignDate = lds_keys-%param-ResignDate.
      lds_update-Status = lcs_status-retired.
      APPEND lds_update TO ldt_update.
    ENDLOOP.

*   更新処理
    IF ldt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_employee_001 IN LOCAL MODE
        ENTITY Employee
          UPDATE FIELDS ( ResignDate Status )
          WITH ldt_update
        FAILED failed
        REPORTED reported.
    ENDIF.

*   最新情報への更新
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(ldt_employees_updated).

    result = VALUE #(
      FOR employee IN ldt_employees_updated
        (
          %tky = employee-%tky
          %param = employee
        )
     ).

  ENDMETHOD.

  METHOD precheck_Resign.
    DATA LDS_reported TYPE STRUCTURE FOR REPORTED EARLY zr_employee_001.
    DATA(ldf_today) = cl_abap_context_info=>get_system_date(  ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
*     未来日チェック
      IF <lfs_keys>-%param-ResignDate > ldf_today.
        APPEND VALUE #( %tky = <lfs_keys>-%tky ) TO failed-employee.

        CLEAR lds_reported.
        lds_reported-%tky = <lfs_keys>-%tky.
        lds_reported-%msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = TEXT-e07  "退職日に未来日は指定できません
         ).
        lds_reported-%action-Resign = if_abap_behv=>mk-on.
        APPEND lds_reported TO reported-employee.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

METHOD updateStatusText.
    DATA: ldt_update TYPE TABLE FOR UPDATE zr_employee_001.

    " 1. 更新されたステータスをドラフトから読み込む
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(ldt_employees).

    IF ldt_employees IS INITIAL.
      RETURN.
    ENDIF.

    " 2. 対象データからユニークなステータスコードを抽出 (検索条件用)
    DATA(ldt_status_keys) = ldt_employees.
    SORT ldt_status_keys BY Status.
    DELETE ADJACENT DUPLICATES FROM ldt_status_keys COMPARING Status.

    " 3. ZI_STATUS_VH_001 から該当するテキストを一括取得
    " ※ ログオン言語の解決はCDS側(where Language = $session.system_language)で自動的に行われる
    SELECT Status, StatusText
      FROM ZI_STATUS_VH_001
      FOR ALL ENTRIES IN @ldt_status_keys
      WHERE Status = @ldt_status_keys-Status
      INTO TABLE @DATA(ldt_texts).

    " 4. 更新用データの組み立て
    LOOP AT ldt_employees INTO DATA(lds_employee).
      " 取得した内部テーブルから該当ステータスのテキストを検索
      ASSIGN ldt_texts[ Status = lds_employee-Status ] TO FIELD-SYMBOL(<ls_text>).
      DATA(ldf_text) = COND #( WHEN <ls_text> IS ASSIGNED THEN <ls_text>-StatusText ELSE '' ).

      " 更新対象としてセット
      APPEND VALUE #( %tky       = lds_employee-%tky
                      StatusText = ldf_text ) TO ldt_update.
    ENDLOOP.

    " 5. ドラフト上の StatusText を更新
    IF ldt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_employee_001 IN LOCAL MODE
        ENTITY Employee
          UPDATE FIELDS ( StatusText ) WITH ldt_update.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZR_EMPLOYEE_001 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_EMPLOYEE_001 IMPLEMENTATION.

  METHOD adjust_numbers.
    DATA:
      ldt_employee_for_read TYPE TABLE FOR READ IMPORT zr_employee_001.

    " 1. mapped 構造体から発番待ちの仮キー(%pid)を持つレコードを収集
    LOOP AT mapped-employee ASSIGNING FIELD-SYMBOL(<ls_mapped>) WHERE %pid IS NOT INITIAL.
      APPEND VALUE #( %pid = <ls_mapped>-%pid ) TO ldt_employee_for_read.
    ENDLOOP.

    " 採番対象がなければ処理終了
    IF ldt_employee_for_read IS INITIAL.
      RETURN.
    ENDIF.

    " 2. 採番に必要なビジネスデータ (JoinDate) をバッファから一括取得
    READ ENTITIES OF zr_employee_001 IN LOCAL MODE
      ENTITY Employee
        FIELDS ( JoinDate )
        WITH ldt_employee_for_read
      RESULT DATA(ldt_employee_data).

    " 3. レコードごとに採番を実行し、mapped 構造体に実キーを上書き
    LOOP AT mapped-employee ASSIGNING <ls_mapped> WHERE %pid IS NOT INITIAL.

      " 該当レコードのビジネスデータを取得
      READ TABLE ldt_employee_data INTO DATA(lds_employee)
        WITH KEY pid
        COMPONENTS
          %pid = <ls_mapped>-%pid.

      IF sy-subrc = 0.
        " 入社日からYYYYMM (6桁) を抽出
        DATA(lf_yyyymm) = CONV string( lds_employee-JoinDate+0(6) ).

        TRY.
            " NROから該当サブオブジェクトの連番を取得
            cl_numberrange_runtime=>number_get(
              EXPORTING
                nr_range_nr = '01'
                object      = 'ZNR_EMP001'
                subobject   = CONV #( lf_yyyymm )
              IMPORTING
                number      = DATA(lf_number)
            ).

            " 10桁の実キー (YYYYMM + 末尾4桁) を生成して mapped にセット
            DATA(lv_seq_4) = lf_number+16(4).
            <ls_mapped>-EmployeeId = |{ lf_yyyymm }{ lv_seq_4 }|.

          CATCH cx_number_ranges INTO DATA(lx_error).
            " 注: Late Numberingフェーズでのエラーは原則ショートダンプ
            " 実際の運用ではシステム管理者に通知する例外処理が必要
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
