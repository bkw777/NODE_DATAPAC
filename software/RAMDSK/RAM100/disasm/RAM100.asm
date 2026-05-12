; RAM100.CO disassembly
; RAMDSK.CO is originally written by Paul Globman
; (modulo reverse engineering the NODE ROM)
;
; This source reproduces the original binary exactly, but is not the original
; source. It started as a crude disassembly, then edited into usable source.
;
; Initial disassembly: z88dk-dis -m8085 -k 0x06 -o 0xF076 RAM100.CO >RAM100.asm
; Compile: z88dk-z80asm -v -m8085 -b -o=RAM100.CO RAM100.asm
;
; Currently compiles to reproduce the original binary exactly.
; make clean all && cmp -l ../RAM100.CO RAM100.CO && echo OK || echo '>>> FAIL <<<'
;
; original binaries:
; https://www.club100.org/library/libpg.html -> "pgnode"
; https://ftp.whtech.com/club100/pg/pgnode/node1/ram100.co		RAM100.CO
; https://ftp.whtech.com/club100/pg/pgnode/node2/ramdsk.co		RAM200.CO
;
; z88dk-dis outputs z80 mnemonics but this is actually 8085 code.
; The original binary includes 8085-isms like "add b",
; and the cpu is 80C85 so you must not try to use z80 features.
;
; Syntax highlighting for Geany:
; https://github.com/bkw777/WP-2_IC-Card/blob/master/SOFTWARE/z88dk/_usr_share_geany_filedefs_filetypes.Z80asm.conf
;
; Brian K. White - b.kenyon.w@gmail.com

; RAMDSK.TIP documents some externally usable function call addresses,
; but they do not appear to be correct for this version of RAMDSK.
; Presumably it was correct before RAMDSK was updated to support banks?
;FREE	61896 = 0xF1C8
;KILL	61942 = 0xF1F6
;NAME	61998 = 0xF22E
;SAVE	62055 = 0xF267
;SAVE1	62061 = 0xF26D
;LOAD	62300 = 0xF35C
;
; We don't have the old version of RAM100 to check, but we do have both old and new versions of RAM200.
; So maybe see if the addresses for 200 match up in the old version of RAM200,
; and then use that to recognize the entry points by the code, to find the equivalents here.

; ascii
ETX			EQU		0x03
LF			EQU		0x0A
FF			EQU		0x0C
CR			EQU		0x0D
ESC 		EQU		0x1B
SPACE		EQU		0x20
;EOF			EQU		0x1A

;------------------------------------------------------------------------------
; TRS-80 Model 100 Platform
;------------------------------------------------------------------------------

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

; rst
RST_4		EQU		0x20		; write A to console, directed by LCDLPT
rPRTA		EQU		RST_4

; system rom routines
PRTSP		EQU		0x1E		; write space to console, directed by LCDLPT
UBLNAS		EQU		0x05F0		; update in-memory line addresses for the current BASIC program lines
LC2UCA		EQU		0x0FE9		; convert the character in A to uppercase
PTILL0		EQU		0x11A2		; print null-terminated string at HL to screen
CHGET		EQU		0x12CB		; wait for a key from the keyboard
POPALL		EQU		0x14ED		; pop all registers
FILES		EQU		0x1F3A		; FILES statement
KILLDO		EQU		0x1FBF		; kill a .DO file
KILLDO1		EQU		0x1FD9		; 2nd section in KILLDO
KILLDO4		EQU		0x2017		; 5th section in KILLDO
FINDFN		EQU		0x20AF		; search dir for filename matching 0xFC93
FINDFN1		EQU		0x20CC		; almost the the end of FINDFN
MYSTERY_20EC	EQU		0x20EC		; unknown
UPDOFILES	EQU		0x213E		; update DOFILES with BC
RESETFPS	EQU		0x2146		; reset file pointers
MKDIRENT	EQU		0x2239		; insert entry into directory
INSTR_2AB5	EQU		0x2AB5		; middle of INSTR function
D2H4Bup		EQU		0x3469		; move the memory pointed to by DE to the memory pointed to by HL
PRTASC		EQU		0x39D4		; print 16bit value in HL as ascii
BEEP		EQU		0x4229		; make a beep sound
ESCB		EQU		0x446E		; ESC+B - move cursor down one line
INLIN		EQU		0x4644		; input line
CKFN		EQU		0x4C0B		; format filename and check validity
CMPARE		EQU		0x5A6D		; compare the buffer pointed to by DE to the buffer pointed to by HL
GETEOF		EQU		0x6B2D		; search for EOF (0x1A)
MAKHOL		EQU		0x6B6D		; insert BC number of spaces in memory
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
UNSBA		EQU		0xF99A		; address of current BASIC program not saved
FNAME		EQU		0xFC93		; 8 bytes padded fname, prog name if not run from menu nor typed on select line
KC7			EQU		0xFF97		; keyboard column 7 / PA6 status bits 0-7: SPACE,DEL,TAB,ESC,PASTE,LABEL,PRINT,ENTER
DOFILES		EQU		0xFBAE		; pointer to start of DO files
COFILES		EQU		0xFBB0		; pointer to start of CO files
MYSTERY_FC99	EQU		0xFC99		; unknown
MYSTERY_FCA2	EQU		0xFCA2		; unknown
CFNAME		EQU		0xFC9C		; filename of last program loaded from tape

; constants
; file types, attribute byte A for MKDIRENT
FattrBA		EQU		0x80	; .BA files
FattrDO		EQU		0xC0	; .DO files
FattrCO		EQU		0xA0	; .CO files

;------------------------------------------------------------------------------
; DATAPAC/RAMPAC Hardware
;------------------------------------------------------------------------------

; device IO ports
PORT_CTL0			EQU		0x81	; control port for bank 0
PORT_DATA			EQU		0x83	; data read/write port
BANK_CTL_OFFSET		EQU		0x04	; bank n ctl port is ctl0 + n*4

; SelectBank
; Switch the hardware to a new bank address
; by doing SelectBlock 0 to the control port for the desired bank.
; Block number is reset to 0, byte position is reset to 0.
MACRO SelectBank n
	xor		a
	out		(PORT_CTL0+(n*BANK_CTL_OFFSET)),a	; write 0 to the bank n control port
ENDM

; SelectBlock
; not a macro, see SlectBlock: below
; Switch the hardware to a new block address.
; Bank is unchanged, byte position is reset to 0.

; ReadData
; Read one byte of data from the current byte position
; Bank & block unchanged, byte position is incremented by 1 after read.
MACRO ReadData
	in		a,(PORT_DATA)			; read one byte from the data port
ENDM

; WriteData
; Write one byte of data to the current byte position
; Bank & block unchanged, byte position is incremented by 1 after write.
MACRO WriteData
	out		(PORT_DATA),a			; write A to the data port
ENDM

; Convenience wrapper for WriteData with argument
MACRO WriteDataN n
	ld		a,n
	WriteData			; write n to the data port
ENDM

; *****************************************************************************
; Here is where we can update to support more than 2 banks (hopefully)
; Replace toggle 0/1 with a 0-N counter
; instead of bank^1 ; port^BANK_CTL_OFFSET
; do bank=(bank+1)%NUMBER_OF_BANKS ; port=PORT_CTL0+bank*BANK_CTL_OFFSET
; (each time you press [Bank], display bank num increments by 1 or rolls back to 0,
;  and port num changes to base port num for bank 0 + bank_num*4)
;
; Toggle the bank control port and bank# screen display between bank 0 / bank 1
; This only updates local variables, does not touch the RAMPAC hardware.
addrCtlPort		EQU		SelectBlock+1		; addr holding ctl port number, port number parameter of SelectBlock:
MACRO ToggleTargetBankNumber
	ld		a,(addrCtlPort)					;[f5da] 3a ec f5	; read bank control port number (0x81/0x85) from SelectBlock portnumber parameter
	xor		BANK_CTL_OFFSET					;[f5dd] ee 04		; toggle bit 2 (toggle control port between 0x81 & 0x85)
	ld		(addrCtlPort),a					;[f5df] 32 ec f5	; write new control port number to SelectBlock portnumber parameter
	ld		a,(BankNumMSG)					;[f5e2] 3a ee f4	; read bank number (0/1) from BankNumMSG (part of TitleMSG)
	xor		0x01							;[f5e5] ee 01		; toggle bit 0 to switch display bank number between ascii "0" & "1"
	ld		(BankNumMSG),a					;[f5e7] 32 ee f4	; write new bank number to BankNumMSG
ENDM

;------------------------------------------------------------------------------
; NODE ROM / RAMDSK arbitrary magic constants
;------------------------------------------------------------------------------

; These values have no meaning we can discern, it's just what the original
; NODE ROM writes to the first 2 bytes of the device to mark
; the device as being formatted, so RAMDSK has to do the same to be compatible.
StampByte0		EQU		0x40
StampByte1		EQU		0x04


;------------------------------------------------------------------------------
HIMEM		EQU		0xF5EE		; TRS-80 Model 100/102 with 32K installed
PRGLEN		EQU		0x578		; FIXME how can we get this without hard coding?
ORG HIMEM-PRGLEN-6				; entry minus length of header

;==============================================================================

; .CO Header
DW PRGTOP	; top
DW PRGLEN	; len
DW PRGEXE	; exe

PRGTOP:
PRGEXE:
	ld		de,sp+0x00				; save initial SP
	ex		de,hl
	ld		(addrSP),hl				; write initial SP to addrSP
	ld		a,(KC7)					; get status bits of keyboard matrix column 7
	cp		0x80					; is ENTER pressed?
	call	z,BANK					; if ENTER is pressed, switch banks ?
Set_SP:
	ld		sp,0x0000				; set SP from addrSP, 0x0000 is just initial value gets overwritten
	ld		hl,Set_SP
	push	hl
	ld		(ETRAP),hl
	ld		hl,FNAME
	ld		(hl),SPACE				; write a space to the 1st byte of fname buffer
	call	DrawTitle
	xor		a
	ld		(addr002),a
	ld		d,FattrBA
	call	j01
	ld		d,FattrCO
	call	j01
	ld		d,FattrDO
	call	j01
j31:
	call	UpdateFreeKB

; Fkeys
; Bank Load Save Name Kill ---- ---- Menu
; F1   F2   F3   F4   F5   F6   F7   F8

ReadKeyboard:
	call	KYREAD					; look for keypress
	jp		z,ReadKeyboard			; if no key then loop
	jp		nc,@end					; if not Fkey then skip to @end
	ld		hl,Set_SP
	push	hl
	cp		0xFF
	jp		z,SAVE1					; save file without displaying file list
	and		a
	jp		z,BANK
	dec		a
	jp		z,LOAD
	dec		a
	jp		z,SAVE
	dec		a
	jp		z,NAME
	dec		a
	jp		z,KILL
	sub		3
	jp		z,MENU
	pop		hl
	jp		ReadKeyboard
@end:
	cp		CR						; is it CR?
	ret		z						; return if CR
	jp		ReadKeyboard			; loop if not CR

j01:
	ld		c,1						; C=1 means SkipCWords will skip 2 bytes later
	call	CheckIsBankFormatted
j33:
	call	ReadDataW				; read 2 bytes into B & A
	ld		a,b
	cp		d
	call	z,j02
	inc		c
	ret		z
	jp		j33

j02:
	push	de
	push	bc
	ld		a,c
	call	SelectBlock
	call	j03
j34:
	ReadData
	PrintByte
@l0:
	ld		a,0x08					; addr003, 0x08 just initial value gets overwritten
	and		a
	cp		0x03
	jp		nz,j39
	push	af
	ld		a,'.'
	PrintByte
	pop		af
j39:
	dec		a
	ld		(addr003),a
	jp		nz,j34
	ld		a,0x08
	ld		(addr003),a
	push	bc
	ReadData
	ld		l,a
	ReadData
	ld		h,a
	PrintSpace
	PrintSpace
	call	PRTASC
	call	j05
	pop		bc
	call	CheckIsBankFormatted
	call	SkipCWords
	pop		bc
	pop		de
	ret

j03:
	ld		hl,(C_ROW)				; read cursor position row 1-8
	ld		a,(addr002)
	and		0x01
	jp		nz,j04
	ld		h,0x04
	jp		ESCB+8					; jump into the middle of the system rom ESC+B routine

j04:
	ld		h,0x18
	jp		ESCB+9					; jump into the middle of the system rom ESC+B routine

j05:
	ld		a,0x00					; read addr002
	inc		a						; increment
	ld		(addr002),a				; write addr002
	cp		10						; is it 10?
	ret		nz						; return if not 10
	xor		a						; if 10,
	ld	(addr002),a					; write 0 to addr002
	call	j31
DrawTitle:
	ld		hl,TitleMSG
	jp		PTILL0					; print TitleMSG to screen

UpdateFreeKB:
	push	hl
	push	de
	push	bc
	push	af
	xor		a
	ld		d,a
	ld		h,a
	ld		l,a
	call	SelectBlock
@l0:
	call	ReadDataW
	or		b
	jp		nz,@l1
	inc		hl
@l1:
	dec		d
	jp		nz,@l0
	push	hl
	ld		hl,FreeMSG				; really just cursor position sequence
	call	PTILL0
	pop		hl
	ld		a,l
	ld		(FreeKB),a
	call	PRTASC					; print free KB
	call	CheckIsBankFormatted
	call	SkipCWords
	jp		POPALL

;------------------------------------------------------------------------------
; KILL
;
KILL:
	ld		hl,KillMSG
	call	j30
	jp		nz,BEEP
	ld		hl,SureMSG
	call	ConfirmWithPrompt
	ret		nz
@l0:
	call	CheckIsBankFormatted
	ld		a,(BlockNumA)
	dec		a
	jp		z,@l1
	ld		c,a
	call	SkipCWords
@l1:
	xor		a
	WriteData
	WriteData
	ld		a,(VAR_D)
	and		a
	ret		z
	ld		(BlockNumA),a
	ld		c,a
	call	CheckIsBankFormatted
	call	SkipCWords
	ld		(VAR_D),a
	jp		@l0

;------------------------------------------------------------------------------
; NAME
;
NAME:
	ld		hl,NameMSG
	call	j30
	jp		nz,BEEP
	call	j40
	ld		a,(BlockNumA)
	ld		b,a
	push	bc
	call	j41
	pop		bc
	jp		z,BEEP
	ld		a,b
	call	SelectBlock
	ld		hl,FNAME
	ld		b,6
@l0:
	ld		a,(hl)
	WriteData
	inc		hl
	dec		b
	jp		nz,@l0
	ret

ConfirmReplace:
	ld		hl,ReplaceMSG
	call	ConfirmWithPrompt
	jp		nz,Set_SP
	ret

ConfirmReplaceKill:
	call	ConfirmReplace
	jp		KILL@l0

;------------------------------------------------------------------------------
; SAVE
;
SAVE:
	PrintByteN FF					; clear the screen
	call	FILES					; display ram files list
SAVE1:
	ld		hl,SaveMSG
	call	InputFileNameWithPrompt
	call	FINDFN
	jp		z,BEEP
	push	hl
	call	j42
	call	j40
	call	j41
	call	z,ConfirmReplaceKill
	call	UpdateFreeKB
	pop		hl
	inc		hl
	ex		de,hl
	ld		hl,(de)
	ld		(addr005),hl
	call	@l0
	inc		hl
	call	@prepfn
	call	@l2
	call	@l6
	call	WriteFilename
	ret
@l0:
	ld		a,(FileAttr)
	cp		FattrBA
	jp		z,@ba
	cp		FattrDO
	jp		z,@do
	ld		de,hl+2
	ld		hl,(de)
	ld		de,0x0005
	add		hl,de
	ret
@do:
	push	hl
	call	GETEOF
	pop		bc
	sub		hl,bc
	ret
@ba:
	push	hl
	call	UBLNAS+3				; jump into the middle of UBLNAS (update BASIC line number addresses)
	pop		bc
	sub		hl,bc
	ret
@prepfn:
	ld		(VAR_A),hl
	ld		hl,FilenameMSG
	jp		j44
@l2:
	ld		hl,(VAR_A)
	ld		d,0x01
	ld		bc,1014					; 1024 byte block minus 10 byte filename header
	jp		@l4
@l3:
	ld		bc,1024					; one full block size
@l4:
	sub		hl,bc
	jp		z,@l5
	jp		m,@l5
	inc		d
	jp		@l3
@l5:
	ld		a,d
	ld		(VAR_E),a
@freekb:	; nothing jumps here, we just need the address+1
	ld		a,0x00					; FreeKB
	cp		d
	jp		c,Beep
	ret
@l6:
	call	CheckIsBankFormatted
	ld		c,0x00
@l7:
	call	ReadDataW
	inc		c
	or		b
	jp		nz,@l7
	xor		a
	call	SelectBlock
	ld		a,c
	ld		(BlockNumA),a
	call	SkipCWords
	call	@l8
	ld		a,(BlockNumA)
	ld		(BlockNumB),a
	jp		@l6
@l8:
	ld		a,(VAR_E)
	dec		a
	ld		(VAR_E),a
	jp		z,@l9
	WriteDataN SPACE
	jp		@la
@l9:
	pop		af
	ld		a,(FileAttr)
	WriteData
@la:
	ld		a,0x00					; BlockNumB
	ld		(VAR_D),a
	WriteData
	ret

; write 10 bytes filename to first 10 bytes of block BlockNumA
WriteFilename:
	ld		a,(BlockNumA)
	call	SelectBlock
	ld		hl,FilenameMSG
	ld		b,10					; loop counter write 10 bytes
@l0:
	ld		a,(hl)
	WriteData
	inc		hl
	dec		b
	jp		nz,@l0
	ld		a,0xD3					; ???  what is 0xD3  ???
	jp		j27@l0

DeleteRamFile:
	push	hl
	call	ConfirmReplace
	pop		hl
	call	FINDFN1					; tail end of FINDFN
	cp		FattrDO
	jp		z,KILLDO				; if it's a .DO file
	cp		FattrCO
	jp		z,KILLDO1				; if it's a .CO file
	jp		KILLDO4					; if it's anything else

;------------------------------------------------------------------------------
; LOAD
;
LOAD:
	ld		hl,LoadMSG
	call	j30
	jp		nz,BEEP
	call	j40
	call	FINDFN
	call	nz,DeleteRamFile
	call	MakeHole
	ld		(addr005),hl
	ex		de,hl
	dec		de
	call	MYSTERY_20EC
	ld		a,(FileAttr)
	call	MKDIRENT
	call	j27
	jp		RESETFPS

MakeHole:
	ld		hl,(VAR_A)
	ld		b,h
	ld		c,l
	ld		a,(FileAttr)
	cp		FattrDO
	jp		z,MakeHoleDO
	cp		FattrBA
	jp		z,MakeHoleBA
	ld		hl,(COFILES)
	push	hl
	call	MAKHOL
	pop		hl
	ld		(COFILES),hl
	jp		c,Beep
	ret

MakeHoleDO:
	ld		hl,(DOFILES)
	call	MAKHOL
	jp		c,Beep
	ret

MakeHoleBA:
	ld		hl,(UNSBA)
	call	MAKHOL
	jp		c,Beep
	push	hl
	call	UPDOFILES
	pop		hl
	ret

Beep:
	pop		af
	jp		BEEP

j27:
	ld		a,0xDB					; ???  what is 0xDB  ???
@l0:
	ld		(@l3),a
	ld		hl,1014					; block size 1024 minus 10 bytes filename we already wrote
	ld		(VAR_C),hl
	ld		hl,(VAR_A)
@l1:
	ld		de,0x0000				; addr005
@l2:
	ld		a,(de)
@l3:
	ReadData
	ld		(de),a
	inc		de
	dec		hl
	ld		a,h
	or		l
	ret		z
	push	hl
	ld		hl,(VAR_C)
	dec		hl
	ld		a,l
	or		h
	call	z,j43
	ld		(VAR_C),hl
	pop		hl
	jp		@l2

InputFileNameWithPrompt:
	call	PTILL0
	call	INLIN
	ret		c
	dec		b
	ret		z
	inc		hl
	ld		e,b
	jp		CKFN

j29:
	ld		hl,MYSTERY_FCA2
	ld		de,MYSTERY_FC99
	ld		a,(hl)
	ld		(de),a
	inc		hl
	inc		de
	ld		a,(hl)
	ld		(de),a
	ret

j30:
	call	InputFileNameWithPrompt
j41:
	xor		a
	ld		(BlockNumA),a
	ld		(BlockNumB),a
	ld		a,(MYSTERY_FC99)
	sub		0x42					; what are these magic values?
	cp		0x03
	jp		nc,INSTR_2AB5
	add		a
	add		a
	add		a
	add		a
	add		a
	add		0x80
	ld		(FileAttr),a
	call	CheckIsBankFormatted
@l0:
	call	ReadDataW
	ld		(VAR_D),a
	ld		a,(BlockNumA)
	inc		a
	jp		z,INSTR_2AB5
	ld		(BlockNumA),a
	ld		a,b
@l1:
	cp		0x3F					; what is 0x3F ?
	jp		nz,@l0
	ld		a,(BlockNumA)
	call	SelectBlock
	ld		b,10					; loop counter read 10 bytes
	ld		hl,FilenameMSG
@l2:
	ReadData
	ld		(hl),a
	inc		hl
	dec		b
	jp		nz,@l2
	ld		c,8
	ld		hl,FilenameMSG
	ld		de,FNAME
	call	CMPARE
	jp		z,j42
	call	CheckIsBankFormatted
	ld		a,(BlockNumA)
	ld		c,a
	call	SkipCWords
	jp		@l0

j42:
	ld		hl,CFNAME				; point HL to "last filename loaded from cassette"
; copy first 8 bytes of filename from DE buffer to HL buffer
j44:
	ld		de,FNAME				; point DE to system active filename
	ld		b,8
	jp		D2H4Bup					; copy B (8) bytes of DE buffer to HL buffer, bottom to top, so bytes 0-7

j43:
	ld		hl,1024
	ld		(VAR_C),hl
	xor		a
	call	SelectBlock
	ld		a,(VAR_D)
	ld		(BlockNumA),a
	ld		c,a
	inc		c
	call	SkipCWords
	ld		(VAR_D),a
	ld		a,(BlockNumA)
	call	SelectBlock
	ret

CheckIsBankFormatted:
	xor		a						; zero A
	call	SelectBlock				; select block 0
	call	ReadDataW				; read bytes 0 & 1 into B & A
	add		b						; add B to A
	cp		StampByte0+StampByte1	; is the total 0x44?
	jp		nz,FORMAT				; if not, ask to format
	ret

; Read-and-discard C*2 bytes, final read will be left in B & A
SkipCWords:
	call		ReadDataW			; read 2 bytes into B & A
	dec			c					; decrement C
	jp			nz,SkipCWords		; repeat until C=0 (discard previous read data)
	ret

; Read a word of data (2 bytes) from device into B & A
ReadDataW:
	ReadData
	ld				b,a
	ReadData
	ret

ConfirmWithPrompt:
	call		PTILL0				; print prompt
	call		CHGET				; wait for keypress
	call		LC2UCA				; convert to uppercase
	cp			'Y'					; is it "Y" ?
	ret								; return cp result

j40:
	ld		hl,AsMSG
	call	InputFileNameWithPrompt
	jp		j29

;------------------------------------------------------------------------------
; FORMAT - prompt user to format and/or fix
;------------------------------------------------------------------------------
FORMAT:
	ld		hl,FormatMSG
	call	ConfirmWithPrompt
	jp		z,@NewFormat
	ld		hl,FixMSG
	call	ConfirmWithPrompt
	jp		z,@WriteStamp
	jp		MENU
; write new format
@NewFormat:
	call	TestHardware
	push	bc
	xor		a
	call	SelectBlock
	ld		b,a
	call	@WriteFormat
	pop		bc
	call	@WriteFormat
@WriteStamp:
	xor		a
	call	SelectBlock
	WriteDataN		StampByte0
	WriteDataN		StampByte1
	jp	Set_SP
@WriteFormat:
	ld		e,d
@l0:
	ld		a,b
	WriteData
	xor		a
	WriteData
	dec		e
	jp		nz,@l0
	ret

; hardware test / presence detection
; this might not be correct, just my best attempt to follow
; return success: Z = set,   B = 0x40, C = block128byte0+1, D = 0x80
; return fail:    Z = unset, B = 0x00, C = 0x00 or 0xFF ?,  D = 0x80
; C on success could be anything, whatever data happened to be stored on the device, incremented by 1
TestHardware:
	ld		d,0x80
	ld		a,d
	call	SelectBlock				; select block 128 byte 0
	ReadData						; read byte 0
	ld		b,a						; save in B
	; B should now have a copy of whatever was in byte 0 at start
	ld		a,d
	call	SelectBlock				; reset byte position back to 0
	ld		a,b						; get saved byte 0 from B
	inc		a						; increment
	WriteData						; write incremented value back to byte 0
	; byte 0 should now be incremented from before
	ld		a,d
	call	SelectBlock				; reset byte position back to 0
	ReadData						; read byte 0
	ld		c,a						; save to C
	; C should now have the incremented value read back from the hardware
	ld		a,d
	call	SelectBlock				; reset byte position back to 0
	ld		a,b						; get original saved byte 0 from B
	WriteData						; write original byte 0 back to byte 0
	; byte 0 should now be restored to what it was originally
	ld		a,c						; get C (value read back from hardware)
	cp		b						; compare test incremented byte 0 with original byte 0
	ld		b,0x40
	; Z is set or unset from the CP
	; B is 0x40 (LD aka 8085 MVI does not change Z)
	ret		z						; if match (test write did not work), return with B = 0x40
	xor		a
	ld		b,a
	ret								; if not match (test write worked), return with B = 0x00

;------------------------------------------------------------------------------
; strings & variables
;------------------------------------------------------------------------------

; variables that only exist as raw locations to the parameter to some instruction
; ie self-modifying code
addrSP		EQU		Set_SP+1
addr002		EQU		j05+1
addr003		EQU		j34@l0+1
FreeKB		EQU		SAVE1@freekb+1
addr005		EQU		j27@l1+1
FileAttr	EQU		j41@l1+1
BlockNumB	EQU		SAVE1@la+1

TitleMSG:
	DB FF
	cursor_invisible
	disable_automatic_scroll
	enter_reverse_mode
;	DB "NODE RAMPAC/Datapac    #"	; original
	DB "NODE RAMPAC/DATAPAC Bank"	; bkw
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

FreeMSG:
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

BlockNumA:
	DB 0

VAR_C:
	DW 0

VAR_D:
	DB 0

VAR_E:
	DB 0

;------------------------------------------------------------------------------
; BANK - switch banks
;------------------------------------------------------------------------------
BANK:
	SelectBank 0
	WriteDataN 0x41					; write 0x41 to Bank0,Block0,byte0
	; blindly wrote to block0,byte0, hope you didn't have non-RAMDSK data there
	; maybe it's to detect if the hardware exists
	SelectBank 1
	ReadData						; read Bank1,Block0,Byte0
	; Note: if the hardware is 256k or smaller, no banks (original DATAPAC/RAMPAC)
	; then the Bank1 read will just read Bank0 again
	ld		b,a						; save (maybe)Bank1,Block0,Byte0 in B
	; - if the hardware has bank1:      then B contains whatever was in Bank1,Block0,Byte0 - COULD BE ANYTHING
	; - if the hardware has no bank1:   then B contains the 0x41 we blindly wrote to bank0
	; - if the hardware does not exist: then B probably contains 0x00 or 0xFF?
	SelectBank 0
	WriteDataN 0x40					; write 0x40 to Bank0,Block0,byte0
	; now we've blindly overwritten bank0,block0,byte0 previous 0x41 now 0x40
	inc		a						; A++ -> A=0x41
	cp		b						; does B = 0x41 ?
	ret		z						; return if B = 0x41 (conclude the hardware does not have banks?)
	ld		a,b						; B & A didn't match, we have hardware with banks, copy B to A 
	cp		PORT_DATA				; ???  compare A to the data port number?                                 ???
	ret		z						; ???  return if match? is this maybe how we detect no hardware present?  ???

	ToggleTargetBankNumber
	; ToggleTargetBankNumber just updates variables, doesn't touch the hardware
	; fall through to SelectBlock to actually switch the hardware to the new bank

	xor		a						; zero A to select block 0 in new bank

;------------------------------------------------------------------------------
; SelectBlock - Select block# in the current bank
;------------------------------------------------------------------------------
; PORT_CTL0 is just the initial condition (bank0) and gets overwritten at run time
SelectBlock:
	out		(PORT_CTL0),a			; write A to the control port
	ret
PRGEND:
