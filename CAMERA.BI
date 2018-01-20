DECLARE SUB SetCamera (viewportArg AS rect, offscreenTileArg AS tile, doClampArg%)
DECLARE SUB DrawWorld (world() AS tile, centreY%, centreX%)

DECLARE FUNCTION WorldToScreenCoord% (y%, x%, r AS position)
