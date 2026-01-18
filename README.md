# zlocal-btp-learning
abapGit導入実践編

## コンテンツ

### Employee管理 (実践編)
ABAP RESTful Application Programming Model (RAP) の基礎を学ぶための実践的なサンプルコードです。
従業員情報の参照アプリケーションを以下の構成で実装しています。

**アーキテクチャ概要:**
1.  **Interface Layer (Core)**: `ZI_EMPLOYEE_001`
    *   データベース `zemployee_001` との直接的なマッピングを行います。
    *   フィールド名をスネークケースからキャメルケースへ変換し、通貨などのセマンティクスを定義します。

2.  **Consumption Layer (Projection)**: `ZC_EMPLOYEE_001`
    *   Fiori Elements (UI) 向けの表示設定（アノテーション）を定義します。
    *   一覧表示、詳細画面のレイアウト、検索フィールドなどを制御します。

3.  **Service Exposition**: `ZUI_EMPLOYEE_001`
    *   外部公開用のサービス定義です。ODataサービスとして `Employee` エンティティを公開します。
