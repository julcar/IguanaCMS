#INCLUDE "../iguanacms.bi"

DIM SHARED UrlProperties() AS DataField

SUB CreateUrlProperty(PropertyName AS STRING, PropertyValue AS STRING)
  CreateProperty(UrlProperties(), PropertyName, PropertyValue)
END SUB

FUNCTION ReadUrl(PropertyName AS STRING) AS STRING
  ReadUrl = ReadProperty(UrlProperties(), PropertyName)
END FUNCTION

SUB ClearUrlProperties()
  ClearProperties(UrlProperties())
END SUB

FUNCTION CreateURL(Scheme AS STRING) AS STRING
  DIM AS STRING ParamValue, Result
  DIM AS ULONG Count = 0, StartPos = 1, NextPos = 1
  WHILE NextPos
    NextPos = INSTR(StartPos, Scheme, ".")
    ParamValue = MID(Scheme, StartPos, NextPos - StartPos)
    IF LEFT(ParamValue, 1) = "{" AND RIGHT(ParamValue, 1) = "}" THEN
      'Dealing with variable in url
      ParamValue = ReadUrl(MID(ParamValue, 2, LEN(ParamValue) - 2))
    END IF
    IF CBOOL(GetSettings("fancy_url")) THEN
      IF Count MOD 2 <> 0 THEN
        'Avoid print odd position params
        Result += ParamValue
        IF NextPos > 0 THEN
          Result += "/"
        END IF
      END IF
    ELSE
      Result += ParamValue
      IF NextPos > 0 THEN
        IF Count MOD 2 = 0 THEN
          Result += "="
        ELSE
          Result += "&amp;"
        END IF
      END IF
    END IF
    Count += 1
    StartPos = NextPos + 1
  WEND
  IF CBOOL(GetSettings("fancy_url")) THEN
    CreateURL = "/" + Result + GetSettings("fancy_url_extension")
  ELSE
    CreateURL = "?" + Result
  END IF
END FUNCTION

FUNCTION URLParam(Arg AS ULONG) AS STRING
  DIM AS ULONG Count = 1, StartPos = 1, NextSlash = 1
  DIM AS STRING StrUri, Result
  StrUri = ENVIRON("REQUEST_URI")
  IF StrUri = "" THEN
    'REQUEST_URI failed or not available, lets check PATH_INFO
    StrUri = ENVIRON("PATH_INFO")
  END IF
  IF INSTR(StrUri, ENVIRON("SCRIPT_NAME")) THEN
    'Webserver is sending file name as part of URI
    'Trim the first slash and the file name
    StrUri = MID(StrUri, INSTR(2, StrUri, "/"))
  END IF
  DO WHILE NextSlash
    NextSlash = INSTR(StartPos, StrUri, "/")
    IF Arg = Count - 1 THEN
      DIM ExtensionPos AS ULONG
      Result = MID(StrUri, StartPos, NextSlash - StartPos)
      ExtensionPos = INSTR(Result, GetSettings("fancy_url_extension"))
      IF ExtensionPos THEN
        Result = LEFT(Result, ExtensionPos - 1)
      END IF
      EXIT DO
    END IF
    StartPos = NextSlash + 1
    Count += 1
  LOOP
  URLParam = Result
END FUNCTION

FUNCTION GetURLParam(VarName AS STRING = "", ParamIndex AS ULONG = 0) AS STRING
  IF CBOOL(GetSettings("fancy_url")) THEN
    DIM FoundParam AS STRING = URLParam(ParamIndex)
    IF ParamIndex > 0 AND FoundParam <> "" THEN
      GetURLParam = FoundParam
    END IF
  ELSE
    IF QueryString(VarName) <> "" THEN
      GetURLParam = QueryString(VarName)
    END IF
  END IF
END FUNCTION
