#INCLUDE "../iguanacms.bi"

DIM SHARED ArraySites() AS DataField

SUB LoadSites()
  ParseDataFile(ArraySites(), ReadFile("sitelist.shtml"), "site")
END SUB

FUNCTION GetBasePath(HostName AS STRING) AS STRING
  GetBasePath = ReadProperty(ArraySites(), HostName)
END FUNCTION
