'Users module file

#INCLUDE "modules.bi"

CONST AS STRING USERS_TABLE_FIELDS = _
    "[id] INTEGER PRIMARY KEY NOT NULL, " _
    "[name] TEXT UNIQUE NOT NULL, " _
    "[password] TEXT NULL, " _
    "[email] TEXT NULL, " _
    "[oauth_login] TEXT NULL, " _
    "[regdate] TEXT NOT NULL, " _
    "[token] TEXT NULL, " _
    "[active] INTEGER NOT NULL, " _
    "[group] INTEGER NOT NULL"

CONST AS STRING SESSIONS_TABLE_FIELDS = _
    "[id] INTEGER PRIMARY KEY NOT NULL, " _
    "[user] TEXT NOT NULL, " _
    "[token] TEXT NOT NULL, " _
    "[ipaddr] TEXT NOT NULL, " _
    "[useragent]TEXT NOT NULL, " _
    "[logintime] TEXT NOT NULL, " _
    "[validuntil] TEXT NULL"

CONST AS STRING OAUTH_LOGINS_TABLE_FIELDS = _
    "[id] INTEGER PRIMARY KEY NOT NULL, " _
    "[name] TEXT NOT NULL, " _
    "[token] TEXT NOT NULL, " _
    "[secret] TEXT NULL"

CONST AS STRING ModuleName = "users"

CONST AS STRING SESSION_NAME = "iguana-token"

CONST MIN_PASSWORD_LENGTH = 8
CONST SALT_LENGTH = 8

'How many seconds will wait user in redirections
CONST SECONDS_TO_WAIT = 5

DIM SHARED AS DataField UserProperties(), SessionProperties() ', ArrayGroups()

SUB CreateUserProperty(PropertyName AS STRING, PropertyValue AS STRING)
  CreateProperty(UserProperties(), PropertyName, PropertyValue)
END SUB

SUB CreateSessionProperty(PropertyName AS STRING, PropertyValue AS STRING)
  CreateProperty(SessionProperties(), PropertyName, PropertyValue)
END SUB

FUNCTION ReadUser(PropertyName AS STRING) AS STRING
  ReadUser = ReadProperty(UserProperties(), PropertyName)
END FUNCTION

FUNCTION ReadSession(PropertyName AS STRING) AS STRING
  ReadSession = ReadProperty(SessionProperties(), PropertyName)
END FUNCTION

SUB ClearUserProperties()
  ClearProperties(UserProperties())
END SUB

SUB ClearSessionProperties()
  ClearProperties(SessionProperties())
END SUB

FUNCTION LoadUser(UserAlias AS STRING) AS LONG
  UserAlias = ValidateChar(LCASE(UserAlias))
  IF UserAlias <> "" THEN
    DIM UserDST AS DataSet, sSQL AS STRING
    sSQL = "SELECT [name] AS [alias], [password], [email], [oauth_login], [regdate], [token], [active], [group] " _
      "FROM [users] WHERE [name] = @UserName;"
    AddParam("@UserName", UserAlias, PARAM_TYPE_TEXT)
    UserDST = FetchData(sSQL)
    ClearParams()
    IF UserDST.RowCount THEN
      WITH UserDST.Rows(0)
        FOR i AS LONG = 0 TO .FieldCount - 1
          CreateUserProperty("user." + .Fields(i).Name, .Fields(i).Value)
        NEXT
      END WITH
      LoadUser = -1
    END IF
  END IF
END FUNCTION

FUNCTION LoadSession(SessionToken AS STRING) AS LONG
  IF SessionToken <> "" THEN
    DIM SessionDST AS DataSet, sSQL AS STRING
    sSQL = "SELECT [user], [token], [ipaddr], [useragent], [logintime], [validuntil] " _
      "FROM [sessions] WHERE [token] = @SessionToken;"
    AddParam("@SessionToken", SHA256(SessionToken), PARAM_TYPE_TEXT)
    SessionDST = FetchData(sSQL)
    ClearParams()
    IF SessionDST.RowCount THEN
      WITH SessionDST.Rows(0)
        FOR i AS LONG = 0 TO .FieldCount - 1
          CreateSessionProperty("session." + .Fields(i).Name, .Fields(i).Value)
        NEXT
      END WITH
      LoadSession = -1
    END IF
  END IF
END FUNCTION

SUB LoadCurrentUser()
  LoadUser(ReadSession("session.user"))
END SUB

SUB LoadCurrentSession()
  LoadSession(GetCookie(SESSION_NAME))
END SUB

SUB CreateUser(UserAlias AS STRING, UserPassword AS STRING = "", UserEmail AS STRING = "", OAuthLoginName AS STRING = "", UserToken AS STRING = "", IsActive AS LONG = 0)
  DIM AS STRING sSQL
  sSQL = "INSERT INTO [users] (" _
    "[name], [password], [email], [oauth_login], [regdate], [token], [active], [group]" _
    ") VALUES (" _
    "@UserName, @UserPass, @UserEmail, @OAuthLoginName, @UserRegDate, @UserToken, @UserActive, @UserGroup" _
    ");"
  AddParam("@UserName", UserAlias, PARAM_TYPE_TEXT)
  AddParam("@UserPass", UserPassword, PARAM_TYPE_TEXT)
  AddParam("@UserEmail", UserEmail, PARAM_TYPE_TEXT)
  AddParam("@OAuthLoginName", OAuthLoginName, PARAM_TYPE_TEXT)
  AddParam("@UserRegDate", SystemDate(), PARAM_TYPE_TEXT)
  AddParam("@UserToken", UserToken, PARAM_TYPE_TEXT)
  AddParam("@UserActive", STR(IsActive), PARAM_TYPE_INTEGER)
  AddParam("@UserGroup", STR(USERS_GROUP), PARAM_TYPE_INTEGER)
  'Save user data
  ExecuteSql(sSQL)
  ClearParams()
END SUB

SUB CreateSession(UserAlias AS STRING)
  DIM AS STRING sSQL, SessionToken, HashedToken
  SessionToken = RandomString(TOKEN_LENGTH)
  HashedToken = SHA256(SessionToken)
  sSQL = "INSERT INTO [sessions] (" _
    "[user], [token], [ipaddr], [useragent], [logintime]" _
    ") VALUES (" _
    "@SessionUser, @SessionToken, @SessionIP, @SessionUA, @SessionLT" _
    ");"
  AddParam("@SessionUser", LCASE(UserAlias), PARAM_TYPE_TEXT)
  AddParam("@SessionToken", HashedToken, PARAM_TYPE_TEXT)
  AddParam("@SessionIP", ENVIRON("REMOTE_ADDR"), PARAM_TYPE_TEXT)
  AddParam("@SessionUA", ENVIRON("HTTP_USER_AGENT"), PARAM_TYPE_TEXT)
  AddParam("@SessionLT", SystemDate() + "T" + SystemTime(), PARAM_TYPE_TEXT)
  ExecuteSql(sSQL)
  ClearParams()
  'Create cookie
  SetCookie(SESSION_NAME, SessionToken, "", "/", "", 3600 * 24 * 30, 0, 1)
END SUB

SUB DeleteSession(SessionToken AS STRING)
  DIM sSQL AS STRING
  sSQL = "DELETE FROM [sessions] WHERE [token] = @SessionToken;"
  AddParam("@SessionToken", SessionToken, PARAM_TYPE_TEXT)
  ExecuteSql(sSQL)
  ClearParams()
  'Cookie deletion
  SetCookie(SESSION_NAME, GetCookie(SESSION_NAME), "", "/", "Thu, 01 Jan 1970 00:00:01 GMT", 0, 0, 1)
END SUB

SUB UpdateUser(UserAlias AS STRING, UserPassword AS STRING = "", UserEmail AS STRING = "", OAuthLoginName AS STRING = "", UserToken AS STRING = "", IsActive AS LONG = 0)
  DIM AS STRING sSQL
  IF UserAlias <> "" THEN
    sSQL = "UPDATE [users] SET"
    IF UserPassword <> "" THEN
      sSQL += " [password] = @UserPassword,"
      AddParam("@UserPassword", UserPassword, PARAM_TYPE_TEXT)
    END IF
    IF UserEmail <> "" THEN
      sSQL += " [email] = @UserEmail,"
      AddParam("@UserEmail", UserEmail, PARAM_TYPE_TEXT)
    END IF
    IF OAuthLoginName <> "" THEN
      sSQL += " [oauth_login] = @OAuthLoginName,"
      AddParam("@OAuthLoginName", OAuthLoginName, PARAM_TYPE_TEXT)
    END IF
    IF UserToken <> "" THEN
      sSQL += " [token] = @UserToken,"
      AddParam("@UserToken", UserToken, PARAM_TYPE_TEXT)
    END IF
    IF IsActive THEN
      sSQL += " [active] = @UserActive"
      AddParam("@UserActive", "-1", PARAM_TYPE_INTEGER)
    END IF
  END IF
  'Clean trailing comma, if any
  IF RIGHT(sSQL, 1) = "," THEN
    sSQL = LEFT(sSQL, LEN(sSQL) - 1)
  END IF
  sSQL += " WHERE [name] = @UserName;"
  AddParam("@UserName", UserAlias, PARAM_TYPE_TEXT)
  ExecuteSql(sSQL)
  ClearParams()
END SUB

FUNCTION LoadOAuthLogin(OAuthLoginName AS STRING) AS LONG
  IF OAuthLoginName <> "" THEN
    DIM OAuthLoginDST AS DataSet, sSQL AS STRING
    sSQL = "SELECT [name], [token], [secret] FROM [oauth_logins] WHERE [name] = @OAuthLoginName;"
    AddParam("@OAuthLoginName", OAuthLoginName, PARAM_TYPE_TEXT)
    OAuthLoginDST = FetchData(sSQL)
    ClearParams()
    IF OAuthLoginDST.RowCount THEN
      LoadOauthLogin = -1
    END IF
  END IF
END FUNCTION

SUB CreateOAuthLogin(OAuthProvider AS STRING, OAuthLoginName AS STRING, OAuthToken AS STRING, RefreshToken AS STRING = "")
  DIM sSQL AS STRING
  OAuthLoginName = LCASE(OAuthLoginName)
  IF LoadOAuthLogin(OAuthProvider + "_" + OAuthLoginName) THEN
    sSQL = "UPDATE [oauth_logins] SET [token] = @OAuthLoginToken, [secret] = @OAuthLoginSecret WHERE [name] = @OAuthLoginName;"
  ELSE
    sSQL = "INSERT INTO [oauth_logins] ([name], [token], [secret]) VALUES (@OAuthLoginName, @OAuthLoginToken, @OAuthLoginSecret);"
  END IF
  AddParam("@OAuthLoginName", OAuthProvider + "_" + OAuthLoginName, PARAM_TYPE_TEXT)
  AddParam("@OAuthLoginToken", OAuthToken, PARAM_TYPE_TEXT)
  AddParam("@OAuthLoginSecret", RefreshToken, PARAM_TYPE_TEXT)
  ExecuteSql(sSQL)
  ClearParams()
END SUB

#IF 0
SUB LoadUserGroups()
  DIM objGroups AS JSON_Object
  objGroups.RawContent = LoadDataFile("groups.json")
  JSON_CountMembers(objGroups)
  IF objGroups.MemberCount > 0 THEN
    REDIM ArrayGroups(objGroups.MemberCount)
    JSON_ParseObject(objGroups, ArrayGroups())
  END IF
END SUB

FUNCTION CountUserGroups() AS ULONG
  IF UBOUND(ArrayGroups) >= 0 THEN
    CountUserGroups = UBOUND(ArrayGroups)
  END IF
END FUNCTION

FUNCTION GetUserGroupName(GroupNumber AS ULONG) AS STRING
  IF UBOUND(ArrayGroups) >= 0 THEN
    WITH ArrayGroups(GroupNumber)
      IF .Value.ValueType = JSON_TYPE_STRING THEN
        GetUserGroupName = JSON_ParseString(.Value.RawContent)
      END IF
    END WITH
  END IF
END FUNCTION
#ENDIF

FUNCTION IsAuth() AS LONG
  IF SHA256(GetCookie(SESSION_NAME)) = ReadSession("session.token") THEN
    IsAuth = -1
  END IF
END FUNCTION

FUNCTION ValidateSession(SessionToken AS STRING) AS LONG
  IF SessionToken = ReadSession("session.token") THEN
    ValidateSession = -1
  END IF
END FUNCTION

FUNCTION ListUserModules() AS STRING
  DIM AS STRING ModName, ModTitle, ModList, ListBody
  DIM AS LONG CanList, ModuleCount
  DIM CompiledModules() AS IguanaModule
  'Get registered modules
  ListCompiledModules(CompiledModules())
  ModuleCount = UBOUND(CompiledModules)
  IF ModuleCount >= 0 THEN
    FOR i AS LONG = 0 TO ModuleCount
      ModName = LCASE(CompiledModules(i).Name)
      IF ModName = "admin" AND VALINT(ReadUser("user.group")) <> ADMIN_GROUP THEN
        CompiledModules(i).ListedForUser = 0
      END IF
      IF CompiledModules(i).ListedForUser THEN
        LoadLanguage(ModName)
        ModTitle = Language("module." + ModName + ".module.title")
        ListBody = ReadTemplate("user-options-menu")
        ListBody = Replace(ListBody, "option.title", ModTitle)
        ListBody = Replace(ListBody, "option.url", CreateURL("module." + ModName))
        ModList += ListBody
      END IF
    NEXT
    ListUserModules = ModList
  END IF
END FUNCTION

FUNCTION HideUserEmail(UserEmail AS STRING) AS STRING
  DIM AS STRING HiddenEmail, char
  FOR i AS LONG = 1 TO LEN(UserEmail)
    char = MID(UserEmail, i, 1)
    SELECT CASE i
      CASE 4 TO LEN(UserEmail) - 8
        IF NOT char = "@" THEN
          char = "*"
        END IF
        HiddenEmail = HiddenEmail + char
      CASE ELSE
        HiddenEmail = HiddenEmail + char
    END SELECT
  NEXT
  HideUserEmail = HiddenEmail
END FUNCTION

SUB LoadUsersInterface()
  DIM AS STRING Action, UserAlias, UserEmail, UserToken, UserPassword, Salt, TempContent, SiteUrl, LastError
  CheckTable("users", USERS_TABLE_FIELDS)
  CheckTable("sessions", SESSIONS_TABLE_FIELDS)
  SiteUrl = TrimTrailingSlash(GetSettings("protocol") + GetSettings("domain") + GetSettings("url"))
  Action = GetURLParam("action", 2)
  IF LEN(Action) THEN
    SELECT CASE Action
      CASE "login"
        UpdateGlobalProperty("document_title", Language("module_users_login"))
        IF IsAuth() THEN
          'Redirect to user panel
          SendHeader("Location", SiteUrl + CreateURL("module.users"))
        ELSE
          UserAlias = Post("user-alias")
          IF LEN(UserAlias) THEN
            IF LoadUser(UserAlias) THEN
              'Retrieve stored password
              UserPassword = ReadUser("user.password")
              'Get the password salt
              Salt = LEFT(UserPassword, INSTR(UserPassword, "+") - 1)
              IF SHA256(Salt + Post("user-password")) = MID(UserPassword, INSTR(UserPassword, "+") + 1) THEN
                'Password match
                IF VALINT(ReadUser("user.active")) THEN
                  'User is active
                  CreateSession(UserAlias)
                  'Redirect to user panel
                  SendHeader("Refresh", STR(SECONDS_TO_WAIT) + ";" + SiteUrl + CreateURL("module.users"))
                  UpdateGlobalProperty("document_content", ReadTemplate("logged"))
                ELSE
                  'The user is inactive or banned
                  LastError = Language("error_user_not_active")
                END IF
              ELSE
                'Password does not match
                LastError = Language("error_wrong_password")
              END IF
            ELSE
              'User does not exists
              LastError = Language("error_user_not_registered")
            END IF
          END IF
          IF LEN(LastError) OR LEN(ReadGlobal("document_content")) = 0 THEN
            CreateGlobalProperty("last_error_message", LastError)
            UpdateGlobalProperty("document_content", ReadTemplate("login"))
          END IF
        END IF
      CASE "logout"
        IF IsAuth() THEN
          IF ReadSession("session.token") <> "" THEN
            DeleteSession(ReadSession("session.token"))
            UpdateGlobalProperty("document_title", Language("module_users_control_panel"))
            UpdateGlobalProperty("document_content", ReadTemplate("logout"))
            SendHeader("Refresh", STR(SECONDS_TO_WAIT) + ";" + SiteUrl)
          ELSE
            UpdateGlobalProperty("document_title", Language("module_users_login"))
            CreateGlobalProperty("last_error_message", Language("error_session_not_exists"))
            UpdateGlobalProperty("document_content", ReadTemplate("login"))
          END IF
        ELSE
          UpdateGlobalProperty("document_content", "403")
        END IF
      CASE "register"
        UpdateGlobalProperty("document_title", Language("module_users_register"))
        IF IsAuth() THEN
          'Redirect to user panel
          SendHeader("Location", SiteUrl + CreateURL("module.users"))
        ELSE
          UserAlias = Post("user-alias")
          IF LEN(UserAlias) THEN
            'Check if the user alias is already registered
            IF NOT LoadUser(UserAlias) THEN
              'Check if password meets required length
              UserPassword = Post("user-password")
              IF LEN(UserPassword) >= MIN_PASSWORD_LENGTH THEN
                Salt = RandomString(SALT_LENGTH)
                UserToken = RandomString(TOKEN_LENGTH)
                UserEmail = ValidateChar(Post("user-email"))
                CreateUser(UserAlias, Salt + "+" + SHA256(Salt + UserPassword), UserEmail, , UserToken)
                'Parse email template
                CreateUrlProperty("useralias", UserAlias)
                CreateUrlProperty("usertoken", UserToken)
                TempContent = ReadTemplate("activate-user-mail")
                ClearURLProperties()
                'Send activation link
                SendMail(UserEmail, UserAlias, GetSettings("site_email"), GetSettings("site_title"), ReadGlobal("document_title"), TempContent)
                UpdateGlobalProperty("document_content", ReadTemplate("registered"))
              ELSE
                LastError = Language("error_password_too_short")
              END IF
            ELSE
              LastError = Language("error_user_already_registered")
            END IF
          ELSE
            LastError = Language("error_user_name_empty")
          END IF
          IF LEN(LastError) OR LEN(ReadGlobal("document_content")) = 0 THEN
            CreateGlobalProperty("last_error_message", LastError)
            UpdateGlobalProperty("document_content", ReadTemplate("register"))
          END IF
        END IF
      CASE "change-password"
        IF IsAuth() THEN
          UserAlias = ReadUser("user.alias")
          IF LEN(Post("current-user-password")) AND ValidateSession(Post("session_token")) THEN
            'Form sent, retrieve the stored salt + hashed password
            UserPassword = ReadUser("user.password")
            'Get the password salt
            Salt = LEFT(UserPassword, INSTR(UserPassword, "+") - 1)
            IF SHA256(Salt + Post("current-user-password")) = MID(UserPassword, INSTR(UserPassword, "+") + 1) THEN
              'Password match, replace old password with the new one
              UserPassword = Post("new-user-password")
              IF LEN(UserPassword) THEN
                IF LEN(UserPassword) >= MIN_PASSWORD_LENGTH THEN
                  'Generate new salt
                  Salt = RandomString(SALT_LENGTH)
                  UpdateUser(UserAlias, Salt + "+" + SHA256(Salt + UserPassword))
                  LastError = Language("success_password_changed")
                ELSE
                  'New password is empty
                  LastError = Language("error_password_too_short")
                END IF
              END IF
            ELSE
              'Password does not match
              LastError = Language("error_wrong_password")
            END IF
          END IF
          UpdateGlobalProperty("document_title", Language("module_users_change_password"))
          CreateGlobalProperty("last_error_message", LastError)
          UpdateGlobalProperty("document_content", ReadTemplate("change-password"))
        ELSE
          UpdateGlobalProperty("document_content", "403")
        END IF
      CASE "reset-password"
        UpdateGlobalProperty("document_title", Language("module_users_reset_password"))
        UserAlias = GetURLParam("username", 3)
        IF LEN(UserAlias) THEN
          IF LoadUser(UserAlias) THEN
            'Check the received token against the stored token
            UserToken = ValidateChar(LCASE(GetURLParam("token", 4)))
            IF UserToken = ReadUser("user.token") THEN
              UserPassword = Post("new-user-password")
              IF LEN(UserPassword) THEN
                IF LEN(UserPassword) >= MIN_PASSWORD_LENGTH THEN
                  'Generate new salt
                  Salt = RandomString(SALT_LENGTH)
                  'Activate user if is inactive
                  UpdateUser(UserAlias, Salt + "+" + SHA256(Salt + UserPassword), , , , -1)
                  UpdateGlobalProperty("document_content", ReadTemplate("reset-password-changed"))
                ELSE
                  'New password is too short
                  LastError = Language("error_password_too_short")
                END IF
              ELSE
                'Show password change form
                CreateUrlProperty("useralias", UserAlias)
                CreateUrlProperty("usertoken", UserToken)
                CreateGlobalProperty("last_error_message", LastError)
                UpdateGlobalProperty("document_content", ReadTemplate("reset-password-change-form"))
                ClearUrlProperties()
              END IF
            ELSE
              LastError = Language("error_wrong_user_token")
            END IF
          ELSE
            LastError = Language("error_user_not_registered")
          END IF
        ELSE
          UserAlias = Post("user-alias")
          IF LEN(UserAlias) THEN
            IF LoadUser(UserAlias) THEN
              'Generate new token
              UserToken = RandomString(TOKEN_LENGTH)
              'Get user email
              UserEmail = ReadUser("user_email")
              'Update token
              UpdateUser(UserAlias, , , , UserToken)
              'Parse email template
              CreateUrlProperty("useralias", UserAlias)
              CreateUrlProperty("usertoken", UserToken)
              TempContent = ReadTemplate("reset-password-mail")
              ClearUrlProperties()
              'Send new activation link
              SendMail(UserEmail, UserAlias, GetSettings("site_email"), GetSettings("site_title"), ReadGlobal("document_title"), TempContent)
              'Hide user email
              CreateGlobalProperty("hidden_email", HideUserEmail(UserEmail))
              UpdateGlobalProperty("document_content", ReadTemplate("reset-password-request-sent"))
            ELSE
              LastError = Language("error_user_not_registered")
            END IF
          END IF
        END IF
        IF LEN(LastError) OR LEN(ReadGlobal("document_content")) = 0 THEN
          CreateGlobalProperty("last_error_message", LastError)
          UpdateGlobalProperty("document_content", ReadTemplate("reset-password"))
          ClearUserProperties()
        END IF
      CASE "activate"
        UserAlias = LCASE(GetURLParam("username", 3))
        IF LoadUser(UserAlias) THEN
          'Check received token against stored token
          IF ValidateChar(LCASE(GetURLParam("token", 4))) = ReadUser("user.token") THEN
            'The user must not be active
            IF NOT VALINT(ReadUser("user_active")) THEN
              'Set user token to null
              UpdateUser(UserAlias, , , , "NULL", -1)
              LastError = Language("success_user_activated")
            ELSE
              LastError = Language("error_user_already_active")
            END IF
          ELSE
            LastError = Language("error_wrong_user_token")
          END IF
        ELSE
          LastError = Language("error_user_not_registered")
        END IF
        UpdateGlobalProperty("document_title", Language("module_users_login"))
        CreateGlobalProperty("last_error_message", LastError)
        UpdateGlobalProperty("document_content", ReadTemplate("login"))
      CASE "oauth-login"
        CheckTable("oauth_logins", OAUTH_LOGINS_TABLE_FIELDS)
        UpdateGlobalProperty("document_title", Language("module_users_oauth_login"))
        'Delegate management to OAuth library
        'OAuthLogin(GetUrlParam("oauth-provider", 3))
    END SELECT
  ELSE
    IF GetCookie(SESSION_NAME) <> "" THEN
      IF IsAuth() THEN
        IF VALINT(ReadUser("user.active")) THEN
          UpdateGlobalProperty("document_title", Language("module_users_control_panel"))
          CreateGlobalProperty("users_options_menu", ListUserModules())
          UpdateGlobalProperty("document_content", ReadTemplate("user"))
        ELSE
          LastError = Language("error_user_not_active") + ReadSession("session.user")
        END IF
      ELSE
        LastError = Language("error_session_not_exists")
      END IF
    END IF
    IF LEN(LastError) OR LEN(ReadGlobal("document_content")) = 0 THEN
      UpdateGlobalProperty("document_title", Language("module_users_login"))
      CreateGlobalProperty("last_error_message", LastError)
      UpdateGlobalProperty("document_content", ReadTemplate("login"))
    END IF
  END IF
END SUB

FUNCTION ReadUserData(Key AS STRING) AS STRING
  SELECT CASE LEFT(Key, INSTR(Key, "."))
    CASE "session"
      ReadUserData = ReadSession(Key)
    CASE "user"
      ReadUserData = ReadUser(Key)
  END SELECT
END FUNCTION

DIM CurrentModule AS IguanaModule

WITH CurrentModule
  .Name = ModuleName
  .ListedForUser = 0
  .MainLoader = CINT(ProcPtr(LoadUsersInterface))
  .VarsFunction = CINT(ProcPtr(ReadUserData))
END WITH

RegisterModule(CurrentModule)
RegisterLoader(CINT(ProcPtr(LoadCurrentSession)))
RegisterLoader(CINT(ProcPtr(LoadCurrentUser)))
