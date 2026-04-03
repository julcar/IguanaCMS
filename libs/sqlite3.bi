'SQLite 3.x library declarations based on https://www.sqlite.org/capi3ref.html

CONST SQLITE_OK = 0

EXTERN "c"
  'SQLite 3.x constructor
  DECLARE FUNCTION sqlite3_open(BYVAL FileName AS ZSTRING PTR, BYREF FileHandle AS INTEGER) AS LONG
  
  'SQLite 3.x destructor
  DECLARE FUNCTION sqlite3_close(BYVAL FileHandle AS INTEGER) AS LONG
  
  'SQLite 3.x query execution
  DECLARE FUNCTION sqlite3_exec( _
    BYVAL FileHandle AS INTEGER, _
    BYVAL StrSQL AS ZSTRING PTR, _
    BYVAL CallBackFunc AS INTEGER = 0, _
    BYVAL CallBackArg AS INTEGER = 0, _
    BYREF ErrorMessage AS ZSTRING PTR PTR = 0 _
  ) AS LONG
END EXTERN
