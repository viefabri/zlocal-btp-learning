//@AbapCatalog.viewEnhancementCategory: [#NONE]   //拡張許可のためコメント化
@AccessControl.authorizationCheck: #NOT_REQUIRED  // 権限チェック
@EndUserText.label: '部署'                        //テキスト
@Metadata.ignorePropagatedAnnotations: false      //メタデータを引き継ぐ

/* Value Help用最適化: データ件数が少ない(XS)ことを宣言し、ドロップダウン表示を可能にする */
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_DEPARTMENT_001
  as select from zdepartment_001
{

  key dept_id   as DeptId,
      dept_name as DeptName

}
