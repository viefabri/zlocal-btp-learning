@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View - Employee Information'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TKG_EMPL
 as select from ZI_TKG_EMPL
composition [1..*] of ZC_TKG_PROJ as _proj
{
    key Emplid,
    Fname,
    Lname,
    Gender,
    Designation,
    Fullname,
    
   // Contact Info 
   _cont.PhoneNum,
   _cont.AltPhoneNum,
   _cont.EmailId,
   _cont.AltEmailId,
   
   // Address Info
  _addr.Street,
  _addr.City,
  @ObjectModel.text.element: [ 'CountryText' ]
  _addr.Country,
  _addr.CountryText,
  @Semantics.imageUrl: true
  _addr.CountryLogoUrl,
  _addr.CountryWebLink,
  
  _proj
  }
