#INCLUDE "../iguanacms.bi"

CONST AS STRING PAGES_TABLE_FIELDS = _
    "[id] INTEGER PRIMARY KEY NOT NULL, " _
    "[name] TEXT NOT NULL, " _
    "[title] TEXT NOT NULL, " _
    "[created_date] TEXT NOT NULL, " _
    "[lastmod_date] TEXT NOT NULL, " _
    "[published] INTEGER NOT NULL, " _
    "[content] TEXT NULL "

CONST MAX_ITEMS_PER_PAGE = 3

DIM SHARED PageProperties() AS DataField

SUB CreatePageProperty(PropertyName AS STRING, PropertyValue AS STRING)
  CreateProperty(PageProperties(), PropertyName, PropertyValue)
END SUB

FUNCTION ReadPage(PropertyName AS STRING) AS STRING
  ReadPage = ReadProperty(PageProperties(), PropertyName)
END FUNCTION

SUB ClearPageProperties()
  ClearProperties(PageProperties())
END SUB

FUNCTION PermalinkToId(PageName AS STRING) AS STRING
  DIM sSQL AS STRING, PageDST AS DataSet
  sSQL = "SELECT [id] FROM [pages] WHERE [name] = @PageName ORDER BY [id] DESC;"
  AddParam("@PageName", PageName, PARAM_TYPE_TEXT)
  PageDST = FetchData(sSQL)
  ClearParams()
  IF PageDST.RowCount THEN
    PermalinkToId = PageDST.Rows(0).Fields(0).Value
  END IF
END FUNCTION

FUNCTION LoadPage(PageName AS STRING, IsEditing AS LONG = 0) AS LONG
  DIM PageDST AS DataSet
  DIM AS STRING sSQL, TempContent
  CheckTable("pages", PAGES_TABLE_FIELDS)
  sSQL = "SELECT [name], [title], [created_date], [lastmod_date], [published], [content] FROM [pages] WHERE [name] = @PageId;"
  AddParam("@PageId", PermalinkToId(PageName), PARAM_TYPE_TEXT)
  PageDST = FetchData(sSQL)
  ClearParams()
  IF PageDST.RowCount THEN
    WITH PageDST.Rows(0)
      FOR i AS LONG = 0 TO .FieldCount - 2
        CreatePageProperty("page." + .Fields(i).Name, .Fields(i).Value)
      NEXT
      TempContent = .Fields(.FieldCount - 1).Value
      IF IsEditing THEN
        'Display properly page content in editor
        TempContent = HTMLEncode(TempContent)
      ELSE
        'Parse any BBCode it could content
        TempContent = CodeParser(TempContent)
#IF 0
        'Convert new lines into line breaks
        TempContent = Replace(TempContent, LINE_ENDING, "<br />")
#ENDIF
      END IF
      CreatePageProperty(.Fields(.FieldCount - 1).Name, TempContent)
    END WITH
    IF IsEditing OR VALINT(ReadPage("page.published")) THEN
      CreateUrlProperty("pagename", ReadPage("page.name"))
      LoadPage = -1
    END IF
  END IF
END FUNCTION

SUB ListPages(BodyTpl AS STRING, IsEditing AS LONG = 0, CurPage AS LONG = 0)
  DIM PageDST AS DataSet
  DIM AS STRING sSQL, PageName, PageList, LastError
  sSQL = "SELECT [name] FROM [pages] ORDER BY [id] DESC LIMIT " + STR(MAX_ITEMS_PER_PAGE) + CHR(32)
  IF CurPage THEN
    sSQL += "OFFSET " + STR(MAX_ITEMS_PER_PAGE * CurPage) + CHR(32)
  END IF
  sSQL += ";"
  PageDST = FetchData(sSQL)
  ClearParams()
  IF PageDST.RowCount THEN
    FOR i AS LONG = 0 TO PageDST.RowCount - 1
      PageName = PageDST.Rows(i).Fields(0).Value
      IF LoadPage(PageName, -1) THEN
        PageList += ReadTemplate(BodyTpl)
        ClearUrlProperties()
        ClearPageProperties()
      END IF
    NEXT
  END IF
  IF PageList = "" THEN
    LastError = Language("error_page_list_empty")
  END IF
  DIM AS STRING UrlScheme, Paginator
  UrlScheme = "module_admin_section_pages_action_page_page_"
  IF CurPage = 0 THEN
    CreatePageProperty("page.paginator_prev", CreateURL(UrlScheme + STR(CurPage)))
  ELSE
    CreatePageProperty("page.paginator_prev", CreateURL(UrlScheme + STR(CurPage - 1)))
  END IF
  CreatePageProperty("page.paginator_page", STR(CurPage))
  IF PageDST.RowCount < MAX_ITEMS_PER_PAGE THEN
    CreatePageProperty("page.paginator_next", CreateURL(UrlScheme + STR(CurPage)))
  ELSE
    CreatePageProperty("page.paginator_next", CreateURL(UrlScheme + STR(CurPage + 1)))
  END IF
  Paginator = ReadTemplate("pages-paginator")
  ClearPageProperties()
  CreatePageProperty("page.list", PageList)
  CreatePageProperty("page.error_message", LastError)
  CreatePageProperty("page.paginator", Paginator)
END SUB
