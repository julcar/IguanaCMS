ENUM User_Groups
  USERS_GROUP
  ADMIN_GROUP
  Count
END ENUM

'Length for random tokens and nonces
CONST TOKEN_LENGTH = 32

'Users module public functions
DECLARE FUNCTION IsAuth() AS LONG
DECLARE FUNCTION LoadUser(UserAlias AS STRING) AS LONG
DECLARE FUNCTION LoadOAuthLogin(OAuthLoginName AS STRING) AS LONG
DECLARE SUB CreateUser(UserAlias AS STRING, UserPassword AS STRING = "", UserEmail AS STRING = "", OAuthLoginName AS STRING = "", UserToken AS STRING = "", IsActive AS LONG = 0)
DECLARE SUB UpdateUser(UserAlias AS STRING, UserPassword AS STRING = "", UserEmail AS STRING = "", OAuthLoginName AS STRING = "", UserToken AS STRING = "", IsActive AS LONG = 0)
DECLARE SUB CreateOAuthLogin(OAuthProvider AS STRING, OAuthLoginName AS STRING, OAuthToken AS STRING, RefreshToken AS STRING = "")
DECLARE SUB CreateSession(UserAlias AS STRING)
DECLARE FUNCTION ValidateSession(SessionToken AS STRING) AS LONG
DECLARE FUNCTION ReadUserData(Key AS STRING) AS STRING
DECLARE SUB LoadUserGroups()
DECLARE FUNCTION CountUserGroups() AS ULONG
DECLARE FUNCTION GetUserGroupName(GroupNumber AS ULONG) AS STRING
