@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST] //拡張許可
@AccessControl.authorizationCheck: #NOT_REQUIRED  // 権限チェック
@EndUserText.label: 'ステータス'
@Metadata.ignorePropagatedAnnotations: true 
/* Value Help用最適化: データ件数が少ない(XS)ことを宣言し、ドロップダウン表示を可能にする */
@ObjectModel.resultSet.sizeCategory: #XS
@VDM.viewType: #COMPOSITE

define view entity ZI_STATUS_VH_001 
  as select from I_Language
{
    key 'A'     as Status,
         cast( '在職中' as abap.char(20) ) as StatusText
}
where
  Language = $session.system_language
  
union all select from I_Language
{
    key 'B'      as Status,
         '休職中' as StatusText
}
where
  Language = $session.system_language
union all select from I_Language
{
    key 'C'      as Status,
         '退職' as StatusText
}
where
  Language = $session.system_language
