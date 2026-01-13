@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Project Info'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TKG_PROJ 
as select from zdb_tkg_proj

{
    key emplid as Emplid,
    key projid as Projid,
    project_name as ProjectName,
    project_type as ProjectType,
    //-----Project Type Text condition
    case project_type
     when 'SAP' then 'Implementation'
     when 'AU' then 'Support'
     else 'Others'
     end as ProjectTypeText,
   //-----project Criticality Status 
     case project_type
     when 'SAP' then 3
     when 'AU' then 2
     else 0
     end as ProjectCriticality,
     
    is_current as IsCurrent,
    duration as Duration
    
}
