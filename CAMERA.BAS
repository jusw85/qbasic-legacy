'$INCLUDE: 'UTIL.BI'
'$INCLUDE: 'TILEMAP.BI'
'$INCLUDE: 'CAMERA.BI'

DEFINT A-Z
DIM SHARED viewport AS rect
DIM SHARED offscreenTile AS tile
DIM SHARED doClamp AS INTEGER
DIM SHARED minW AS position

SUB SetCamera (viewportArg AS rect, offscreenTileArg AS tile, doClampArg%)
viewport = viewportArg
offscreenTile = offscreenTileArg
doClamp = doClampArg
END SUB

SUB DrawWorld (world() AS tile, centreY%, centreX%)
minW.y = centreY - (viewport.sizey \ 2)
minW.x = centreX - (viewport.sizex \ 2)

DIM bounds AS rect
MakeRectTileMap world(), bounds
IF doClamp = TRUE THEN ClampCamera bounds

FOR y = 0 TO viewport.sizey
	FOR x = 0 to viewport.sizex
		iY = minW.y + y
		iX = minW.x + x
		IF iY < 0 OR iY > bounds.max.y OR iX < 0 OR iX > bounds.max.x THEN
			COLOR offscreenTile.colour
			sym$ = offscreenTile.symbol
		ELSE
			COLOR world(iY, iX).colour
			sym$ = world(iY, iX).symbol
		ENDIF
		LOCATE viewport.min.y + y, viewport.min.x + x
		PRINT sym$
	NEXT x
NEXT y
END SUB

SUB ClampCamera (bounds AS rect)
DIM maxW AS position
IF bounds.sizey <= viewport.sizey THEN
	centreY = (bounds.min.y + bounds.max.y) \ 2
	minW.y = centreY - (viewport.sizey \ 2)
ELSE
	maxW.y = minW.y + viewport.sizey
	IF minW.y < bounds.min.y THEN minW.y = bounds.min.y
	IF maxW.y > bounds.max.y THEN minW.y = bounds.max.y - viewport.sizey
ENDIF

IF bounds.sizex <= viewport.sizex THEN
	centreX = (bounds.min.x + bounds.max.x) \ 2
	minW.x = centreX - (viewport.sizex \ 2)
ELSE
	maxW.x = minW.x + viewport.sizex
	IF minW.x < bounds.min.x THEN minW.x = bounds.min.x
	IF maxW.x > bounds.max.x THEN minW.x = bounds.max.x - viewport.sizex

ENDIF
END SUB 

FUNCTION WorldToScreenCoord% (y%, x%, r AS position)
DIM offset AS position
offset.y = y - minW.y
offset.x = x - minW.x
r.y = viewport.min.y + offset.y
r.x = viewport.min.x + offset.x
IF r.y >= viewport.min.y AND r.y <= viewport.max.y AND r.x >= viewport.min.x AND r.x <= viewport.max.x THEN
	WorldToScreenCoord = TRUE
ELSE
	WorldToScreenCoord = FALSE
ENDIF
END SUB
