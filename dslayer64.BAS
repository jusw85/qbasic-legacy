' Dragon Slayer
' Unfinished
' Inspired by QHack

DEFINT A-Z
'$STATIC

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

TYPE tile
	walkable AS INTEGER
	symbol AS STRING * 1
    colour AS INTEGER
END TYPE

DECLARE SUB InitTileMap ()
DECLARE SUB CreateEmptyMap (map() AS tile)
DECLARE SUB PopulateMap (map() AS tile, percentFull%)
DECLARE SUB GetEmptyTile (map() AS tile, p AS position)
DECLARE SUB MakeRectTileMap(map() AS tile, r AS rect)

DIM SHARED isInitialisedT AS INTEGER
DIM SHARED floor AS tile
DIM SHARED wall AS tile

DECLARE SUB SetCamera (viewportArg AS rect, offscreenTileArg AS tile, doClampArg%)
DECLARE SUB DrawWorld (world() AS tile, centreY%, centreX%)

DECLARE FUNCTION WorldToScreenCoord% (y%, x%, r AS position)

DIM SHARED viewportL AS rect
DIM SHARED offscreenTileL AS tile
DIM SHARED doClamp AS INTEGER
DIM SHARED minW AS position

TYPE monster
    names AS STRING * 16
    symbol AS STRING * 1
    colour AS INTEGER
    maxHp AS INTEGER
    maxMp AS INTEGER
END TYPE

TYPE entity
    isAlive AS INTEGER
    mId AS INTEGER
    hp AS INTEGER
    maxhp AS INTEGER
    mp AS INTEGER
    maxmp AS INTEGER
    xy AS position
    minDmg AS INTEGER
    maxDmg AS INTEGER
END TYPE

DECLARE SUB TitleMain ()
DECLARE SUB GameMain ()
DECLARE SUB FarewellScreen ()
DECLARE SUB InstructionsScreen ()
DECLARE SUB CreditsScreen ()
DECLARE SUB ResetStats ()
DECLARE SUB InitMonsters ()

DECLARE SUB DrawMap ()
DECLARE SUB DrawHUD ()
DECLARE SUB DrawStats ()
DECLARE SUB DrawEntities ()
DECLARE SUB Message (msg$)

DECLARE FUNCTION TitleScreen (previousChoice)
DECLARE FUNCTION ResumeScreen ()
DECLARE FUNCTION DoAttack (fromEntity, toEntity)
DECLARE FUNCTION CheckGameOver ()

CONST NoAction = 0
CONST AttackMoveAction = 1
CONST WaitAction = 2

DIM SHARED monsterList(16) AS monster
DIM SHARED entityList(16) AS entity

InitUtil
InitTileMap
InitMonsters

REDIM SHARED map(RandomInt(10, 40), RandomInt(20, 60)) AS tile
CreateEmptyMap map()
PopulateMap map(), 10

DIM SHARED viewport AS rect
DIM SHARED offscreenTile AS tile
offscreenTile.walkable = FALSE
offscreenTile.symbol = "~"
offscreenTile.colour = 9
MakeRect 4, 22, 2, 57, viewport
SetCamera viewport, offscreenTile, TRUE

' Main

DIM SHARED hasOngoingGame
hasOngoingGame = FALSE

'SCREEN 0, 0, 0, 0
SCREEN _NEWIMAGE(80, 25, 0)
DO: LOOP UNTIL _SCREENEXISTS

_TITLE "Dragon Slayer"
f& = _LOADFONT("Px437_IBM_VGA8.ttf", 32, "MONOSPACE")
_FONT f&

fw = _FONTWIDTH(f&): fh = _FONTHEIGHT(f&)
userwidth& = _DESKTOPWIDTH: userheight& = _DESKTOPHEIGHT 'get current screen resolution
scrnwidth& = fw * _WIDTH: scrnheight& = fh * _HEIGHT 'get the dimensions of the program screen
_SCREENMOVE (userwidth& \ 2 - scrnwidth& \ 2) - 3, (userheight& \ 2 - scrnheight& \ 2) - 29 'centre screen

CLS 0

InitUtil
TitleMain
END

SUB TitleMain
choice = 0
quitGame = FALSE
DO
    choice = TitleScreen(choice)

    IF choice = 0 THEN
        GameMain
    ELSEIF choice = 1 THEN
        InstructionsScreen
    ELSEIF choice = 2 THEN
        CreditsScreen
    ELSEIF choice = 3 THEN
        quitGame = TRUE
    ENDIF
LOOP UNTIL quitGame = TRUE
FarewellScreen
END SUB

SUB GameMain
resumeOngingGame = ResumeScreen
IF resumeOngingGame = FALSE THEN ResetStats

CLS 0
DrawHUD
DrawStats
DrawMap
DrawEntities

DIM toMove AS position
DIM pc AS entity
DIM e AS entity
DIM e2 AS entity
DO
    DO: in$ = INKEY$: LOOP UNTIL in$ <> ""
    IF CheckGameOver = TRUE THEN EXIT DO
    pc = entityList(0)
    msg$ = ""
    action = NoAction

    IF in$ = HomeKey$ OR in$ = "7" THEN
        action = AttackMoveAction
        toMove.y = pc.xy.y - 1
        toMove.x = pc.xy.x - 1
    ELSEIF in$ = UpKey$ OR in$ = "8" THEN
        action = AttackMoveAction
        toMove.y = pc.xy.y - 1
        toMove.x = pc.xy.x
    ELSEIF in$ = PgupKey$ OR in$ = "9" THEN
        action = AttackMoveAction
        toMove.y = pc.xy.y - 1
        toMove.x = pc.xy.x + 1
    ELSEIF in$ = LeftKey$ OR in$ = "4" THEN
        action = AttackMoveAction
        toMove.y = pc.xy.y
        toMove.x = pc.xy.x - 1
    ELSEIF in$ = RightKey$ OR in$ = "6" THEN
        action = AttackMoveAction
        toMove.y = pc.xy.y
        toMove.x = pc.xy.x + 1
    ELSEIF in$ = EndKey$ OR in$ = "1" THEN
        action = AttackMoveAction
        toMove.y = pc.xy.y + 1
        toMove.x = pc.xy.x - 1
    ELSEIF in$ = DownKey$ OR in$ = "2" THEN
        action = AttackMoveAction
        toMove.y = pc.xy.y + 1
        toMove.x = pc.xy.x
    ELSEIF in$ = PgdownKey$ OR in$ = "3" THEN
        action = AttackMoveAction
        toMove.y = pc.xy.y + 1
        toMove.x = pc.xy.x + 1
    ELSEIF in$ = "." OR in$ = "5" THEN
		action = WaitAction
    ELSEIF in$ = EscapeKey$ THEN
        hasOngoingGame = TRUE
        EXIT DO
    ELSE
        msg$ = msg$ + "I don't quite understand. "
    ENDIF

    IF action = AttackMoveAction THEN
        isAttacking = FALSE
        FOR i = 1 to UBOUND(entityList, 1)
            e = entityList(i)
            IF e.isAlive AND e.xy.y = toMove.y AND e.xy.x = toMove.x THEN
                isAttacking = TRUE
                dmg = DoAttack(0, i)
                n$ = RTRIM$(monsterList(e.mId).names)
                IF dmg < 15 THEN
                    msg$ = msg$ + "You slash the " + n$ + ". "
                ELSEIF dmg >= 15 THEN
                    msg$ = msg$ + "You strike hard at the " + n$ + ". "
                ENDIF
            ENDIF
        NEXT
        IF isAttacking = FALSE THEN
            IF map(toMove.y, toMove.x).walkable THEN
                entityList(0).xy.y = toMove.y
                entityList(0).xy.x = toMove.x
            ENDIF
            IF map(toMove.y, toMove.x).symbol$ = "#" THEN
                action = NoAction
                msg$ = msg$ + "Ouch! You bump into a wall. "
            ENDIF
        ENDIF
    ENDIF
    
    IF action <> NoAction THEN
        pc = entityList(0)
        FOR i = 1 to UBOUND(entityList, 1)
            e = entityList(i)
            IF e.isAlive = TRUE THEN
                toMove.x = pc.xy.x
                toMove.y = pc.xy.y
                IF e.xy.x > pc.xy.x THEN toMove.x = e.xy.x - 1
                IF e.xy.x < pc.xy.x THEN toMove.x = e.xy.x + 1
                IF e.xy.y > pc.xy.y THEN toMove.y = e.xy.y - 1
                IF e.xy.y < pc.xy.y THEN toMove.y = e.xy.y + 1
                isMoving = FALSE
                isAttacking = FALSE
                
                IF toMove.y = pc.xy.y AND toMove.x = pc.xy.x THEN
                    isAttacking = TRUE
                ELSE
                    isMoving = map(toMove.y, toMove.x).walkable
                    ' check for other entities here
                    FOR j = 1 to UBOUND(entityList, 1)
                        e2 = entityList(j)
                        IF e2.isAlive = TRUE AND toMove.y = e2.xy.y AND toMove.x = e2.xy.x THEN
                            isMoving = FALSE
                        ENDIF
                    NEXT
                ENDIF
                
                IF isMoving = TRUE THEN
                    entityList(i).xy.y = toMove.y
                    entityList(i).xy.x = toMove.x
                ENDIF
                IF isAttacking THEN
                    dmg = DoAttack(i, 0)
                    n$ = RTRIM$(monsterList(e.mId).names)
                    IF dmg < 10 THEN
                        msg$ = msg$ + "The " + n$ + " cuts you. "
                    ELSEIF dmg >= 10 THEN
                        msg$ = msg$ + "The " + n$ + " claws you. "
                    ENDIF
                ENDIF
            ENDIF
        NEXT
    ENDIF

    FOR i = 0 to UBOUND(entityList, 1)
        IF entityList(i).isAlive = TRUE AND entityList(i).hp <= 0 THEN
            entityList(i).isAlive = FALSE
            IF i = 0 THEN
                msg$ = msg$ + "You die. "
            ELSE
                n$ = RTRIM$(monsterList(entityList(i).mId).names)
                msg$ = msg$ + "The " + n$ + " dies. "
            ENDIF
        ENDIF
    NEXT

    SCREEN 0, 0, 1, 0
    PCOPY 0, 1
    DrawStats
    DrawMap
    Message msg$
    PCOPY 1, 0
    SCREEN 0, 0, 0, 0
    DrawEntities
LOOP
END SUB

FUNCTION DoAttack(fromEntity, toEntity)
DIM eF AS entity
eF = entityList(fromEntity)
dmg = RandomInt(eF.minDmg, eF.maxDmg)
DoAttack = dmg
entityList(toEntity).hp = entityList(toEntity).hp - dmg
END FUNCTION

FUNCTION ResumeScreen
DIM cursorXY AS position
IF hasOngoingGame = TRUE THEN
    CLS 0
    COLOR 7: LOCATE 1, 1: PRINT "Do you wish to resume? (y/n)";
    cursorXY.y = CSRLIN: cursorXY.x = POS(0)

    isChosen = FALSE
    DO
        LOCATE cursorXY.y, cursorXY.x, 1

        DO: in$ = INKEY$: LOOP UNTIL in$ <> ""

        IF in$ = "n" OR in$ = "N" OR in$ = EscapeKey$ THEN
            isChosen = TRUE
            ResumeScreen = FALSE
        ELSEIF in$ = "y" THEN
            isChosen = TRUE
            ResumeScreen = TRUE
        ELSE
            LOCATE 3, 1: PRINT "Please enter y or n."
        ENDIF
    LOOP UNTIL isChosen = TRUE
ENDIF
END FUNCTION

FUNCTION CheckGameOver ()
CheckGameOver = FALSE
youAlive = entityList(0).isAlive
enemiesAlive = FALSE
FOR i = 1 to UBOUND(entityList, 1)
    IF entityList(i).isAlive = TRUE THEN
        enemiesAlive = TRUE
        EXIT FOR
    ENDIF
NEXT

IF youAlive = TRUE AND enemiesAlive = TRUE THEN EXIT SUB
IF youAlive = FALSE AND enemiesAlive = FALSE THEN
    msg1$ = "Your slay your final foe. However, you have suffered grievous wounds."
    msg2$ = "You lean against the dungeon walls to await your death."
ELSEIF youAlive = TRUE AND enemiesAlive = FALSE THEN
    msg1$ = "With a mighty blow, you slay your final foe."
    msg2$ = "You are victorious!"
ELSEIF youAlive = FALSE AND enemiesAlive = TRUE THEN
    msg1$ = "Unfortunately, your enemies were too strong for you."
    msg2$ = "You have failed in your quest."
ENDIF

CLS 0
COLOR 7: LOCATE 1, 1, 1
PRINT msg1$: PRINT msg2$
PRINT "Do you wish to quit? (y/n) ";
DIM cursorXY AS position
cursorXY.y = CSRLIN: cursorXY.x = POS(0) - 1
DO
    LOCATE cursorXY.y, cursorXY.x, 1
    DO: in$ = INKEY$: LOOP UNTIL in$ <> ""

    IF in$ = "y" OR in$ = "Y" OR in$ = EscapeKey$ THEN
        FarewellScreen
        END
    ELSEIF in$ = "n" OR in$ = "N" THEN
        hasOngoingGame = FALSE
    ELSE
        LOCATE 5, 1: PRINT "Please enter y or n."
    ENDIF
LOOP UNTIL in$ = "n" OR in$ = "N"
CheckGameOver = TRUE
END FUNCTION

SUB Message (msg$)
VIEW PRINT 24 to 25
CLS: LOCATE 24, 1: COLOR 7: PRINT msg$;
VIEW PRINT
END SUB

SUB ResetStats
ERASE map
REDIM map(RandomInt(10, 40), RandomInt(20, 60)) AS tile
CreateEmptyMap map()
PopulateMap map(), 10

DIM e AS entity
DIM p AS position
e.isAlive = TRUE
e.mId = 0
e.maxHp = monsterList(e.mId).maxHp
e.maxMp = monsterList(e.mId).maxMp
e.hp = e.maxHp
e.mp = e.maxMp
e.minDmg = 10
e.maxDmg = 20
GetEmptyTile map(), p
e.xy.y = p.y
e.xy.x = p.x
entityList(0) = e

e.isAlive = TRUE
e.mId = 1
e.maxHp = monsterList(e.mId).maxHp
e.maxMp = monsterList(e.mId).maxMp
e.hp = e.maxHp
e.mp = e.maxMp
e.minDmg = 5
e.maxDmg = 15
GetEmptyTile map(), p
e.xy.y = p.y
e.xy.x = p.x
entityList(1) = e

e.isAlive = TRUE
e.mId = 2
e.maxHp = monsterList(e.mId).maxHp
e.maxMp = monsterList(e.mId).maxMp
e.hp = e.maxHp
e.mp = e.maxMp
e.minDmg = 3
e.maxDmg = 5
FOR i = 2 to 6
    GetEmptyTile map(), p
    e.xy.y = p.y
    e.xy.x = p.x
    entityList(i) = e
NEXT
END SUB

SUB DrawEntities
DIM e AS entity
FOR i = UBOUND(entityList, 1) to 0 STEP -1
    e = entityList(i)
    IF e.isAlive = TRUE THEN
        DIM p AS position
        onScreen = WorldToScreenCoord(e.xy.y, e.xy.x, p)
        IF onScreen THEN
            LOCATE p.y, p.x
            COLOR monsterList(e.mId).colour: PRINT monsterList(e.mId).symbol;
            LOCATE ,POS(0) - 1,1
        ELSE
            LOCATE ,,0
        ENDIF
    ENDIF
NEXT
END SUB

SUB DrawStats
DIM pc AS entity
pc = entityList(0)
COLOR 10
LOCATE 5, 61: PRINT "Hp:"; pc.hp; "/"; pc.maxhp
'LOCATE 10, 41: PRINT "Hp:"; entityList(1).hp; "/"; entityList(1).maxhp
COLOR 11
LOCATE 6, 61: PRINT "Mp:"; pc.mp; "/"; pc.maxmp
'LOCATE 11, 41: PRINT "Mp:"; entityList(1).mp; "/"; entityList(1).maxmp
END SUB

SUB DrawMap
DIM pc AS entity
pc = entityList(0)
DrawWorld map(), pc.xy.y, pc.xy.x
END SUB

SUB DrawHUD
LOCATE 1, 1
COLOR 6: PRINT "Dragon Slayer"
COLOR 8: PRINT "============="
COLOR 15:PRINT "##########################################################"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "#                                                        #"
         PRINT "##########################################################"

COLOR 1: LOCATE 3, 61: PRINT "Player Stats:"
COLOR 9: LOCATE 4, 61: PRINT "============="
'COLOR 4: LOCATE 8, 41: PRINT "Dragon Stats:"
'COLOR 12: LOCATE 9, 41: PRINT "============="
END SUB

SUB InstructionsScreen
CLS 0
COLOR 10: PRINT "Instructions"
COLOR 7:  PRINT "============"
COLOR 7:  PRINT "1. Use ";:COLOR 9:PRINT "numpad or arrow keys";:COLOR 7:PRINT " to move around"
COLOR 7:  PRINT "2. Kill the ";:COLOR 12:PRINT "dragon";:COLOR 7:PRINT "."
COLOR 7:  PRINT "3. Hit ";:COLOR 9:PRINT "ESC";:COLOR 7:PRINT " to exit."
COLOR 7:  PRINT "4. Good luck!"
COLOR 7:  PRINT
COLOR 7:  PRINT "Press ";:COLOR 9:PRINT "anykey";:COLOR 7:PRINT " to return...";
LOCATE ,,1
WaitForAnykey
END SUB

SUB CreditsScreen
CLS 0
COLOR 10: PRINT "Credits"
COLOR 7:  PRINT "======="
COLOR 7:  PRINT "Programmers: ";:COLOR 12:PRINT "Justin Wong"
COLOR 7:  PRINT
COLOR 7:  PRINT "Press ";:COLOR 9:PRINT "anykey";:COLOR 7:PRINT " to return...";
LOCATE ,,1
WaitForAnykey
END SUB

SUB FarewellScreen
CLS 0
COLOR 7
line$ = "Till next time, dragon slayer!"
LOCATE 12, (80 - LEN(line$)) / 2, 0
PRINT line$
END SUB

FUNCTION TitleScreen(previousChoice)
CLS 0
LOCATE 5, 1, 0
COLOR 9:  PRINT "                                DRAGON SLAYER"
COLOR 9:  PRINT "                                ============="
PRINT
COLOR 5:  PRINT "                                 Start"
COLOR 2:  PRINT "                                 Instructions"
COLOR 4:  PRINT "                                 Credits"
COLOR 14: PRINT "                                 Exit"
PRINT
COLOR 12: PRINT "                        Use arrows to move up and down"
          PRINT "                             Return to select"
          PRINT "                              Escape to quit"

COLOR 15

isChosen = FALSE
y = previousChoice + 8
LOCATE y, 33: PRINT ">"
LOCATE y, 46: PRINT "<"

DO
    DO: in$ = INKEY$: LOOP UNTIL in$ <> ""

    LOCATE y, 33: PRINT " "
    LOCATE y, 46: PRINT " "

    IF in$ = DownKey$ OR in$ = "2" THEN
        y = y + 1
        IF y > 11 THEN y = 8
    ELSEIF in$ = UpKey$ OR in$ = "8" THEN
        y = y - 1
        IF y < 8 THEN y = 11
    ELSEIF in$ = EnterKey$ THEN
        isChosen = TRUE
    ELSEIF in$ = EscapeKey$ THEN
        isChosen = TRUE
        y = 11
    ENDIF

    LOCATE y, 33: PRINT ">"
    LOCATE y, 46: PRINT "<"
LOOP UNTIL isChosen = TRUE
TitleScreen = y - 8
END FUNCTION

SUB InitMonsters ()
DIM m AS monster
m.symbol = "@"
m.colour = 14
m.maxHp = 1000
m.maxMp = 50
monsterList(0) = m

m.names = "red dragon"
m.symbol = "D"
m.colour = 4
m.maxHp = 100
m.maxMp = 50
monsterList(1) = m

m.names = "goblin"
m.symbol = "g"
m.colour = 6
m.maxHp = 20
m.maxMp = 0
monsterList(2) = m
END SUB

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

SUB InitTileMap
' Initialise some values
IF isInitialisedT = TRUE THEN EXIT SUB
floor.walkable = TRUE
floor.symbol = "."
floor.colour = 7
wall.walkable = FALSE
wall.symbol = "#"
wall.colour = 7
isInitialised = TRUE
END SUB

SUB CreateEmptyMap (map() AS tile)
DIM bounds AS rect
MakeRectTileMap map(), bounds
FOR y = bounds.min.y to bounds.max.y
	FOR x = bounds.min.x to bounds.max.x
		IF y = 0 OR x = 0 OR y = bounds.max.y OR x = bounds.max.x THEN
			map(y, x) = wall
		ELSE
			map(y, x) = floor
		ENDIF
	NEXT x
NEXT y
END SUB

SUB PopulateMap (map() AS tile, percentFull%)
DIM bounds AS rect
DIM p AS position
MakeRectTileMap map(), bounds
mapSize& = ((bounds.sizey - 2) * (bounds.sizex - 2))
numPillars& = mapSize& * percentFull% \ 100
FOR i = 1 to numPillars&
	GetEmptyTile map(), p
	map(p.y, p.x) = wall
NEXT
END SUB

SUB GetEmptyTile (map() AS tile, p AS position)
DIM bounds AS rect
MakeRectTileMap map(), bounds
DO
	ry = RandomInt(1, bounds.max.y - 1)
	rx = RandomInt(1, bounds.max.x - 1)
LOOP UNTIL map(ry, rx).symbol <> "#"
p.y = ry
p.x = rx
END SUB

SUB MakeRectTileMap(map() AS tile, r AS rect)
r.min.y = LBOUND(map, 1)
r.max.y = UBOUND(map, 1)
r.min.x = LBOUND(map, 2)
r.max.x = UBOUND(map, 2)
r.sizey = r.max.y - r.min.y
r.sizex = r.max.x - r.min.x
END SUB

SUB SetCamera (viewportLArg AS rect, offscreenTileLArg AS tile, doClampArg%)
viewportL = viewportLArg
offscreenTileL = offscreenTileLArg
doClamp = doClampArg
END SUB

SUB DrawWorld (world() AS tile, centreY%, centreX%)
minW.y = centreY - (viewportL.sizey \ 2)
minW.x = centreX - (viewportL.sizex \ 2)

DIM bounds AS rect
MakeRectTileMap world(), bounds
IF doClamp = TRUE THEN ClampCamera bounds

FOR y = 0 TO viewportL.sizey
	FOR x = 0 to viewportL.sizex
		iY = minW.y + y
		iX = minW.x + x
		IF iY < 0 OR iY > bounds.max.y OR iX < 0 OR iX > bounds.max.x THEN
			COLOR offscreenTileL.colour
			sym$ = offscreenTileL.symbol
		ELSE
			COLOR world(iY, iX).colour
			sym$ = world(iY, iX).symbol
		ENDIF
		LOCATE viewportL.min.y + y, viewportL.min.x + x
		PRINT sym$
	NEXT x
NEXT y
END SUB

SUB ClampCamera (bounds AS rect)
DIM maxW AS position
IF bounds.sizey <= viewportL.sizey THEN
	centreY = (bounds.min.y + bounds.max.y) \ 2
	minW.y = centreY - (viewportL.sizey \ 2)
ELSE
	maxW.y = minW.y + viewportL.sizey
	IF minW.y < bounds.min.y THEN minW.y = bounds.min.y
	IF maxW.y > bounds.max.y THEN minW.y = bounds.max.y - viewportL.sizey
ENDIF

IF bounds.sizex <= viewportL.sizex THEN
	centreX = (bounds.min.x + bounds.max.x) \ 2
	minW.x = centreX - (viewportL.sizex \ 2)
ELSE
	maxW.x = minW.x + viewportL.sizex
	IF minW.x < bounds.min.x THEN minW.x = bounds.min.x
	IF maxW.x > bounds.max.x THEN minW.x = bounds.max.x - viewportL.sizex

ENDIF
END SUB 

FUNCTION WorldToScreenCoord% (y%, x%, r AS position)
DIM offset AS position
offset.y = y - minW.y
offset.x = x - minW.x
r.y = viewportL.min.y + offset.y
r.x = viewportL.min.x + offset.x
IF r.y >= viewportL.min.y AND r.y <= viewportL.max.y AND r.x >= viewportL.min.x AND r.x <= viewportL.max.x THEN
	WorldToScreenCoord = TRUE
ELSE
	WorldToScreenCoord = FALSE
ENDIF
END SUB

