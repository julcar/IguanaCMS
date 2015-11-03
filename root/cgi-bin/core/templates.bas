FUNCTION blockParser$(blockName$)
  'FIXME: checkfileExists()
  blockParser$ = tplParser$(ReadFile$(tplPath$ & blockName$ & ".html"))
END FUNCTION

FUNCTION keyParser$(query$, value$)
  SELECT CASE query$
    CASE "site"
      keyParser$ = getSettings$(query$ & CHR$(95) & value$)
    CASE "block"
      keyParser$ = blockParser$(value$)
    CASE "page"
      keyParser$ = pageParser$(value$)
    CASE "system"
      'keyParser$ = systemVars$(value$)
      keyParser$ = ""
    CASE "component"
      keyParser$ = loadComponent$(value$)
    CASE "user"
      keyParser$ = loadSession$(value$, QueryString$("session"))
    CASE "querystring"
      keyParser$ = QueryString$(value$)
    CASE "post"
      keyParser$ = Post$(value$)
    CASE ELSE
      keyParser$ = query$ & CHR$(95) & value$
  END SELECT
END FUNCTION

FUNCTION tplParser$(tplContent$)
  DIM char$, strCommand$, leftKey$, rightKey$, strQuery$, strOutput$, i
  strOutput$ = ""
  FOR i = 1 TO LEN(tplContent$)
    char$ = MID$(tplContent$, i, 1)
    IF char$ = "%" THEN
      strCommand$ = MID$(tplContent$, i + 1, INSTR(MID$(tplContent$, i + 2, LEN(tplContent$)), "%"))
      leftKey$ = MID$(strCommand$, 1, INSTR(strCommand$, CHR$(95)) - 1)
      rightKey$ = MID$(strCommand$, INSTR(strCommand$, CHR$(95)) + 1, LEN(strCommand$))
      strQuery$ = keyParser$(leftKey$, rightKey$)
      strOutput$ = strOutput$ & strQuery$
      i = i + INSTR(MID$(tplContent$, i + 2, LEN(tplContent$)), "%") + 1
    ELSE
      strOutput$ = strOutput$ & char$
    END IF
  NEXT
  tplParser$ = strOutput$
  strOutput$ = ""
END FUNCTION

FUNCTION LoadTemplate$(tplFile$)
  LoadTemplate$ = tplParser$(ReadFile$(tplFile$))
END FUNCTION
