FUNCTION getSettings$ (Key$)
  DIM fileContent$, keyParsed$
  fileContent$ = ReadFile$(dataPath$ + "\settings.txt")
  keyParsed$ = SplitVar$(fileContent$, Key$, CHR$(10))
  IF keyParsed$ <> "" THEN
    getSettings$ = keyParsed$
  ELSE
    getSettings$ = Key$
  END IF
END FUNCTION
