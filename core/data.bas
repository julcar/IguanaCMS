#INCLUDE "../libs/sqlite3.bi"
#INCLUDE "data.bi"

DIM SHARED DB_Handler AS INTEGER, ParamList() AS SqlParam

FUNCTION GetRow CDECL ( _
  ThisSet AS DataSet PTR, _
  ColCount AS LONG, _
  FieldValues AS ZSTRING PTR PTR, _
  ColNames AS ZSTRING PTR PTR _
) AS LONG
  DIM RowIndex AS LONG
  WITH (*ThisSet)
    RowIndex = UBOUND(.Rows) + 1
    REDIM PRESERVE .Rows(RowIndex)
    WITH .Rows(RowIndex)
      .FieldCount = ColCount
      REDIM .Fields(.FieldCount)
      FOR i AS ULONG = 0 TO .FieldCount - 1
        .Fields(i).Name = *ColNames[i]
        .Fields(i).Value = *FieldValues[i]
      NEXT
    END WITH
    .RowCount = RowIndex + 1
  END WITH
  GetRow = SQLITE_OK
END FUNCTION

FUNCTION OpenConnection(DB_File AS STRING) AS LONG
  IF sqlite3_open(DB_File, DB_Handler) = SQLITE_OK THEN
    OpenConnection = -1
  ELSE
    sqlite3_close(DB_Handler)
  END IF
END FUNCTION

FUNCTION CloseConnection() AS LONG
  IF sqlite3_close(DB_Handler) = SQLITE_OK THEN
    CloseConnection = -1
  END IF
END FUNCTION

FUNCTION EscapeParam(ParamValue AS STRING) AS STRING
  DIM Result AS STRING, NewChar AS STRING, Char AS LONG
  FOR i AS ULONG = 1 TO LEN(ParamValue)
    Char = ASC(MID(ParamValue, i, 1))
    SELECT CASE Char
      CASE 39 'single quote
        NewChar = CHR(39, 39)
      CASE ELSE
        NewChar = CHR(Char)
    END SELECT
    Result += NewChar
  NEXT
  EscapeParam = Result
END FUNCTION

SUB AddParam(StrName AS STRING, StrValue AS STRING, DefaultType AS ParamTypes)
  DIM ParamIndex AS LONG = UBOUND(ParamList) + 1
  IF StrValue <> "" THEN
    REDIM PRESERVE ParamList(ParamIndex)
    WITH ParamList(ParamIndex)
      .ParamName = StrName
      .ParamValue = StrValue
      .ParamType = DefaultType
    END WITH
  END IF
END SUB

SUB ClearParams()
  IF UBOUND(ParamList) >= 0 THEN
    ERASE ParamList
  END IF
END SUB

FUNCTION BuildCommand(RawSql AS STRING) AS STRING
  DIM AS ULONG StartPos, FoundPos
  DIM NewValue AS STRING
  DIM ParamCount AS LONG = UBOUND(ParamList)
  IF ParamCount >= 0 THEN
    FOR i AS ULONG = 0 TO ParamCount
      WITH ParamList(i)
        SELECT CASE .ParamType
          CASE PARAM_TYPE_INTEGER
            NewValue = STR(VALINT(.ParamValue))
          CASE PARAM_TYPE_REAL
            NewValue = STR(VAL(.ParamValue))
          CASE PARAM_TYPE_TEXT, PARAM_TYPE_BLOB
            'Escape single quotes and wrap with single quotes
            NewValue = CHR(39) + EscapeParam(.ParamValue) + CHR(39)
          CASE ELSE
            NewValue = "NULL"
        END SELECT
        'Init cursors
        StartPos = 1
        FoundPos = StartPos
        WHILE FoundPos
          FoundPos = INSTR(StartPos, RawSql, .ParamName)
          IF FoundPos THEN
            RawSql = LEFT(RawSql, FoundPos - 1) + NewValue + MID(RawSql, FoundPos + LEN(.ParamName))
          END IF
          StartPos = FoundPos + LEN(.ParamName)
        WEND
      END WITH
    NEXT
  END IF
  BuildCommand = RawSql
END FUNCTION

FUNCTION ExecuteSql(sSQL AS STRING) AS LONG
  sSQL = BuildCommand(sSQL)
  IF sqlite3_exec(DB_Handler, sSQL) = SQLITE_OK THEN
    ExecuteSql = -1
  END IF
END FUNCTION

FUNCTION FetchData(sSQL AS STRING) AS DataSet
  sSQL = BuildCommand(sSQL)
  DIM TempSet AS DataSet
  IF sqlite3_exec( _
    DB_Handler, _
    sSQL, _
    CINT(ProcPtr(GetRow)), _
    CINT(VarPtr(TempSet)), _
  ) = SQLITE_OK THEN
    FetchData = TempSet
  END IF
END FUNCTION

FUNCTION TableExists(TableName AS STRING) AS LONG
  DIM sSQL AS STRING, TableDST AS DataSet
  sSQL = "SELECT [name] FROM [sqlite_master] WHERE [type] = 'table' AND [name] = @TableName"
  AddParam("@TableName", TableName, PARAM_TYPE_TEXT)
  TableDST = FetchData(sSQL)
  ClearParams()
  IF TableDST.RowCount THEN
    TableExists = -1
  END IF
END FUNCTION

SUB CheckTable(TableName AS STRING, Fields AS STRING = "")
  IF NOT TableExists(TableName) THEN
    DIM sSQL AS STRING = "" _
    "CREATE TABLE IF NOT EXISTS [" + TableName + "] (" + Fields + ");"
    ExecuteSql(sSQL)
  END IF
END SUB
