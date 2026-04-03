#INCLUDE "../iguanacms.bi"

EXTERN "C"
  DECLARE FUNCTION fread( _
    BYVAL Buffer AS ZSTRING PTR, _
    BYVAL Size AS ULONG, _
    BYVAL Length AS ULONG, _
    BYVAL Stream AS ULONG PTR _
  ) AS ULONG
END EXTERN

DIM SHARED StdinQuery AS STRING
DIM SHARED StdinParams() AS DataField
DIM SHARED QueryStringParams() AS DataField
DIM SHARED CookieParams() AS DataField

'Get the Stdin content
StdinQuery = ReadStdin()

'Parse the Stdin content
IF NOT INSTR(ENVIRON("CONTENT_TYPE"), "multipart/form-data") THEN
  ParseQuery(StdinQuery, StdinParams(), "&")
END IF

'Parse the query string
ParseQuery(ENVIRON("QUERY_STRING"), QueryStringParams(), "&")

'Parse the cookies
ParseQuery(ENVIRON("HTTP_COOKIE"), CookieParams(), "; ")

FUNCTION URLDecode(Query AS STRING) AS STRING
  DIM AS STRING Char, Result
  FOR i AS ULONG = 1 TO LEN(Query)
    Char = MID(Query, i, 1)
    SELECT CASE Char
      CASE "%"
        Result += CHR(VAL("&H" + MID(Query, i + 1, 2)))
        i += 2
      CASE "+"
        Result += CHR(32)
      CASE ELSE
        Result += Char
    END SELECT
  NEXT
  URLDecode = Result
END FUNCTION

SUB ParseQuery(InputQuery AS STRING, ArrayParams() AS DataField, Delimiter AS STRING)
  DIM AS ULONG StartPos = 1, NextPos = 1
  DIM ParamContent AS STRING
  WHILE NextPos
    NextPos = INSTR(StartPos, InputQuery, Delimiter)
    ParamContent = MID(InputQuery, StartPos, NextPos - StartPos)
    CreateProperty(ArrayParams(), LEFT(ParamContent, INSTR(ParamContent, "=") - 1), MID(ParamContent, INSTR(ParamContent, "=") + 1))
    StartPos = NextPos + LEN(Delimiter)
  WEND
END SUB

FUNCTION ReadStdin() AS STRING
  IF ENVIRON("REQUEST_METHOD") = "POST" THEN
    DIM Length AS ULONG = VAL(ENVIRON("CONTENT_LENGTH"))
    DIM Content AS STRING = SPACE(Length)
    IF INSTR(ENVIRON("CONTENT_TYPE"), "multipart/form-data") THEN
      DIM AS ULONG ReadLen, StdIn
      ReadLen = Fread(Content, 1, Length, VarPtr(StdIn))
    ELSE
      DIM fFile AS ULONG = FREEFILE
      OPEN CONS FOR INPUT AS #fFile
      GET #fFile,,Content
      CLOSE #fFile
    END IF
    ReadStdin = Content
  END IF
END FUNCTION

FUNCTION Post(Arg AS STRING) AS STRING
  IF INSTR(ENVIRON("CONTENT_TYPE"), "multipart/form-data") THEN
    DIM AS STRING Boundary, ContDisp, FieldName
    'Custom cursors
    DIM AS ULONG StartPos, CurPos
    'Get the boundary
    Boundary = "--" + MID(ENVIRON("CONTENT_TYPE"), INSTR(ENVIRON("CONTENT_TYPE"), "boundary=") + 9)
    StartPos = INSTR(StdinQuery, Boundary)
    DO WHILE StartPos
      'Get the "Content-Disposition" header
      CurPos = INSTR(StartPos + LEN(Boundary), StdinQuery, "Content-Disposition:")
      ContDisp = MID(StdinQuery, CurPos, INSTR(CurPos, StdinQuery, CHR(10)) - CurPos)
      'Get the field name
      CurPos = INSTR(ContDisp, "name=") + 6
      FieldName = MID(ContDisp, CurPos, INSTR(CurPos, ContDisp, CHR(34)) - CurPos)
      IF Arg = FieldName THEN
        'Look if we have the filename field
        IF INSTR(ContDisp, "filename=") > 0 THEN
          'Return the file name
          CurPos = INSTR(ContDisp, "filename=") + 10
          Post = MID(ContDisp, CurPos, INSTR(CurPos, ContDisp, CHR(34)) - CurPos)
        ELSE
          'Return the field value
          CurPos = INSTR(StartPos + LEN(ContDisp), StdinQuery, CHR(10)) + 3
          Post = MID(StdinQuery, CurPos, INSTR(CurPos, StdinQuery, CHR(10)) - CurPos - 1)
        END IF
        EXIT DO
      END IF
      StartPos = INSTR(StartPos + LEN(Boundary), StdinQuery, Boundary)
    LOOP
  ELSE
    Post = URLDecode(ReadProperty(StdinParams(), Arg))
  END IF
END FUNCTION

FUNCTION QueryString(Arg AS STRING) AS STRING
  QueryString = URLDecode(ReadProperty(QueryStringParams(), Arg))
END FUNCTION

FUNCTION GetCookie(CookieName AS STRING) AS STRING
  GetCookie = ReadProperty(CookieParams(), CookieName)
END FUNCTION

FUNCTION GetFileMIMEType(FileName AS STRING) AS STRING
  IF INSTR(ENVIRON("CONTENT_TYPE"), "multipart/form-data") THEN
    DIM AS ULONG CurPos = INSTR(StdinQuery, "filename=" + CHR(34) + FileName + CHR(34))
    IF CurPos THEN
      CurPos = INSTR(CurPos, StdinQuery, CHR(10))
      IF INSTR(CurPos, StdinQuery, "Content-Type") THEN
        'Return the Content-Type header
        CurPos = INSTR(CurPos, StdinQuery, "Content-Type") + 14
        GetFileMIMEType = MID(StdinQuery, CurPos, INSTR(CurPos, StdinQuery, CHR(10)) - CurPos - 1)
      END IF
    END IF
  END IF
END FUNCTION

FUNCTION GetFileContent(FileName AS STRING) AS STRING
  IF INSTR(ENVIRON("CONTENT_TYPE"), "multipart/form-data") THEN
    DIM Boundary AS STRING, CurPos AS ULONG
    Boundary = "--" + MID(ENVIRON("CONTENT_TYPE"), INSTR(ENVIRON("CONTENT_TYPE"), "boundary=") + 9)
    CurPos = INSTR(StdinQuery, "filename=" + CHR(34) + FileName + CHR(34))
    IF CurPos THEN
      CurPos = INSTR(CurPos, StdinQuery, CHR(10))
      IF INSTR(CurPos, StdinQuery, "Content-Type") THEN
        'Skip the Content-Type header
        CurPos = INSTR(CurPos + 1, StdinQuery, CHR(10)) + 3
        'Return the file content
        GetFileContent = MID(StdinQuery, CurPos, INSTR(CurPos, StdinQuery, Boundary) - (CurPos + 2))
      END IF
    END IF
  END IF
END FUNCTION

'HTTP 1.1 headers initialization

SUB SendHeader(HeaderName AS STRING, HeaderContent AS STRING)
  PRINT HeaderName + ": " + HeaderContent
END SUB

SUB SetCookie(CookieName AS STRING, CookieValue AS STRING, _
 Domain AS STRING, Path AS STRING, ExpiresDate AS STRING, _
 MaxAgeTime AS ULONG, IsSecure AS LONG, IsHttpOnly AS LONG)
  DIM StrOut AS STRING
  'Add standard parameters
  StrOut = CookieName + "=" + CookieValue
  IF Domain <> "" THEN
    StrOut += "; Domain=" + Domain
  END IF
  IF Path <> "" THEN
    StrOut += "; Path=" + Path
  END IF
  IF ExpiresDate <> "" THEN
    'FIXME: validate standard date format Wdy, DD Mon YYYY HH:MM:SS GMT
    StrOut += "; Expires=" + ExpiresDate
  END IF
  IF MaxAgeTime > 0 THEN
    StrOut += "; Max-Age=" + LTRIM(STR(MaxAgeTime))
  END IF
  IF IsSecure THEN
    StrOut += "; Secure"
  END IF
  IF IsHttpOnly THEN
    StrOut += "; HttpOnly"
  END IF
  SendHeader("Set-Cookie", StrOut)
END SUB
