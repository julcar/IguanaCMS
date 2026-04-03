#INCLUDE "../iguanacms.bi"

'NAMESPACE Files

  FUNCTION ReadFile(FilePath AS STRING) AS STRING
    DIM Result AS STRING, fFile AS ULONG = FREEFILE
    OPEN FilePath FOR INPUT AS #fFile
    Result = SPACE(LOF(fFile))
    GET #fFile,,Result
    CLOSE #fFile
    ReadFile = Result
  END FUNCTION
  
  SUB DeleteFile(FilePath AS STRING)
    KILL(FilePath)
  END SUB

  SUB WriteFile(FilePath AS STRING, FileContent AS STRING)
    DIM AS ULONG fFile = FREEFILE
    OPEN FilePath FOR OUTPUT AS #fFile
    PRINT #fFile, FileContent;
    CLOSE #fFile
  END SUB

  SUB CheckPath(DirPath AS STRING)
    IF DIR(DirPath, 16) = "" THEN
      MKDIR(DirPath)
    END IF
  END SUB

  FUNCTION ListFiles(Path AS STRING, Ext AS STRING, Count AS ULONG) AS STRING
    DIM AS STRING TempLine, FileList
    DIM CurLine AS ULONG = 1
    TempLine = DIR(Path + PATH_DELIMITER + "*." + Ext, 32)
    IF TempLine <> "" THEN
      DO WHILE TempLine <> ""
        FileList += Replace(TempLine, "." + Ext, "") + LINE_ENDING
        IF Count > 0 AND CurLine = Count THEN
          EXIT DO
        END IF
        CurLine += 1
        TempLine = DIR()
      LOOP
    END IF
    'Trim the last line feed
    ListFiles = LEFT(FileList, LEN(FileList) - LEN(LINE_ENDING))
  END FUNCTION
  
'END NAMESPACE
