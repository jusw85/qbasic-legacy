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
