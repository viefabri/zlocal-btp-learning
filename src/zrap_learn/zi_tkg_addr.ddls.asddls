@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Address Info'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TKG_ADDR 
as select from zdb_tkg_addr
association[1..1] to ZI_COUNTRY_VH as _ctry on $projection.Country = _ctry.Country
{
    key emplid as Emplid,
    street as Street,
    city as City,
    country as Country,
    _ctry.CountryName as CountryText
}
