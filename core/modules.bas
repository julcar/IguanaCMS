#INCLUDE "../modules/modules.bi"

DIM SHARED CompiledModules() AS IguanaModule
DIM SHARED ArrayLoaders() AS INTEGER

SUB RegisterModule(NewModule AS IguanaModule)
  DIM ModuleIndex AS LONG = UBOUND(CompiledModules) + 1
  REDIM PRESERVE CompiledModules(ModuleIndex)
  CompiledModules(ModuleIndex) = NewModule
END SUB

SUB ListCompiledModules(ArrayModules() AS IguanaModule)
  DIM ModuleIndex AS LONG = UBOUND(CompiledModules)
  IF ModuleIndex >= 0 THEN
    REDIM ArrayModules(ModuleIndex)
    FOR i AS LONG = 0 TO ModuleIndex
      ArrayModules(i) = CompiledModules(i)
    NEXT
  END IF
END SUB

SUB LoadModule(ModuleName AS STRING)
  DIM ModuleFrontEnd AS SUB()
  DIM ModuleIndex AS LONG = UBOUND(CompiledModules)
  IF ModuleIndex >= 0 THEN
    FOR i AS LONG = 0 TO ModuleIndex
      IF ModuleName = CompiledModules(i).Name THEN
        ModuleFrontEnd = CPTR(SUB, CompiledModules(i).MainLoader)
        IF ModuleFrontEnd > 0 THEN
          LoadLanguage(ModuleName)
	      IF CompiledModules(i).HasOwnTemplate THEN
            'This module has a self-contained template
            ClearSnippets()
          END IF
          LoadTemplate(ModuleName)
          ModuleFrontEnd()
        END IF
        EXIT FOR
      END IF
    NEXT
  END IF
END SUB

SUB LoadAdminModule(ModuleName AS STRING)
  DIM ModuleBackEnd AS SUB()
  DIM ModuleIndex AS LONG = UBOUND(CompiledModules)
  IF ModuleIndex >= 0 THEN
    FOR i AS LONG = 0 TO ModuleIndex
      IF ModuleName = CompiledModules(i).Name THEN
        ModuleBackEnd = CPTR(SUB, CompiledModules(i).AdminLoader)
        IF ModuleBackEnd > 0 THEN
          LoadLanguage(ModuleName)
          LoadTemplate(ModuleName)
          ModuleBackEnd()
        END IF
        EXIT FOR
      END IF
    NEXT
  END IF
END SUB

FUNCTION ReadModule(ObjectExpr AS STRING) AS STRING
  DIM ModuleProperties AS FUNCTION(PropertyName AS STRING) AS STRING
  DIM ModuleIndex AS LONG = UBOUND(CompiledModules)
  DIM AS STRING ObjectName, EvalExpr, Result
  ObjectName = MID(ObjectExpr, 1, INSTR(ObjectExpr, ".") - 1)
  EvalExpr = MID(ObjectExpr, INSTR(ObjectExpr, ".") + 1, LEN(ObjectExpr) - INSTR(ObjectExpr, "."))
  IF ModuleIndex >= 0 THEN
    FOR i AS LONG = 0 TO ModuleIndex
      IF ObjectName = CompiledModules(i).Name THEN
        ModuleProperties = CPTR(FUNCTION(AS STRING) AS STRING, CompiledModules(i).PropertiesFunction)
        IF ModuleProperties > 0 THEN
          Result = ModuleProperties(EvalExpr)
        ELSE
          Result = EvalExpr
        END IF
        EXIT FOR
      END IF
      IF i = ModuleIndex THEN
        Result = EvalExpr
      END IF
    NEXT
  END IF
  ReadModule = Result
END FUNCTION

SUB RegisterLoader(LoaderPointer AS INTEGER)
  DIM LoaderIndex AS LONG = UBOUND(ArrayLoaders) + 1
  REDIM PRESERVE ArrayLoaders(LoaderIndex)
  ArrayLoaders(LoaderIndex) = LoaderPointer
END SUB

SUB RunLoaders()
  DIM LoaderEntry AS SUB()
  DIM LoaderIndex AS LONG = UBOUND(ArrayLoaders)
  IF LoaderIndex >= 0 THEN
    FOR i AS LONG = 0 TO LoaderIndex
      LoaderEntry = CPTR(SUB, ArrayLoaders(i))
      IF LoaderEntry > 0 THEN
        LoaderEntry()
      END IF
    NEXT
  END IF
END SUB
