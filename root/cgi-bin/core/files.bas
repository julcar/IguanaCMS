FUNCTION ReadFile$ (filePath$)
  fFile = FREEFILE
  OPEN filePath$ FOR INPUT AS #fFile
  fileContent$ = ""
  WHILE NOT EOF(fFile)
    LINE INPUT #fFile, line$
    fileContent$ = fileContent$ + line$ + CHR$(10)
  WEND
  CLOSE #fFile
  ReadFile$ = fileContent$
END FUNCTION

SUB DeleteFile (filePath$)
  KILL (filePath$)
END SUB

FUNCTION WriteFile (filePath$, fileContent$)
  fFile = FREEFILE
  OPEN filePath$ FOR OUTPUT AS #fFile
  PRINT #fFile, fileContent$
  CLOSE #fFile
  WriteFile = 0
END FUNCTION
