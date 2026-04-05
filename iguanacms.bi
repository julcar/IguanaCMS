'################################# Iguana CMS ##################################
'Main include file
'Compile it with FreeBasic => 0.24.0
'###############################################################################

#IFDEF __FB_WIN32__
  CONST AS STRING PATH_DELIMITER = "\"
  CONST AS STRING LINE_ENDING = CHR(13, 10)
#ELSE
  CONST AS STRING PATH_DELIMITER = "/"
  CONST AS STRING LINE_ENDING = CHR(10)
#ENDIF

CONST AS STRING IGUANA_VERSION = "0.1.8-beta"

'##############################
'File I/O
'##############################
DECLARE FUNCTION FileExists ALIAS "fb_FileExists" (BYVAL FilePath AS ZSTRING PTR) AS LONG
DECLARE SUB CheckPath(DirPath AS STRING)
DECLARE FUNCTION ListFiles(Path AS STRING, Ext AS STRING, Count AS ULONG) AS STRING
DECLARE FUNCTION ReadFile(FilePath AS STRING) AS STRING
DECLARE SUB DeleteFile(FilePath AS STRING)
DECLARE SUB WriteFile(FilePath AS STRING, FileContent AS STRING)

'##############################
'Data
'##############################
#INCLUDE "core/data.bi"

'##############################
'Pseudo-Objetcs
'##############################
DECLARE SUB CreateProperty(ArrayProperties() AS DataField, PropertyName AS STRING, PropertyValue AS STRING)
DECLARE FUNCTION ReadProperty(ArrayProperties() AS DataField, PropertyName AS STRING, ReturnNameOnFail AS LONG = 0) AS STRING
DECLARE SUB UpdateProperty(ArrayProperties() AS DataField, PropertyName AS STRING, PropertyValue AS STRING)
DECLARE SUB ClearProperties(ArrayProperties() AS DataField)
DECLARE FUNCTION LoadDataFile(FilePath AS STRING) AS STRING
DECLARE SUB ParseDataFile(ArrayProperties() AS DataField, FileContent AS STRING, DirectiveTag AS STRING)

'##############################
'CGI
'##############################
DECLARE FUNCTION ReadStdin() AS STRING
DECLARE SUB ParseQuery(InputQuery AS STRING, ArrayParams() AS DataField, Delimiter AS STRING)
DECLARE FUNCTION URLDecode(Query AS STRING) AS STRING
DECLARE FUNCTION Post(Arg AS STRING) AS STRING
DECLARE FUNCTION QueryString(Arg AS STRING) AS STRING
DECLARE FUNCTION GetFileMIMEType(FileName AS STRING) AS STRING
DECLARE FUNCTION GetFileContent(FileName AS STRING) AS STRING
DECLARE SUB SetCookie(CookieName AS STRING, CookieValue AS STRING, _
 Domain AS STRING, Path AS STRING, ExpiresDate AS STRING, _
 MaxAgeTime AS ULONG, IsSecure AS LONG, IsHttpOnly AS LONG)
DECLARE FUNCTION GetCookie(CookieName AS STRING) AS STRING
DECLARE SUB SendHeader(HeaderName AS STRING, HeaderContent AS STRING)

'##############################
'System
'##############################
DECLARE SUB InitLoad()
DECLARE SUB CleanMemory()
DECLARE FUNCTION SystemProperties(ObjectExpr AS STRING) AS STRING

'##############################
'Strings
'##############################
DECLARE FUNCTION Replace(Query AS STRING, LookFor AS STRING, ReplaceWith AS STRING) AS STRING
DECLARE FUNCTION ValidateChar(RawStr AS STRING) AS STRING
DECLARE FUNCTION HTMLEncode(Query AS STRING) AS STRING
DECLARE FUNCTION RandomString (StrLength AS ULONG) AS STRING
DECLARE FUNCTION TrimTrailingSlash(RawUrl AS STRING) AS STRING
DECLARE FUNCTION CreatePermalink(RawTitle AS STRING) AS STRING
DECLARE FUNCTION PercentEncode(RawStr AS STRING) AS STRING
DECLARE FUNCTION Latin1ToUtf8(RawStr AS STRING) AS STRING

'##############################
'Date-Time
'##############################
DECLARE FUNCTION SystemDate() AS STRING
DECLARE FUNCTION SystemTime() AS STRING
DECLARE FUNCTION Year() AS STRING
DECLARE FUNCTION Month() AS STRING
DECLARE FUNCTION MonthName() AS STRING
DECLARE FUNCTION Day() AS STRING
DECLARE FUNCTION WeekDay(TheYear AS ULONG, TheMonth AS ULONG, TheDay AS ULONG) AS ULONG
DECLARE FUNCTION DayName(TheYear AS ULONG, TheMonth AS ULONG, TheDay AS ULONG) AS STRING
DECLARE FUNCTION IsDateFormat(RawDate AS STRING) AS LONG
DECLARE FUNCTION CurrentTimeStamp() AS STRING

'##############################
'Languages
'##############################
DECLARE FUNCTION Language(Key AS STRING) AS STRING
DECLARE SUB LoadLanguage(ModuleName AS STRING)

'##############################
'Templates
'##############################
DECLARE FUNCTION ExpandObject(ObjectExpr AS STRING) AS STRING
DECLARE FUNCTION SnippetParser(SnippetContent AS STRING) AS STRING
DECLARE SUB LoadTemplate(ModuleName AS STRING)
DECLARE FUNCTION ReadTemplate(SnippetName AS STRING) AS STRING
DECLARE SUB ClearSnippets()

'##############################
'URLs
'##############################
DECLARE SUB CreateUrlProperty(PropertyName AS STRING, PropertyValue AS STRING)
DECLARE FUNCTION ReadUrl(PropertyName AS STRING) AS STRING
DECLARE FUNCTION CreateURL(Scheme AS STRING) AS STRING
DECLARE FUNCTION URLParam(Arg AS ULONG) AS STRING
DECLARE FUNCTION GetURLParam(VarName AS STRING = "", ParamIndex AS ULONG = 0) AS STRING
DECLARE SUB ClearUrlProperties()

'##############################
'BBCodes
'##############################
DECLARE SUB LoadBBCodes()
DECLARE FUNCTION CodeParser(Content AS STRING) AS STRING

'##############################
'MultiSites
'##############################
DECLARE SUB LoadSites()
DECLARE FUNCTION GetBasePath(HostName AS STRING) AS STRING

'##############################
'Pages
'##############################
DECLARE SUB ListPages(BodyTpl AS STRING, IsEditing AS LONG = 0, CurPage AS LONG = 0)
DECLARE FUNCTION LoadPage(PageName AS STRING, IsEditing AS LONG = 0) AS LONG
DECLARE FUNCTION ReadPage(Query AS STRING) AS STRING

'##############################
'Modules
'##############################
DECLARE SUB LoadModule(ModuleName AS STRING)
DECLARE FUNCTION ReadModule (Key AS STRING) AS STRING
DECLARE SUB RunLoaders()

'##############################
'Libraries Includes
'##############################
#INCLUDE "libs/libs.bi"

'##############################
'Settings
'##############################
DECLARE SUB LoadSettings()
DECLARE FUNCTION GetSettings(PropertyName AS STRING) AS STRING
DECLARE SUB SetSettings(PropertyName AS STRING, PropertyValue AS STRING)

'##############################
'Globals
'##############################
DECLARE SUB CreateGlobalProperty(PropertyName AS STRING, PropertyValue AS STRING)
DECLARE SUB UpdateGlobalProperty(PropertyName AS STRING, PropertyValue AS STRING)
DECLARE FUNCTION ReadGlobal(PropertyName AS STRING) AS STRING
DECLARE SUB ClearGlobalProperties()

'Windows-only Debug Macro
#DEFINE PrintLog(LogAction) (SHELL("echo " + SystemDate() + "-" + SystemTime() + ":" + LogAction + " >> " + BasePath + "logs\logfile.txt"))
