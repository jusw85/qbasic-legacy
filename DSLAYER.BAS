' Dragon Slayer
' Unfinished
' Inspired by QHack

'$INCLUDE: 'UTIL.BI'
'$INCLUDE: 'TILEMAP.BI'
'$INCLUDE: 'CAMERA.BI'

DEFINT A-Z
'$STATIC

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

SCREEN 0, 0, 0, 0
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
