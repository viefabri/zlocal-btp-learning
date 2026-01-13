CLASS zcl_data_load DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS zcl_data_load IMPLEMENTATION.
Method if_oo_adt_classrun~main.

DATA lt_data TYPE TABLE OF zdb_tkg_country.

lt_data = value #(
( client = '100'
  country = 'AU'
  logo_url = 'https://hampusborgos.github.io/country-flags/'
   )
).
INSERT zdb_tkg_country FROM TABLE @lt_data.
commit work.
out->write( 'Country data uploaded successfully' ).


ENDMETHOD.

ENDCLASS.
