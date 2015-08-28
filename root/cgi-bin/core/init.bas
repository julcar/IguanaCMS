SUB SendHeaders()
  'FIXME: Out there are more headers than just these
  PRINT "Content-type: text/html"
  PRINT
END SUB

SUB InitLoad()
  'Just to see if we need to init a page or a module
  'If is our built-in pages module then let him work
  'If is any other module then load it
  CALL SendHeaders()
  'Is calling a module?
  IF QueryString$("module") <> "" THEN
    'Load a module
    PrintError = 1
    IF NOT QueryString$("module") = "pages" THEN
      FOR i = 0 TO UBOUND(compiledModules$)
        IF QueryString$("module") = compiledModules$(i) THEN
          PRINT "The module " & compiledModules$(i) & " seems to be compiled"
          PrintError = 0
          EXIT FOR
        END IF
      NEXT
      IF NOT PrintError = 0 THEN
        PRINT "Error: the module " & QueryString$("module") & " was not compiled"
      END IF
    END IF
  ELSE
    'Attemping to load the default page/module
    IF NOT getSettings$("site_index_type") = "page" THEN
      'now we need the getSettings$("site_index_module") key
    END IF
  END IF
END SUB
