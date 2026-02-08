CLASS lhc_Employee DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Employee RESULT result.

    METHODS initStatus FOR DETERMINATION Employee~initStatus
      IMPORTING keys FOR Employee.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Employee~validateStatus.

    METHODS validateSalary FOR VALIDATE ON SAVE
      IMPORTING keys FOR Employee~validateSalary.

    METHODS validateJoinDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Employee~validateJoinDate.

ENDCLASS.

CLASS lhc_Employee IMPLEMENTATION.

  METHOD get_instance_authorizations.
* 権限チェックを実装しないためスキップ
  ENDMETHOD.

* --- Determination: ステータス初期値設定 ---
  METHOD initStatus.
*   1. 対象データの読み込み (現在のステータスを確認)
    READ ENTITIES OF ZI_EMPLOYEE_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(employees).

*   2. ステータスが空のデータのみを対象とする
    DELETE employees WHERE Status IS NOT INITIAL.
    CHECK employees IS NOT INITIAL.

*   3. ステータスを 'A' (在職中) に更新
    MODIFY ENTITIES OF ZI_EMPLOYEE_001 IN LOCAL MODE
      ENTITY Employee
      UPDATE
      FIELDS ( Status )
      WITH VALUE #( FOR employee IN employees
                    ( %tky = employee-%tky
                      Status = 'A' ) ).
  ENDMETHOD.

* --- Validation: ステータス値検証 ---
  METHOD validateStatus.
*   1. 検証対象の読み込み
    READ ENTITIES OF ZI_EMPLOYEE_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(employees).

    LOOP AT employees INTO DATA(employee).
*     2. 値の検証 (A, B, C 以外はエラー)
      CASE employee-Status.
        WHEN 'A' OR 'B' OR 'C'.
*        OK
        WHEN OTHERS.
*          3. エラー処理
          APPEND VALUE #( %tky = employee-%tky ) TO failed-employee.

          APPEND VALUE #( %tky = employee-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'ステータスは A(在職中), B(休職中), C(退職) のいずれかを指定してください'
                                 )
                          %element-Status = if_abap_behv=>mk-on
                        ) TO reported-employee.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

* --- Validation: 給与検証 ---
  METHOD validateSalary.
    READ ENTITIES OF ZI_EMPLOYEE_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( Salary ) WITH CORRESPONDING #( keys )
      RESULT DATA(employees).

    LOOP AT employees INTO DATA(employee).
*     給与がマイナスの場合エラー (0は許容)
      IF employee-Salary < 0.
        APPEND VALUE #( %tky = employee-%tky ) TO failed-employee.

        APPEND VALUE #( %tky = employee-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = '給与にマイナスの値は設定できません'
                               )
                        %element-Salary = if_abap_behv=>mk-on
                      ) TO reported-employee.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

*  --- Validation: 入社日検証 ---
  METHOD validateJoinDate.
    READ ENTITIES OF ZI_EMPLOYEE_001 IN LOCAL MODE
      ENTITY Employee
      FIELDS ( JoinDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(employees).

    LOOP AT employees INTO DATA(employee).
*     入社日が未入力(Initial)の場合エラー
      IF employee-JoinDate IS INITIAL.
        APPEND VALUE #( %tky = employee-%tky ) TO failed-employee.

        APPEND VALUE #( %tky = employee-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = '入社日は必須入力です'
                               )
                        %element-JoinDate = if_abap_behv=>mk-on
                      ) TO reported-employee.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
