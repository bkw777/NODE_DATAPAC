N-READ.CO by Paul Globman (c) 1990
----------------------------------

N-READ.CO allows a BASIC program to have sequential access to TEXT files in 
Node RAM without having to move the entire file into T200 RAM.

Your BASIC program must first:

         LOADM "N-READ"

Then the following calls are available:


CALL63600,0  closes any previously opened file in Node.

CALL63600,1,VARPTR(X$) opens file X$ in Node if no files are open, else closes
opened file, beeps, and returns.

CALL63600,2,VARPTR(X$) reads bytes from opened Node file and returns with data
in X$.  The read begins where previous read ended and stops at CRLF or 255 
bytes, whichever occurs first.

PEEK(63603) examines result descriptor.  This location holds 1 if the OPEN or
READ was sucessful.  If this is not 1 after an OPEN then file was not found.
If this is not 1 after a read then EOF was found.  Upon encountering an EOF
condition after a read, examine LEN(X$) to determine if valid data was 
encountered prior to EOF.


To implement N-READ.CO in your application program, study (and run)
this READ TEST PROGRAM.

0 REM READ TEST PROGRAM (c) P.GLOBMAN
10 LOADM"N-READ":INPUT"file";X$
20 CALL63600,1,VARPTR(X$)  ' OPEN FILE
30 IFPEEK(63603)=1THEN50   ' TEST OPEN
40 PRINT"File not found":GOTO10
50 CALL63600,2,VARPTR(X$)  ' GET INPUT
60 IFPEEK(63603)=1THENPRINTX$:GOTO50
70 IF X$<>""THENPRINTX$;   ' TEST EOF
80 END
