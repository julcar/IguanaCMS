#INCLUDE "../iguanacms.bi"

DIM SHARED ArraySettings() AS DataField

SUB LoadSettings()
  ParseDataFile(ArraySettings(), LoadDataFile("settings.shtml"), "settings")
END SUB

FUNCTION GetSettings(PropertyName AS STRING) AS STRING
  GetSettings = ReadProperty(ArraySettings(), PropertyName)
END FUNCTION

SUB SetSettings(PropertyName AS STRING, PropertyValue AS STRING)
  UpdateProperty(ArraySettings(), PropertyName, PropertyValue)
END SUB
