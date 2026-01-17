/* [権限チェック] アクセス制御の設定
   #NOT_REQUIRED: 学習用のため、権限チェックをスキップします。
   実プロジェクトでは #CHECK を指定し、別途 DCL (Data Control Language) で
   「会社コード1000の人だけ見れる」といった行レベルのアクセス制御を行います。
*/
@AccessControl.authorizationCheck: #NOT_REQUIRED

/* [ビューの説明] ABAPリポジトリ上の説明文 */
@EndUserText.label: '社員名簿 Interface View'

/* [アノテーション継承の注意点]
   @Metadata.ignorePropagatedAnnotations: true は **記述してはいけません**。
   これを書くと、ここで定義した通貨設定(@Semantics...)が上位ビュー(ZC)に伝わらず、
   金額表示エラーの原因になります。VDMでは「意味(Semantics)の継承」が重要です。
*/

/* [RAP定義] ビジネスオブジェクト (BO) のルート定義
   define root: このビューが「ビジネスオブジェクトの親(Root)」であることを宣言します。
   この宣言があるからこそ、上位(ZC)で Transactional 契約を結ぶことができます。
   view entity: 従来の 'define view' (SE11 View作成) とは異なり、
   CDS専用の高速なランタイムで動作する最新構文です。
*/
define root view entity ZI_EMPLOYEE_001
  as select from zemployee_001
{
  /* --- フィールドマッピング (物理名 → 論理名) --- */
  
  /* [キー項目] EmployeeId
     物理名(emp_id)のようなスネークケースを、
     論理名(EmployeeId)のようなキャメルケースに変換します。
     Fiori/ODataの世界ではキャメルケースが標準規約です。
  */
  key emp_id        as EmployeeId,

  /* [データ項目] 名前、メールアドレス、入社日 */
      first_name    as FirstName,
      last_name     as LastName,
      email         as Email,
      join_date     as JoinDate,

  /* [意味的定義] 金額と通貨の紐付け
     @Semantics.amount.currencyCode:
     「この Salary という数値は、CurrencyCode という項目の単位に従う」という定義。
     これをここで定義しておくことで、UI層、分析層、Excel出力など、
     あらゆる利用シーンで「正しい金額」として扱われます。
  */
      @Semantics.amount.currencyCode: 'CurrencyCode'
      salary        as Salary,
      
  /* [通貨コード] */
      currency_code as CurrencyCode

}
