'$INCLUDE: 'UTIL.BI'

DEFINT A-Z

TYPE trail
	length AS INTEGER
	head AS INTEGER
	x AS INTEGER
END TYPE

CALL SetupTimer(2048)

SCREEN 0, 0, 0, 0
CLS 0
LOCATE ,,0
COLOR 7

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

		IF tr.head <= 25 AND tr.head > 0 THEN
			LOCATE tr.head, tr.x
			PRINT GetRandomChar;
		ENDIF

		tail = tr.head - tr.length
		IF tail <= 25 AND tail > 0 THEN
			LOCATE tail, tr.x
			PRINT " ";
		ELSEIF tail > 25 THEN
			ResetTrail i
		ENDIF
		
	NEXT
	PCOPY 1, 0
	SCREEN 0, 0, 0, 0
	CALL Delay(0.10)
LOOP
SLEEP 100

CALL UnSetupTimer

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