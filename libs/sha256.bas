'Self contained SHA-256 hash function
'https://freebasic.net/forum/viewtopic.php?f=3&t=25916#p236199

FUNCTION SHA256(BYVAL Message AS STRING, BYVAL RawOutput AS BYTE = 0) AS STRING
  DIM AS ULONG h0, h1, h2, h3, h4, h5, h6, h7
  DIM AS ULONG a, b, c, d, e, f, g, h, t1, t2
  DIM AS ULONG K(64), W(64), MessageLen, i, t
  DIM AS STRING Chunk, Result

  MessageLen = LEN(Message)
  Message += CHR(VALINT("&H80"))

  WHILE (LEN(Message) MOD 64) <> 56
    Message += CHR(0)
  WEND

  FOR i AS LONG = 56 TO 0 STEP -8
    Message += CHR(INT((MessageLen * 8) / (2 ^ i)))
  NEXT

  K(0) = &H428A2F98 : K(1) = &H71374491 : K(2) = &HB5C0FBCF : K(3) = &HE9B5DBA5
  K(4) = &H3956C25B : K(5) = &H59F111F1 : K(6) = &H923F82A4 : K(7) = &HAB1C5ED5
  K(8) = &HD807AA98 : K(9) = &H12835B01 : K(10) = &H243185BE : K(11) = &H550C7DC3
  K(12) = &H72BE5D74 : K(13) = &H80DEB1FE : K(14) = &H9BDC06A7 : K(15) = &HC19BF174
  K(16) = &HE49B69C1 : K(17) = &HEFBE4786 : K(18) = &HFC19DC6 : K(19) = &H240CA1CC
  K(20) = &H2DE92C6F : K(21) = &H4A7484AA : K(22) = &H5CB0A9DC : K(23) = &H76F988DA
  K(24) = &H983E5152 : K(25) = &HA831C66D : K(26) = &HB00327C8 : K(27) = &HBF597FC7
  K(28) = &HC6E00BF3 : K(29) = &HD5A79147 : K(30) = &H6CA6351 : K(31) = &H14292967
  K(32) = &H27B70A85 : K(33) = &H2E1B2138 : K(34) = &H4D2C6DFC : K(35) = &H53380D13
  K(36) = &H650A7354 : K(37) = &H766A0ABB : K(38) = &H81C2C92E : K(39) = &H92722C85
  K(40) = &HA2BFE8A1 : K(41) = &HA81A664B : K(42) = &HC24B8B70 : K(43) = &HC76C51A3
  K(44) = &HD192E819 : K(45) = &HD6990624 : K(46) = &HF40E3585 : K(47) = &H106AA070
  K(48) = &H19A4C116 : K(49) = &H1E376C08 : K(50) = &H2748774C : K(51) = &H34B0BCB5
  K(52) = &H391C0CB3 : K(53) = &H4ED8AA4A : K(54) = &H5B9CCA4F : K(55) = &H682E6FF3
  K(56) = &H748F82EE : K(57) = &H78A5636F : K(58) = &H84C87814 : K(59) = &H8CC70208
  K(60) = &H90BEFFFA : K(61) = &HA4506CEB : K(62) = &HBEF9A3F7 : K(63) = &HC67178F2

  h0 = &H6A09E667 : h1 = &HBB67AE85 : h2 = &H3C6EF372 : h3 = &HA54FF53A
  h4 = &H510E527F : h5 = &H9B05688C : h6 = &H1F83D9AB : h7 = &H5BE0CD19

  FOR i AS LONG = 1 TO LEN(Message) STEP 64
    Chunk = MID(Message, i, 64)
    FOR j AS LONG = 1 TO 64 STEP 4
      W(j \ 4) = ASC(MID(Chunk, j, 1)) SHL 24 + _
             ASC(MID(Chunk, j + 1, 1)) SHL 16 + _
             ASC(MID(Chunk, j + 2, 1)) SHL 8 + _
             ASC(MID(Chunk, j + 3, 1))
    NEXT
    FOR t = 16 TO 63
      W(t) = (((W(t - 2)) SHR 17 OR (W(t - 2)) SHL 15) XOR ((W(t -2)) SHR 19 OR (W(t -2)) SHL 13) XOR ((W(t -2)) SHR 10)) + W(t - 7) + _
             (((W(t - 15)) SHR 7 OR (W(t - 15)) SHL 25) XOR ((W(t - 15)) SHR 18 OR (W(t - 15)) SHL 14) XOR ((W(t - 15)) SHR 3)) + W(t - 16)
    NEXT t

    a = h0 : b = h1 : c = h2 : d = h3 : e = h4 : f = h5 : g = h6 : h = h7

    FOR t = 0 TO 63
      t1 = h + (((e) SHR 6 OR (e) SHL 26) XOR ((e) SHR 11 OR (e) SHL 21) XOR ((e) SHR 25 OR (e) SHL 7)) + _
           (((e) AND (f)) XOR ((NOT (e)) AND g)) + K(t) + W(t)
      t2 = (((a) SHR 2 OR (a) SHL 30) XOR ((a) SHR 13 OR (a) SHL 19) XOR ((a) SHR 22 OR (a) SHL 10)) + _
           (((a) AND (b)) XOR ((a) AND (c)) XOR ((b) AND (c)))
      h = g
      g = f
      f = e
      e = d + t1
      d = c
      c = b
      b = a
      a = t1 + t2
    NEXT t

    h0 = h0 + a
    h1 = h1 + b
    h2 = h2 + c
    h3 = h3 + d
    h4 = h4 + e
    h5 = h5 + f
    h6 = h6 + g
    h7 = h7 + h
  NEXT i

  Result = RIGHT("0000000" + HEX(h0), 8) + RIGHT("0000000" + HEX(h1), 8) + _
           RIGHT("0000000" + HEX(h2), 8) + RIGHT("0000000" + HEX(h3), 8) + _
           RIGHT("0000000" + HEX(h4), 8) + RIGHT("0000000" + HEX(h5), 8) + _
           RIGHT("0000000" + HEX(h6), 8) + RIGHT("0000000" + HEX(h7), 8)

  IF RawOutput THEN
    DIM RawStr AS STRING
    FOR i = 1 TO LEN(Result) STEP 2
      RawStr += CHR(VALINT("&H" + MID(Result, i, 2)))
    NEXT i
    SHA256 = RawStr
  ELSE
    SHA256 = LCASE(Result)
  END IF
END FUNCTION
