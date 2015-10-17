FUNCTION ReadStdin$
  DIM numChars, postQuery$
  IF ENVIRON$("REQUEST_METHOD") = "POST" THEN
    numChars = VAL(ENVIRON$("CONTENT_LENGTH"))
    postQuery$ = INPUT$(numChars)
    ReadStdin$ = postQuery$
  ELSE
    ReadStdin$ = ""
  END IF
END FUNCTION

COMMON SHARED StdinQuery$
StdinQuery$ = ReadStdin$

FUNCTION Post$ (arg$)
  Post$ = UnEscape$(SplitVar$(StdinQuery$, arg$, CHR$(38)))
END FUNCTION

FUNCTION QueryString$ (arg$)
  QueryString$ = UnEscape$(SplitVar$(ENVIRON$("QUERY_STRING"), arg$, CHR$(38)))
END FUNCTION
