CLASS zcl_data_load DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS zcl_data_load IMPLEMENTATION.
Method if_oo_adt_classrun~main.

data wa_tkg_empl type zdb_tkg_empl.
wa_tkg_empl-emplid = '1'.
wa_tkg_empl-fname = '0010967890'.
wa_tkg_empl-lname = '9898765432'.
wa_tkg_empl-gender = '1'.
wa_tkg_empl-designation = '09khlhlh@gamil.com'.
Delete  zdb_tkg_empl from @wa_tkg_empl.

if sy-subrc = 0.

out->write( 'Employee data deleted successfully' ).
commit work.
else.
out->write( |Record not found or error occured. Return code: { sy-subrc }| ).
endif.

ENDMETHOD.

ENDCLASS.
