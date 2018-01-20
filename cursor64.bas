'http://www.qb64.net/forum/index.php?topic=12323.msg106309#msg106309
'- Blinkrate: the flashing speed of the cursor in milliseconds
'- CursorActive: set to 0 to disable the showing of the cursor, non-zero for regular operation
'- CursorX/CursorY: the X/Y coordinates on screen, in terms of character cells.
'- CursorShape: An integer that controls the style of cursor being drawn. 0 = vertical bar, 1 = underline, 2 = full-character box.

DIM SHARED Blinkrate AS INTEGER
DIM SHARED CursorActive AS INTEGER
DIM SHARED CursorX AS INTEGER
DIM SHARED CursorY AS INTEGER
DIM SHARED CursorShape AS INTEGER

Blinkrate = 100
CursorActive = 1
CursorX = 1
CursorY = 2
CursorShape = 2

SCREEN 0
f& = _LOADFONT("Px437_IBM_VGA8.ttf", 32, "MONOSPACE")
_FONT f&
LOCATE , , 0
PRINT "Test Cursor"
SLEEP
END

SUB _GL
    STATIC blinker!, showing
    IF TIMER - blinker! >= Blinkrate / 1000 THEN showing = NOT showing: blinker! = TIMER
    IF showing AND CursorActive THEN
        cy = CursorY
        cx = CursorX
        fh = _FONTHEIGHT
        fw = _FONTWIDTH

        'For SCREEN 0:
        h = _HEIGHT
        w = _WIDTH

        'For all other screen modes:
        'h = _HEIGHT / fh
        'w = _WIDTH / fw

        _glMatrixMode _GL_PROJECTION
        _glLoadIdentity
        _glOrtho 0, w * fw, 0, h * fh, 0, -1
        x = (cx - 1) * fw
        SELECT CASE CursorShape
            CASE 0
                'Left vertical bar
                _glBegin _GL_LINES
                _glVertex2i x + 1, (h - cy) * fh
                _glVertex2i x + 1, (h - cy + 1) * fh
            CASE 1
                'Underline
                _glBegin _GL_LINES
                _glVertex2i x, (h - cy) * fh
                _glVertex2i x + fw, (h - cy) * fh
            CASE 2
                'Box
                _glBegin _GL_QUADS
                _glVertex2i x, (h - cy) * fh
                _glVertex2i x, (h - cy + 1) * fh
                _glVertex2i x + fw, (h - cy + 1) * fh
                _glVertex2i x + fw, (h - cy) * fh
        END SELECT
        _glEnd
    END IF
END SUB
