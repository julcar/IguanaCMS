FUNCTION SplitVar$ (strQuery$, arg$, delimiter$)
  DIM results$, strVal$
  result$ = ""
  IF INSTR(strQuery$, arg$) <> 0 THEN
    strVal$ = MID$(strQuery$, INSTR(strQuery$, arg$), LEN(strQuery$))
    IF INSTR(strVal$, delimiter$) <> 0 THEN
      result$ = MID$(strVal$, LEN(arg$) + 2, INSTR(strVal$, delimiter$) - LEN(arg$) - 2)
    ELSE
      result$ = MID$(strVal$, LEN(arg$) + 2, LEN(strVal$))
    END IF
  END IF
  SplitVar$ = result$
END FUNCTION

FUNCTION UnEscape$ (strQuery$)
  DIM result$, char$, value$
  result$ = ""
  FOR i = 1 TO LEN(strQuery$)
    char$ = MID$(strQuery$, i, 1)
    SELECT CASE char$
      CASE CHR$(37)
        value$ = CHR$(VAL("&H" & MID$(strQuery$, i + 1, 2)))
        result$ = result$ & value$
        i = i + 2
      CASE CHR$(43)
        value$ = CHR$(32)
        result$ = result$ & value$
      CASE ELSE
        result$ = result$ & char$
    END SELECT
  NEXT
  UnEscape$ = result$
END FUNCTION

FUNCTION Replace$ (strQuery$, lookFor$, replaceWith$)
  DIM result$, foundPos, startPos, nextPos, strLeft$, strRight$
  result$ = strQuery$
  DO
    foundPos = INSTR(result$, lookFor$)
    IF foundPos <> 0 THEN
      startPos = foundPos - 1
      nextPos = foundPos + LEN(lookFor$)
      strLeft$ = LEFT$(result$, startPos)
      strRight$ = MID$(result$, nextPos, LEN(result$))
      result$ = strLeft$ & replaceWith$ & strRight$
    ELSE
      EXIT DO
    END IF
  LOOP
  Replace$ = result$
END FUNCTION

FUNCTION RandomString$ (strLength)
  DIM arrayPos, currentChar, result$
  DIM arrayChars(0 TO 36)
  arrayPos = 0
  currentChar = 48
  FOR i = 0 TO 74
    IF currentChar < 58 OR currentChar > 96 THEN
      arrayChars(arrayPos) = currentChar
      arrayPos = arrayPos + 1
    END IF
    currentChar = currentChar + 1
  NEXT
  RANDOMIZE TIMER
  result$ = ""
  DO WHILE LEN(result$) < strLength
    result$ = result$ & CHR$(arrayChars(INT(RND * 36)))
  LOOP
  RandomString$ = result$
END FUNCTION
