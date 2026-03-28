@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '社員名簿 Base BO (Composite)'
@VDM.viewType: #COMPOSITE
define root view entity ZR_EMPLOYEE_001
  as select from ZI_EMPLOYEE_001
{
  key EmployeeId,
      FirstName,
      LastName,
      Email,
      DeptId,
      Grade,
      JoinDate,
      ResignDate, //退職日
      Salary,
      
      /* ビジネス計算ロジックをここで定義 */
      @Semantics.amount.currencyCode: 'CurrencyCode'
      cast( Salary * 12 as zannual_salary ) as AnnualSalary,
      
      CurrencyCode,
      Status,
      
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _Department,
      _Status
}
