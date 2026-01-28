/* [権限チェック] 学習用のためスキップ */
@AccessControl.authorizationCheck: #NOT_REQUIRED

/* [ビュー説明] */
@EndUserText.label: '社員名簿 Interface View'

/* [RAP定義] BO Root定義
   define root: Transactional動作の起点となる宣言
   view entity: 新構文 (パフォーマンス・厳密性向上)
*/
define root view entity ZI_EMPLOYEE_001
  as select from zemployee_001

  /* [Association] 部署マスタへの関連定義
     [0..1]: カーディナリティ (0または1)
     $projection: 自ビューの論理項目(DeptId)を使用
  */
  association [0..1] to ZI_DEPARTMENT_001 as _Department on $projection.DeptId = _Department.DeptId
{
      /* --- フィールドマッピング (物理名 → 論理名) --- */

      /* EmployeeId: キー項目 (CamelCaseへ変換) */
  key emp_id        as EmployeeId,

      /* 基本データ */
      first_name    as FirstName,
      last_name     as LastName,
      email         as Email,
      
      /* [FK] 外部キー (部署ID)
         テーブル指定なしのためメイン (zemployee_001) の項目を採用
      */
      dept_id       as DeptId,
      
      join_date     as JoinDate,

      /* [Semantics] 金額と通貨の紐付け
         UIや分析で正しく通貨単位を扱うための定義
      */
      @Semantics.amount.currencyCode: 'CurrencyCode'
      salary        as Salary,

      /* 通貨コード */
      currency_code as CurrencyCode,
      
      /* タイムスタンプ */
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,

      /* [Association公開]
         上位 (Consumption View) やUIからのアクセスを許可
      */
      _Department

}
