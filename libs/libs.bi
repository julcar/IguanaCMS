DECLARE FUNCTION SHA256(BYVAL Message AS STRING, BYVAL RawOutput AS BYTE = 0) AS STRING

'##############################
'Mails
'##############################
DECLARE SUB SendMail(ToAddress AS STRING, ToName AS STRING, _
                     FromAddress AS STRING, FromName AS STRING, _
                     Subject AS STRING, Body AS STRING)
