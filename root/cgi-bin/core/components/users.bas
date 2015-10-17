'Component Users file

FUNCTION loadSession$(query$, sessionID$)
  DIM fileName$, result$
  result$ = ""
  IF sessionID$ <> "" THEN
    fileName$ = tempPath$ & "sessions/" & sessionID$ & ".txt"
    IF checkFileExists(fileName$) = 0 THEN
      result$ = SplitVar$(ReadFile$(fileName$), "user_" & query$, CHR$(10))
    END IF
  END IF
  loadSession$ = result$
  result$ = ""
END FUNCTION

FUNCTION loadUserAction$()
  DIM fileName$, fileContent$, userData$, sessionID$, result$, saved
  result$ = ""
  IF QueryString$("action") <> "" THEN
    SELECT CASE QueryString$("action")
      CASE "login"
        IF Post$("loginButton") <> "" THEN
          'Login attempt
          fileName$ = Replace$(Replace$(Post$("emailText"), CHR$(46), "[dot]"), CHR$(64), "[at]") & ".txt"
          IF checkFileExists(dataPath$ & "users/" & fileName$) = 0 THEN
            userData$ = ReadFile$(dataPath$ & "users/" & fileName$)
            'FIXME: Passwords should be encrypted at this time!
            IF Post$("passwordText") = SplitVar$(userData$, "user_password", CHR$(10)) THEN
              'Password match
              'Create random session ID
              sessionID$ = RandomString$(8)
              'Create session file
              fileContent$ = ""
              fileContent$ = fileContent$ & "user_email=" & SplitVar$(userData$, "user_email", CHR$(10)) & CHR$(13) & CHR$(10)
              fileContent$ = fileContent$ & "user_alias=" & SplitVar$(userData$, "user_alias", CHR$(10)) & CHR$(13) & CHR$(10)
              fileContent$ = fileContent$ & "user_ip=" & ENVIRON$("REMOTE_ADDR") & CHR$(13) & CHR$(10)
              fileContent$ = fileContent$ & "user_browser=" & ENVIRON$("HTTP_USER_AGENT") & CHR$(13) & CHR$(10)
              fileContent$ = fileContent$ & "user_login_timestamp=" & DATE & TIME & CHR$(13) & CHR$(10)
              'FIXME: checkFileExists(sessionID$) to avoid overwrite any other session
              saved = WriteFile(tempPath$ & "sessions/" & sessionID$ & ".txt", fileContent$)
              userData$ = ""
              fileContent$ = ""
              IF saved = 0 THEN
                'FIXME: Find a less crappy way to redirect than this!
                result$ = "<meta http-equiv=""Refresh"" content=""0;url=index.exe?session="& sessionID$ &""">"
              END IF
            END IF
          END IF
        ELSE
          result$ = tplParser$(readFile$(tplPath$ & "login.html"))
        END IF
      CASE "logout"
        IF Post$("logoutButton") <> "" THEN
          fileName$ = tempPath$ & "sessions/" & Post$("sessionID") & ".txt"
          IF checkFileExists(fileName$) = 0 THEN
            DeleteFile(fileName$)
            result$ = tplParser$(readFile$(tplPath$ & "logout.html"))
          END IF
        END IF
      CASE "register"
        IF Post$("registerButton") <> "" THEN
          'FIXME: Validate correct email user@domain.tld format
          fileName$ = Replace$(Replace$(Post$("emailText"), CHR$(46), "[dot]"), CHR$(64), "[at]") & ".txt"
          'Check if file exists to avoid overwrite it
          IF NOT checkFileExists(dataPath$ & "users/" & fileName$) = 0 THEN
            'Target file does not exists previously
            fileContent$ = ""
            fileContent$ = fileContent$ & "user_email=" & Post$("emailText") & CHR$(13) & CHR$(10)
            fileContent$ = fileContent$ & "user_alias=" & Post$("aliasText") & CHR$(13) & CHR$(10)
            'FIXME: Passwords should be encrypted before saving
            fileContent$ = fileContent$ & "user_password=" & Post$("passwordText") & CHR$(13) & CHR$(10)          
            saved = WriteFile(dataPath$ & "users/" & fileName$, fileContent$)
            fileContent$ = ""
            IF saved = 0 THEN
              result$ = tplParser$(readFile$(tplPath$ & "registered.html"))
            END IF
          END IF
        ELSE
          result$ = tplParser$(readFile$(tplPath$ & "register.html"))
        END IF
      CASE ELSE
    END SELECT
  ELSE
    result$ = tplParser$(readFile$(tplPath$ & "login.html"))
  END IF
  IF LEN(result$) = 0 THEN
    result$ = "Error: failed execution on last action"
  END IF
  loadUserAction$ = result$
  result$ = ""
END FUNCTION

FUNCTION loadUsers$()
  IF QueryString$("session") <> "" THEN
    IF LEN(loadSession$("email", QueryString$("session"))) = 0 THEN
      loadUsers$ = "Error: could not open session"
    ELSE
      loadUsers$ = tplParser$(readFile$(tplPath$ & "user.html"))
    END IF
  ELSE
    loadUsers$ = loadUserAction$()
  END IF
END FUNCTION
