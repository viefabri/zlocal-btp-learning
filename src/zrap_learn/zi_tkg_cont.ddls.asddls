@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'InterfaceView - Contact Info'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TKG_CONT as select from zdb_tkg_cont
{
    key emplid as Emplid,
    phone_num as PhoneNum,
    alt_phone_num as AltPhoneNum,
    email_id as EmailId,
    alt_email_id as AltEmailId
}
