10000 KJ%=13:ES$=M$'Help system
10002 ONKJ%GOSUB10108,10110,10109,10111,10113,10112,10114,10116,10115,10117,10119,10118,10101,10125,10121,10120,10122,10123,10103,10104,10106,10126,10127,10102,10107,10124,10105
10004 I%=200:GOSUB70'show help msg
10006 IFI%THENELSE10002
10010 IFPEEK(-86)THENELSEI%=I%-1:GOTO10006
10020 J%=KJ%:GOSUB12'get keystroke
10022 IFKJ%THENELSEKJ%=J%:GOTO10010
10030 J%=PEEK(-94)AND3:IF(KJ%<15)OR(KJ%>20)THEN10070
10040 IFKJ%=15THENKJ%=14:GOTO10070
10050 IFKJ%=16THENKJ%=KJ%-J%MOD2:GOTO10070
10060 J%=J%\2:IFJ%THENELSE10070
10062 KJ%=(KJ%-17)\2+26
10070 IFKJ%=13THENELSE10002
10090 MS$=ES$:ES$="":GOSUB70:MS$=""
10099 RETURN
10100 'Help text, queue next
10101 MS$="Shut power down. Or you can use ESC to stop other commands   ESC":KJ%=24:RETURN
10102 MS$="Help is the command now in progress                        LABEL":KJ%=19:RETURN
10103 MS$="Bar to LPT: print whole Bar as one 64-character line       PRINT":KJ%=20:RETURN
10104 MS$="Map to LPT: print whole Map as seen on the screen     SHIFTPRINT":KJ%=27:RETURN
10105 MS$="Diagnostic Report print to LPT or to Bar if no LPT     CTRLPRINT":KJ%=21:RETURN
10106 MS$="FilesAll: Filename(bytes\1of)>cur to Bar; trace lines on Map  F1":KJ%=25:RETURN
10107 MS$="Menu exit                                                     F8":KJ%=1:RETURN
10108 MS$="Move cursor right                                              "+CHR$(154):KJ%=3:RETURN
10109 MS$="Trace Fwd:      Bar>cur Map line to next                  SHIFT"+CHR$(154):KJ%=2:RETURN
10110 MS$="Trace/Move Fwd: Bar>cur Map line to/Move cursor to next    CTRL"+CHR$(154):KJ%=4:RETURN
10111 MS$="Move cursor left                                               "+CHR$(155):KJ%=6:RETURN
10112 MS$="Trace Rev:      >curBar Map line to prior                 SHIFT"+CHR$(155):KJ%=5:RETURN
10113 MS$="Trace/Move Rev: >curBar Map line to/Move cursor to prior   CTRL"+CHR$(155):KJ%=7:RETURN
10114 MS$="Move cursor down                                               "+CHR$(153):KJ%=9:RETURN
10115 MS$="Trace Fwd Entire:       repeated SHIFT"+CHR$(154)+" until chain-end   SHIFT"+CHR$(153):KJ%=8:RETURN
10116 MS$="Trace/Move Fwd Entire:  repeated CTRL"+CHR$(154)+" until chain-end     CTLR"+CHR$(153):KJ%=10:RETURN
10117 MS$="Move cursor up                                                 "+CHR$(152):KJ%=12:RETURN
10118 MS$="Trace Rev Entire:       repeated SHIFT"+CHR$(155)+" until chain-top   SHIFT"+CHR$(152):KJ%=11:RETURN
10119 MS$="Trace/Move Rev Entire:  repeated CTRL"+CHR$(155)+" until chain-top     CTRL"+CHR$(152):KJ%=16:RETURN
10120 MS$="Clear Bar erases all of the 64 positions of the Bar        SPACE":KJ%=15:RETURN
10121 MS$="Clear Map removes trace lines and joint marks on Map  SHIFTSPACE":KJ%=17:RETURN
10122 MS$="FileInfo: for file type sectors Bar shows Filename(bytes\1of)  f":KJ%=18:RETURN
10123 MS$="Forced FileInfo:        like f but for all type of sectors     F":KJ%=26:RETURN
10124 MS$="Trace/Move Fwd:         exactly the same as CTRL"+CHR$(154)+"          CTRLf":KJ%=14:RETURN
10125 MS$="Joints: mark the Map so any joints show in reverse video  j or J":KJ%=22:RETURN
10126 MS$="View by ASCII a 64-byte content using ? for non ASCII content  v":KJ%=23:RETURN
10127 MS$="View by Hex-2 a 32-byte content shows two Hex digits per byte  V":KJ%=13:RETURN
64000 IFPEEK(72)THENPRINT"Wrong laptop":NEWELSEPRINT"Model 10"CHR$(48+PEEK(31009))" diagnostic of Rampac
64002 CLEAR512+382:SCREEN,0'382Joint&Way
64004 F$="":L$="":L!=0:M$="":KJ$=""'cnst Flags, Links, MsgWndw, KeyJump
64006 KJ%=0:CS%=0:MS$=""'var KeyJump, CsrStat, Msg
64008 RS%=0:RF%=0:RT%=0:HG%=0:JT%=0'var RefSec, RefFm, RefTo, HunG, JoinT
64010 I%=0:J%=0'var gen use
64012 CC%=0'var CharCode
64014 DIMVB%(1,31)'var view use
64016 DIMJ$(127)'Joint(0)&Way(1 up to 127)
64018 CP%=1:MI%=0'var CursorPosit, MoveIncrement
64020 MC%=0:EP%=0'var Rev/Fwd Trace controls
64022 DS$="":NV!=0:ND%=0'var DigitStr, NumerVal, NumofDigits
64024 DF%=0:UN%=0:AD%=0:HS%=0:RE%=0:CE%=0:NF%=0:FL%=0:FS%=0:FE%=0'var statistics
64026 I%=VARPTR(F$):POKEI%,255:POKEI%+2,65025/256:POKEI%+1,65025-256*PEEK(I%+2):RESTORE64060:GOSUB64058:IFCS%THENBEEP:PRINT"Bad checksum":END
64028 L!=VARPTR(#0)+9+2^16:I%=VARPTR(L$):POKEI%,255:POKEI%+2,(L!+1)/256:POKEI%+1,L!+1-256*PEEK(I%+2)'FilBfr#0 for Links
64030 I%=VARPTR(M$):POKEI%,64:POKEI%+2,65280/256:POKEI%+1,65280-256*PEEK(I%+2)'LCD256to319 for Message left-scroll
64032 E$=CHR$(27):OV$=E$+"q":RV$=E$+"p":SC$=E$+"P":HC$=E$+"Q"'Escape seuences: ObverseVideo, ReverseVideo, ShowCursor, HideCursor
64034 RESTORE64034:FORI%=1TO25:READJ%:KJ$=KJ$+CHR$(J%):NEXT:DATA28,18,6,29,17,1,31,26,2,30,23,20,27,106,74,32,102,70,137,138,128,118,86,136,135:'KeyCode
64036 CT%=0:TF%=0:SN%=0:ES$=""'var
64038 ONERRORGOTO65256:GOSUB64800:CALL-162'Rampac dirctry: FLAGS>LCDbuf; LINKS>FilBfr#0
64040 FORI%=1TO255:J%=0:MS$="":PSET(I%MOD40+100,I%\40+56)'fill min-map except the Dir point
64042 J%=INSTR(J%+1,L$,CHR$(I%)):IFJ%THENELSE64048'none or no more Joints found
64044 IFJ%=I%THENELSEMS$=CHR$(J%)+MS$'ignore Hung else accumulate Ways in descend order
64046 IFJ%<255THEN64042'more may be found
64048 IFLEN(MS$)<2THEN64052'ignore no-Way and 1-Way accumulation
64050 J$(0)=J$(0)+CHR$(I%):J$(LEN(J$(0)))=MS$'build Joint record, attach Way record
64052 NEXT:MS$=""'release string space
64054 GOSUB64900:GOSUB64890:GOSUB29
64056 GOTO17
64058 READMS$:IFLEN(MS$)=0THENCS%=RS%ANDCS%:RETURNELSEIFSGN(VAL(MS$))=0THENGOSUB64060:GOTO64058ELSEND%=VAL(MS$):CS%=INSTR(MS$,"."):RS%=VAL(RIGHT$(MS$,SGN(CS%)*3)):CS%=255*SGN(CS%):RT%=0:I%=0:GOTO64058
64060 FORRF%=1TOLEN(MS$):I%=I%*2^6+ASC(MID$(MS$,RF%,1))-62:RT%=RT%+6:IFRT%>6THENRT%=RT%-8:J%=I%\2^RT%:I%=I%AND2^RT%-1:POKEND%,J%:ND%=ND%+1:RS%=(RS%+J%)MOD256:NEXT:RETURNELSENEXT:RETURN:DATA-162.150,iztBQ@^GFNA|i{L?Q{lA[{lAB`JQAJGi}zb,
64800 CLS'
64810 PRINT" 255-sector Map is here.  Symbols are:"
64811 PRINT"  a    alternate directory"
64812 PRINT"  bcd  one-sector file (.BA .CO .DO)"
64813 PRINT"  BCD  Many-sector files start"
64814 PRINT"  _    continuation (many-sector file)"
64815 PRINT"  ^r?  free, reserved, unknown"
64816 PRINT"  H    hung."
64817 MS$="64-position Bar is here. Mapping - wait"+SPACE$(25):GOSUB70
64820 LINE(0,8)-(6,8):LINE-(6,0):LINE-(239,0):LINE-(239,47):LINE-(95,47):LINE-(95,55):LINE-(0,55):LINE-(0,8):RETURN
64890 MS$="Rampac Diagnostic ver_0 June 1996 by Ron Wiesen.  LABEL for Help":GOSUB70:RETURN
64900 DF%=1:IFPEEK(-512)<>64THENERROR101'Sec0 bad dir format flag AJST DF RESUME
64902 DF%=DF%*1:IFPEEK(L!)<>4THENERROR102'Sec0 bad dir format link TST/AJST DF RESUME
64904 FORRS%=0TO255:RF%=PEEK(RS%-512):PRESET(RS%MOD40+100,RS%\40+56):IFRS%THENELSE64910'clear min-map
64906 IFNOT(RF%=0ORRF%=32ORRF%=64ORRF%=128ORRF%=160ORRF%=192)THENRF%=63:UN%=UN%+1:GOTO64912'?, UNknown
64908 IFRF%=64THENRF%=97:AD%=AD%+1'a, Alternate Directory
64910 RF%=(RF%AND224)/32+94'translate
64912 POKERS%-512,RF%:IFRS%THENELSE64936
64914 RT%=PEEK(L!+RS%):IFRT%THENELSE64928'bypass for any Next=0
64916 IF(RT%=RS%ANDRF%=63)THENUN%=UN%-1:HS%=HS%+1:RF%=72:ERROR103:GOTO64926:'UNknown is Hung
64918 IF(RT%=RS%)THENHS%=HS%+1:RF%=72:ERROR103:GOTO64926'Hung
64920 'gets here if not hung and chained
64922 IFRF%>95THENRF%=RF%-32'except FreE & ConT, indicate this is chained
64924 IF(RF%=94ANDRT%<>0)THENRE%=RE%+1:RF%=114'REserved
64926 POKERS%-512,RF%
64928 IF(RF%=95ANDRT%=0)THENCE%=CE%+1'_, Chain Ends should equal FL
64930 IF(RF%>65AND69>RF%)THENNF%=NF%+1:FL%=FL%+1'BCD, #Files, Files Large are chain tops
64932 IF(RF%>97AND101>RF%)THENNF%=NF%+1:FS%=FS%+1'bcd, #Files, Files Small
64934 IFRF%=94THENFE%=FE%+1'^,FreE
64936 NEXT:PRINT@0,OV$CHR$(PEEK(-512))F$;:RETURN'Format & Link check complete, show max-map
65100 ONERRMOD10GOTO65101,65102,65103,65104,65105,65106,65107,65108,65109:GOSUB65294:RESUMENEXT'
65101 DF%=0:ER$="Directory Flag":GOSUB65295:RESUMENEXT'
65102 DF%=0:ER$="Directory Link":GOSUB65295:RESUMENEXT'
65103 ER$="Hung sector":GOSUB65293:RESUMENEXT'
65104 PRINT"104":RESUMENEXT'
65105 PRINT"105":LIST.'
65106 PRINT"106":RESUMENEXT'
65107 PRINT"107":LIST.'
65108 PRINT"108":RESUMENEXT'
65109 PRINT"109":LIST.'
65110 PRINT"110-119":RESUMENEXT'
65120 PRINT"120-129":RESUMENEXT'
65130 PRINT"130-139":RESUMENEXT'
65140 PRINT"140-149":RESUMENEXT'
65150 PRINT"150-159":RESUMENEXT'
65160 PRINT"160-169":RESUMENEXT'
65170 PRINT"170-179":RESUMENEXT'
65180 PRINT"180-189":RESUMENEXT'
65190 PRINT"190-199":RESUMENEXT'
65200 'rsrv 65200-65255 for Errors 200-255
65256 'Error Handler routes Errors 1xx to lines 651xx
65260 ONERR\100GOTO65291:ONERRORGOTO'BASIC handles Errors 0xx & 200-255
65290 '
65291 ON(ERR-100)\10+1GOTO65100,65110,65120,65130,65140,65150,65160,65170,65180,65190
65292 '
65293 GOSUB65297:ER$=ES$:GOTO65297'[ER$] Flashes
65294 GOSUB65296:GOTO65298'Err###,BEEPs
65295 GOSUB65297:GOTO65298'[ER$],BEEPs
65296 ER$="Err"+MID$(STR$(ERR),2)
65297 ES$=SPACE$(LEN(ER$)):CS%=(PEEK(-2503)-1)*2+(PEEK(-2502)-1)*16+ABS(SGN(PEEK(-2498))):PRINT@320-LEN(ER$),E$"V"ER$E$"Y"CHR$((CS%\2AND7)+32)CHR$(CS%\16+32)E$CHR$(87-CS%MOD2);:RETURN'RowColScroll
65298 BEEP:IFINKEY$=""THEN65298ELSEER$=ES$:GOTO65297
65299 'end Error Handler
65300 'rsrv 65300-65529
