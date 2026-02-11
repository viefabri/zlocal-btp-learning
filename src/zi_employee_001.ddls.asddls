@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '社員名簿 Interface View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_EMPLOYEE_001
  as select from zemployee_001

  association [0..1] to ZI_DEPARTMENT_001 as _Department on $projection.DeptId = _Department.DeptId
  association [0..1] to ZI_STATUS_VH_001  as _Status     on $projection.Status = _Status.Status
{
      /* キー項目 */
  key emp_id                as EmployeeId,

      /* 基本データ */
      first_name            as FirstName,
      last_name             as LastName,
      email                 as Email,
      dept_id               as DeptId,
      emp_grade             as Grade,
      join_date             as JoinDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      salary                as Salary,
      
/* --- 年収 (計算項目) --- */
      @Semantics.amount.currencyCode: 'CurrencyCode'
      cast( salary * 12 as zannual_salary ) as AnnualSalary,
      
      currency_code         as CurrencyCode,

      /* --- ステータス --- */
      @Consumption.valueHelpDefinition: [{ entity : { name: 'ZI_STATUS_VH_001', element: 'Status' } }]
      @ObjectModel.text.element: [ 'StatusText' ]
      status                as Status,

      /* ステータステキスト (UI表示用) */
      _Status.StatusText    as StatusText,

      /* --- 監査・管理項目 (Audit Fields) --- */

      /* 作成者 */
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      /* 作成日時 */
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      /* 最終更新者 */
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,

      /* 最終更新日時 (インスタンスETag) */
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* トータル更新日時 (Total ETag) */
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      /* Association公開 */
      _Department,
      _Status
}
