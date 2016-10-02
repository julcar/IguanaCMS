'Component Users file

arrayIndex = UBOUND(compiledComponents$)
REDIM compiledComponents$(arrayIndex + 1)
compiledComponents$(arrayIndex + 1) = "users"

FUNCTION loadSession$(strCmd$, sessionToken$)
  DIM fileName$, result$
  result$ = ""
  IF LEN(sessionToken$) > 0 THEN
    fileName$ = tempPath$ + "sessions/" + sessionToken$ + ".txt"
    IF checkFileExists(fileName$) = 0 THEN
      result$ = SplitVar$(ReadFile$(fileName$), strCmd$, CHR$(10))
    END IF
  END IF
  IF result$ = "" THEN
    result$ = strCmd$
  END IF
  loadSession$ = result$
  result$ = ""
END FUNCTION

FUNCTION loadUserAction$()
  DIM fullPath$, fileName$, fileContent$, userData$, sessionToken$, result$, saved
  fullPath$ = tplPath$ + getSettings$("site_template") + "\components\users\"
  result$ = ""
  IF QueryString$("userAction") <> "" THEN
    SELECT CASE QueryString$("userAction")
      CASE "login"
        IF Post$("loginButton") <> "" THEN
          'Login attempt
          fileName$ = Replace$(Post$("emailText"), CHR$(64), "[at]")
          fileName$ = Replace$(fileName$, CHR$(46), "[dot]") + ".txt"
          IF checkFileExists(dataPath$ + "users/" + fileName$) = 0 THEN
            userData$ = ReadFile$(dataPath$ + "users/" + fileName$)
            'FIXME: Passwords should be encrypted at this time!
            IF Post$("passwordText") = SplitVar$(userData$, "user_password", CHR$(10)) THEN
              'Password match
              'Create random session ID
              DIM DATE, TIME
              sessionToken$ = RandomString$(8)
              'Create session file
              fileContent$ = ""
              fileContent$ = fileContent$ + "session_userfile=" + fileName$ + CHR$(13) + CHR$(10)
              fileContent$ = fileContent$ + "session_token=" + sessionToken$ + CHR$(13) + CHR$(10)
              fileContent$ = fileContent$ + "session_ipaddr=" + ENVIRON$("REMOTE_ADDR") + CHR$(13) + CHR$(10)
              fileContent$ = fileContent$ + "session_useragent=" + ENVIRON$("HTTP_USER_AGENT") + CHR$(13) + CHR$(10)
              fileContent$ = fileContent$ + "session_logintime=" + STR$(DATE) + STR$(TIME) + CHR$(13) + CHR$(10)
              'FIXME: checkFileExists(sessionToken$) to avoid overwrite any other session
              saved = WriteFile(tempPath$ + "sessions/" + sessionToken$ + ".txt", fileContent$)
              userData$ = ""
              fileContent$ = ""
              IF saved = 0 THEN
                result$ = Replace$(tplParser$(readFile$(fullPath$ + "logged.html")), "session_token", sessionToken$)
              ELSE
                result$ = Replace$(tplParser$(readFile$(fullPath$ + "login.html")), "login_error", "Error: unable to create session")
              END IF
            ELSE
              result$ = Replace$(tplParser$(readFile$(fullPath$ + "login.html")), "login_error", "Error: incorrect password")
            END IF
          ELSE
            result$ = Replace$(tplParser$(readFile$(fullPath$ + "login.html")), "login_error", "Error: email not registered")
          END IF
        ELSE
          result$ = Replace$(tplParser$(readFile$(fullPath$ + "login.html")), "login_error", "")
        END IF
      CASE "logout"
        fileName$ = tempPath$ + "sessions/" + GetCookie$("sessionToken") + ".txt"
        IF checkFileExists(fileName$) = 0 THEN
          DeleteFile(fileName$)
          result$ = tplParser$(readFile$(fullPath$ + "logout.html"))
        ELSE
          result$ = Replace$(tplParser$(readFile$(fullPath$ + "login.html")), "login_error", "Error: unable to find current session")
        END IF
      CASE "register"
        IF Post$("registerButton") <> "" THEN
          'FIXME: Validate correct email user@domain.tld format and in error case return back to form with error message
          fileName$ = Replace$(Post$("emailText"), CHR$(64), "[at]")
          fileName$ = Replace$(fileName$, CHR$(46), "[dot]") + ".txt"
          'Check if file exists to avoid overwrite it
          IF NOT checkFileExists(dataPath$ + "users/" + fileName$) = 0 THEN
            'Target file does not exists previously, start creating one
            fileContent$ = ""
            fileContent$ = fileContent$ + "user_email=" + Post$("emailText") + CHR$(13) + CHR$(10)
            fileContent$ = fileContent$ + "user_alias=" + Post$("aliasText") + CHR$(13) + CHR$(10)
            'FIXME: Passwords should be encrypted before saving
            fileContent$ = fileContent$ + "user_password=" + Post$("passwordText") + CHR$(13) + CHR$(10)          
            saved = WriteFile(dataPath$ + "users/" + fileName$, fileContent$)
            fileContent$ = ""
            IF saved = 0 THEN
              result$ = tplParser$(readFile$(fullPath$ + "registered.html"))
            ELSE
              result$ = Replace$(tplParser$(readFile$(fullPath$ + "register.html")), "register_error", "Error: could not save user file")
            END IF
          ELSE
            result$ = Replace$(tplParser$(readFile$(fullPath$ + "register.html")), "register_error", "Error: email is already registered")
          END IF
        ELSE
          result$ = Replace$(tplParser$(readFile$(fullPath$ + "register.html")), "register_error", "")
        END IF
      CASE "createSession"
        result$ = "Creating session..."
    END SELECT
  ELSEIF LEN(GetCookie$("sessionToken")) > 0 THEN
    sessionToken$ = GetCookie$("sessionToken")
    IF sessionToken$ = loadSession$("session_token", sessionToken$) THEN
      result$ = tplParser$(readFile$(fullPath$ + "user.html"))
    ELSE
      result$ = Replace$(tplParser$(readFile$(fullPath$ + "login.html")), "login_error", "Error: unable to open session")
    END IF
  ELSE
    result$ = Replace$(tplParser$(readFile$(fullPath$ + "login.html")), "login_error", "")
  END IF
  IF result$ = "" THEN
    result$ = Replace$(tplParser$(readFile$(fullPath$ + "login.html")), "login_error", "Error: failed execution on last action")
  END IF
  loadUserAction$ = result$
  result$ = ""
END FUNCTION

FUNCTION loadUsers$(strCmd$)
  DIM result$, query$, value$, fileName$, userData$
  IF strCmd$ <> "" THEN
    query$ = MID$(strCmd$, 1, INSTR(strCmd$, CHR$(95)) - 1)
    value$ = MID$(strCmd$, INSTR(strCmd$, CHR$(95)) + 1, LEN(strCmd$))
    SELECT CASE query$
      CASE "session"
        result$ = loadSession$(query$ + CHR$(95) + value$, GetCookie$("sessionToken"))
      CASE "user"
        fileName$ = loadSession$("session_userfile", GetCookie$("sessionToken"))
        userData$ = ReadFile$(dataPath$ + "users/" + fileName$)
        result$ = SplitVar$(userData$, query$ + CHR$(95) + value$, CHR$(10))
        userData$ = ""
      CASE ELSE
        result$ = strCmd$
    END SELECT
  ELSE
    result$ = loadUserAction$()
  END IF
  loadUsers$ = result$
  result$ = ""
END FUNCTION

'Headers section

IF QueryString$("userAction") = "createSession" THEN
  IF QueryString$("token") = loadSession$("session_token", QueryString$("token")) THEN
    httpHeader$ = httpHeader$ + SetCookie$("sessionToken", QueryString$("token"), "", "/cgi-bin", "", 300, 0, 1)
    httpHeader$ = httpHeader$ + "Refresh: 0;url=?" + CHR$(13) + CHR$(10)
  END IF
END IF

IF QueryString$("userAction") = "logout" THEN
  IF GetCookie$("sessionToken") = loadSession$("session_token", GetCookie$("sessionToken")) THEN
    httpHeader$ = httpHeader$ + SetCookie$("sessionToken", GetCookie$("sessionToken"), "", "/cgi-bin", "Thu, 01 Jan 1970 00:00:01 GMT", 0, 0, 1)
    httpHeader$ = httpHeader$ + "Refresh: 5;url=?" + CHR$(13) + CHR$(10)
  END IF
END IF
