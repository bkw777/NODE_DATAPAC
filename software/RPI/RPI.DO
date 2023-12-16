0' Basic RAMPAC inspector
0' * Display raw data from anywhere on a DATAPAC / RAMPAC
0' * Supports both banks on 512k units
0' * Does not require any option rom or RAMDSK.CO
0' * Does not contain any machine code or call any
0' RAMPAC Inspector - 2023-12-15 Brian K. White
10 CLEAR:H$="0123456789ABCDEF":E$=CHR$(27):IV$=E$+"p":NV$=E$+"q":M%=0
20 ON ERROR GOTO 900
30 CLS:?"RAMPAC INSPECTOR":GOSUB 3000:GOSUB 3200
100 ?"? BANK,BLOCK,START,LENGTH":P%=9:B%=999:S%=9999:L%=9999:INPUT P%,B%,S%,L%
110 IF P% > 1 THEN 900
110 IF P% = 1 THEN P%=133 ELSE P%=129
120 IF B% > 255 THEN 900
130 IF S% > 1023 THEN 900
140 E%=S%+L%-1:IF E% > 1023 THEN 900
150 W%=1:OUT P%,B%:FOR I%=0TO1023:D%=INP(131)
160 IF I% < S% THEN NEXT
170 IF W% = 1 THEN ? USING "####";I%;:?": ";:KEY(2) STOP
180 ON M% GOSUB 1000,2000:W%=W%+1
190 IF W% > MW% THEN W%=1:?:KEY(2) ON
200 IF I% < E% THEN NEXT
500 ?:GOTO 100
900 ?:?"F8 or BREAK to exit":?"F2 - toggle hex/ascii":?"   0-1,0-255,0-1023,0-(1024-START)":GOTO 100
1000 ' hex
1010 D$=MID$(H$,(D%AND15)+1,1):IF D% = 0 THEN D%=1 ELSE D%=(D%/16AND15)+1
1020 D$=MID$(H$,D%,1)+D$:?D$;:RETURN
2000 ' ascii
2010 D$=CHR$(D%):IF D% < 32 THEN D$=IV$+CHR$(D%+64)+NV$
2020 IF D% = 127 THEN D$=IV$+"?"+NV$
2030 ?D$;:RETURN
3000 ' F-keys
3010 KEY OFF:SCREEN 0,0:ON KEY GOSUB ,3200,,,,,,3800
3020 KEY(2) ON:KEY(8) ON
3099 RETURN
3100 ' bank - reserved to match RAMDSK.CO
3199 RETURN
3200 ' hex/ascii
3210 IF M% = 1 THEN M%=2 ELSE M%=1
3220 IF M% = 1 THEN MW%=16 ELSE MW%=32
3299 RETURN
3300 '
3400 '
3500 '
3600 '
3700 '
3799 RETURN
3800 ' --- exit
3810 MENU
