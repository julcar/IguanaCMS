#INCLUDE "../iguanacms.bi"

DIM SHARED ArrayLanguage() AS DataField
  
SUB LoadLanguage(ModuleName AS STRING)
  DIM ModulePath AS STRING
  IF ModuleName <> "main" THEN
    ModulePath = "modules" + PATH_DELIMITER
  END IF
  ParseDataFile(ArrayLanguage(), LoadDataFile("languages" + PATH_DELIMITER + _
  GetSettings("language") + PATH_DELIMITER + ModulePath + ModuleName + ".shtml"), "key")
END SUB

FUNCTION Language(Key AS STRING) AS STRING
  Language = ReadProperty(ArrayLanguage(), Key)
END FUNCTION
