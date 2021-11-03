###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Piece Scene ### by Fenxy
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
extends Area2D



###################################################################################################################
      # Variables #
###################################################################################################################
  # 
const LYNX_QUEEN = 0
const LYNX_KNIGHT = 1

var active = true 
var locked = false
var file = 0
var rank = 0
var value = 0
var type = "zZ"
var localPlayerColor = "z"
var clicked = false
var tapped = false
var ignoreTaps = false
var mousedOver = false
var clickedHighlight = false
var clickedHighlightShowing = false
var dragToMove = false
var defaultZ = 0
var squares = PoolVector3Array()      # rename moveableSquares
var checkLine = PoolVector2Array()
var allSquares = PoolVector3Array()

var state = 0
# King          - holds whether or not this piece has moved
# Lynx          - holds the attack state
# Mage          - holds the total number of pawns captured
# Marshall      - holds whether or not this piece has moved
# Pawn          - holds whether or not this piece has moved

var count = 0
# Lynx          - holds the turn count and resets on 9
# Mage          - holds the available charges



###################################################################################################################
      # _ready #
###################################################################################################################
  # Called when the node enters the scene tree for the first time
  #   
func _ready():
  defaultZ = z_index
  squares = []
  checkLine = []
  $CrownTexture.hide()
  $CollisionShape2D.shape.extents = Vector2((Game.SQUARE_SIZE / 2), (Game.SQUARE_SIZE / 2))



###################################################################################################################
      # _input #
###################################################################################################################
  # Use global input for smooth dragging
  #   
func _input(_event):
  if !locked and clicked and localPlayerColor == type[0]:
    global_position = get_viewport().get_mouse_position()
    global_position.x = clamp(
        global_position.x,
        (get_parent().global_position.x - (Game.BOARD_WINDOW_SIZE / 2) + (Game.SQUARE_SIZE / 4)),
        (get_parent().global_position.x + (Game.BOARD_WINDOW_SIZE / 2) - (Game.SQUARE_SIZE / 4)))
    global_position.y = clamp(
        global_position.y,
        (get_parent().global_position.y - (Game.BOARD_WINDOW_SIZE / 2) + (Game.SQUARE_SIZE / 4)),
        (get_parent().global_position.y + (Game.BOARD_WINDOW_SIZE / 2) - (Game.SQUARE_SIZE / 4)))
        


###################################################################################################################
      # _on_Piece_mouse_entered #
###################################################################################################################
  # Received when the mouse enters the pieces collision box
  #
func _on_Piece_mouse_entered():
  mousedOver = true
  updateSquareHighlight()



###################################################################################################################
      # _on_Piece_mouse_entered #
###################################################################################################################
  # Received when the mouse leaves the pieces collision box
  #
func _on_Piece_mouse_exited():
  mousedOver = false
  clickedHighlight = false
  updateSquareHighlight()
    
    
    
###################################################################################################################
      # _on_Piece_input_event #
###################################################################################################################
  # This is registered with the CollisionShape2D
  # There cannot be any control classes above it in the parent class, otherwise their input must be ignored
  #
func _on_Piece_input_event(_viewport, event, _shape_idx):
  if active:
    if !locked and localPlayerColor == type[0]:
      if event is InputEventScreenTouch:
        if event.pressed == true:
          if !dragToMove:
            tapped = true
            get_parent().grabPiece(self, true)
          elif clicked == false:
            clicked = true
            z_index = (defaultZ + 10)
            get_parent().grabPiece(self, false)
        elif event.pressed == false:
          if dragToMove and clicked == true:
            clicked = false
            z_index = defaultZ
            get_parent().dropPiece(self)
      elif event is InputEventMouseButton:
        if event.pressed == true and event.button_index == BUTTON_LEFT:
          if !dragToMove:
            tapped = true
            get_parent().grabPiece(self, true)
          elif clicked == false:
            clicked = true
            z_index = (defaultZ + 10)
            get_parent().grabPiece(self, false)
        elif event.pressed == false and event.button_index == BUTTON_LEFT:
          if dragToMove and clicked == true:
            clicked = false
            z_index = defaultZ
            get_parent().dropPiece(self)
        elif event.pressed == true and event.button_index == BUTTON_RIGHT:
          if dragToMove and clicked == true:
            clicked = false
            z_index = defaultZ
            get_parent().cancleDrop(file, rank)
          
    else:
      if event is InputEventScreenTouch:
        if event.pressed == true and clickedHighlight == false:
          clickedHighlight = true
          updateSquareHighlight()
        elif event.pressed == false and clickedHighlight == true:
          clickedHighlight = false
          updateSquareHighlight()
      elif event is InputEventMouseButton:
        if event.pressed == true and clickedHighlight == false and event.button_index == BUTTON_LEFT:
          clickedHighlight = true
          updateSquareHighlight()
        elif event.pressed == false and clickedHighlight == true and event.button_index == BUTTON_LEFT:
          clickedHighlight = false
          updateSquareHighlight()
        elif event.pressed == true and clickedHighlight == true and event.button_index == BUTTON_RIGHT:
          clickedHighlight = false
          updateSquareHighlight()
        
        
        
###################################################################################################################
      # updateSquareHighlight #
###################################################################################################################
  # Update whether or not the viewable only squares are visible
  #   
func updateSquareHighlight():
  if !ignoreTaps:
    var meow = clickedHighlightShowing
    if mousedOver and clickedHighlight:
      clickedHighlightShowing = true
    else:
      clickedHighlightShowing = false
      
    if meow != clickedHighlightShowing:
      if clickedHighlightShowing:
        get_parent().grabPiece(self, false)
      else:
        get_parent().cancleDrop(file, rank)
  
  
        
###################################################################################################################
      # setMoveOption #
###################################################################################################################
  # Set the method for moving this piece. IE: drag and drop, or click and click
  #   
func setMoveOption(index):
  tapped = false
  clicked = false
  if index == Game.MOVE_DRAG:
    dragToMove = true
  else:
    dragToMove = false
    
        
        
###################################################################################################################
      # setTapped #
###################################################################################################################
  # Sets tapped
  #   
func setTapped(t):
  tapped = t
    
        
        
###################################################################################################################
      # setTapped #
###################################################################################################################
  # Sets ignore taps
  #   
func setIgnoreTaps(t):
  ignoreTaps = t
        
        
        
###################################################################################################################
      # cancleSelf #
###################################################################################################################
  # Used to externally call get_parent().cancleDrop(file, rank) from within
  #   
func cancleSelf():
  tapped = false
  clicked = false
  get_parent().cancleDrop(file, rank)
       
       
        
###################################################################################################################
      # dropSelf #
###################################################################################################################
  # Used to externally call get_parent().dropPiece(self) from within
  #   
func dropSelf():
  tapped = false
  clicked = false
  get_parent().dropPiece(self)
        
        
        
###################################################################################################################
      # setActive #
###################################################################################################################
  # Sey whether or not the piece is active
  #   
func setActive(a):
  active = a
  clicked = false
  tapped = false
  get_parent().cancleDrop(file, rank)
  
  
        
###################################################################################################################
      # setLocked #
###################################################################################################################
  # Lock the square so it cannot be moved
  #   
func setLocked():
  locked = true
  tapped = false
  clicked = false
  get_parent().cancleDrop(file, rank)



###################################################################################################################
      # setType #
###################################################################################################################
  # Set the piece type and the team color of whichever player is loading this client
  #   
func setType(t, l):
  type = t
  localPlayerColor = l
  $Pieces.animation = t



###################################################################################################################
      # getTypeIcon / setTypeIcon #
###################################################################################################################
  # Get / set the icon number for this specific type
  #   
func getTypeIcon():
  return $Pieces.frame
  
func setTypeIcon(n):
  if n <= $Pieces.frames.get_frame_count(type):
    $Pieces.set_frame(n)
  
  
  
###################################################################################################################
      # showCrown / hideCrown #
###################################################################################################################
  # Toggle the crown texture above the piece.
  #   
func showCrown():
  $CrownTexture.show()
func hideCrown():
  $CrownTexture.hide()
    
      

###################################################################################################################
      # removeSquare #
###################################################################################################################
  # Remove a specific square from the list of moveable squares
  #   
func removeSquare(i):
  squares.remove(i)
  
  
  
###################################################################################################################
      # dropPiece #
###################################################################################################################
  # Called from the board when a move is cancled from the board scene
  #   
func dropPiece():
  if clicked:
    clicked = false
    get_parent().cancleDrop(file, rank)
    
    
    
###################################################################################################################
      # updateTurn #
###################################################################################################################
  # Called at the end of each turn, aka every 2 moves
  # 
func updateTurn(turnValue, _pieceSet):
  if type[1] == "C":
    count += turnValue
    if count >= 9:
      count = 0
      if state <= 0:
        state = 1
        setTypeIcon(LYNX_KNIGHT)
      else:
        state = 0
        setTypeIcon(LYNX_QUEEN)
    
    
    
###################################################################################################################
      # updateMove #
###################################################################################################################
  # Called every time a piece has moved
  # 
func updateMove(_turnValue, _pieceSet):
  pass


###################################################################################################################
      # updateSquareList #
###################################################################################################################
  # This takes in a piece set and updates this pieces moveable squares and checkline depending on it's type
  # 
func updateSquareList(pieceSet):
  if type[1] == "P":    # "P" is reserved for default behavior
    movePawn(pieceSet)  # "P" is reserved for default behavior
  elif type[1] == "K":  # "K" is reserved for the king
    moveKing(pieceSet)  # "K" is reserved for the king
    
  elif type[1] == "A":
    moveGeneral(pieceSet)
  elif type[1] == "C":
    moveLynx(pieceSet)
  elif type[1] == "D":
    movePredator(pieceSet)
  elif type[1] == "E":
    moveElite(pieceSet)
  elif type[1] == "G":
    moveGuardian(pieceSet)
  elif type[1] == "H":
    moveHunter(pieceSet)
  elif type[1] == "I":
    moveMinion(pieceSet)
  elif type[1] == "M":
    moveMarshall(pieceSet)
  elif type[1] == "N":
    moveKnight(pieceSet)
  elif type[1] == "O":
    moveMammoth(pieceSet)
  elif type[1] == "Q":
    moveQueen(pieceSet)
  elif type[1] == "R":
    moveRook(pieceSet)
  elif type[1] == "T":
    moveMage(pieceSet)
  elif type[1] == "X":
    movePhoenix(pieceSet)
  elif type[1] == "Z":
    moveZ(pieceSet)



###################################################################################################################
      # testMoveSquare #
###################################################################################################################
  # Tests a square for moveability
  # return[keepGrowing, squareState]
  # squareState = [0 = empty, 1 = skip, 2 = king, 3 = guarded, 4 = attack] 6 = attack only square, 7 = move only square
  #
func testMoveSquare(destFile, destRank, pieceSet):
  var occupiedByFriendly = false
  var occupied = false
  var occupiedByKing = false
  var occupyType = "zZ"
  
  if destFile >= 0 and destFile <= 9 and destRank >= 0 and destRank <= 9:
    for i in pieceSet:
      if destFile == i.file and destRank == i.rank:
        occupied = true
        occupyType = i.type
        if type[0] == i.type[0]:
          occupiedByFriendly = true
        elif i.type[1] == "K":
          occupiedByKing = true
  
    if !occupiedByFriendly:
      if occupied:
        if occupiedByKing:   
          return [false, 2, occupyType]
        else:
          return [false, 4, occupyType]
      else:
        return [true, 0, occupyType]
    else:
      return [false, 3, occupyType]
          
  return [false, 0, "zz"]



###################################################################################################################
      # moveGeneral #
###################################################################################################################
  # Get the moveable squares and check line for a general
  # 
func moveGeneral(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  var tmpCheckLine = PoolVector2Array()
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()

  if type[0] == "w":
    # 6 north squares
    f = file - 1
    r = rank + 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file - 1
    r = rank + 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file
    r = rank + 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file
    r = rank + 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file + 1
    r = rank + 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file + 1
    r = rank + 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
    # South
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while r > 0:
      if !testMoveReturn[0]:
        blocked = true
      r -= 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(file, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(file, r))
    
    # South east
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f < 9 and r > 0:
      if !testMoveReturn[0]:
        blocked = true
      f += 1
      r -= 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
      
    # South west
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f > 0 and r > 0:
      if !testMoveReturn[0]:
        blocked = true
      f -= 1
      r -= 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
    
  else:
    # 6 south squares
    f = file - 1
    r = rank - 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file - 1
    r = rank - 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file
    r = rank - 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file
    r = rank - 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file + 1
    r = rank - 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    f = file + 1
    r = rank - 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
    # North
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while r < 9:
      if !testMoveReturn[0]:
        blocked = true
      r += 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(file, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(file, r))

    # North west
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f > 0 and r < 9:
      if !testMoveReturn[0]:
        blocked = true
      f -= 1
      r += 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
      
    # North east
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f < 9 and r < 9:
      if !testMoveReturn[0]:
        blocked = true
      f += 1
      r += 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
    
    
  
###################################################################################################################
      # movePredator #
###################################################################################################################
  # Get the moveable squares and check line for a predator
  # 
func movePredator(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  var tmpCheckLine = PoolVector2Array()
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()

  # North west 3
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f > (file - 3) and r < (rank + 3):
    if !testMoveReturn[0]:
      blocked = true
    f -= 1
    r += 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
  
  # North east 3
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f < (file + 3) and r < (rank + 3):
    if !testMoveReturn[0]:
      blocked = true
    f += 1
    r += 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
  
  # South east 3
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f < (file + 3) and r > (rank - 3):
    if !testMoveReturn[0]:
      blocked = true
    f += 1
    r -= 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
  
  # South west 3
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f > (file - 3) and r > (rank - 3):
    if !testMoveReturn[0]:
      blocked = true
    f -= 1
    r -= 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
  
  
  
###################################################################################################################
      # moveElite #
###################################################################################################################
  # Get the moveable squares and check line for an elite
  # 
func moveElite(pieceSet):
  var f = 0
  var r = 0
  var testMoveReturn = [true, 0, "zZ"]
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()
  
  # Top left
  f = file - 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top right
  f = file + 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom left
  f = file - 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom right
  f = file + 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Left top
  f = file - 2
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Left bottom
  f = file - 2
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Right top
  f = file + 2
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Right bottom
  f = file + 2
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top left corner
  f = file - 1
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
  
  # Top right corner
  f = file + 1
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
  
  # Bottom left corner
  f = file - 1
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
  
  # Bottom right corner
  f = file + 1
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
  
  
  
###################################################################################################################
      # moveGuardian #
###################################################################################################################
  # Get the moveable squares and check line for a guardian
  # 
func moveGuardian(pieceSet):
  var f = 0
  var r = 0
  var testMoveReturn = [true, 0, "zZ"]
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()
  
  # Top left
  f = file - 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top right
  f = file + 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom left
  f = file - 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom right
  f = file + 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Left
  f = file - 2
  testMoveReturn = testMoveSquare(f, rank, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, rank, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, rank, testMoveReturn[1]))
  
  # Right
  f = file + 2
  testMoveReturn = testMoveSquare(f, rank, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, rank, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, rank, testMoveReturn[1]))
    
  #forward 1 if white
  if type[0] == "w":
    f = file
    r = rank + 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
      
  # forward 1 if black
  elif type[0] == "b":
    f = file
    r = rank - 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
  
  
  
###################################################################################################################
      # moveHunter #
###################################################################################################################
  # Get the moveable squares and check line for a hunter
  # 
func moveHunter(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  var tmpCheckLine = PoolVector2Array()
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()

  if type[0] == "w":
    # South 2
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while r > (rank - 2):
      if !testMoveReturn[0]:
        blocked = true
      r -= 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(file, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(file, r))
    
    # North west 2
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f > (file - 2) and r < (rank + 2):
      if !testMoveReturn[0]:
        blocked = true
      f -= 1
      r += 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
    
    # North east 2
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f < (file + 2) and r < (rank + 2):
      if !testMoveReturn[0]:
        blocked = true
      f += 1
      r += 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))

  else:
    # North 2
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while r < (rank + 2):
      if !testMoveReturn[0]:
        blocked = true
      r += 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(file, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(file, r))
          
    # South east 2
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f < (file + 2) and r > (rank - 2):
      if !testMoveReturn[0]:
        blocked = true
      f += 1
      r -= 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
    
    # South west 2
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f > (file - 2) and r > (rank - 2):
      if !testMoveReturn[0]:
        blocked = true
      f -= 1
      r -= 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))



###################################################################################################################
      # moveMinion #
###################################################################################################################
  # Get the moveable squares and check line for a minion
  # 
func moveMinion(pieceSet):
  var f = 0
  var r = 0
  var testMoveReturn = [true, 0, "zZ"]
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()
  
  # Left
  f = file - 1
  testMoveReturn = testMoveSquare(f, rank, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, rank, 7)) # set to a move only square
  if testMoveReturn[0] and testMoveReturn[1] == 0:
    squares.push_back(Vector3(f, rank, testMoveReturn[1]))
  
  # Right
  f = file + 1
  testMoveReturn = testMoveSquare(f, rank, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, rank, 7)) # set to a move only square
  if testMoveReturn[0] and testMoveReturn[1] == 0:
    squares.push_back(Vector3(f, rank, testMoveReturn[1]))
    
  if type[0] == "w":
    # Attack north
    r = rank + 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, 6)) # set to attack only square
    if !testMoveReturn[0] and testMoveReturn[1] > 1:
      squares.push_back(Vector3(file, r, testMoveReturn[1]))
      
  else:
    # Attack south
    r = rank - 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, 6)) # set to attack only square
    if !testMoveReturn[0] and testMoveReturn[1] > 1:
      squares.push_back(Vector3(file, r, testMoveReturn[1]))
  
  
  
###################################################################################################################
      # moveLynx #
###################################################################################################################
  # Get the moveable squares and check line for a lynx
  # The count is a range between 0-19
  # For 0-9 the attack pattern is a queen
  # For 10-19 the attack pattern is a knight
func moveLynx(pieceSet):
  if state == 0:
    moveQueen(pieceSet)
  else:
    moveKnight(pieceSet)
  
  
  
###################################################################################################################
      # moveMarshall #
###################################################################################################################
  # Get the moveable squares and check line for a marshall
  # 
func moveMarshall(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  var tmpCheckLine = PoolVector2Array()
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()
  
  # Left
  f = file
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f > 0:
    if !testMoveReturn[0]:
      blocked = true
    f -= 1
    testMoveReturn = testMoveSquare(f, rank, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, rank, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, rank, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, rank))
    
  # Right
  f = file
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f < 9:
    if !testMoveReturn[0]:
      blocked = true
    f += 1
    testMoveReturn = testMoveSquare(f, rank, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, rank, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, rank, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, rank))
        
  if type[0] == "w":
    # North 2
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while r < (rank + 2):
      if !testMoveReturn[0]:
        blocked = true
      r += 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(file, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(file, r))
    
    # South 1
    r = rank - 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(file, r, testMoveReturn[1]))
  
  else:        
    # South 2
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while r > (rank - 2):
      if !testMoveReturn[0]:
        blocked = true
      r -= 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(file, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(file, r))
    
    # North 1
    r = rank + 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(file, r, testMoveReturn[1]))
  
  
  
###################################################################################################################
      # moveKnight #
###################################################################################################################
  # Get the moveable squares and check line for a knight
  # 
func moveKnight(pieceSet):
  var f = 0
  var r = 0
  var testMoveReturn = [true, 0, "zZ"]
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()
  
  # Top left
  f = file - 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top right
  f = file + 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom left
  f = file - 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom right
  f = file + 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Left top
  f = file - 2
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Left bottom
  f = file - 2
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Right top
  f = file + 2
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Right bottom
  f = file + 2
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
    
    
###################################################################################################################
      # moveMammoth #
###################################################################################################################
  # Get the moveable squares and check line for a mammoth
  # 
func moveMammoth(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  var tmpCheckLine = PoolVector2Array()
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()
  
  # North
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while r < 9:
    if !testMoveReturn[0]:
      blocked = true
    r += 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(file, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(file, r))
    
  # South
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while r > 0:
    if !testMoveReturn[0]:
      blocked = true
    r -= 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(file, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(file, r))
  
  # Top left
  f = file - 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top right
  f = file + 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom left
  f = file - 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom right
  f = file + 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Left top
  f = file - 2
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Left bottom
  f = file - 2
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Right top
  f = file + 2
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Right bottom
  f = file + 2
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
  
  
  
  
  
###################################################################################################################
      # movePawn #
###################################################################################################################
  # Get the moveable squares and check line for a pawn
  # 
func movePawn(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()
  
  if type[0] == "w":
    if state == 0:
      # grow two non-attacking squares north
      r = rank
      testMoveReturn = [true, 0, "zZ"]
      blocked = false
      while r < (rank + 2):
        if !testMoveReturn[0]:
          blocked = true
        r += 1
        testMoveReturn = testMoveSquare(file, r, pieceSet)
        if testMoveReturn[2] != "zz":
          allSquares.push_back(Vector3(file, r, 7)) # set to a move only square
        if !blocked:
          if testMoveReturn[0] and testMoveReturn[1] == 0:
            squares.push_back(Vector3(file, r, testMoveReturn[1]))

    else:
      # one non-attacking square north
      r = rank + 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, 7)) # set to a move only square
      if testMoveReturn[0] and testMoveReturn[1] == 0:
        squares.push_back(Vector3(file, r, testMoveReturn[1]))
        
    # attack only north west
    f = file - 1
    r = rank + 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, 6)) # set to attack only square
    if !testMoveReturn[0] and testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))

    # attack only north east
    f = file + 1
    r = rank + 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, 6)) # set to attack only square
    if !testMoveReturn[0] and testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  else:
    if state == 0:
      # grow two non-attacking squares south
      r = rank
      testMoveReturn = [true, 0, "zZ"]
      blocked = false
      while r > (rank - 2):
        if !testMoveReturn[0]:
          blocked = true
        r -= 1
        testMoveReturn = testMoveSquare(file, r, pieceSet)
        if testMoveReturn[2] != "zz":
          allSquares.push_back(Vector3(file, r, 7)) # set to a move only square
        if !blocked:
          if testMoveReturn[0] and testMoveReturn[1] == 0:
            squares.push_back(Vector3(file, r, testMoveReturn[1]))
        
    else:
      # one non-attacking square south
      r = rank - 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, 7)) # set to a move only square
      if testMoveReturn[0] and testMoveReturn[1] == 0:
        squares.push_back(Vector3(file, r, testMoveReturn[1]))
      
    # attack only south west
    f = file - 1
    r = rank - 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, 6)) # set to attack only square
    if !testMoveReturn[0] and testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
  
    # attack only south east
    f = file + 1
    r = rank - 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, 6)) # set to attack only square
    if !testMoveReturn[0] and testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))

  
  
###################################################################################################################
      # moveQueen #
###################################################################################################################
  # Get the moveable squares and check line for a queen
  # 
func moveQueen(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  var tmpCheckLine = PoolVector2Array()
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()

  if type[0] == "w":
    # North 3
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while r < (rank + 3):
      if !testMoveReturn[0]:
        blocked = true
      r += 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(file, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(file, r))
          
    # South east 2
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f < (file + 2) and r > (rank - 2):
      if !testMoveReturn[0]:
        blocked = true
      f += 1
      r -= 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
    
    # South west 2
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f > (file - 2) and r > (rank - 2):
      if !testMoveReturn[0]:
        blocked = true
      f -= 1
      r -= 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
    
    # 4 northern knight squares #
    # Top left
    f = file - 1
    r = rank + 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
      
    # Top right
    f = file + 1
    r = rank + 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
      
    # Left top
    f = file - 2
    r = rank + 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
      
    # Right top
    f = file + 2
    r = rank + 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  else:
    # South 3
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while r > (rank - 3):
      if !testMoveReturn[0]:
        blocked = true
      r -= 1
      testMoveReturn = testMoveSquare(file, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(file, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(file, r))
        
    # North west 2
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f > (file - 2) and r < (rank + 2):
      if !testMoveReturn[0]:
        blocked = true
      f -= 1
      r += 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
    
    # North east 2
    f = file
    r = rank
    testMoveReturn = [true, 0, "zZ"]
    tmpCheckLine = PoolVector2Array()
    blocked = false
    while f < (file + 2) and r < (rank + 2):
      if !testMoveReturn[0]:
        blocked = true
      f += 1
      r += 1
      testMoveReturn = testMoveSquare(f, r, pieceSet)
      if testMoveReturn[2] != "zz":
        allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
      if !blocked:
        if testMoveReturn[0] or testMoveReturn[1] > 1:
          squares.push_back(Vector3(f, r, testMoveReturn[1]))
          if testMoveReturn[1] == 2:
            checkLine = tmpCheckLine
          else:
            tmpCheckLine.push_back(Vector2(f, r))
  
    # 4 Southern knight squares #
    # Bottom left
    f = file - 1
    r = rank - 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
      
    # Bottom right
    f = file + 1
    r = rank - 2
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
    # Left bottom
    f = file - 2
    r = rank - 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
    # Right bottom
    f = file + 2
    r = rank - 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if testMoveReturn[0] or testMoveReturn[1] > 1:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
      
    

###################################################################################################################
      # moveRook #
###################################################################################################################
  # Get the moveable squares and check line for a rook
  # 
func moveRook(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  var tmpCheckLine = PoolVector2Array()
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()
  
  # Left
  f = file
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f > 0:
    if !testMoveReturn[0]:
      blocked = true
    f -= 1
    testMoveReturn = testMoveSquare(f, rank, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, rank, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, rank, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, rank))
    
  # Right
  f = file
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f < 9:
    if !testMoveReturn[0]:
      blocked = true
    f += 1
    testMoveReturn = testMoveSquare(f, rank, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, rank, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, rank, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, rank))
    
  # North
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while r < 9:
    if !testMoveReturn[0]:
      blocked = true
    r += 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(file, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(file, r))
    
  # South
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while r > 0:
    if !testMoveReturn[0]:
      blocked = true
    r -= 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(file, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(file, r))
        


###################################################################################################################
      # moveMage #
###################################################################################################################
  # Get the moveable squares and check line for a mage
  # 
func moveMage(pieceSet):
  var f = 0
  var r = 0
  var testMoveReturn = [true, 0, "zZ"]
  squares = PoolVector3Array()
  allSquares = PoolVector3Array()

  # Top left
  f = file - 1
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    if !(testMoveReturn[2][1] == "P" and count >= 4):
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top center
  f = file
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    if !(testMoveReturn[2][1] == "P" and count >= 4):
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top right
  f = file + 1
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    if !(testMoveReturn[2][1] == "P" and count >= 4):
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Left
  f = file - 1
  r = rank
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    if !(testMoveReturn[2][1] == "P" and count >= 4):
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Right
  f = file + 1
  r = rank
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    if !(testMoveReturn[2][1] == "P" and count >= 4):
      squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Bottom left
  f = file - 1
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    if !(testMoveReturn[2][1] == "P" and count >= 4):
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom center
  f = file
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    if !(testMoveReturn[2][1] == "P" and count >= 4):
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom right
  f = file + 1
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    if !(testMoveReturn[2][1] == "P" and count >= 4):
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
        


###################################################################################################################
      # moveMageSummon #
###################################################################################################################
  # Get the summonable squares for a mage
  # 
func updateMageSummonSquares(pieceSet):
  var f = 0
  var r = 0
  var testMoveReturn = [true, 0, "zZ"]
  checkLine = PoolVector2Array()  

  # Top center
  f = file
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[0] or testMoveReturn[1] == 4:
      checkLine.push_back(Vector2(f, r))
 
  # Left
  f = file - 1
  r = rank
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[0] or testMoveReturn[1] == 4:
      checkLine.push_back(Vector2(f, r))
    
  # Right
  f = file + 1
  r = rank
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[0] or testMoveReturn[1] == 4:
      checkLine.push_back(Vector2(f, r))

  # Bottom center
  f = file
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[0] or testMoveReturn[1] == 4:
      checkLine.push_back(Vector2(f, r))
  
  
  
###################################################################################################################
      # movePhoenix #
###################################################################################################################
  # Get the moveable squares and check line for a phoenix
  # 
func movePhoenix(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  var tmpCheckLine = PoolVector2Array()
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()

  # North west
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f > 0 and r < 9:
    if !testMoveReturn[0]:
      blocked = true
    f -= 1
    r += 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
    
  # North east
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f < 9 and r < 9:
    if !testMoveReturn[0]:
      blocked = true
    f += 1
    r += 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))

  # South east
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f < 9 and r > 0:
    if !testMoveReturn[0]:
      blocked = true
    f += 1
    r -= 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
    
  # South west
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f > 0 and r > 0:
    if !testMoveReturn[0]:
      blocked = true
    f -= 1
    r -= 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
        
  # Top left
  f = file - 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top right
  f = file + 1
  r = rank + 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom left
  f = file - 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom right
  f = file + 1
  r = rank - 2
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Left top
  f = file - 2
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Left bottom
  f = file - 2
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Right top
  f = file + 2
  r = rank + 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Right bottom
  f = file + 2
  r = rank - 1
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 1:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
  
  
  
###################################################################################################################
      # moveZ #
###################################################################################################################
  # Get the moveable squares and check line for a phoenix
  # 
func moveZ(pieceSet):
  var f = 0
  var r = 0
  var blocked = false
  var testMoveReturn = [true, 0, "zZ"]
  var tmpCheckLine = PoolVector2Array()
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()
  allSquares = PoolVector3Array()

  # North west
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f > 0 and r < 9:
    if !testMoveReturn[0]:
      blocked = true
    f -= 1
    r += 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
    
  # North east
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f < 9 and r < 9:
    if !testMoveReturn[0]:
      blocked = true
    f += 1
    r += 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))

  # South east
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f < 9 and r > 0:
    if !testMoveReturn[0]:
      blocked = true
    f += 1
    r -= 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
    
  # South west
  f = file
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f > 0 and r > 0:
    if !testMoveReturn[0]:
      blocked = true
    f -= 1
    r -= 1
    testMoveReturn = testMoveSquare(f, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, r))
        
  # Left
  f = file
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f > 0:
    if !testMoveReturn[0]:
      blocked = true
    f -= 1
    testMoveReturn = testMoveSquare(f, rank, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, rank, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, rank, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, rank))
    
  # Right
  f = file
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while f < 9:
    if !testMoveReturn[0]:
      blocked = true
    f += 1
    testMoveReturn = testMoveSquare(f, rank, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(f, rank, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(f, rank, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(f, rank))
    
  # North
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while r < 9:
    if !testMoveReturn[0]:
      blocked = true
    r += 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(file, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(file, r))
    
  # South
  r = rank
  testMoveReturn = [true, 0, "zZ"]
  tmpCheckLine = PoolVector2Array()
  blocked = false
  while r > 0:
    if !testMoveReturn[0]:
      blocked = true
    r -= 1
    testMoveReturn = testMoveSquare(file, r, pieceSet)
    if testMoveReturn[2] != "zz":
      allSquares.push_back(Vector3(file, r, testMoveReturn[1]))
    if !blocked:
      if testMoveReturn[0] or testMoveReturn[1] > 1:
        squares.push_back(Vector3(file, r, testMoveReturn[1]))
        if testMoveReturn[1] == 2:
          checkLine = tmpCheckLine
        else:
          tmpCheckLine.push_back(Vector2(file, r))
        
        

###################################################################################################################
      # moveKing #
###################################################################################################################
  # Get the moveable squares for a king
  # 
func moveKing(pieceSet):
  var f = 0
  var r = 0
  var testMoveReturn = [true, 0, "zZ"]
  squares = PoolVector3Array()
  checkLine = PoolVector2Array()  # for the king, this stores the full movement patern instead of check line
  allSquares = PoolVector3Array()
  
  # Top left
  f = file - 1
  r = rank + 1
  checkLine.push_back(Vector2(f, r))
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
      squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top center
  f = file
  r = rank + 1
  checkLine.push_back(Vector2(f, r))
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Top right
  f = file + 1
  r = rank + 1
  checkLine.push_back(Vector2(f, r))
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Left
  f = file - 1
  r = rank
  checkLine.push_back(Vector2(f, r))
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Right
  f = file + 1
  r = rank
  checkLine.push_back(Vector2(f, r))
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))

  # Bottom left
  f = file - 1
  r = rank - 1
  checkLine.push_back(Vector2(f, r))
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom center
  f = file
  r = rank - 1
  checkLine.push_back(Vector2(f, r))
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Bottom right
  f = file + 1
  r = rank - 1
  checkLine.push_back(Vector2(f, r))
  testMoveReturn = testMoveSquare(f, r, pieceSet)
  if testMoveReturn[2] != "zz":
    allSquares.push_back(Vector3(f, r, testMoveReturn[1]))
  if testMoveReturn[0] or testMoveReturn[1] > 0:
    squares.push_back(Vector3(f, r, testMoveReturn[1]))
    
  # Do a final check unique to the king to remove all moveableSquares that are guarded
  var i = 0
  var tmpSquares = squares
  squares = PoolVector3Array()
  while i < tmpSquares.size():
    for j in pieceSet:
      if type[0] != j.type[0]:
        if j.type[1] == "K":
          for k in j.checkLine:
            if tmpSquares[i].x == k.x and tmpSquares[i].y == k.y:
              tmpSquares[i].z = 13.0
        elif j.type[1] == "P" or j.type[1] == "I":
          for k in j.allSquares:
            if tmpSquares[i].x == k.x and tmpSquares[i].y == k.y and k.z == 6:
              tmpSquares[i].z = 13.0
        else:
          for k in j.squares:
            if tmpSquares[i].x == k.x and tmpSquares[i].y == k.y:
              tmpSquares[i].z = 13.0
    i += 1

  for k in tmpSquares:
    if k.z != 13.0:
      squares.push_back(Vector3(k.x, k.y, k.z))
     
  # Test for castling #
  if state == 0:
    # grow left and check if the path is clear to the marshall
    i = file
    testMoveReturn = [true, 0]
    var isClear = true
    while i > 0 and testMoveReturn[0]:
      i -= 1
      for j in pieceSet:
        if type[0] != j.type[0]:
          for k in j.squares:
            if i == k.x and rank == k.y:
              isClear = false
      testMoveReturn = testMoveSquare(i, rank, pieceSet)
      if !testMoveReturn[0] and testMoveReturn[1] == 3:
        for j in pieceSet:
          if i == j.file and rank == j.rank:
            if j.type[1] == Game.CASTLE_TYPE and j.state == 0 and isClear:
              squares.push_back(Vector3((file - 3), rank, 0))
              allSquares.push_back(Vector3((file - 3), rank, 0))

    
    # grow right and check if the path is clear to the marshall
    i = file
    testMoveReturn = [true, 0]
    isClear = true
    while i < 9 and testMoveReturn[0]:
      i += 1
      for j in pieceSet:
        if type[0] != j.type[0]:
          for k in j.squares:
            if i == k.x and rank == k.y:
              isClear = false
      testMoveReturn = testMoveSquare(i, rank, pieceSet)
      if !testMoveReturn[0] and testMoveReturn[1] == 3 and isClear:
        for j in pieceSet:
          if i == j.file and rank == j.rank:
            if j.type[1] == Game.CASTLE_TYPE and j.state == 0:
              squares.push_back(Vector3((file + 2), rank, 0))
              allSquares.push_back(Vector3((file + 2), rank, 0))


