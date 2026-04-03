#INCLUDE "../iguanacms.bi"

DIM SHARED ArrayBBCodes() AS DataField

SUB LoadBBCodes()
  ParseDataFile(ArrayBBCodes(), LoadDataFile("bbcodes.shtml"), "tag")
END SUB

FUNCTION CodeParser(Content AS STRING) AS STRING
  DIM AS STRING Char, Tag, TagAttr, TagStr, TagValue, Result
  DIM AS ULONG TagLen, TagStrLen
  FOR i AS ULONG = 1 TO LEN(Content)
    Char = MID(Content, i, 1)
    IF Char = "[" THEN
      Tag = MID(Content, i + 1, INSTR(MID(Content, i + 2), "]"))
      'Reset tag attribute as it can lead to misbehaviors
      TagAttr = ""
      IF INSTR(Tag, "=") > 0 THEN
        'Tag contains attribute
        TagAttr = HTMLEncode(MID(Tag, INSTR(Tag, "=") + 1))
        Tag = LEFT(Tag, INSTR(Tag, "=") - 1)
      END IF
      TagLen = LEN(Tag)
      IF LEN(TagAttr) > 0 THEN
        TagLen += LEN(TagAttr) + 1
      END IF
      TagStr = HTMLEncode(MID(Content, i + TagLen + 2, INSTR(MID(Content, i + TagLen + 2), "[/" + Tag + "]") - 1))
      TagStrLen = LEN(TagStr)
      TagStr = CodeParser(TagStr)
      TagValue = ReadProperty(ArrayBBCodes(), LCASE(Tag))
      IF TagValue <> "" THEN
        TagValue = Replace(TagValue, "%value%", TagStr)
        IF TagAttr <> "" THEN
          TagValue = Replace(TagValue, "%attribute%", TagAttr)
        ELSE
          TagValue = Replace(TagValue, "%attribute%", TagStr)
        END IF
      ELSE
        TagValue = TagStr
      END IF
      IF LEN(TagAttr) > 0 THEN
        i += (((TagLen * 2) + 4) - (LEN(TagAttr) + 1) + TagStrLen)
      ELSE
        i += (((TagLen * 2) + 4) + TagStrLen)
      END IF
      Result += TagValue
    ELSE
      Result += Char
    END IF
  NEXT
  CodeParser = Result
END FUNCTION
