@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '社員'
@Metadata.allowExtensions: true
@Search.searchable: true

@UI.headerInfo: {
    typeName: 'Employee',
    typeNamePlural: 'Employees',
    title: { value: 'LastName' },
    description: { value: 'FirstName' }
}

define root view entity ZC_EMPLOYEE_001
  provider contract transactional_query
  as projection on ZI_EMPLOYEE_001
{
      @UI.facet: [{ id: 'General', type: #IDENTIFICATION_REFERENCE, label: 'General Info' }]

      /* --- 各項目のUI表示設定 --- */
      /* EmployeeId: position 10 */
      @UI.lineItem:       [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @EndUserText.label: '社員ID' // 明示的に上書き
  key EmployeeId,

      /* --- ステータス : position 15 --- */
      @UI.lineItem:       [{ position: 15 }] 
      @UI.selectionField: [{ position: 15 }]
      @UI.identification: [{ position: 15 }]
      @ObjectModel.text.element: ['StatusText']
      @Consumption.valueHelpDefinition: [{ entity : { name: 'ZI_STATUS_VH_001', element: 'Status' } }]
      Status,

      /* StatusText */
      @UI.hidden: true
      StatusText,

      /* FirstName: position 20 */
      @UI.lineItem:       [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @EndUserText.label: '姓' // 明示的に上書き
      FirstName,

      /* LastName: position 30 */
      @Search.defaultSearchElement: true
      @UI.lineItem:       [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @EndUserText.label: '名' // 明示的に上書き
      LastName,

      /* Email: position 40 */
      @UI.lineItem:       [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      @EndUserText.label: 'メールアドレス' // 明示的に上書き
      Email,

      /* DeptId: position 45 */
      @UI.lineItem:       [{ position: 45 }]
      @UI.selectionField: [{ position: 40 }]
      @UI.identification: [{ position: 45 }]
      @ObjectModel.text.element: ['DeptName']
      @Consumption.valueHelpDefinition: [{ entity : { name: 'ZI_DEPARTMENT_001', element: 'DeptId' } }]
      @EndUserText.label: '部署' // 明示的に上書き
      DeptId,

      /* DeptName */
      @Search.defaultSearchElement: true
      _Department.DeptName as DeptName,

      /* JoinDate: position 50 */
      @UI.lineItem:       [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      JoinDate,

      /* Salary: position 60 */
      @UI.lineItem:       [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      Salary,
      
      CurrencyCode,
      
      /* LastChangedAt */
      @UI.identification: [{ position: 99 }]
      @EndUserText.label: '最終更新日時' // 明示的に上書き
      LastChangedAt
}
