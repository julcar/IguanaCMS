'################################# Iguana CMS ##################################
'Main application file
'Compile it with FreeBasic => 0.24.0
'###############################################################################

#INCLUDE "iguanacms.bi"

DIM AS STRING Request, PageName

'Setup the environment
InitLoad()

'Look for a request
Request = GetURLParam("module", 1)

IF Request <> "" THEN
  IF Request = "pages" THEN
    'Load the pages module
    PageName = GetURLParam("pagename", 2)
    IF PageName = "" THEN
      'Load the default page
      PageName = GetSettings("index_page")
    END IF
    IF LoadPage(PageName) THEN
      CreateGlobalProperty("document_title", ReadPage("title"))
      CreateGlobalProperty("document_content", ReadTemplate("page"))
    END IF
  ELSE
    'Load any other module
    LoadModule(Request)
  END IF
ELSE
  'Load default settings
  SELECT CASE GetSettings("index_type")
    CASE "page"
      PageName = GetSettings("index_page")
      IF LoadPage(PageName) THEN
        CreateGlobalProperty("document_title", ReadPage("title"))
        CreateGlobalProperty("document_content", ReadTemplate("page"))
      END IF
    CASE "module"
      LoadModule(GetSettings("index_module"))
  END SELECT
END IF

IF ReadGlobal("document_content") = "403" THEN
  'Display error 403
  UpdateGlobalProperty("document_content", ReadTemplate("403"))
END IF

IF LEN(ReadGlobal("document_content")) = 0 THEN
  'Display error 404
  UpdateGlobalProperty("document_content", ReadTemplate("404"))
END IF

IF LEN(ReadGlobal("document_title")) = 0 THEN
  UpdateGlobalProperty("document_title", GetSettings("description"))
END IF

'Do the magic
SendHeader("Content-Type", "text/html; Charset=" + GetSettings("encoding") + LINE_ENDING)
PRINT ReadTemplate("main")

'Free memory
CleanMemory()

END
