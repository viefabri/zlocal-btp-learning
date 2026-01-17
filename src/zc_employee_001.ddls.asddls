@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '社員情報～VDM Consumption View～'

/* [拡張性] メタデータ拡張 (MDE) の許可
   UIアノテーションを別ファイル(MDE)に分離して管理できるようにする設定。
   実プロジェクトでは「コード(ロジック)」と「UI設定」を分けるために推奨されます。
*/
@Metadata.allowExtensions: true

/* [UIヘッダー] 詳細画面 (Object Page) のタイトル設定
   一覧から行をクリックして詳細画面に入った際、上部に表示される情報です。
   typeName: 単数形の名称 (例: Employee)
   title: ヘッダーのメインタイトル (例: LastName=山田)
   description: タイトルの下の補足情報 (例: FirstName=太郎)
*/
@UI.headerInfo: { 
    typeName: 'Employee', 
    typeNamePlural: 'Employees',
    title: { value: 'LastName' },
    description: { value: 'FirstName' }
}

/* [RAP定義] ビジネスオブジェクト (BO) 宣言
   define root: このビューがBOの「親(Root)」であることを宣言します。
   transactional_query: データの読み取りだけでなく、将来的な更新処理(CRUD)も見据えた契約を結びます。
   as projection on: 下層のInterface View (ZI) を「投影(Projection)」して作ります。
*/
define root view entity ZC_EMPLOYEE_001
  provider contract transactional_query
  as projection on ZI_EMPLOYEE_001
{
      /* [UI構造] ファセット定義
         詳細画面の中身のレイアウトを定義します。
         type: #IDENTIFICATION_REFERENCE は、「@UI.identification」が付いた項目を
         ひとまとめにして表示するセクションを作る、という意味です。
      */
      @UI.facet: [{ id: 'General', type: #IDENTIFICATION_REFERENCE, label: 'General Info' }]
      
      /* --- 以下、各項目のUI表示設定 --- */

      /* EmployeeId: 社員ID */
      @UI.lineItem:       [{ position: 10 }]  // 一覧リストでの表示順 (左から1番目)
      @UI.selectionField: [{ position: 10 }]  // 検索条件バーでの表示順 (左から1番目)
      @UI.identification: [{ position: 10 }]  // 詳細画面での表示順 (上から1番目)
  key EmployeeId,

      /* FirstName: 名 */
      @UI.lineItem:       [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      FirstName,

      /* LastName: 姓 */
      @UI.lineItem:       [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]  // 姓でも検索できるように追加
      @UI.identification: [{ position: 30 }]
      LastName,

      /* Email: メールアドレス */
      @UI.lineItem:       [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      Email,

      /* JoinDate: 入社日 */
      @UI.lineItem:       [{ position: 50 }]
      // identificationがないため、詳細画面のメインエリアには表示されません
      JoinDate,
      
      /* Salary: 給与 */
      @UI.lineItem:       [{ position: 60 }]
      // 通貨コード(CurrencyCode)と紐づいているため、画面上は「500 JPY」のように単位付きで表示されます
      Salary,
      
      /* CurrencyCode: 通貨 */
      // UIアノテーションがないため画面には表示されませんが、Salaryの単位として裏で必須です
      CurrencyCode
}
