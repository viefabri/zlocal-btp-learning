@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '社員名簿 Basic View'
@VDM.viewType: #BASIC
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory:   #L,
    dataClass:      #MASTER
}
define view entity ZI_EMPLOYEE_001
  as select from zemployee_001
  association [0..1] to ZI_DEPARTMENT_001 as _Department on $projection.DeptId = _Department.DeptId
  association [0..1] to ZI_STATUS_VH_001  as _Status     on $projection.Status = _Status.Status
{
  key emp_id                as EmployeeId,
      first_name            as FirstName,
      last_name             as LastName,
      email                 as Email,
      dept_id               as DeptId,
      emp_grade             as Grade,
      join_date             as JoinDate,
      resign_date           as ResignDate, //退職日
      @Semantics.amount.currencyCode: 'CurrencyCode'
      salary                as Salary,
      currency_code         as CurrencyCode,
      status                as Status,

      /* 監査項目群 */
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Department,
      _Status
}
