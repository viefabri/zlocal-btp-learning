@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Country Logo'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_Country_logo 
as select from zdb_tkg_country
{
key country as Country,
logo_url as CountryLogo,

case country
when 'AU' then 'https://www.sap.com/australia/index.html'
when 'IN' then 'https://www.sap.com/india/index.html'
when 'US' then 'https://www.sap.com/index.html'
else ''
end as CountryWebLink
    
}
