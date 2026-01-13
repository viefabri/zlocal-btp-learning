@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gender Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
serviceQuality:#X,
sizeCategory: #S,
dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_GENDER_VH as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZD_GENDER_MF')
{
 key domain_name,
 key value_position,
 key language,
 @ObjectModel.text.element: [ 'GenderText' ]
 value_low as GenderCode,
 text as GenderText   
}
where language = $session.system_language
