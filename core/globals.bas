#INCLUDE "../iguanacms.bi"

DIM SHARED GlobalProperties() AS DataField

SUB CreateGlobalProperty(PropertyName AS STRING, PropertyValue AS STRING)
  CreateProperty(GlobalProperties(), PropertyName, PropertyValue)
END SUB

FUNCTION ReadGlobal(PropertyName AS STRING) AS STRING
  ReadGlobal = ReadProperty(GlobalProperties(), PropertyName)
END FUNCTION

SUB UpdateGlobalProperty(PropertyName AS STRING, PropertyValue AS STRING)
  UpdateProperty(GlobalProperties(), PropertyName, PropertyValue)
END SUB

SUB ClearGlobalProperties()
  ClearProperties(GlobalProperties())
END SUB
