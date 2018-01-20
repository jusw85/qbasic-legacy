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
