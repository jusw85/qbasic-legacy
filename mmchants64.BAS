' Mediaeval Merchants
' Experiment to prototype concepts, nothing is implemented

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
DECLARE SUB GameStart ()
DECLARE SUB GameEnd ()
DECLARE SUB Load ()
DECLARE SUB DrawOpeningBorder ()
DECLARE FUNCTION Opening ()

CALL SetupTimer(2048)
'SCREEN 0 '25 x 80
SCREEN _NEWIMAGE(80, 25, 0)
DO: LOOP UNTIL _SCREENEXISTS

_TITLE "Mediaeval Merchants"
f& = _LOADFONT("Px437_IBM_VGA8.ttf", 32, "MONOSPACE")
_FONT f&

fw = _FONTWIDTH(f&): fh = _FONTHEIGHT(f&)
userwidth& = _DESKTOPWIDTH: userheight& = _DESKTOPHEIGHT 'get current screen resolution
scrnwidth& = fw * _WIDTH: scrnheight& = fh * _HEIGHT 'get the dimensions of the program screen
_SCREENMOVE (userwidth& \ 2 - scrnwidth& \ 2) - 3, (userheight& \ 2 - scrnheight& \ 2) - 29 'centre screen

LOCATE ,,0
DO
    CLS
    choice = Opening
    IF choice = 0 THEN
        GameStart
    ELSEIF choice = 1 THEN
        Load
    ELSEIF choice = 2 THEN
        GameEnd
    END IF
LOOP UNTIL quitGame > 0
CALL UnSetupTimer
END

SUB GameEnd
CLS
COLOR 7
line$ = "Thanks for playing!"
LOCATE 12, (80 - LEN(line$)) / 2
PRINT line$
SHARED quitGame
quitGame = 1
END SUB

SUB GameStart
CLS
COLOR 7
LOCATE ,,1

PRINT "Choose a race:"
PRINT
PRINT "1) Human"
PRINT "2) Elf"
PRINT "3) Dwarf"
PRINT "4) Halfling"
PRINT
PRINT "Your choice? ";
race$ = ""
DO
    in$ = INKEY$
    IF in$ = "1" THEN
        race$ = "Human"
    ELSEIF in$ = "2" THEN
        race$ = "Elf"
    ELSEIF in$ = "3" THEN
        race$ = "Dwarf"
    ELSEIF in$ = "4" THEN
        race$ = "Halfling"
    ENDIF
LOOP WHILE race$ = ""
PRINT in$

LOCATE 11, 1
PRINT "Choose a class:"
PRINT
PRINT "1) Warrior"
PRINT "2) Mage"
PRINT "3) Thief"
PRINT
PRINT "Your choice? ";
class$ = ""
DO
    in$ = INKEY$
    IF in$ = "1" THEN
        class$ = "Warrior"
    ELSEIF in$ = "2" THEN
        class$ = "Mage"
    ELSEIF in$ = "3" THEN
        class$ = "Thief"
    ENDIF
LOOP WHILE class$ = ""
PRINT in$

pointsLeft = 8
baseStr = 9
baseInt = 9
baseDex = 9

strPoints = 0
intPoints = 0
dexPoints = 0

raceStrMod = 0
raceIntMod = 0
raceDexMod = 0

SELECT CASE race$
    CASE "Human"
        raceStrMod = 0
        raceIntMod = 0
        raceDexMod = 0
    CASE "Elf"
        raceStrMod = -4
        raceIntMod = 2
        raceDexMod = 2
    CASE "Dwarf"
        raceStrMod = 4
        raceIntMod = -2
        raceDexMod = -2
    CASE "Halfling"
        raceStrMod = -3
        raceIntMod = 0
        raceDexMod = 3
END SELECT

classStrMod = 0
classIntMod = 0
classDexMod = 0

SELECT CASE class$
    CASE "Warrior"
        classStrMod = 3
        classIntMod = -3
        classDexMod = 0
    CASE "Mage"
        classStrMod = -4
        classIntMod = 5
        classDexMod = -1
    CASE "Thief"
        classStrMod = -2
        classIntMod = 0
        classDexMod = 2
END SELECT

CLS
PRINT "Race         : "; race$
PRINT "Class        : "; class$
PRINT
PRINT      "                   Base     Race     Class     Points     Final"
strLine$ = "Strength     :       ##       +#       +#          ##        ##"
intLine$ = "Intelligence :       ##       +#       +#          ##        ##"
dexLine$ = "Dexterity    :       ##       +#       +#          ##        ##"

LOCATE 10, 1
PRINT "Use arrow keys to navigate, +/- to allot your points and enter to finish."

selected = 5

redrawStats:
VIEW PRINT 5 TO 7
CLS 2
VIEW PRINT 13 TO 25
CLS 2
VIEW PRINT
COLOR 7
finalStr = baseStr + classStrMod + raceStrMod + strPoints
finalInt = baseInt + classIntMod + raceIntMod + intPoints
finalDex = baseDex + classDexMod + raceDexMod + dexPoints

LOCATE 5, 1
PRINT USING strLine$; baseStr; raceStrMod; classStrMod; strPoints; finalStr
PRINT USING intLine$; baseInt; raceIntMod; classIntMod; intPoints; finalInt
PRINT USING dexLine$; baseDex; raceDexMod; classDexMod; dexPoints; finalDex;

LOCATE selected, 55
COLOR 9
PRINT "<";

COLOR 7
LOCATE 11, 1
PRINT "Points remaining: "; StringifyInt(pointsLeft);
LOCATE ,POS(0) - 1, 1

done = FALSE
DO
    in$ = INKEY$
    SELECT CASE in$
        CASE CHR$(0) + CHR$(72), "8"
            selected = selected - 1
            IF selected < 5 THEN selected = 5
            GOTO redrawStats
        CASE CHR$(0) + CHR$(80), "2"
            selected = selected + 1
            IF selected > 7 THEN selected = 7
            GOTO redrawStats
        CASE "+", "="
            IF pointsLeft > 0 THEN
                pointsLeft = pointsLeft - 1
                SELECT CASE selected
                    CASE 5
                        strPoints = strPoints + 1
                    CASE 6
                        intPoints = intPoints + 1
                    CASE 7
                        dexPoints = dexPoints + 1
                END SELECT
            ENDIF
            GOTO redrawStats
        CASE "-", "_"
            SELECT CASE selected
                CASE 5
                    IF strPoints > 0 THEN
                        pointsLeft = pointsLeft + 1
                        strPoints = strPoints - 1
                    ENDIF
                CASE 6
                    IF intPoints > 0 THEN
                        pointsLeft = pointsLeft + 1
                        intPoints = intPoints - 1
                    ENDIF
                CASE 7
                    IF dexPoints > 0 THEN
                        pointsLeft = pointsLeft + 1
                        dexPoints = dexPoints - 1
                    ENDIF
            END SELECT
            GOTO redrawStats
        CASE CHR$(13)
            IF pointsLeft > 0 THEN
                LOCATE 13, 1, 0
                COLOR 4
                PRINT "Not all points have been assigned!";
            ELSE
                done = TRUE
            ENDIF
    END SELECT
LOOP UNTIL done = TRUE

END
END SUB

SUB Load
CLS
COLOR 7
line$ = "Sorry, I didn't program a load function yet."
LOCATE 12, (80 - LEN(line$)) / 2
PRINT line$
LOCATE 25, 1
PRINT "Press any key to continue"
CALL WaitForAnykey
END SUB

SUB DrawOpeningBorder
stepSizeX = 2
stepSizeY = 1
xMin = 1 - stepSizeX
xMax = 80 + stepSizeX
yMin = 1 - stepSizeY
yMax = 25 + stepSizeY
FOR charType = 1 TO 4
    SELECT CASE charType
        CASE 1
            colour = 12: symbol$ = "*"
        CASE 2
            colour = 10: symbol$ = "+"
        CASE 3
            colour = 14: symbol$ = "/"
        CASE 4
            colour = 11: symbol$ = "#"
    END SELECT
    COLOR colour

    xMin = xMin + stepSizeX
    xMax = xMax - stepSizeX
    yMin = yMin + stepSizeY
    yMax = yMax - stepSizeY

    ' draw horizontal lines (top and bottom)
    FOR y = yMin TO yMax STEP yMax - yMin
        FOR x = xMin TO xMax STEP stepSizeX
            LOCATE y, x
            PRINT symbol$;
        NEXT x
    NEXT y
    xMax = x - stepSizeX

    ' draw vertical lines (left and right)
    FOR x = xMin TO xMax STEP xMax - xMin
        FOR y = yMin TO yMax STEP stepSizeY
            LOCATE y, x
            PRINT symbol$;
        NEXT y
    NEXT x
NEXT charType
END SUB

FUNCTION Opening
STATIC firstCall
CALL DrawOpeningBorder

COLOR 15
LOCATE 8, 30
line$ = "Mediaeval Merchants"
FOR i = 1 TO LEN(line$)
    PRINT MID$(line$, i, 1);
    IF firstCall = 0 THEN _DELAY 0.02
NEXT i

LOCATE 9, 31
line$ = "Written By Justin"
FOR i = 1 TO LEN(line$)
    PRINT MID$(line$, i, 1);
    IF firstCall = 0 THEN _DELAY 0.02
NEXT i

LOCATE 12, 37
PRINT "Start"
LOCATE 13, 37
PRINT "Load"
LOCATE 14, 37
PRINT "Quit"

FOR x = 18 TO 55 STEP 37
     COLOR 3: LOCATE 10, x: PRINT " ----- ";
     COLOR 3: LOCATE 11, x: PRINT "/-----\";
    COLOR 14: LOCATE 12, x: PRINT "| o o |";
    COLOR 14: LOCATE 13, x: PRINT "|  o  |";
    COLOR 14: LOCATE 14, x: PRINT "| --- |";
    COLOR 14: LOCATE 15, x: PRINT "\_____/";
NEXT x

newY = 12
COLOR 15
LOCATE newY, 35
PRINT ">"
isChosen = 0

DO
    DO
        in$ = INKEY$
    LOOP UNTIL in$ <> ""

    oldY = newY
    SELECT CASE in$
        CASE CHR$(0) + CHR$(72), "8"
            newY = newY - 1
            IF newY < 12 THEN newY = 12
        CASE CHR$(0) + CHR$(80), "2"
            newY = newY + 1
            IF newY > 14 THEN newY = 14
        CASE CHR$(13), CHR$(32)
            isChosen = 1
    END SELECT
    LOCATE oldY, 35
    PRINT " "
    LOCATE newY, 35
    PRINT ">"
LOOP UNTIL isChosen > 0

IF firstCall = 0 THEN firstCall = 1
Opening = newY - 12
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

