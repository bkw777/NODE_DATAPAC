                        RD DOCUMENTATION
 
        USES
 
This documentation regards version 0 of RD.  RD means Rampac Diagnostic.  RD can operate without a Rampac so even if you don't own a Rampac you may find RD useful.  You can use RD to:
 
* troubleshoot Rampacs - it's excellent for this
* obtain or study BASIC constructs of general utility - there are many
* amuse yourself - pretend you own a Rampac, or modify RD to be a video game
 
        SCOPE
 
The main focus of this documentation is the diagnosis of Rampac content that appears incorrect from the file oriented point of view that commercial Rampac utilities take.  The content of a Rampac is just that -- content!  Utility software which transfers file content between a Rampac and laptop memory is one thing - application software (e.g., database) is quite another thing.  What appears incorrect to utilities may be correct with respect to an application.
 
Generally, RD considers Rampac content the way utilities consider it - but the point of view which RD takes is no more stringent than is needed for file orientation.  So RD is strongly file oriented but RD can be applied in the diagnosis of Rampac content that is not file oriented.
 
        TYPICAL SCENARIO
 
The typical scenario where RD helps you spans four events.  First, you make a mistake such as detaching the Rampac while laptop power is on.  This disorganizes the Rampac content - "trouble" is born but you don't not know it at this time.  Second, while using a Rampac utility you notice trouble - you're now under stress.  Third, you use corrective measures to recover files and mitigate your loss.  These measure include those of the utility and recovery programs such as N-DKTR.BA.  Fourth, you use RD to confirm corrective measures, detect and diagnose remaining aftermath, and plan more corrective measures.  The ideal scenario is where you use RD before and after each corrective measure, but cool-headedness isn't typical under stress.
 
Note that RD does not alter Rampac content so it can't "fix" anything.  RD lets you thoroughly diagnose trouble so you may plan how to fix it.  As to Rampac hardware faults, some faults can be observed while using RD to exercise a Rampac.
 
        TERMINOLOGY
 
A few terms are defined here for clarity.  They are:
 
Rampac - This is hardware.  It is mass storage hardware.  Inside the hardware the total storage volume is divided equally into granular units of less volume.  Rampacs attach to the system bus of a laptop.  Several commercial makers (Node, EME, etc.) manufacture this hardware, name it differently (DataPac, Rampac, etc.), and offer it in various total storage volumes (256K, 128K, etc.).  These makers include file oriented utility software (or ROMware) with their hardware.
 
Sector - This term is borrowed from disk terminology.  In Rampac terminology a sector is a granular unit of storage with a volume of 1,024 bytes, that is 1 Kbyte.  Sectors are numbered beginning with 000.  A 256K Rampac for example has 256 sectors - numbered 000 through 255.  Access to the content of a sector is byte-serial and initially begins with the first byte.  Unlike a disk sector, access to a Rampac sector is circular-serial in the sense that after access to the last (1024th) byte a subsequent access is an access to the first byte.
 
Directory - This term is borrowed from disk terminology.  Directory is a meaningful term only with respect to files.  A directory is a big deal to certain file oriented utility software that accesses Rampac content.  Commercial software such as RAM100.CO by EME uses a specific region of a 
Rampac as a directory where, according to a certain scheme, physical sector organization correlates to logical file organization.  Sector 000 is used as a directory.  Fortunately other commercial software also uses sector 000 as a directory and the same scheme of correlation.  RD assumes sector 000 is a directory, so its file oriented commands (e.g., trace forward to end) depend on this assumption but its sector oriented commands (e.g., view) are independent except that they exclude sector 000.
 
Flag and Link - These terms are names for paired bytes that reside within the directory.  For each physical sector of a Rampac there is a flag byte and a link byte.  Remember - flag and byte pairs are in the directory, not in the sectors that they relate.  The flag identifies how the related sector is currently used - a general type classification.  In the special case for sector 000, the content of the link byte doesn't indicate linkage.  For sector 001 and upward, the link in most circumstances of usage (per the flag) specifies the "next" sector number in a chain of sectors that logically trace  a file.  Where the related sector is an "end" sector the link contains zero - in other words linkage ends back at sector 000 which is the directory.
 
        HARDWARE SPECIFICS
 
RD detects the laptop model.  Where a Tandy Model 100 or Model 102 is detected, the particular model number is displayed and operation continues.  For other models (Tandy Model 200, NECs, etc.) operation stops.  Subsequent versions of RD can be made that either expand the scope of laptops which RD supports, or are specific to other groups of laptops.
 
Rampacs of up to 256K are supported.  RD assumes a 256K capacity Rampac and arranges the laptop screen to accommodate 255 sectors.  Where lesser capacity Rampacs are used, it's pointless for you to navigate the cursor on the screen beyond sectors that your Rampac actually has.  For example, a so-called 128K Rampac has one directory and 127 sectors.  In this case there is no point to navigate beyond sector 127 other than for amusement.
 
In certain operations RD senses whether a printer (LPT) is attached and ready.  Where a printer is not attached or not ready, messages and reports that are best suited to hard copy divert to the laptop screen.  You can toggle the ready state of an attached printer so that only desired portions of an entire report end up as hard copy while undesired portions divert to the screen.
 
        SCREEN REGIONS
 
The first physical screen (LCD) position corresponds to sector 000 - the directory.  Where RD finds the directory flag format correct, the ` symbol is shown.  Otherwise some other symbol is shown based on the directory flag.  RD divides the rest of the screen into two regions:
 
Map - 255 cells covering sector 001 to sector 255, you navigate the cursor
Bar - a 64-position strip where messages and reports appear
 
        Map
 
RD determines the type of a sector based on the flag byte and the link byte for the sector.  RD obtains these two bytes from the directory (physical sector 000) of the Rampac.  Each cell of the Map corresponds to a sector.  RD shows a symbol in each cell that indicates the sector type.  Twelve types are possible.  The symbols, types, and explanations are:
 
a  alternate directory - its flag shows what's expected for a directory.
b  one-sector BASIC file - a complete (.BA) file is within this sector.
B  Many-sector BASIC file start - 1st sector.  More sectors continue it.
c  one-sector binary file - a complete (.CO) file is within this sector.
C  Many-sector binary file start - 1st sector.  More sectors continue it.
d  one-sector ASCII file - a complete (.DO) file is within this sector.
D  Many-sector ASCII file start - 1st sector.  More sectors continue it.
_  continuation - flag shows it is a portion of a many-sector file.
^  free - flag shows free, link is 0 (no linkage to another sector).
r  reserved - flag shows free, there is linkage but not to itself.
?  unknown - flag shows an unknown usage, linkage if any is not to itself.
H  hung - flag ignored because there is linkage is to itself.
 
The cursor always lies within the Map.  You navigate among the cells, that is sectors of the Map, by moving the cursor.
 
The first screen display shows an outline around the 255 cell area of the Map.  The symbols and types are listed in this area while RD is "mapping" the Rampac and collecting statistics.
 
After mapping is completed, the Map appears showing 255 symbols and RD establishes the cursor at sector 001.  Where you use "trace" commands, RD draws lines from sector to sector in accordance with sector linkage.  With the cursor positioned on a D symbol for example, a "trace forward to end" command draws a line from the D symbol to some _ symbol and if there is more linkage then more lines are drawn until no more linkage is found.  In this case all the sectors of a many-sector ASCII file are identified and their order is graphically portrayed on the Map.
 
        Bar
 
The Bar is a strip that extends for 64 positions.  The "front" of the Bar immediately follows the end (sector 255) of the Map.  The "back" of the Bar is the 64th position and it is the last physical screen position.  RD inserts some messages into the back of the Bar, and other messages into the front of the Bar.  Where a message is inserted at the back of the Bar, the Bar scrolls leftward.  Where a message is inserted at the front of the Bar, the Bar scrolls rightward.
 
For example, a "trace forward" command inserts a message about sector linkage at the back of the Bar and the Bar scrolls leftward.  After a second "trace forward" command, two messages appear at the back end of the Bar and reading these two messages from left to right shows you the progression of linkage.  Using two "trace reverse" commands produces messages at the front end of the Bar and reading them from left to right shows you the progression of linkage in the same way as for the previous example.
 
The first screen display has a message that merely identifies the 64-position Bar and indicates that RD is mapping the Rampac and collecting statistics.  The progress of the mapping is shown on the Bar as a pixel by pixel appearance of a miniature 255-pixel map.  Then the progress of collecting statistics is shown on the Bar as a pixel by pixel disappearance of the miniature map.  Error messages regarding the directory or the detection of hung sectors can appear at the back end of the Bar during this time.
 
After mapping is completed and the Map appears, the Bar shows a message regarding the version of RD with a reminder that the LABEL key provides help to the operator.
 
                COMMANDS
 
All commands are invoked by pressing a key, or a key in conjunction with the [SHIFT] or [CTRL] keys.  For example, the four arrow keys merely navigate the cursor on the Map.  In conjunction with the [SHIFT] or [CTRL] keys, the arrow keys invoke "trace" type commands.
 
In addition to [SHIFT] and [CTRL] and the arrow keys, the remaining command keys are [ESC], [LABEL], [PRINT], [F1], [F8], [SPACE], [f], [F], [j], [J], [v], and [V].  Generally, [ESC] stops the progress of a command.
 
The [LABEL] key provides extensive help about all commands.  This help is a series of messages on the Bar.  Each message is a brief explanation of a command along with the key or key combination that invokes the command.  Each help message persists for a while before the next help message appears on the Bar.  During the series of help messages, you can press a command key and its help message appears on the Bar.  The series repeats endlessly until you press [ESC] to stop the help command.  Given the extensive help within RD, this documentation need not and does not explain all of the commands.
 
                Shut Power Down
 
Where no command is in progress, [ESC] is the Shut Power Down command.  The prompt "Shut power down (Y/N)?" appears at the back of the Bar.  If you press [y] or [Y], RD shuts down power of the laptop and suspends operation until you cycle the laptop power switch to restore power.  When you restore power, RD restores the Map (without trace lines) and the cursor along with the Bar and inserts a "Power up." message at the back of the Bar.  If you press any key other than [y] or [Y], RD removes the prompt and the Bar appears exactly as it did prior to the command.
 
This command is useful where you want to continue to diagnose a Rampac at a later time.  With power off, it's safe to detach a Rampac.  Later you can attach the Rampac, restore power, and then continue where you stopped.
 
                Diagnostic Report
 
The [CTRL] and [PRINT] key combination is the Diagnostic Report command.  It's best to have a printer attached and ready before you use this command, otherwise each line of this lengthy report diverts to the Bar.  The widest lines of the report have 64 positions so no special setup is needed for form width of the printer.  The report has seven sections.
 
        Date and Time
 
This section has one line.  It contains the date and dime of the report.
 
        Directory and Map
 
This section has 7 lines.  It shows the directory symbol and the 255 symbols of the Map exactly as they appear on the laptop screen.
 
        Directory Flag and Link Format
 
This section has one line and it is 64 positions wide.  Where the flag byte and the link byte of the directory are both correct, then the format is marked as `OK.  Otherwise it's marked as BAD.
 
        Statistics
 
This section has several lines and each is 64 positions wide.  The right-hand end of each line has a 3-digit decimal number which is a total, grand-total, or sub-total statistic.  For any statistic that totals zero, RD does not include a statistic line.  For example, if the total number of FREE type sectors is zero then there is no line regarding this total in the report.
 
        File Info from Sector and Info Derived from Directory
 
This section has one heading line and it is followed by 255 lines - one for each sector.  All lines are 64 positions wide.  The heading line has titles for 7 columns.
 
The first column titled "Sec" heads the list of sector numbers which follow in ascending order from 001 to 255.
 
The second column titled "Filename(bytes\1of)" heads the list of file info which RD gleans from the first 10 bytes within each sector.  Sometimes this file info is relevant, sometimes not, but RD provides it for all sectors.
 
The remaining column titles "Type", "Frm<", "Jointed_Jnt#_min-max", "Link", and ">Fwd" head the list of info that RD derives from the directory.
 
Two abbreviated examples of this report section are shown and explained below.  The first example is typical.
 
Sec Filename(bytes\1of) Type Frm< Jointed_Jnt#_min-max Link >Fwd
001 ??!???S?(32202\032) Cont 002<                      end. >Dir
002 RAM100CO(01406\002) File    <                      more >001

File info within sector 002 indicates:
 
* filename is RAM100.CO
* size of file is 1,406 bytes
* it's the 1st of 2 sectors for the file (based on size of file)
 
Directory info bearing upon sector 002 indicates:
 
* it is a File type of sector
* there is no linkage to it from any other sector (Frm is blank)
* it has no jointed condition (i.e., linkage from two or more other sectors)
* it has linkage to a "next" sector (more)
* the forward linkage is to sector 001.
 
File info within sector 001 does not appear to be relevant.  Directory info bearing upon sector 001 indicates:
 
* it is a continuation (Cont) type of sector - file info is not relevant
* there is linkage to it exclusively from sector 002 (002<)
* consequently, it has no jointed condition
* it has no linkage to another sector, consequently it's an end (end.) sector
* in other words, the forward linkage is to the directory (>Dir)
 
Although file info within sector 001 is provided, it is not relevant because the first 10 bytes within continuation type sectors have no special purpose.  However where the directory of a Rampac has an incorrect flag byte for a sector, then file info within the corresponding sector can be useful.
 
The second abbreviated example of this report section is exactly what RD produces where no Rampac is attached to the laptop.  You can use this to confirm that the RD program operates properly.  This example illustrates two things: a hung sector, and a large 254-way joint condition.
 
With no Rampac attached, the I/O port number used to read content bytes of a sector echoes back to the system bus of the laptop as if it were content.  Rampacs use I/O port number 131 for read and for write of sector content.  So in this example bear in mind that RD always receives a byte value of 131 where it "reads" file info or directory info.
 
Sec Filename(bytes\1of) Type Frm< Jointed_Jnt#_min-max Link >Fwd
001 ????????(33667\033) Unk?    <                      more >131
002 ????????(33667\033) Unk?    <                      more >131
 |
130 ????????(33667\033) Unk?    <                      more >131
131 ????????(33667\033) Hung ???< 254-way_#001_001-255 Self >131
132 ????????(33667\033) Unk?    <                      more >131
 |
254 ????????(33667\033) Unk?    <                      more >131
255 ????????(33667\033) Unk?    <                      more >131
 
File info within all sectors is not relevant.  Directory info bearing upon sectors 001 through 130 and sectors 132 through 255 (a group of 254 sectors) indicates:
 
* unknown (Unk?) type of sectors
* there is no linkage from any other sector (Frm is blank)
* consequently, these sectors have no jointed condition
* all of these 254 sectors have linkage forward to sector 131
* consequently, their identical forward linkages define a 254-way joint.
 
Directory info bearing upon sector 131 indicates:
 
* it is a Hung type of sector because it links to itself (Self >131)
* there is linkage to it from more than one other sector (Frm is ???)
* because there are several ways to this sector it has a jointed condition
* the linkage to it is from 254 other (254-way_) sectors, and
* RD numbers this joint as joint number one (#001_), and
* the lowest and highest joint-ways are from sectors 001 and 255 (001-255).
 
        Joints
 
This section of the report only appears if there are any joints.  Where there are any sectors that have a jointed condition, this section has a paragraph for each.  The joints are numbered from #001 and onward.  The paragraph identifies the joint number, the jointed sector which is the subject of the joint, the amount of joint-ways, and every joint-way sector.  For joints of up to 8 joint-ways, the paragraph is one line.  Any additional lines of the paragraph provide up to 16 additional joint-ways.
 
An extreme case of "jointedness" for a 256K Rampac is where there is one 3-way joint and 126 2-way joints.  In this case, the report has 127 paragraphs of one line each.
 
But extreme jointedness can come in another flavor.  The following example is exactly what RD produces where no Rampac is attached to the laptop.  This example illustrates another extreme case of jointedness where there is one large 254-way joint.  In this case, the report has one large paragraph of 17 lines.
 
Joint#001 >131 is 254-way from: 001,002,003,004,005,006,007,008,
009,010,011,012,013,014,015,016,017,018,019,020,021,022,023,024,
025,026,027,028,029,030,031,032,033,034,035,036,037,038,039,040,
041,042,043,044,045,046,047,048,049,050,051,052,053,054,055,056,
057,058,059,060,061,062,063,064,065,066,067,068,069,070,071,072,
073,074,075,076,077,078,079,080,081,082,083,084,085,086,087,088,
089,090,091,092,093,094,095,096,097,098,099,100,101,002,003,104,
105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,
121,122,123,124,125,126,127,128,129,130,132,133,134,135,136,137,
138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,
154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,
170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,
186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,
202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,
218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,
234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,
250,251,252,253,254,255.
 
                View
 
The [v] and [V] keys are respectively the View by ASCII and View by Hex-2 commands.  These commands are useful where you want to directly view the content of a Rampac sector.  Content of a sector, expressed in ASCII or in 2-digit Hexadecimal, appears on the Bar.  Each time you press one of these keys, all 64 positions of the Bar fill with the expression (ASCII or Hex-2) of content from a portion of the sector.
 
The first time you press one of these keys, RD presents the first portion of the sector.  Repeatedly pressing the same key presents a view of the next portion of the sector.  The amount of sector bytes in a portion and the number of repeated key presses to view an entire 1,024-byte sector is listed below for each type of expression.
 
ASCII - 64-byte portion/16 portions per sector, "?" substitute for non-ASCII
HEX-2 - 32-byte portion/32 portions per sector, 2 Hexadecimal digits per byte
 
RD provides a 32-pixel wide gauge on the Bar that relates the viewed portion to the entire 1,024-byte sector.  Each pixel represents 32 bytes: Two adjacent pixels are blank for ASCII; one pixel is blank for Hex-2.
 
Alternating between [v] and [V] keys, presents the same portion but with the alternate expression.
