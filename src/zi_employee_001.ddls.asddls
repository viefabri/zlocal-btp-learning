@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '社員名簿 Interface View'
@Metadata.ignorePropagatedAnnotations: true

/* VDM Basic View (Interface View)
   物理テーブルを隠蔽し、ビジネスロジックで使用する共通の型を定義
   従来のDDIC Viewとは異なり、'define view entity' を使用
*/
define view entity ZI_EMPLOYEE_001
  as select from zemployee_001
{
  /* Field Mapping:
     物理項目名（スネークケース）から論理項目名（キャメルケース）への変換
     これにより、UI層や外部APIでの可読性と標準準拠を保証します。
  */
  key emp_id        as EmployeeId,
      first_name    as FirstName,
      last_name     as LastName,
      email         as Email,
      join_date     as JoinDate,

  /* Semantics Annotation:
     金額項目(Salary)と通貨コード(CurrencyCode)の関係性を定義します。
     Fiori画面上で正しい桁数処理と単位表示を行うために必須です。
  */
      @Semantics.amount.currencyCode: 'CurrencyCode'
      salary        as Salary,
      
      currency_code as CurrencyCode

}
