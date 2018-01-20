TYPE position
    x AS INTEGER
    y AS INTEGER
END TYPE

TYPE rect
	min AS position
	max AS position
	sizey AS INTEGER
	sizex AS INTEGER
END TYPE

DECLARE SUB InitUtil ()
DECLARE SUB SetupTimer (ticksPerTimer&)
DECLARE SUB UnSetupTimer ()
DECLARE SUB Delay (numSeconds#)
DECLARE SUB WaitForAnykey ()
DECLARE SUB MakeRect (miny%, maxy%, minx%, maxx%, r AS rect)

DECLARE FUNCTION StringifyInt$ (num%)
DECLARE FUNCTION RandomInt% (lower%, upper%)

COMMON SHARED UpKey AS STRING
COMMON SHARED DownKey AS STRING
COMMON SHARED RightKey AS STRING
COMMON SHARED LeftKey AS STRING
COMMON SHARED HomeKey AS STRING
COMMON SHARED EndKey AS STRING
COMMON SHARED PgupKey AS STRING
COMMON SHARED PgdownKey AS STRING
COMMON SHARED EnterKey AS STRING
COMMON SHARED EscapeKey AS STRING

CONST FALSE% = 0
CONST TRUE% = NOT FALSE%

DIM SHARED isInitialised AS INTEGER
DIM SHARED timerFreq AS DOUBLE

DEFINT A-Z

TYPE trail
	length AS INTEGER
	head AS INTEGER
	x AS INTEGER
END TYPE

SCREEN _NEWIMAGE(80, 25, 0)
DO: LOOP UNTIL _SCREENEXISTS

_TITLE "Matrix"
f& = _LOADFONT("Px437_IBM_VGA8.ttf", 32, "MONOSPACE")
_FONT f&

fw = _FONTWIDTH(f&): fh = _FONTHEIGHT(f&)
userwidth& = _DESKTOPWIDTH: userheight& = _DESKTOPHEIGHT 'get current screen resolution
scrnwidth& = fw * _WIDTH: scrnheight& = fh * _HEIGHT 'get the dimensions of the program screen
_SCREENMOVE (userwidth& \ 2 - scrnwidth& \ 2) - 3, (userheight& \ 2 - scrnheight& \ 2) - 29 'centre screen

CLS 0
LOCATE ,,0

_PALETTECOLOR 1, _RGB32(255, 255, 255)
_PALETTECOLOR 2, _RGB32(127, 255, 127)
_PALETTECOLOR 3, _RGB32(0, 255, 0)
_PALETTECOLOR 4, _RGB32(0, 192, 0)
_PALETTECOLOR 5, _RGB32(0, 128, 0)

DIM SHARED trails(25) AS trail
FOR i = 0 to UBOUND(trails, 1)
	ResetTrail i
NEXT

DIM tr AS trail
DO
	SCREEN 0, 0, 1, 0
	PCOPY 0, 1
	FOR i = 0 to UBOUND(trails, 1)
		trails(i).head = trails(i).head + 1
		tr = trails(i)
		tail = tr.head - tr.length

		IF tr.head <= 25 AND tr.head > 0 THEN
			LOCATE tr.head, tr.x
			PRINT GetRandomChar;
		ENDIF

		IF tail <= 25 AND tail > 0 THEN
			LOCATE tail, tr.x
			PRINT " ";
		ELSEIF tail > 25 THEN
			ResetTrail i
		ENDIF
		
		FOR j = tr.head TO tr.head - 4 STEP -1
			IF j <= 25 AND j > 0 THEN
				c = SCREEN(j, tr.x)
				LOCATE j, tr.x
				COLOR tr.head - j + 1
				PRINT CHR$(c);
			ENDIF
		NEXT
	NEXT
	PCOPY 1, 0
	SCREEN 0, 0, 0, 0
	_Delay 0.10
LOOP

SUB ResetTrail(i)
trails(i).length = RandomInt(5, 20)
trails(i).head = RandomInt(-25, -1)
trails(i).x = RandomInt(1, 80)
END SUB

FUNCTION GetRandomChar$ ()
' Non printing characters
' 0, 7, 9, 10, 11, 12, 13, 28, 29, 30, 31, 32, 255
DO
	idx = RandomInt(1, 255)
LOOP UNTIL idx <> 0 AND idx <> 7 AND idx <> 9 AND idx <> 10 AND idx <> 11 AND idx <> 12 AND idx <> 13 AND idx <> 28 AND idx <> 29 AND idx <> 30 AND idx <> 31 AND idx <> 32 AND idx <> 255
GetRandomChar$ = CHR$(idx)
END FUNCTION

SUB InitUtil
' Initialise some values
IF isInitialised = TRUE THEN EXIT SUB
timerFreq = 0#
RANDOMIZE TIMER
UpKey$ = CHR$(0) + CHR$(72)
DownKey$ = CHR$(0) + CHR$(80)
RightKey$ = CHR$(0) + CHR$(77)
LeftKey$ = CHR$(0) + CHR$(75)
HomeKey$ = CHR$(0) + CHR$(71)
EndKey$ = CHR$(0) + CHR$(79)
PgupKey$ = CHR$(0) + CHR$(73)
PgdownKey$ = CHR$(0) + CHR$(81)
EnterKey$ = CHR$(13)
EscapeKey$ = CHR$(27)
isInitialised = TRUE
END SUB

SUB SetupTimer(ticksPerTimer&)
' Ticks per timer from 1 to 65536, a lower value increases timer resolution
' A value of 2048 gives timer resolution of 2048 / 1193182 = ~0.0017s
' Ref: http://wiki.osdev.org/Programmable_Interval_Timer
' Ref: https://en.wikibooks.org/wiki/X86_Assembly/Programmable_Interval_Timer
ticksPerTimer& = ticksPerTimer& MOD 65536
OUT &H43, &H34
OUT &H40, ticksPerTimer& AND &HFF
OUT &H40, ticksPerTimer& \ 256
IF ticksPerTimer& = 0 THEN ticksPerTimer& = 65536
timerFreq# = 1193182 / ticksPerTimer&
END SUB

SUB UnSetupTimer
' Returns the timer to normal operation
OUT &H43, &H34
OUT &H40, 0
OUT &H40, 0
END SUB

SUB Delay(numSeconds#)
' Delay for a number of seconds
numTicks& = numSeconds# * timerFreq#
IF numTicks& <= 0 THEN numTicks& = 1
FOR i& = 1 TO numTicks&
    st# = TIMER
    WHILE st# = TIMER: WEND
NEXT i&
END SUB

SUB WaitForAnykey
' Wait for input
DO: in$ = INKEY$: LOOP WHILE in$ = ""
END SUB

SUB MakeRect(miny%, maxy%, minx%, maxx%, r AS rect)
' Create a rect from arguments
r.min.y = miny%
r.max.y = maxy%
r.min.x = minx%
r.max.x = maxx%
r.sizey = r.max.y - r.min.y
r.sizex = r.max.x - r.min.x
END SUB

FUNCTION StringifyInt$(num%)
' Stringify number
StringifyInt$ = RTRIM$(LTRIM$(STR$(num%)))
END FUNCTION

FUNCTION RandomInt%(lower%, upper%)
' Generates an integer from lower to upper inclusive
RandomInt% = INT(RND * (upper% - lower% + 1)) + lower%
END FUNCTION
