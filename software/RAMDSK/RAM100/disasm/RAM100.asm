; RAM100.CO disassembly
; Initial disassembly: z88dk-dis -m8085 -k 0x06 -o 0xF076 RAM100.CO >RAM100.asm
; Compile: z88dk-z80asm -v -m8085 -b -o=RAM100.CO RAM100.asm
;
; Currently compiles to reproduce the original binary exactly.
;
; z88dk-dis outputs z80 mnemonics but this is actually 8085 code including 8085-isms like "add b".
;
; Syntax highlighting for Geany:
; https://github.com/bkw777/WP-2_IC-Card/blob/master/SOFTWARE/z88dk/_usr_share_geany_filedefs_filetypes.Z80asm.conf
;
; Brian K. White - b.kenyon.w@gmail.com

; See RAMDSK.TIP for function call addresses, though they all seem to be wrong.
; Maybe the doc was correct for an earlier version of RAM100 from before
; it was updated to add support for banks/512K?
;FREE	61896 = 0xF1C8
;KILL	61942 = 0xF1F6
;NAME	61998 = 0xF22E
;SAVE	62055 = 0xF267
;SAVE1	62061 = 0xF26D
;LOAD	62300 = 0xF35C
;
; We do have the old version of RAM200, so maybe see if the addresses for 200 match up in the old version of RAM200,
; and then use that to recognize what the function entry points, to find the equivalents here.

; ascii
ETX			EQU		0x03
LF			EQU		0x0A
FF			EQU		0x0C
CR			EQU		0x0D
ESC 		EQU		0x1B
SPACE		EQU		0x20
;EOF			EQU		0x1A

; vt52/screen control sequences
MACRO clr_eol
	DB ESC,"K"
ENDM
MACRO cursor_address row,col
	DB ESC,"Y",row+31,col+31
ENDM
MACRO disable_automatic_scroll
	DB ESC,"V"
ENDM
MACRO cursor_normal
	DB ESC,"P"
ENDM
MACRO cursor_invisible
	DB ESC,"Q"
ENDM
MACRO enter_reverse_mode
	DB ESC,"p"
ENDM
MACRO exit_attribute_mode
	DB ESC,"q"
ENDM

; TRS-80 Model 100 Platform
; rst
RST_4		EQU		0x20		; write A to console, directed by LCDLPT
rPRTA		EQU		RST_4

; system rom routines
PRTSP		EQU		0x1E		; write space to console, directed by LCDLPT
UBLNAS		EQU		0x05F0		; update in-memory line addresses for the current BASIC program lines
PTILL0		EQU		0x11A2		; print null-terminated string at HL to screen
POPALL		EQU		0x14ED		; pop all registers
FILES		EQU		0x1F3A		; FILES statement
FINDFN		EQU		0x20AF		; Search dir for filename matching 0xFC93
PRTASC		EQU		0x39D4		; print 16bit value in HL as ascii
BEEP		EQU		0x4229		; make a beep sound
ESCB		EQU		0x446E		; ESC+B - move cursor down one line
INLIN		EQU		0x4644		; input line
CKFN		EQU		0x4C0B		; format filename and check validity
GETEOF		EQU		0x6B2D		; search for EOF (0x1A)
KYREAD		EQU		0x7242		; read keyboard
MENU		EQU		0x5797		; go to main menu

MACRO PrintByte
	rst rPRTA
ENDM
MACRO PrintByteN n
	ld		a,n
	PrintByte
ENDM
MACRO PrintSpace
	call PRTSP
ENDM

; addresses
ETRAP		EQU		0xF652		; error trap? status?
C_ROW		EQU		0xF639		; cursor row (1-8) [poking changes cursor position]
LCDLPT		EQU		0xF675		; console output to LCD(0) or LPT(1)
FNAME		EQU		0xFC93		; 8 bytes padded fname, prog name if not run from menu nor typed on select line
KC7			EQU		0xFF97		; keyboard column 7 / PA6 status bits 0-7: SPACE,DEL,TAB,ESC,PASTE,LABEL,PRINT,ENTER

; RAMPAC IO Ports
PORT_CTL0			EQU		0x81	; control port for bank 0
PORT_DATA			EQU		0x83	; data read/write port
BANK_CTL_OFFSET		EQU		0x04	; bank n ctl port is ctl0 + n*4

MACRO SelectBank n
	xor		a
	out		(PORT_CTL0+(n*BANK_CTL_OFFSET)),a		; write 0 to the bank n control port
ENDM

MACRO ReadData
	in		a,(PORT_DATA)			; read one byte from the data port
ENDM

MACRO WriteData
	out		(PORT_DATA),a			; write A to the data port
ENDM

MACRO WriteDataN n
	ld		a,n
	WriteData			; write n to the data port
ENDM


; *****************************************************************************
; Here is where we can update to support more than 2 banks (hopefully)
; Replace toggle 0/1 with a 0-N counter
; instead of bank^1 ; port^BANK_CTL_OFFSET
; do bank=(bank+1)%NUMBER_OF_BANKS ; port=PORT_CTL0+bank*BANK_CTL_OFFSET
;
; Toggle the bank control port and bank# screen display between bank 0 / bank 1
; This only updates local variables, does not touch the RAMPAC hardware.
addrCtlPort		EQU		SelectBlock+1		; addr holding ctl port number, port number parameter of SelectBlock:
MACRO ToggleTargetBankNumber
	ld		a,(addrCtlPort)					;[f5da] 3a ec f5	; read bank control port number (0x81/0x85) from SelectBlock portnumber parameter
	xor		BANK_CTL_OFFSET					;[f5dd] ee 04		; toggle bit 2 (toggle control port between 0x81 & 0x85)
	ld		(addrCtlPort),a					;[f5df] 32 ec f5	; write new control port number to SelectBlock portnumber parameter
	ld		a,(BankNumMSG)					;[f5e2] 3a ee f4	; read bank number (0/1) from BankNumMSG (part of TitleMSG)
	xor		0x01							;[f5e5] ee 01		; toggle bit 0 to switch display bank number between 0/1
	ld		(BankNumMSG),a					;[f5e7] 32 ee f4	; write new bank number to BankNumMSG
ENDM

;------------------------------------------------------------------------------
HIMEM		EQU		0xF5EE		; TRS-80 Model 100/102 with 32K installed
PRGLEN		EQU		0x578		; FIXME how can we get this without hard coding?
ORG HIMEM-PRGLEN-6				; entry minus length of header

; variables that only exist as raw locations to the parameter to some instruction
; ie self-modifying code
addrSP		EQU		Set_SP+1	; $f085
addr002		EQU		j05+1		; $f14b
addr003		EQU		j34@l0+1	; $f100
addr004		EQU		j16@l0+1	; $f285
addr005		EQU		j27@l0+1	; $f371
addr006		EQU		j41@l0+1	; $f3db
addr007		EQU		j19@l0+1	; $f2c7

;==============================================================================

; .CO Header
DW PRGTOP	; top
DW PRGLEN	; len
DW PRGEXE	; exe

PRGTOP:
PRGEXE:
	ld		de,sp+0x00				;[f076] 38 00		; save initial SP
	ex		de,hl					;[f078] eb
	ld		(addrSP),hl				;[f079] 22 85 f0	; write initial SP to addrSP
	ld		a,(KC7)					;[f07c] 3a 97 ff	; get status bits of keyboard matrix column 7
	cp		0x80					;[f07f] fe 80		; is ENTER pressed?
	call	z,BANK					;[f081] cc bf f5	; if ENTER is pressed, switch banks ?
Set_SP:
	ld		sp,0x0000				;[f084] 31 00 00	; set SP from addrSP, 0x0000 is just initial value gets overwritten
	ld		hl,Set_SP				;[f087] 21 84 f0
	push	hl						;[f08a] e5
	ld		(ETRAP),hl				;[f08b] 22 52 f6
	ld		hl,FNAME				;[f08e] 21 93 fc
	ld		(hl),SPACE				;[f091] 36 20		; write a space to the 1st byte of fname buffer
	call	DrawTitle				;[f093] cd 5a f1
	xor		a						;[f096] af
	ld		(addr002),a				;[f097] 32 4b f1
	ld		d,0x80					;[f09a] 16 80
	call	j01						;[f09c] cd e1 f0
	ld		d,0xA0					;[f09f] 16 a0
	call	j01						;[f0a1] cd e1 f0
	ld		d,0xC0					;[f0a4] 16 c0
	call	j01						;[f0a6] cd e1 f0
j31:
	call	j06						;[f0a9] cd 60 f1

; Fkeys
; Bank Load Save Name Kill ---- ---- Menu
; F1   F2   F3   F4   F5   F6   F7   F8

ReadKeyboard:
	call	KYREAD					;[f0ac] cd 42 72	; look for keypress
	jp		z,ReadKeyboard			;[f0af] ca ac f0	; if no key then loop
	jp		nc,@end					;[f0b2] d2 db f0	; if not Fkey then skip to @end
	ld		hl,Set_SP				;[f0b5] 21 84 f0
	push	hl						;[f0b8] e5
	cp		0xFF					;[f0b9] fe ff
	jp		z,SAVE1					;[f0bb] ca 07 f2	; save file without displaying file list
	and		a						;[f0be] a7
	jp		z,BANK					;[f0bf] ca bf f5
	dec		a						;[f0c2] 3d
	jp		z,LOAD					;[f0c3] ca fb f2
	dec		a						;[f0c6] 3d
	jp		z,SAVE					;[f0c7] ca 01 f2
	dec		a						;[f0ca] 3d
	jp		z,NAME					;[f0cb] ca c7 f1
	dec		a						;[f0ce] 3d
	jp		z,KILL					;[f0cf] ca 8f f1
	sub		3						;[f0d2] d6 03
	jp		z,MENU					;[f0d4] ca 97 57
	pop		hl						;[f0d7] e1
	jp		ReadKeyboard			;[f0d8] c3 ac f0
@end:
	cp		CR						;[f0db] fe 0d		; is it CR?
	ret		z						;[f0dd] c8			; return if CR
	jp		ReadKeyboard			;[f0de] c3 ac f0	; loop if not CR

j01:
	ld		c,1						;[f0e1] 0e 01		; C=1 means SkipCWords will skip 2 bytes later
	call	CheckIsBankFormatted	;[f0e3] cd 37 f4
j33:
	call	ReadWordBA				;[f0e6] cd 4d f4	; read 2 bytes into B & A
	ld		a,b						;[f0e9] 78
	cp		d						;[f0ea] ba
	call	z,j02					;[f0eb] cc f3 f0
	inc		c						;[f0ee] 0c
	ret		z						;[f0ef] c8
	jp		j33						;[f0f0] c3 e6 f0

j02:
	push	de						;[f0f3] d5
	push	bc						;[f0f4] c5
	ld		a,c						;[f0f5] 79
	call	SelectBlock				;[f0f6] cd eb f5
	call	j03						;[f0f9] cd 35 f1
j34:
	ReadData						;[f0fc]
	PrintByte
@l0:
	ld		a,0x08					;[f0ff] 3e 08		; addr003, 0x08 just initial value gets overwritten
	and		a						;[f101] a7
	cp		0x03					;[f102] fe 03
	jp		nz,j39					;[f104] c2 0c f1
	push	af						;[f107] f5
	ld		a,'.'					;[f108] 3e 2e
	PrintByte
	pop		af						;[f10b] f1
j39:
	dec		a						;[f10c] 3d
	ld		(addr003),a				;[f10d] 32 00 f1
	jp		nz,j34					;[f110] c2 fc f0
	ld		a,0x08					;[f113] 3e 08
	ld		(addr003),a				;[f115] 32 00 f1
	push	bc						;[f118] c5
	ReadData
	ld		l,a						;[f11b] 6f
	ReadData
	ld		h,a						;[f11e] 67
	PrintSpace
	PrintSpace
	call	PRTASC					;[f125] cd d4 39
	call	j05						;[f128] cd 4a f1
	pop		bc						;[f12b] c1
	call	CheckIsBankFormatted	;[f12c] cd 37 f4
	call	SkipCWords				;[f12f] cd 45 f4
	pop		bc						;[f132] c1
	pop		de						;[f133] d1
	ret								;[f134] c9

j03:
	ld		hl,(C_ROW)				;[f135] 2a 39 f6	; read cursor position row 1-8
	ld		a,(addr002)				;[f138] 3a 4b f1
	and		0x01					;[f13b] e6 01
	jp		nz,j04					;[f13d] c2 45 f1
	ld		h,0x04					;[f140] 26 04
	jp		ESCB+8					;[f142] c3 76 44	; jump into the middle of the system rom ESC+B routine

j04:
	ld		h,0x18					;[f145] 26 18
	jp		ESCB+9					;[f147] c3 77 44	; jump into the middle of the system rom ESC+B routine

j05:
	ld		a,0x00					;[f14a] 3e 00		; read addr002
	inc		a						;[f14c] 3c			; increment
	ld		(addr002),a				;[f14d] 32 4b f1	; write addr002
	cp		10						;[f150] fe 0a		; is it 10?
	ret		nz						;[f152] c0			; return if not 10
	xor		a						;[f153] af			; if 10,
	ld	(addr002),a					;[f154] 32 4b f1	; write 0 to addr002
	call	j31						;[f157] cd a9 f0
DrawTitle:
	ld		hl,TitleMSG				;[f15a] 21 cf f4
	jp		PTILL0					;[f15d] c3 a2 11	; print TitleMSG to screen

j06:
	push	hl						;[f160] e5
	push	de						;[f161] d5
	push	bc						;[f162] c5
	push	af						;[f163] f5
	xor		a						;[f164] af
	ld		d,a						;[f165] 57
	ld		h,a						;[f166] 67
	ld		l,a						;[f167] 6f
	call	SelectBlock				;[f168] cd eb f5
@l0:
	call	ReadWordBA				;[f16b] cd 4d f4
	or		b						;[f16e] b0
	jp		nz,@l1					;[f16f] c2 73 f1
	inc		hl						;[f172] 23
@l1:
	dec		d						;[f173] 15
	jp		nz,@l0					;[f174] c2 6b f1
	push	hl						;[f177] e5
	ld		hl,Cursor_7_25			;[f178] 21 7c f5
	call	PTILL0					;[f17b] cd a2 11
	pop		hl						;[f17e] e1
	ld		a,l						;[f17f] 7d
	ld		(addr004),a				;[f180] 32 85 f2
	call	PRTASC					;[f183] cd d4 39
	call	CheckIsBankFormatted	;[f186] cd 37 f4
	call	SkipCWords				;[f189] cd 45 f4
	jp		POPALL					;[f18c] c3 ed 14

KILL:
	ld		hl,KillMSG				;[f18f] 21 3f f5
	call	j30						;[f192] cd a8 f3
	jp		nz,BEEP					;[f195] c2 29 42
	ld		hl,SureMSG				;[f198] 21 9d f5
	call	GetYes					;[f19b] cd 53 f4
	ret		nz						;[f19e] c0
@l0:
	call	CheckIsBankFormatted	;[f19f] cd 37 f4
	ld		a,(BlockNum)			;[f1a2] 3a ba f5
	dec		a						;[f1a5] 3d
	jp		z,@l1					;[f1a6] ca ad f1
	ld		c,a						;[f1a9] 4f
	call	SkipCWords				;[f1aa] cd 45 f4
@l1:
	xor		a						;[f1ad] af
	WriteData
	WriteData
	ld		a,(VAR_D)				;[f1b2] 3a bd f5
	and		a						;[f1b5] a7
	ret		z						;[f1b6] c8
	ld		(BlockNum),a			;[f1b7] 32 ba f5
	ld		c,a						;[f1ba] 4f
	call	CheckIsBankFormatted	;[f1bb] cd 37 f4
	call	SkipCWords				;[f1be] cd 45 f4
	ld		(VAR_D),a				;[f1c1] 32 bd f5
	jp		@l0						;[f1c4] c3 9f f1

NAME:
	ld		hl,NameMSG				;[f1c7] 21 5d f5
	call	j30						;[f1ca] cd a8 f3
	jp		nz,BEEP					;[f1cd] c2 29 42
	call	j40						;[f1d0] cd 5f f4
	ld		a,(BlockNum)			;[f1d3] 3a ba f5
	ld		b,a						;[f1d6] 47
	push	bc						;[f1d7] c5
	call	j41						;[f1d8] cd ab f3
	pop		bc						;[f1db] c1
	jp		z,BEEP					;[f1dc] ca 29 42
	ld		a,b						;[f1df] 78
	call	SelectBlock				;[f1e0] cd eb f5
	ld		hl,FNAME				;[f1e3] 21 93 fc
	ld		b,6						;[f1e6] 06 06
@l0:
	ld		a,(hl)					;[f1e8] 7e
	WriteData
	inc		hl						;[f1eb] 23
	dec		b						;[f1ec] 05
	jp		nz,@l0					;[f1ed] c2 e8 f1
	ret								;[f1f0] c9

ConfirmReplace:
	ld		hl,ReplaceMSG			;[f1f1] 21 6f f5
	call	GetYes					;[f1f4] cd 53 f4
	jp		nz,Set_SP				;[f1f7] c2 84 f0
	ret								;[f1fa] c9

ConfirmReplaceKill:
	call	ConfirmReplace			;[f1fb] cd f1 f1
	jp		KILL@l0					;[f1fe] c3 9f f1

SAVE:
	PrintByteN FF					;[f201]				; clear the screen
	call	FILES					;[f204] cd 3a 1f	; BASIC FILES statement
SAVE1:
	ld		hl,SaveMSG				;[f207] 21 53 f5
	call	InputFileNameWithPrompt	;[f20a] cd 8d f3
	call	FINDFN					;[f20d] cd af 20
	jp		z,BEEP					;[f210] ca 29 42
	push	hl						;[f213] e5
	call	j42						;[f214] cd 0d f4
	call	j40						;[f217] cd 5f f4
	call	j41						;[f21a] cd ab f3
	call	z,ConfirmReplaceKill	;[f21d] cc fb f1
	call	j06						;[f220] cd 60 f1
	pop		hl						;[f223] e1
	inc		hl						;[f224] 23
	ex		de,hl					;[f225] eb
	ld		hl,(de)					;[f226] ed
	ld		(addr005),hl			;[f227] 22 71 f3
	call	j11						;[f22a] cd 3b f2
	inc		hl						;[f22d] 23
	call	j14						;[f22e] cd 5e f2
	call	SAVE2					;[f231] cd 67 f2
	call	j17						;[f234] cd 8b f2
	call	j20						;[f237] cd ce f2
	ret								;[f23a] c9

j11:
	ld		a,(addr006)				;[f23b] 3a db f3
	cp		0x80					;[f23e] fe 80
	jp		z,j13					;[f240] ca 57 f2
	cp		0xC0					;[f243] fe c0
	jp		z,j12					;[f245] ca 50 f2
	ld		de,hl+2					;[f248] 28 02
	ld		hl,(de)					;[f24a] ed
	ld		de,0x0005				;[f24b] 11 05 00
	add		hl,de					;[f24e] 19
	ret								;[f24f] c9

j12:
	push	hl						;[f250] e5
	call	GETEOF					;[f251] cd 2d 6b
	pop		bc						;[f254] c1
	sub		hl,bc					;[f255] 08
	ret								;[f256] c9

j13:
	push	hl						;[f257] e5
	call	UBLNAS+3				;[f258] cd f3 05	; jump into the middle of UBLNAS (update BASIC line number addresses)
	pop		bc						;[f25b] c1
	sub		hl,bc					;[f25c] 08
	ret								;[f25d] c9

j14:
	ld		(VAR_A),hl				;[f25e] 22 b8 f5
	ld		hl,FilenameMSG			;[f261] 21 b0 f5
	jp		j44						;[f264] c3 10 f4

SAVE2:
	ld		hl,(VAR_A)				;[f267] 2a b8 f5
	ld		d,0x01					;[f26a] 16 01
	ld		bc,1014					;[f26c] 01 f6 03	; is it block size minus 10 bytes?
	jp		j15@l0					;[f26f] c3 75 f2

j15:
	ld		bc,1024					;[f272] 01 00 04	; one full block size
@l0:
	sub		hl,bc					;[f275] 08
	jp		z,j16					;[f276] ca 80 f2
	jp		m,j16					;[f279] fa 80 f2
	inc		d						;[f27c] 14
	jp		j15						;[f27d] c3 72 f2

j16:
	ld		a,d						;[f280] 7a
	ld		(VAR_E),a				;[f281] 32 be f5
@l0:
	ld		a,0x00					;[f284] 3e 00		; addr004
	cp		d						;[f286] ba
	jp		c,Beep					;[f287] da 5e f3
	ret								;[f28a] c9

j17:
	call	CheckIsBankFormatted	;[f28b] cd 37 f4
	ld		c,0x00					;[f28e] 0e 00
@l0:
	call	ReadWordBA				;[f290] cd 4d f4
	inc		c						;[f293] 0c
	or		b						;[f294] b0
	jp		nz,@l0					;[f295] c2 90 f2
	xor		a						;[f298] af
	call	SelectBlock				;[f299] cd eb f5
	ld		a,c						;[f29c] 79
	ld		(BlockNum),a			;[f29d] 32 ba f5
	call	SkipCWords				;[f2a0] cd 45 f4
	call	j18						;[f2a3] cd af f2
	ld		a,(BlockNum)			;[f2a6] 3a ba f5
	ld		(addr007),a				;[f2a9] 32 c7 f2
	jp		j17						;[f2ac] c3 8b f2

j18:
                    ld        a,(VAR_E)                     ;[f2af] 3a be f5
                    dec       a                             ;[f2b2] 3d
                    ld        (VAR_E),a                     ;[f2b3] 32 be f5
                    jp        z,$f2c0                       ;[f2b6] ca c0 f2
                    ld        a,$20                         ;[f2b9] 3e 20
                    out       (PORT_DATA),a                       ;[f2bb] d3 83
                    jp        $f2c6                         ;[f2bd] c3 c6 f2

j19:
                    pop       af                            ;[f2c0] f1
                    ld        a,(addr006)                     ;[f2c1] 3a db f3
                    out       (PORT_DATA),a                       ;[f2c4] d3 83
@l0:
                    ld        a,$00                         ;[f2c6] 3e 00	; addr007
                    ld        (VAR_D),a                     ;[f2c8] 32 bd f5
                    out       (PORT_DATA),a                       ;[f2cb] d3 83
                    ret                                     ;[f2cd] c9

j20:
                    ld        a,(BlockNum)                     ;[f2ce] 3a ba f5
                    call      SelectBlock                         ;[f2d1] cd eb f5
                    ld        hl,FilenameMSG                      ;[f2d4] 21 b0 f5
                    ld        b,10                         ;[f2d7] 06 0a
                    ld        a,(hl)                        ;[f2d9] 7e
                    out       (PORT_DATA),a                       ;[f2da] d3 83
                    inc       hl                            ;[f2dc] 23
                    dec       b                             ;[f2dd] 05
                    jp        nz,$f2d9                      ;[f2de] c2 d9 f2
                    ld        a,$d3                         ;[f2e1] 3e d3
                    jp        $f364                         ;[f2e3] c3 64 f3

j21:
                    push      hl                            ;[f2e6] e5
                    call      ConfirmReplace                         ;[f2e7] cd f1 f1
                    pop       hl                            ;[f2ea] e1
                    call      $20cc                         ;[f2eb] cd cc 20
                    cp        $c0                           ;[f2ee] fe c0
                    jp        z,$1fbf                       ;[f2f0] ca bf 1f
                    cp        $a0                           ;[f2f3] fe a0
                    jp        z,$1fd9                       ;[f2f5] ca d9 1f
                    jp        $2017                         ;[f2f8] c3 17 20

LOAD:
                    ld        hl,LoadMSG                      ;[f2fb] 21 49 f5
                    call      j30                         ;[f2fe] cd a8 f3
                    jp        nz,BEEP                      ;[f301] c2 29 42
                    call      j40                         ;[f304] cd 5f f4
                    call      FINDFN                         ;[f307] cd af 20
                    call      nz,$f2e6                      ;[f30a] c4 e6 f2
                    call      $f324                         ;[f30d] cd 24 f3
                    ld        (addr005),hl                    ;[f310] 22 71 f3
                    ex        de,hl                         ;[f313] eb
                    dec       de                            ;[f314] 1b
                    call      $20ec                         ;[f315] cd ec 20
                    ld        a,(addr006)                     ;[f318] 3a db f3
                    call      $2239                         ;[f31b] cd 39 22
                    call      $f362                         ;[f31e] cd 62 f3
                    jp        $2146                         ;[f321] c3 46 21

j23:
                    ld        hl,(VAR_A)                    ;[f324] 2a b8 f5
                    ld        b,h                           ;[f327] 44
                    ld        c,l                           ;[f328] 4d
                    ld        a,(addr006)                     ;[f329] 3a db f3
                    cp        $c0                           ;[f32c] fe c0
                    jp        z,$f345                       ;[f32e] ca 45 f3
                    cp        $80                           ;[f331] fe 80
                    jp        z,$f34f                       ;[f333] ca 4f f3
                    ld        hl,($fbb0)                    ;[f336] 2a b0 fb
                    push      hl                            ;[f339] e5
                    call      $6b6d                         ;[f33a] cd 6d 6b
                    pop       hl                            ;[f33d] e1
                    ld        ($fbb0),hl                    ;[f33e] 22 b0 fb
                    jp        c,Beep                       ;[f341] da 5e f3
                    ret                                     ;[f344] c9

j24:
                    ld        hl,($fbae)                    ;[f345] 2a ae fb
                    call      $6b6d                         ;[f348] cd 6d 6b
                    jp        c,Beep                       ;[f34b] da 5e f3
                    ret                                     ;[f34e] c9

j25:
                    ld        hl,($f99a)                    ;[f34f] 2a 9a f9
                    call      $6b6d                         ;[f352] cd 6d 6b
                    jp        c,Beep                       ;[f355] da 5e f3
                    push      hl                            ;[f358] e5
                    call      $213e                         ;[f359] cd 3e 21
                    pop       hl                            ;[f35c] e1
                    ret                                     ;[f35d] c9

Beep:
                    pop       af                            ;[f35e] f1
                    jp        BEEP                         ;[f35f] c3 29 42

j27:
                    ld        a,$db                         ;[f362] 3e db
                    ld        ($f374),a                     ;[f364] 32 74 f3
                    ld        hl,$03f6                      ;[f367] 21 f6 03
                    ld        (VAR_C),hl                    ;[f36a] 22 bb f5
                    ld        hl,(VAR_A)                    ;[f36d] 2a b8 f5
@l0:
                    ld        de,$0000                      ;[f370] 11 00 00	; addr005
                    ld        a,(de)                        ;[f373] 1a
                    in        a,(PORT_DATA)                       ;[f374] db 83
                    ld        (de),a                        ;[f376] 12
                    inc       de                            ;[f377] 13
                    dec       hl                            ;[f378] 2b
                    ld        a,h                           ;[f379] 7c
                    or        l                             ;[f37a] b5
                    ret       z                             ;[f37b] c8
                    push      hl                            ;[f37c] e5
                    ld        hl,(VAR_C)                    ;[f37d] 2a bb f5
                    dec       hl                            ;[f380] 2b
                    ld        a,l                           ;[f381] 7d
                    or        h                             ;[f382] b4
                    call      z,$f418                       ;[f383] cc 18 f4
                    ld        (VAR_C),hl                    ;[f386] 22 bb f5
                    pop       hl                            ;[f389] e1
                    jp        $f373                         ;[f38a] c3 73 f3

InputFileNameWithPrompt:
	call		PTILL0						;[f38d] cd a2 11
	call		INLIN						;[f390] cd 44 46
	ret			c							;[f393] d8
	dec			b							;[f394] 05
	ret			z							;[f395] c8
	inc			hl							;[f396] 23
	ld			e,b							;[f397] 58
	jp			CKFN						;[f398] c3 0b 4c

j29:
                    ld        hl,$fca2                      ;[f39b] 21 a2 fc
                    ld        de,$fc99                      ;[f39e] 11 99 fc
                    ld        a,(hl)                        ;[f3a1] 7e
                    ld        (de),a                        ;[f3a2] 12
                    inc       hl                            ;[f3a3] 23
                    inc       de                            ;[f3a4] 13
                    ld        a,(hl)                        ;[f3a5] 7e
                    ld        (de),a                        ;[f3a6] 12
                    ret                                     ;[f3a7] c9

j30:
                    call      InputFileNameWithPrompt                         ;[f3a8] cd 8d f3
j41:
                    xor       a                             ;[f3ab] af
                    ld        (BlockNum),a                     ;[f3ac] 32 ba f5
                    ld        (addr007),a                     ;[f3af] 32 c7 f2
                    ld        a,($fc99)                     ;[f3b2] 3a 99 fc
                    sub       $42                           ;[f3b5] d6 42
                    cp        $03                           ;[f3b7] fe 03
                    jp        nc,$2ab5                      ;[f3b9] d2 b5 2a
                    add       a                             ;[f3bc] 87
                    add       a                             ;[f3bd] 87
                    add       a                             ;[f3be] 87
                    add       a                             ;[f3bf] 87
                    add       a                             ;[f3c0] 87
                    add       $80                           ;[f3c1] c6 80
                    ld        (addr006),a                     ;[f3c3] 32 db f3
                    call      CheckIsBankFormatted                         ;[f3c6] cd 37 f4
                    call      ReadWordBA                         ;[f3c9] cd 4d f4
                    ld        (VAR_D),a                     ;[f3cc] 32 bd f5
                    ld        a,(BlockNum)                     ;[f3cf] 3a ba f5
                    inc       a                             ;[f3d2] 3c
                    jp        z,$2ab5                       ;[f3d3] ca b5 2a
                    ld        (BlockNum),a                     ;[f3d6] 32 ba f5
                    ld        a,b                           ;[f3d9] 78
@l0:
                    cp        $3f                           ;[f3da] fe 3f
                    jp        nz,$f3c9                      ;[f3dc] c2 c9 f3
                    ld        a,(BlockNum)                     ;[f3df] 3a ba f5
                    call      SelectBlock                         ;[f3e2] cd eb f5
                    ld        b,10                         ;[f3e5] 06 0a				; read 10 bytes
                    ld        hl,FilenameMSG                      ;[f3e7] 21 b0 f5
                    in        a,(PORT_DATA)                       ;[f3ea] db 83
                    ld        (hl),a                        ;[f3ec] 77
                    inc       hl                            ;[f3ed] 23
                    dec       b                             ;[f3ee] 05
                    jp        nz,$f3ea                      ;[f3ef] c2 ea f3
                    ld        c,$08                         ;[f3f2] 0e 08
                    ld        hl,FilenameMSG                      ;[f3f4] 21 b0 f5
                    ld        de,FNAME                      ;[f3f7] 11 93 fc
                    call      $5a6d                         ;[f3fa] cd 6d 5a
                    jp        z,j42                       ;[f3fd] ca 0d f4
                    call      CheckIsBankFormatted                         ;[f400] cd 37 f4
                    ld        a,(BlockNum)                     ;[f403] 3a ba f5
                    ld        c,a                           ;[f406] 4f
                    call      SkipCWords                         ;[f407] cd 45 f4
                    jp        $f3c9                         ;[f40a] c3 c9 f3

j42:
                    ld        hl,$fc9c                      ;[f40d] 21 9c fc
j44:
                    ld        de,FNAME                      ;[f410] 11 93 fc
                    ld        b,$08                         ;[f413] 06 08
                    jp        $3469                         ;[f415] c3 69 34

j43:
                    ld        hl,$0400                      ;[f418] 21 00 04
                    ld        (VAR_C),hl                    ;[f41b] 22 bb f5
                    xor       a                             ;[f41e] af
                    call      SelectBlock                         ;[f41f] cd eb f5
                    ld        a,(VAR_D)                     ;[f422] 3a bd f5
                    ld        (BlockNum),a                     ;[f425] 32 ba f5
                    ld        c,a                           ;[f428] 4f
                    inc       c                             ;[f429] 0c
                    call      SkipCWords                         ;[f42a] cd 45 f4
                    ld        (VAR_D),a                     ;[f42d] 32 bd f5
                    ld        a,(BlockNum)                     ;[f430] 3a ba f5
                    call      SelectBlock                         ;[f433] cd eb f5
                    ret                                     ;[f436] c9

CheckIsBankFormatted:
                    xor       a                             ;[f437] af					; zero A
                    call      SelectBlock                         ;[f438] cd eb f5		; select block 0
                    call      ReadWordBA                         ;[f43b] cd 4d f4			; read bytes 0 & 1 into B & A
                    add       b                             ;[f43e] 80					; add B to A
                    cp        $44                           ;[f43f] fe 44               ; is the total 0x44?
                    jp        nz,$f468                      ;[f441] c2 68 f4
                    ret                                     ;[f444] c9

; Read-and-discard C*2 bytes, final read will be left in B & A
SkipCWords:
	call		ReadWordBA			;[f445] cd 4d f4	; read 2 bytes into B & A
	dec			c					;[f448] 0d			; decrement C
	jp			nz,SkipCWords		;[f449] c2 45 f4	; repeat until C=0 (discard previous read data)
	ret								;[f44c] c9

; Read 2 bytes into B & A
ReadWordBA:
	ReadData
	ld				b,a				;[f44f] 47			; copy A to B
	ReadData
	ret								;[f452] c9

GetYes:
                    call      PTILL0                         ;[f453] cd a2 11
                    call      $12cb                         ;[f456] cd cb 12
                    call      $0fe9                         ;[f459] cd e9 0f
                    cp        $59                           ;[f45c] fe 59
                    ret                                     ;[f45e] c9
j40:
                    ld        hl,AsMSG                      ;[f45f] 21 67 f5
                    call      InputFileNameWithPrompt                         ;[f462] cd 8d f3
                    jp        $f39b                         ;[f465] c3 9b f3
j35:
                    ld        hl,FormatMSG                      ;[f468] 21 81 f5
                    call      GetYes                         ;[f46b] cd 53 f4
                    jp        z,$f47d                       ;[f46e] ca 7d f4
                    ld        hl,FixMSG                      ;[f471] 21 a5 f5
                    call      GetYes                         ;[f474] cd 53 f4
                    jp        z,$f48d                       ;[f477] ca 8d f4
                    jp        MENU                         ;[f47a] c3 97 57
j36:
                    call      $f4a8                         ;[f47d] cd a8 f4
                    push      bc                            ;[f480] c5
                    xor       a                             ;[f481] af
                    call      SelectBlock                         ;[f482] cd eb f5
                    ld        b,a                           ;[f485] 47
                    call      $f49c                         ;[f486] cd 9c f4
                    pop       bc                            ;[f489] c1
                    call      $f49c                         ;[f48a] cd 9c f4
                    xor       a                             ;[f48d] af
                    call      SelectBlock                         ;[f48e] cd eb f5
                    ld        a,$40                         ;[f491] 3e 40
                    out       (PORT_DATA),a                       ;[f493] d3 83
                    ld        a,$04                         ;[f495] 3e 04
                    out       (PORT_DATA),a                       ;[f497] d3 83
                    jp        Set_SP                         ;[f499] c3 84 f0
j37:
                    ld        e,d                           ;[f49c] 5a
                    ld        a,b                           ;[f49d] 78
                    out       (PORT_DATA),a                       ;[f49e] d3 83
                    xor       a                             ;[f4a0] af
                    out       (PORT_DATA),a                       ;[f4a1] d3 83
                    dec       e                             ;[f4a3] 1d
                    jp        nz,$f49d                      ;[f4a4] c2 9d f4
                    ret                                     ;[f4a7] c9
j38:
                    ld        d,$80                         ;[f4a8] 16 80
                    ld        a,d                           ;[f4aa] 7a
                    call      SelectBlock                         ;[f4ab] cd eb f5
                    in        a,(PORT_DATA)                       ;[f4ae] db 83
                    ld        b,a                           ;[f4b0] 47
                    ld        a,d                           ;[f4b1] 7a
                    call      SelectBlock                         ;[f4b2] cd eb f5
                    ld        a,b                           ;[f4b5] 78
                    inc       a                             ;[f4b6] 3c
                    out       (PORT_DATA),a                       ;[f4b7] d3 83
                    ld        a,d                           ;[f4b9] 7a
                    call      SelectBlock                         ;[f4ba] cd eb f5
                    in        a,(PORT_DATA)                       ;[f4bd] db 83
                    ld        c,a                           ;[f4bf] 4f
                    ld        a,d                           ;[f4c0] 7a
                    call      SelectBlock                         ;[f4c1] cd eb f5
                    ld        a,b                           ;[f4c4] 78
                    out       (PORT_DATA),a                       ;[f4c5] d3 83
                    ld        a,c                           ;[f4c7] 79
                    cp        b                             ;[f4c8] b8
                    ld        b,$40                         ;[f4c9] 06 40
                    ret       z                             ;[f4cb] c8
                    xor       a                             ;[f4cc] af
                    ld        b,a                           ;[f4cd] 47
                    ret                                     ;[f4ce] c9


TitleMSG:
	DB FF
	cursor_invisible
	disable_automatic_scroll
	enter_reverse_mode
	DB "NODE RAMPAC/DATAPAC Bank"
BankNumMSG:
	DB "0"
	DB "   (c)P.Globman"
	exit_attribute_mode
	cursor_address 8,1
	DB "Bank Load Save Name Kill           Menu"
	cursor_address 7,29
	DB "Kbytes free"
	cursor_address 1,1
	DB 0

KillMSG:
	cursor_address 7,1
	DB "Kill:",0

LoadMSG:
	cursor_address 7,1
	DB "Load:",0

SaveMSG:
	cursor_address 7,1
	DB "Save:",0

NameMSG:
	cursor_address 7,1
	DB "Name:",0

AsMSG:
	DB "  as:"
	clr_eol
	DB 0

ReplaceMSG:
	cursor_address 8,19
	DB "Replace?",0

Cursor_7_25:
	cursor_address 7,25
	DB 0

FormatMSG:
	cursor_address 7,1
	DB "Format RAMdisk",LF,CR,"Are you "
SureMSG:
	DB "Sure?"
	clr_eol
	DB 0

FixMSG:
	cursor_address 8,1
	DB "Fix?"
	clr_eol
	DB 0

FilenameMSG:
	DB "filename"

VAR_A:
	DW 0

BlockNum:
	DB 0

VAR_C:
	DW 0

VAR_D:
	DB 0

VAR_E:
	DB 0

;------------------------------------------------------------------------------
; Code here after the strings & vars shows how the format mark fixer
; and the bank support was added later.

; I don't fully understand this
BANK:
	SelectBank 0
	WriteDataN 0x41										; write 0x41 to Bank0,Block0,byte0
	; blindly wrote to block0,byte0, hope you didn't have non-RAMDSK data there
	; maybe it's to detect if the hardware exists
	SelectBank 1
	ReadData											; read Bank1,Block0,Byte0
	; Note: if the hardware is 256k or smaller, no banks (original DATAPAC/RAMPAC)
	; then the Bank1 read will just read Bank0 again
	ld		b,a						;[f5cb] 47			; save (maybe)Bank1,Block0,Byte0 in B
	; - if the hardware has bank1:      then B contains whatever was in Bank1,Block0,Byte0 - COULD BE ANYTHING
	; - if the hardware has no bank1:   then B contains the 0x41 we blindly wrote to bank0
	; - if the hardware does not exist: then B probably contains 0x00 or 0xFF?
	SelectBank 0
	WriteDataN 0x40										; write 0x40 to Bank0,Block0,byte0
	; now we've blindly overwritten bank0,block0,byte0 previous 0x41 now 0x40
	inc		a						;[f5d3] 3c			; A++ -> A=0x41
	cp		b						;[f5d4] b8			; does B = 0x41 ?
	ret		z						;[f5d5] c8			; return if B = 0x41 (conclude the hardware does not have banks?)
	ld		a,b						;[f5d6] 78			; B & A didn't match, we have hardware with banks, copy B to A 
	cp		PORT_DATA				;[f5d7] fe 83		; ???  compare A to the data port number?                                 ???
	ret		z						;[f5d9] c8			; ???  return if match? is this maybe how we detect no hardware present?  ???

	ToggleTargetBankNumber
	; ToggleTargetBankNumber just updates variables, doesn't touch the hardware
	; fall through to SelectBlock to actually switch the hardware to the new bank

	xor		a						;[f5ea] af			; zero A to select block 0 in new bank

; Select block# in the current bank
; PORT_CTL0 is just the initial condition and gets overwritten at run time
SelectBlock:
	out		(PORT_CTL0),a			;[f5eb] d3 81		; write A to the control port
	ret								;[f5ed] c9
PRGEND:
