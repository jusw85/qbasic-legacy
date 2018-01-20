' Testing the high resolution timer function
'$INCLUDE: 'UTIL.BI'

DEFINT A-Z
SCREEN 13 '25 x 40

CALL SetupTimer(2048)

s$ = "The fox jumped over the dog."

xLoc = 8
yLoc = 12
FOR strIndex = 1 TO LEN(s$)
    c$ = MID$(s$, strIndex, 1)
    FOR colorVal = 16 to 31
        LOCATE yLoc, xLoc
        COLOR colorVal
        PRINT c$;
        CALL Delay(0.01)
    NEXT colorVal
    xLoc = xLoc + 1
NEXT strIndex

CALL WaitForAnykey

xLoc = 8
yLoc = 12
FOR strIndex = 1 TO LEN(s$)
    c$ = MID$(s$, strIndex, 1)
    FOR colorVal = 31 to 16 STEP -1
        LOCATE yLoc, xLoc
        COLOR colorVal
        PRINT c$;
        CALL Delay(0.01)
    NEXT colorVal
    xLoc = xLoc + 1
NEXT strIndex

CALL UnSetupTimer
