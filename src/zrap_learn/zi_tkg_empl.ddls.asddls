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
association [1..1] to ZI_TKG_CONT as _cont on $projection.Emplid = _cont.Emplid
association [1..1] to ZI_TKG_ADDR as _addr on $projection.Emplid = _addr.Emplid
{
  key emplid as Emplid,
  fname as Fname,
  lname as Lname,
  gender as Gender,
  designation as Designation,
  concat_with_space( fname, lname, 1 ) as Fullname,
  _cont, 
  _addr
}
