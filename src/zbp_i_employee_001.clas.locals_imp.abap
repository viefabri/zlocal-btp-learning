CLASS lsc_zi_employee_001 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zi_employee_001 IMPLEMENTATION.

METHOD adjust_numbers.
    DATA:
      ldt_employee_for_read TYPE TABLE FOR READ IMPORT zi_employee_001.

    " 1. mapped 構造体から発番待ちの仮キー(%pid)を持つレコードを収集
    LOOP AT mapped-employee ASSIGNING FIELD-SYMBOL(<ls_mapped>) WHERE %pid IS NOT INITIAL.
      APPEND VALUE #( %pid = <ls_mapped>-%pid ) TO ldt_employee_for_read.
    ENDLOOP.

    " 採番対象がなければ処理終了
    IF ldt_employee_for_read IS INITIAL.
      RETURN.
    ENDIF.

    " 2. 採番に必要なビジネスデータ (JoinDate) をバッファから一括取得
    READ ENTITIES OF zi_employee_001 IN LOCAL MODE
      ENTITY Employee
        FIELDS ( JoinDate )
        WITH ldt_employee_for_read
      RESULT DATA(ldt_employee_data).

    " 3. レコードごとに採番を実行し、mapped 構造体に実キーを上書き
    LOOP AT mapped-employee ASSIGNING <ls_mapped> WHERE %pid IS NOT INITIAL.

      " 該当レコードのビジネスデータを取得
      READ TABLE ldt_employee_data INTO DATA(ls_employee)
        WITH KEY pid
        COMPONENTS
          %pid = <ls_mapped>-%pid.

      IF sy-subrc = 0.
        " 入社日からYYYYMM (6桁) を抽出
        DATA(lf_yyyymm) = CONV string( ls_employee-JoinDate+0(6) ).

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

ENDCLASS.

CLASS lhc_Employee DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES:
      ltt_result_employees  TYPE TABLE FOR READ RESULT zi_employee_001,
      lts_result_employees  TYPE LINE OF ltt_result_employees,
      ltt_reported_employee TYPE RESPONSE FOR REPORTED LATE zi_employee_001,
      lts_reported_employee TYPE STRUCTURE FOR REPORTED LATE zi_employee_001,
      ltt_failed_employee   TYPE RESPONSE FOR FAILED LATE zi_employee_001,
      lts_failed_employee   TYPE STRUCTURE FOR FAILED LATE zi_employee_001.

    CONSTANTS:
      BEGIN OF lcs_state_area,
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
    READ ENTITIES OF zi_employee_001 IN LOCAL MODE
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
    MODIFY ENTITIES OF zi_employee_001 IN LOCAL MODE
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
    READ ENTITIES OF zi_employee_001 IN LOCAL MODE
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
    READ ENTITIES OF zi_employee_001 IN LOCAL MODE
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

    READ ENTITIES OF zi_employee_001 IN LOCAL MODE
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

* --- Determination: 保存前処理 (Finalize) ---
  METHOD finalizeData.

    DATA: ldt_employees TYPE ltt_result_employees.

*   1. 更新対象のデータを読み込む (IDとEmail)
    READ ENTITIES OF zi_employee_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( EmployeeId Email ) WITH CORRESPONDING #( keys )
      RESULT ldt_employees.

*   2. Emailが空のデータのみを対象とする
    DELETE ldt_employees WHERE Email IS NOT INITIAL.
    IF ldt_employees IS INITIAL.
      RETURN.
    ENDIF.

*   3. Emailを自動生成して更新 ( ID + example.com )
    MODIFY ENTITIES OF zi_employee_001 IN LOCAL MODE
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
      ldt_update    TYPE TABLE FOR UPDATE zi_employee_001,
      lds_update    TYPE STRUCTURE FOR UPDATE zi_employee_001,
      ldt_employees TYPE ltt_result_employees,
      lds_employee  TYPE lts_result_employees,
      ldf_grade     TYPE zemployee_001-emp_grade,
      ldf_salary    TYPE zemployee_001-salary.

*   1. 対象データの読み込み (給与と現在のランクを取得)
    READ ENTITIES OF zi_employee_001 IN LOCAL MODE
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
      MODIFY ENTITIES OF zi_employee_001 IN LOCAL MODE
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

*  通貨コードを読込専用に変更
    result
      = VALUE #(
        FOR key IN ldt_keys (
          %tky = key-%tky
          %field-CurrencyCode = if_abap_behv=>fc-f-read_only
         )
     ).
  ENDMETHOD.

ENDCLASS.
