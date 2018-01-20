'$INCLUDE: 'UTIL.BI'

DIM SHARED isInitialised AS INTEGER
DIM SHARED timerFreq AS DOUBLE

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
