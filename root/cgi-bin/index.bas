'################################# Iguana CMS ##################################
'Main application file
'Version 0.0.1 alpha
'Compile it with FreeBasic 0.24 beta
'###############################################################################
'DECLARE SUB SendHeaders()
'CALL SendHeaders()
'##########################
'Paths block
'##########################

CONST basePath$ = "\"
CONST rootPath$ = basePath$ & "root\"
CONST tempPath$ = basePath$ & "temp\"
CONST dataPath$ = basePath$ & "data\"
'CONST SQLitePath$ = "\sqlite\sqlite3.exe"
'CONST databasePath$ = dataPath$ & "database.s3db"

'##############################
'Includes block
'##############################

'$INCLUDE: "core/files.bas"
'$INCLUDE: "core/strings.bas"
'$INCLUDE: "core/request.bas"
'$INCLUDE: "core/settings.bas"
'$INCLUDE: "core/data.bas"
'$INCLUDE: "core/pages.bas"
'$INCLUDE: "core/modules.bas"
'$INCLUDE: "core/init.bas"

'##############################
'Templates block
'##############################

COMMON SHARED tplPath$
tplPath$ = rootPath$ & "templates\" & getSettings$("site_template") & "\"
'$INCLUDE: "core/templates.bas"

'##############################
'Page initialization
'##############################

CALL InitLoad()
PRINT LoadTemplate$(tplPath$ & "main.html")
SYSTEM
