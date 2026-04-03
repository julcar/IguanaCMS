'Sqlite 3 storage classes
'https://www.sqlite.org/datatype3.html
ENUM ParamTypes
  PARAM_TYPE_NULL
  PARAM_TYPE_INTEGER
  PARAM_TYPE_REAL
  PARAM_TYPE_TEXT
  PARAM_TYPE_BLOB
END ENUM

TYPE DataField
  Name AS STRING
  Value AS STRING
END TYPE

TYPE DataRow
  FieldCount AS ULONG
  Fields(Any) AS DataField
END TYPE

TYPE DataSet
  RowCount AS ULONG
  Rows(Any) AS DataRow
END TYPE

TYPE SqlParam
  ParamName AS STRING
  ParamValue AS STRING
  ParamType AS ParamTypes
END TYPE

DECLARE FUNCTION OpenConnection(DB_File AS STRING) AS LONG
DECLARE FUNCTION CloseConnection() AS LONG
DECLARE SUB AddParam(StrName AS STRING, StrValue AS STRING, DefaultType AS ParamTypes)
DECLARE SUB ClearParams()
DECLARE FUNCTION ExecuteSql(sSQL AS STRING) AS LONG
DECLARE FUNCTION FetchData(sSQL AS STRING) AS DataSet
DECLARE FUNCTION TableExists(TableName AS STRING) AS LONG
DECLARE SUB CheckTable(TableName AS STRING, Fields AS STRING = "")
