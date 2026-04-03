FUNCTION Replace(RawStr AS STRING, LookFor AS STRING, ReplaceWith AS STRING) AS STRING
  DIM AS ULONG FoundPos = 1, StartPos = 1
  DIM AS STRING Result
  WHILE FoundPos
    FoundPos = INSTR(StartPos, RawStr, LookFor)
    IF FoundPos THEN
      Result += MID(RawStr, StartPos, FoundPos - StartPos) + ReplaceWith
      StartPos = FoundPos + LEN(LookFor)
    ELSE
      Result += MID(RawStr, StartPos, LEN(RawStr) - StartPos + 1)
    END IF
  WEND
  Replace = Result
END FUNCTION

FUNCTION ValidateChar(RawStr AS STRING) AS STRING
  DIM AS ULONG Char, NewChar
  DIM NewStr AS STRING
  FOR i AS ULONG = 1 TO LEN(RawStr)
    Char = ASC(MID(RawStr, i, 1))
    'List of allowed chars
    SELECT CASE Char
      CASE 45, 46, 64, 95
        NewChar = Char
      CASE 48 TO 57, 97 TO 122 'a-z, 0-9
        NewChar = Char
      CASE 65 TO 90 'A-Z
        NewChar = Char + 32
      CASE 192 TO 198, 224 TO 229
        NewChar = 97 'a
      CASE 128, 135
        NewChar = 99 'c
      CASE 200 TO 203, 232 TO 235
        NewChar = 101 'e
      CASE 204 TO 207, 236 TO 239
        NewChar = 105 'i
      CASE 209, 241
        NewChar = 110 'n
      CASE 210 TO 214, 216, 242 TO 246, 248
        NewChar = 111 'o
      CASE 217 TO 220, 249 TO 252
        NewChar = 117 'u
      CASE 221, 253, 255
        NewChar = 121 'y
      CASE ELSE
        NewChar = 0
    END SELECT
    IF NewChar > 0 THEN
      NewStr += CHR(NewChar)
    END IF
  NEXT
  ValidateChar = NewStr
  NewStr = ""
END FUNCTION

FUNCTION HTMLEncode(Query AS STRING) AS STRING
  DIM Char AS ULONG, Result AS STRING
  FOR i AS ULONG = 1 TO LEN(Query)
    Char = ASC(MID(Query, i, 1))
    SELECT CASE Char
      CASE 38, 39, 60, 62
        Result += "&#" + LTRIM(STR(Char)) + ";"
      CASE ELSE
        Result += CHR(Char)
    END SELECT
  NEXT
  HTMLEncode = Result
  'Clean memory
  Result = ""
END FUNCTION

FUNCTION RandomString(StrLength AS ULONG) AS STRING
  DIM AS ULONG ArrayChars(37), ArrayPos, CurrentChar = 48 
  DIM Result AS STRING
  FOR i AS ULONG = 0 TO 74
    IF CurrentChar < 58 OR CurrentChar > 96 THEN
      ArrayChars(ArrayPos) = CurrentChar
      ArrayPos += 1
    END IF
    CurrentChar += 1
  NEXT
  RANDOMIZE TIMER
  DO WHILE LEN(Result) < StrLength
    Result += CHR(ArrayChars(INT(RND * 36)))
  LOOP
  RandomString = Result
  'Clean memory
  Result = ""
END FUNCTION

FUNCTION TrimTrailingSlash(RawUrl AS STRING) AS STRING
  IF RIGHT(RawUrl, 1) = "/" THEN
    'Trim trailing slash
    RawUrl = LEFT(RawUrl, LEN(RawUrl) - 1)
  END IF
  TrimTrailingSlash = RawUrl
END FUNCTION

FUNCTION CreatePermalink(RawTitle AS STRING) AS STRING
  DIM AS STRING SubStr, NewTitle
  DIM AS ULONG NextSpace = 1, StartPos = 1
  DO UNTIL NextSpace = 0
    NextSpace = INSTR(StartPos, RawTitle, CHR(32))
    IF NextSpace > 0 THEN
      SubStr = MID(RawTitle, StartPos, NextSpace - StartPos)
    ELSE
      SubStr = MID(RawTitle, StartPos)
    END IF
    IF LEN(SubStr) >= 2 THEN
      NewTitle = NewTitle + ValidateChar(SubStr) + CHR(45)
    END IF
    StartPos = NextSpace + 1
  LOOP
  CreatePermalink = LEFT(NewTitle, LEN(NewTitle) - 1)
  NewTitle = ""
END FUNCTION

FUNCTION PercentEncode(RawStr AS STRING) AS STRING
  DIM AS STRING NewChar, Result
  DIM Char as UBYTE
  FOR i AS ULONG = 1 TO LEN(RawStr)
    Char = ASC(MID(RawStr, i, 1))
    SELECT CASE Char
      CASE 45, 46, 48 TO 57, 65 TO 90, 95, 97 TO 122, 126
        'Reserved chars: -, ., 0-9, a-z, _, A-Z, ~
        NewChar = CHR(Char)
      CASE ELSE
        NewChar = "%" + HEX(Char)
    END SELECT
    Result += NewChar
  NEXT
  PercentEncode = Result
END FUNCTION

'https://gist.github.com/MightyPork/52eda3e5677b4b03524e40c9f0ab1da5
FUNCTION Latin1ToUtf8(RawStr AS STRING) AS STRING
  DIM Char AS ULONG, NewChar AS STRING, Result AS STRING
  FOR i AS ULONG = 1 TO LEN(RawStr)
    Char = ASC(MID(RawStr, i, 1))
    SELECT CASE Char
      CASE 0 TO 127
        NewChar = CHR(Char)
      CASE 128 TO 255
        NewChar = CHR(((Char SHR 6) AND 31) OR 192)
        NewChar += CHR(((Char SHR 0) AND 63) OR 128)
    END SELECT
    Result += NewChar
  NEXT
  Latin1ToUtf8 = Result
END FUNCTION
