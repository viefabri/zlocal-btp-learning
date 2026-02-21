CLASS zcl_http_hello_world_01 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_HELLO_WORLD_01 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    " レスポンスヘッダの設定（HTMLを返すことを明示） Pullテストのためコメント追加
    response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).

    " ブラウザに表示するHTMLボディの設定
    response->set_text( '<h1>Hello World from BTP Web!Git Hub Chane</h1>' ).

  ENDMETHOD.
ENDCLASS.
