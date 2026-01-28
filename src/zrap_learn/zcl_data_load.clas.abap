CLASS zcl_data_load DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS zcl_data_load IMPLEMENTATION.
Method if_oo_adt_classrun~main.

Delete from ZDB_TKG_EMPL where emplid = '   1'.
if sy-subrc = 0.
out->write( 'Employee record deleted successfuly' ).
commit work.
else.
out->write( 'Record not found' ).

endif.
ENDMETHOD.

ENDCLASS.
