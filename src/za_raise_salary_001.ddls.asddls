@EndUserText.label: '昇給パラメータ'
define root abstract entity ZA_RAISE_SALARY_001
{
  @EndUserText.label: '昇給額'
  @Semantics.amount.currencyCode:  'CurrencyCode'
  RaiseAmount  : zsalary_amount_001;

  @EndUserText.label: '通貨コード'
  @UI.defaultValue: ''
  CurrencyCode : abap.cuky;

  @EndUserText.label: '昇給理由'
  @UI.multiLineText: true
  reason       : abap.char( 256 );

}
