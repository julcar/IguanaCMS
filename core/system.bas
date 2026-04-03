#INCLUDE "../iguanacms.bi"

FUNCTION SystemProperties(ObjectExpr AS STRING) AS STRING
  DIM AS STRING ObjectName, EvalExpr, Result
  ObjectName = MID(ObjectExpr, 1, INSTR(ObjectExpr, ".") - 1)
  EvalExpr = MID(ObjectExpr, INSTR(ObjectExpr, ".") + 1, LEN(ObjectExpr) - INSTR(ObjectExpr, "."))
  SELECT CASE ObjectName
    CASE "date"
      Result = SystemDate()
    CASE "time"
      Result = SystemTime()
    CASE "year"
      Result = Year()
    CASE "month"
      Result = Month()
    CASE "day"
      Result = Day()
    CASE "env"
      Result = ENVIRON(EvalExpr)
    CASE "version"
      Result = IGUANA_VERSION
    CASE "os"
      IF LCASE(ENVIRON("OS")) = "windows_nt" THEN
        Result = "Windows"
      ELSE
        Result = "Linux"
      END IF
    CASE "char"
      Result = CHR(VALINT(EvalExpr))
    CASE ELSE
      Result = EvalExpr
  END SELECT
  SystemProperties = Result
END FUNCTION

SUB InitLoad()
  DIM BasePath AS STRING
  LoadSites()
  'Initialize Site Paths
  BasePath = GetBasePath(ENVIRON("HTTP_HOST"))
  IF BasePath <> "" THEN
    CreateGlobalProperty("root_path", BasePath + "root" + PATH_DELIMITER)
    CreateGlobalProperty("temp_path", BasePath + "temp" + PATH_DELIMITER)
    CreateGlobalProperty("data_path", BasePath + "data" + PATH_DELIMITER)
    'Initialize global settings
    LoadSettings()
    'Open database connection
    OpenConnection(ReadGlobal("data_path") + GetSettings("database"))
    LoadBBCodes()
    LoadLanguage("main")
    LoadTemplate("main")
    RunLoaders()
  END IF
END SUB
  
SUB CleanMemory()
  'Close database connection
  CloseConnection()
  ClearGlobalProperties()
END SUB
