0' Crude RAMPAC Inspector
0' It's crude but it exists for these reasons vs the other existing utils:
0' * Display raw data from anywhere on a DATAPAC / RAMPAC
0' * Supports both Bank0 and Bank1 on 512k units
0' * Runs on both Model 100 and 200
0' * Does not require the option rom or RAM100.CO or RAM200.CO
0' * Does not contain any machine code, nor call any
0' * For MiniNDP 1M edit line 10 NN%=3
0' Crude RAMPAC Inspector - 2024-11-18 Brian K. White
10 CLEAR:NN%=1 ' highest Bank# (0-3)
20 H$="0123456789ABCDEF":E$=CHR$(27):IV$=E$+"p":NV$=E$+"q":DIM P%(3):P%(0)=129:P%(1)=133:P%(2)=137:P%(3)=141
30 ON ERROR GOTO 4000
100 CLS:?"CRUDE RAMPAC INSPECTOR":GOSUB 3000:M%=0:GOSUB 3200         
110 ?:?"F2-toggle hex/ascii   F8-Exit":?"   0-"+MID$(H$,NN%+1,1)+",0-255,0-1023,1-(1024-START)"
120 ?"? BANK,BLOCK,START,LENGTH":N%=-1:B%=-1:S%=-1:L%=-1:INPUT N%,B%,S%,L%
130 IF N% < 0 OR N% > NN% OR B% < 0 OR B% > 255 OR S% < 0 OR S% > 1023 THEN 100
140 E%=S%+L%-1:IF E% < 0 OR E% > 1023 THEN 100
200 OUT P%(N%),B%:IF S%>0 THEN FOR I%=0TOS%:D%=INP(131):NEXT
210 I%=-1:GOSUB 600:FOR I%=S%TOE%:D%=INP(131)
220 ON M% GOSUB 1000,2000:C%=C%+1:IF C% > W% THEN GOSUB 600
300 NEXT
500 ?:GOTO 120
600 KEY(2) ON:IF I% >= E% THEN RETURN ELSE C%=1:?:? USING "####";I%+1;:?": ";:KEY(2) STOP:RETURN
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
3220 IF M% = 1 THEN W%=16 ELSE W%=32
3299 RETURN
3300 '
3400 '
3500 '
3600 '
3700 '
3799 RETURN
3800 ' exit
3810 MENU
4000 RESUME 100
