'$INCLUDE: 'UTIL.BI'
'$INCLUDE: 'TILEMAP.BI'

DIM SHARED isInitialised AS INTEGER
DIM SHARED floor AS tile
DIM SHARED wall AS tile

SUB InitTileMap
' Initialise some values
IF isInitialised = TRUE THEN EXIT SUB
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
