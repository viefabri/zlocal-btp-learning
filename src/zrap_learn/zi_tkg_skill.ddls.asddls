@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Skill Info'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TKG_SKILL as select from zdb_tkg_skill
{
    key emplid as Emplid,
    key projid as Projid,
    key skillid as Skillid,
    skill_level as SkillLevel,
    is_primary as IsPrimary,
    is_certified as IsCertified
}
