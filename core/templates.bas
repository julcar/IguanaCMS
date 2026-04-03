#INCLUDE "../iguanacms.bi"

DIM SHARED ArraySnippets() AS DataField

FUNCTION ExpandObject(ObjectExpr AS STRING) AS STRING
  DIM AS STRING ObjectName, EvalExpr, Result
  ObjectName = MID(ObjectExpr, 1, INSTR(ObjectExpr, ".") - 1)
  EvalExpr = MID(ObjectExpr, INSTR(ObjectExpr, ".") + 1, LEN(ObjectExpr) - INSTR(ObjectExpr, "."))
  SELECT CASE ObjectName
    CASE "site"
      Result = GetSettings(EvalExpr)
    CASE "system"
      Result = SystemProperties(EvalExpr)
    CASE "global"
      Result = ReadGlobal(EvalExpr)
    CASE "language"
      Result = Language(EvalExpr)
    CASE "querystring"
      Result = QueryString(EvalExpr)
    CASE "post"
      Result = Post(EvalExpr)
    CASE "url"
      Result = CreateURL(EvalExpr)
    CASE "snippet"
      Result = ReadTemplate(EvalExpr)
    CASE "page"
      Result = ReadPage(EvalExpr)
    CASE "module"
      Result = ReadModule(EvalExpr)
    CASE ELSE
      Result = EvalExpr
  END SELECT
  ExpandObject = Result
END FUNCTION

FUNCTION SnippetParser(SnippetContent AS STRING) AS STRING
  'Declare and initialize custom cursors
  DIM AS ULONG StartPos = 1, NextPos, FoundPos = StartPos
  DIM AS STRING ObjectExpr, Result
  WHILE FoundPos
    FoundPos = INSTR(StartPos, SnippetContent, "<%= ")
    IF FoundPos THEN
      Result += MID(SnippetContent, StartPos, FoundPos - StartPos)
      StartPos = FoundPos + LEN("<%= ")
      NextPos = INSTR(StartPos, SnippetContent, " %>")
      ObjectExpr = MID(SnippetContent, StartPos, NextPos - StartPos)
      'Expand object expression
      Result += ExpandObject(ObjectExpr)
      StartPos = NextPos + LEN(" %>")
    ELSE
      Result += MID(SnippetContent, StartPos, LEN(SnippetContent) - StartPos + 1)
    END IF
  WEND
  SnippetParser = Result
END FUNCTION

SUB LoadTemplate(ModuleName AS STRING)
  DIM AS STRING TemplatePath, ModulePath, TemplateContent
  TemplatePath = "templates" + PATH_DELIMITER + GetSettings("template") + PATH_DELIMITER
  IF ModuleName <> "main" THEN
    ModulePath = "modules" + PATH_DELIMITER
  END IF
  ModuleName += ".shtml"
  IF NOT FileExists(ReadGlobal("data_path") + TemplatePath + ModulePath + ModuleName) THEN
    'Fallback to default template
    TemplatePath = "templates" + PATH_DELIMITER + "default" + PATH_DELIMITER
  END IF
  TemplateContent = LoadDataFile(TemplatePath + ModulePath + ModuleName)
  ParseDataFile(ArraySnippets(), TemplateContent, "snippet")
END SUB

FUNCTION ReadTemplate(SnippetName AS STRING) AS STRING
  ReadTemplate = SnippetParser(ReadProperty(ArraySnippets(), SnippetName))
END FUNCTION

SUB ClearSnippets()
  ClearProperties(ArraySnippets())
END SUB
