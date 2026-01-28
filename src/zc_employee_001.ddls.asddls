@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '社員管理'

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

      /* --- 以下、各項目のUI表示設定 --- */

      /* EmployeeId: 社員ID */
      @UI.lineItem:       [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      /* ラベル追加 */
      @EndUserText.label: '社員ID'
  key EmployeeId,

      /* FirstName: 名 */
      @UI.lineItem:       [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      /* ラベル追加 */
      @EndUserText.label: '名'
      FirstName,

      /* LastName: 姓 */
      @Search.defaultSearchElement: true
      @UI.lineItem:       [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      /* ラベル追加 */
      @EndUserText.label: '姓'
      LastName,

      /* Email: メールアドレス */
      @UI.lineItem:       [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      /* 【修正4】ラベル追加 */
      @EndUserText.label: 'メールアドレス'
      Email,

      /* 部署ID: Value Help / テキスト連携 */
      @UI.lineItem:       [{ position: 45 }]
      @UI.selectionField: [{ position: 40 }]
      @UI.identification: [{ position: 45 }]
      @ObjectModel.text.element: ['DeptName']
      @Consumption.valueHelpDefinition: [{ entity : { name: 'ZI_DEPARTMENT_001', element: 'DeptId' } }]
      /* ラベル追加 */
      @EndUserText.label: '部署'
      DeptId,

      /* 部署名 (検索・連携用) */
      @Search.defaultSearchElement: true
      _Department.DeptName as DeptName,

      /* JoinDate: 入社日 */
      @UI.lineItem:       [{ position: 50 }]
      @UI.identification: [{ position: 50 }] // 詳細画面にも表示
      /* ラベル追加 */
      @EndUserText.label: '入社日'
      JoinDate,

      /* Salary: 給与 */
      @UI.lineItem:       [{ position: 60 }]
      @UI.identification: [{ position: 60 }] // 詳細画面にも表示
      /* 【修正7】ラベル追加 */
      @EndUserText.label: '給与'
      Salary,

      CurrencyCode
}
