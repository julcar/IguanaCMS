'Date functions

'NOTE: Many of these functions are already implemented on RTL

FUNCTION SystemDate() AS STRING
  'Freebasic always return the date in mm-dd-yyyy format
  'but for our internals we need the date in yyyy-mm-dd format
  DIM AS STRING CurrentDate = DATE
  SystemDate = MID(CurrentDate, 7) + "-" + LEFT(CurrentDate, 2) + "-" + MID(CurrentDate, 4, 2)
END FUNCTION

FUNCTION SystemTime() AS STRING
  SystemTime = TIME
END FUNCTION

FUNCTION Year() AS STRING
  Year = MID(DATE, 7)
END FUNCTION

FUNCTION Month() AS STRING
  Month = LEFT(DATE, 2)
END FUNCTION

FUNCTION MonthName() AS STRING
  DIM AS STRING Months(11) = _
    {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
  MonthName = Months(CLNG(VALINT(Month)) - 1)
END FUNCTION

FUNCTION Day() AS STRING
  Day = MID(DATE, 4, 2)
END FUNCTION

FUNCTION WeekDay(TheYear AS ULONG, TheMonth AS ULONG, TheDay AS ULONG) AS ULONG
  'Zeller's congruence
  IF TheMonth < 3 THEN
    'If month is jan or feb, add 12 snd substract 1 to year
    TheMonth = TheMonth + 12
    TheYear = TheYear - 1
  END IF
  'Returns 0 for Sunday up to 6 for Saturday
  WeekDay = (TheDay + TheYear + (TheYear \ 4) - (TheYear \ 100) + (TheYear \ 400) + (13 * (TheMonth + 3) \ 5) + 1) MOD 7
END FUNCTION

FUNCTION DayName(TheYear AS ULONG, TheMonth AS ULONG, TheDay AS ULONG) AS STRING
  DIM AS STRING Days(6) = _
    {"Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"}
  DayName = Days(WeekDay(TheYear, TheMonth, TheDay))
END FUNCTION

FUNCTION IsZeroTime(TimePart AS STRING) AS LONG
  IF TimePart = "00" THEN
    IsZeroTime = -1
  END IF
END FUNCTION

FUNCTION IsDateFormat(RawDate AS STRING) AS LONG
  'We manage dates as yyyy-mm-ddThh:mm:ss
  DIM AS LONG ConvDigit, IsValid = -1
  DIM CurNumber AS STRING
  IF LEN(RawDate) <> 19 THEN
    IsValid = 0
  END IF
  'Test the year
  IF VALINT(MID(RawDate, 1, 4)) = 0 THEN
    IsValid = 0
  END IF
  'Test the month
  CurNumber = MID(RawDate, 6, 2)
  ConvDigit = VALINT(CurNumber)
  IF ConvDigit = 0 THEN
    IsValid = 0
  ELSE
    IF ConvDigit > 12 THEN
      IsValid = 0
    END IF
  END IF
  'Test the day
  CurNumber = MID(RawDate, 9, 2)
  ConvDigit = VALINT(CurNumber)
  IF ConvDigit = 0 THEN
    IsValid = 0
  ELSE
    'FIXME: Feb-31 is a valid date here
    IF ConvDigit > 31 THEN
      IsValid = 0
    END IF
  END IF
  'Test if we have a capital T as separator
  IF MID(RawDate, 11, 1) <> "T" THEN
    IsValid = 0
  END IF
  'Test the hour
  CurNumber = MID(RawDate, 12, 2)
  ConvDigit = VALINT(CurNumber)
  IF ConvDigit = 0 THEN
    IF NOT IsZeroTime(CurNumber) THEN
      IsValid = 0
    END IF
  ELSE
    IF ConvDigit > 23 THEN
      IsValid = 0
    END IF
  END IF
  'Test the minute
  CurNumber = MID(RawDate, 15, 2)
  ConvDigit = VALINT(CurNumber)
  IF ConvDigit = 0 THEN
    IF NOT IsZeroTime(CurNumber) THEN
      IsValid = 0
    END IF
  ELSE
    IF ConvDigit > 59 THEN
      IsValid = 0
    END IF
  END IF
  'Test the seconds
  CurNumber = MID(RawDate, 18, 2)
  ConvDigit = VALINT(CurNumber)
  IF ConvDigit = 0 THEN
    IF NOT IsZeroTime(CurNumber) THEN
      IsValid = 0
    END IF
  ELSE
    IF ConvDigit > 59 THEN
      IsValid = 0
    END IF
  END IF
  IF IsValid THEN
    IsDateFormat = -1
  END IF
END FUNCTION

'Avoid including datetime.bi just for this
DECLARE FUNCTION Now ALIAS "fb_Now"() AS DOUBLE

FUNCTION CurrentTimeStamp() AS STRING
  'https://www.freebasic-portal.de/code-beispiele/system/unix-timestamp-99.html
  CurrentTimeStamp = STR(CLNG(((Now() - 25569) * 86400)))
END FUNCTION
