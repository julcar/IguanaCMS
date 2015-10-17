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
  fileContent$ = ""
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

FUNCTION checkFileExists(filePath$)
  fileContent$ = ReadFile$(filePath$)
  IF LEN(fileContent$) > 0 THEN
    'File exist
    checkFileExists = 0
  ELSE
    'File does not exists or is empty
    checkFileExists = 1
  END IF
  fileContent$ = ""
END FUNCTION
