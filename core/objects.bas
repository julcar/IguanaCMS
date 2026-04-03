#INCLUDE "../iguanacms.bi"

SUB CreateProperty(ArrayProperties() AS DataField, PropertyName AS STRING, PropertyValue AS STRING)
  DIM Count AS LONG = UBOUND(ArrayProperties) + 1
  REDIM PRESERVE ArrayProperties(Count)
  WITH ArrayProperties(Count)
    .Name = PropertyName
    .Value = PropertyValue
  END WITH
END SUB

FUNCTION ReadProperty(ArrayProperties() AS DataField, PropertyName AS STRING) AS STRING
  DIM Count AS LONG = UBOUND(ArrayProperties)
  IF Count >= 0 THEN
    FOR i AS LONG = 0 TO Count
      WITH ArrayProperties(i)
        IF .Name = PropertyName THEN
          ReadProperty = .Value
          EXIT FOR
        END IF
      END WITH
#IF 0
      IF i = Count THEN
        ReadProperty = PropertyName
      END IF
#ENDIF
    NEXT
  END IF
END FUNCTION

SUB UpdateProperty(ArrayProperties() AS DataField, PropertyName AS STRING, PropertyValue AS STRING)
  DIM Count AS LONG = UBOUND(ArrayProperties)
  IF Count >= 0 THEN
    FOR i AS LONG = 0 TO Count
      WITH ArrayProperties(i)
        IF .Name = PropertyName THEN
          .Value = PropertyValue
          EXIT FOR
        END IF
      END WITH
    NEXT
  END IF
END SUB

SUB ClearProperties(ArrayProperties() AS DataField)
  IF UBOUND(ArrayProperties) >= 0 THEN
    ERASE ArrayProperties
  END IF
END SUB

FUNCTION LoadDataFile(FilePath AS STRING) AS STRING
  FilePath = ReadGlobal("data_path") + FilePath
  IF FileExists(FilePath) THEN
    LoadDataFile = ReadFile(FilePath)
  END IF
END FUNCTION

SUB ParseDataFile(ArrayProperties() AS DataField, FileContent AS STRING, DirectiveTag AS STRING)
  'Initialize custom cursors
  DIM AS ULONG NameAttrLen, StartPos = 1, NextPos, FoundPos = StartPos
  DIM AS STRING DirectiveName, DirectiveValue, NameAttr = "name="
  NameAttrLen = LEN(NameAttr)
  WHILE FoundPos
    FoundPos = INSTR(StartPos, FileContent, "<!-- #" + DirectiveTag)
    IF FoundPos THEN
      'We have found directive opening
      StartPos = FoundPos + LEN("<!-- #" + DirectiveTag) + 1
      NextPos = INSTR(StartPos, FileContent, " -->")
      'Test if we have name attribute
      IF INSTR(MID(FileContent, StartPos, NextPos - StartPos), NameAttr) THEN
        'Get Directive name
        DirectiveName = MID(FileContent, StartPos + NameAttrLen + 1, NextPos - StartPos - NameAttrLen - 2)
        IF LEN(DirectiveName) THEN
          StartPos = NextPos + NameAttrLen
          NextPos = INSTR(StartPos, FileContent, "<!-- #end-" + DirectiveTag)
          IF NextPos - StartPos > 0 THEN
            'Get Directive value
            DirectiveValue = MID(FileContent, StartPos, NextPos - StartPos - 1)
            IF LEN(DirectiveValue) THEN
              CreateProperty(ArrayProperties(), DirectiveName, DirectiveValue)
            END IF
          END IF
        END IF
      END IF
      StartPos = NextPos + 1
    END IF
  WEND
END SUB
