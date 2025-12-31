@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Employee Basic Info'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType :{
       serviceQuality: #X,
       sizeCategory : #S,
       dataClass: #MIXED
       }
define view entity ZI_TKG_EMPL 
as select from zdb_tkg_empl
{
  key emplid as Emplid,
  fname as Fname,
  lname as Lname,
  gender as Gender,
  designation as Designation  
}
