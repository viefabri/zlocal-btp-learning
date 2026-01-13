@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View - Project Information'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_TKG_PROJ as select from ZI_TKG_PROJ
association to parent ZC_TKG_EMPL as _empl on $projection.Emplid = _empl.Emplid
composition[1..*] of ZC_TKG_SKILL as _skill
{
    key Emplid,
    key Projid,
    ProjectName,
    @ObjectModel.text.element: [ 'ProjectTypeText' ]
    ProjectType,
    ProjectTypeText,
    ProjectCriticality,
    IsCurrent,
    Duration,    
    _empl,
    _skill
   
}
