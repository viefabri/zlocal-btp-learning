@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View - Skill Info'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_TKG_SKILL 
as select from ZI_TKG_SKILL
association to parent ZC_TKG_PROJ as _proj on $projection.Emplid = _proj.Emplid and
                                             $projection.Projid = _proj.Projid
{
    key Emplid,
    key Projid,
    key Skillid,
    SkillLevel,
    IsPrimary,
    IsCertified,
    _proj
}
