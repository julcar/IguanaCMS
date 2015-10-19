FUNCTION LoadPage$()
  DIM pageID, strSQL$
  
  IF QueryString$("module") = "pages" THEN
    IF QueryString$("pageid") <> "" THEN
      'Attemping to load a page with a given ID
      pageID = CINT(QueryString$("pageid"))
    ELSE
      'Attemping to load the pages module without any page ID
      IF getSettings$("site_index_type") = "page" THEN
        pageID = CINT(getSettings$("site_index_page"))
      END IF
    END IF  
  ELSE
    'Attemping to load the default page/module
    IF getSettings$("site_index_type") = "page" THEN
      pageID = CINT(getSettings$("site_index_page"))
    END IF
  END IF
  
  LoadPage$ = ReadFile$(dataPath$ & "pages\page-" & LTRIM$(STR$(pageID)) & ".txt")
END FUNCTION

COMMON SHARED pageContent$
pageContent$ = LoadPage$()
'FIXME: If page_status = 0 (not published) or page does not exists, then display an 404 error message
'pageContent$ = ""

FUNCTION pageParser$(strQuery$)
  DIM keyParsed$
  keyParsed$ = splitVar$(pageContent$, "page_" & strQuery$, CHR$(10))
  
  IF keyParsed$ <> "" THEN
    pageParser$ = keyParsed$
  ELSE
    pageParser$ = strQuery$
  END IF
END FUNCTION
