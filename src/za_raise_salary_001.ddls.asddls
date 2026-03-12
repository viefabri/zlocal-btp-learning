@EndUserText.label: '昇給パラメータ'
define abstract entity ZA_RAISE_SALARY_001
{
    @EndUserText.label: '昇給パラメータ'
    @Semantics.amount.currencyCode:  'CurrencyCode'
    RaiseAmount : zsalary_amount_001;
    
    @UI.hidden: true
    CurrencyCode : abap.cuky;
    
    @EndUserText.label: '昇給理由'
    @UI.multiLineText: true
    reason : abap.char( 256 );
    
}
