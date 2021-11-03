###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Board Scene ### by Fenxy
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
const MAGE_EMPTY = 0
const MAGE_HALF = 1
const MAGE_FULL = 2
  
onready var square_scene = preload("res://Square.tscn")
onready var piece_scene = preload("res://Piece.tscn")
onready var dottie_scene = preload("res://DotOverlay.tscn")
onready var coord_scene = preload("res://CoordText.tscn")
onready var iconHighlight = preload("res://assets/kinghighlight.png")

var whitePromotionSet = []
var blackPromotionSet = []
var pieceValues = {}
var whiteKingHighlight = TextureRect.new()
var blackKingHighlight = TextureRect.new()
var moveHighlightOrig = ColorRect.new()
var moveHighlightDest = ColorRect.new()

var pieces = []
var squares = [[]]
var dots = [[]]
var coordText = []
var lastCheck = []
var gameState = Game.GameState.new()
var currentlySummoning = false
var currentlyPromoting = false
var promotingPiece = Game.PieceMove.new()
var promotionWasAttack = "zZ"

var lastMove = Game.PieceMove.new()
var lastCapture = Game.PieceMove.new()

var moveMethod = 0
var moveVisibility = 0



###################################################################################################################
      # _ready #
###################################################################################################################
  # Called when the node enters the scene tree for the first time
  #   
func _ready():
  add_child(whiteKingHighlight)
  whiteKingHighlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
  whiteKingHighlight.texture = iconHighlight
  whiteKingHighlight.rect_scale = Vector2((100 / Game.SQUARE_SIZE), (100 / Game.SQUARE_SIZE))
  whiteKingHighlight.hide()
  
  add_child(blackKingHighlight)
  blackKingHighlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
  blackKingHighlight.texture = iconHighlight
  blackKingHighlight.rect_scale = Vector2((100 / Game.SQUARE_SIZE), (100 / Game.SQUARE_SIZE))
  blackKingHighlight.hide()

  add_child(moveHighlightOrig)
  moveHighlightOrig.rect_size.x = Game.SQUARE_SIZE
  moveHighlightOrig.rect_size.y = Game.SQUARE_SIZE
  moveHighlightOrig.color = Color(1.0, 1.0, 0.0, 0.5)
  moveHighlightOrig.mouse_filter = Control.MOUSE_FILTER_IGNORE
  moveHighlightOrig.hide()
  
  add_child(moveHighlightDest)
  moveHighlightDest.rect_size.x = Game.SQUARE_SIZE
  moveHighlightDest.rect_size.y = Game.SQUARE_SIZE
  moveHighlightDest.color = Color(1.0, 1.0, 0.0, 0.5)
  moveHighlightDest.mouse_filter = Control.MOUSE_FILTER_IGNORE
  moveHighlightDest.hide()
  
  

###################################################################################################################
      # _process #
###################################################################################################################
  # This is called every frame to update the timer text
  # The timers have milisecond precision, and there are no events for when 1 second passes
  #   
func _process(_delta):
  updateTimeText()





###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Pieces ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # loadPieces #
###################################################################################################################
  # Sets the starting position
  #   
func loadPieces():
  
  for i in pieces:
    i.queue_free()
  pieces = []
  
  # White #
  createPiece("wM",0,0)
  createPiece("wE",2,0)
  createPiece("wG",3,0)
  createPiece("wQ",4,0)
  createPiece("wK",5,0)
  createPiece("wG",6,0)
  createPiece("wE",7,0)
  createPiece("wM",9,0)
  
  createPiece("wD",1,1)
  createPiece("wN",2,1)
  createPiece("wT",3,1)
  createPiece("wH",6,1)
  createPiece("wN",7,1)
  createPiece("wD",8,1)
  
  for i in 10:
    createPiece("wP",i,2)
  
  # Black #
  createPiece("bM",0,9)
  createPiece("bE",2,9)
  createPiece("bG",3,9)
  createPiece("bQ",4,9)
  createPiece("bK",5,9)
  createPiece("bG",6,9)
  createPiece("bE",7,9)
  createPiece("bM",9,9)
  
  createPiece("bD",1,8)
  createPiece("bN",2,8)
  createPiece("bH",3,8)
  createPiece("bT",6,8)
  createPiece("bN",7,8)
  createPiece("bD",8,8)
  
  for i in 10:
    createPiece("bP",i,7)

  # update all the pieces
  for i in pieces:
    i.hideCrown()
    i.updateSquareList(pieces)
  
 
  
###################################################################################################################
      # loadPieceValues #
###################################################################################################################
  # Load the promotion set for white
  #    
func loadPieceValues():
  pieceValues = {
      "P": 1,
      "K": 3.5,
      "A": 5,
      "C": 5,
      "D": 5,
      "E": 5,
      "G": 5,
      "H": 5,
      "I": 1,
      "M": 5,
      "N": 5,
      "O": 5,
      "Q": 5,
      "R": 5,
      "T": 5,
      "X": 5,
      "Z": 5
  }
 

  
###################################################################################################################
      # loadWhitePromotionSet #
###################################################################################################################
  # Load the promotion set for white
  #    
func loadWhitePromotionSet():
  whitePromotionSet = []
  whitePromotionSet.push_back(Game.PromotionSet.new())
  whitePromotionSet.back().type = "wP"
  whitePromotionSet.back().promotionList = ["wA"]
  whitePromotionSet.push_back(Game.PromotionSet.new())
  whitePromotionSet.back().type = "wM"
  whitePromotionSet.back().promotionList = ["wR"]
  whitePromotionSet.push_back(Game.PromotionSet.new())
  whitePromotionSet.back().type = "wE"
  whitePromotionSet.back().promotionList = ["wZ"]
  whitePromotionSet.push_back(Game.PromotionSet.new())
  whitePromotionSet.back().type = "wG"
  whitePromotionSet.back().promotionList = ["wX"]
  whitePromotionSet.push_back(Game.PromotionSet.new())
  whitePromotionSet.back().type = "wD"
  whitePromotionSet.back().promotionList = ["wC"]
  whitePromotionSet.push_back(Game.PromotionSet.new())
  whitePromotionSet.back().type = "wH"
  whitePromotionSet.back().promotionList = ["wO"]
  whitePromotionSet.push_back(Game.PromotionSet.new())
  whitePromotionSet.back().type = "wN"
  whitePromotionSet.back().promotionList = ["wX"]
  
 
  
###################################################################################################################
      # loadBlackPromotionSet #
###################################################################################################################
  # Load the promotion set for black
  #    
func loadBlackPromotionSet():
  blackPromotionSet = []
  blackPromotionSet.push_back(Game.PromotionSet.new())
  blackPromotionSet.back().type = "bP"
  blackPromotionSet.back().promotionList = ["bA"]
  blackPromotionSet.push_back(Game.PromotionSet.new())
  blackPromotionSet.back().type = "bM"
  blackPromotionSet.back().promotionList = ["bR"]
  blackPromotionSet.push_back(Game.PromotionSet.new())
  blackPromotionSet.back().type = "bE"
  blackPromotionSet.back().promotionList = ["bZ"]
  blackPromotionSet.push_back(Game.PromotionSet.new())
  blackPromotionSet.back().type = "bG"
  blackPromotionSet.back().promotionList = ["bX"]
  blackPromotionSet.push_back(Game.PromotionSet.new())
  blackPromotionSet.back().type = "bD"
  blackPromotionSet.back().promotionList = ["bC"]
  blackPromotionSet.push_back(Game.PromotionSet.new())
  blackPromotionSet.back().type = "bH"
  blackPromotionSet.back().promotionList = ["bO"]
  blackPromotionSet.push_back(Game.PromotionSet.new())
  blackPromotionSet.back().type = "bN"
  blackPromotionSet.back().promotionList = ["bX"]
  
  
  
###################################################################################################################
      # createPiece #
###################################################################################################################
  # Create a piece and place it on the desired square
  #   
func createPiece(type, file, rank, count = 0, state = 0, animation = 0):
  pieces.push_back(piece_scene.instance())
  add_child(pieces.back())
  pieces.back().setType(type, gameState.playerColor[0])
  pieces.back().file = file
  pieces.back().rank = rank
  pieces.back().value = pieceValues[type[1]]
  pieces.back().state = state
  pieces.back().count = count
  pieces.back().position = squares[file][rank].position
  pieces.back().updateSquareList(pieces)
  pieces.back().setTypeIcon(animation)
  pieces.back().setMoveOption(moveMethod)
  
  
  
###################################################################################################################
      # setPieceActive #
###################################################################################################################
  # Set whether or not all the pieces are active
  #   
func setPieceActive(active):
  for i in pieces:
    i.setActive(active)
    
  
  
###################################################################################################################
      # removePiece #
###################################################################################################################
  # Find a specific piece and delete it
  #   
func removePiece(file, rank, store):
  var r = "zZ"
  if store:
    lastCapture.type = "zZ"
  for i in pieces:
    if i.file == file and i.rank == rank:
      if store:
        lastCapture.type = i.type
        lastCapture.oFile = file
        lastCapture.oRank = rank
        lastCapture.dFile = file
        lastCapture.dRank = rank
        lastCapture.state = i.state
        lastCapture.count = i.count
        lastCapture.animation = i.getTypeIcon()
      r = i.type
      i.queue_free()
      pieces.erase(i)
  return r
  
  
  
###################################################################################################################
      # summonReceived #
###################################################################################################################
  # Receive a confirmed click from one of the summonable squares
  #   
func summonReceived(file, rank):
  var type = "zZ"
  promotingPiece.dFile = file
  promotingPiece.dRank = rank
  
  for i in pieces:
    if i.type[0] == gameState.playerColor[0] and i.type[1] == "T":
      i.count -= 1

  if gameState.playerColor[0] == "w":
    type = "wI"
  else:
    type = "bI"

  promotionWasAttack = removePiece(promotingPiece.dFile, promotingPiece.dRank, true)
  createPiece(type, promotingPiece.dFile, promotingPiece.dRank)
  promotingPiece.type = type
  promotingPiece.state = 0
  promotingPiece.count = 0
  promotingPiece.oFile = promotingPiece.dFile
  promotingPiece.oRank = promotingPiece.dRank
  dropPromotion(type)
  hideSummonSquares()
  
  
  
###################################################################################################################
      # specialButtonDown #
###################################################################################################################
  # Received from the HUD class when the special button has been pressed
  #   
func specialButtonReceived():
  var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
  for i in pieces:
    if i.type[0] == gameState.playerColor[0] and i.type[1] == "T":
      var meow = "Summon charges: " + String(i.count) + "/" + String(i.state)
      hudNode.pushNotificationToChat(meow)
  if !currentlySummoning:
    if !currentlyPromoting and gameState.isTurn:
        showSummonSquares()
  else:
    hideSummonSquares()
        
        
        
###################################################################################################################
      # grabPiece #
###################################################################################################################
  # Called by the piece on mouse selection
  # It's main purpose is to test for king related constraints, and draw valid moveable squares
  #   
func grabPiece(piece, tapped):
  yield(get_tree(), "idle_frame") # let all the mouse events finish up
  yield(get_tree(), "idle_frame") # second one just to make sure

  var showFrames = true
  if moveVisibility == Game.SHOW_NONE:
    showFrames = false

  if tapped:
    moveReset()
    for i in pieces:
      i.setTapped(false)
    piece.setTapped(true)

  for i in squares:
    for j in i:
      if tapped:
        j.setTapMode(true)
      if piece.file == j.file and piece.rank == j.rank:
        j.showTappedHighlight(true)
      else:
        j.showTappedHighlight(false)

  if !currentlyPromoting and !currentlySummoning:
    piece.updateSquareList(pieces)
      
    # if there is a double check on the player, the king has to move
    if lastCheck.size() >= 2:
      for k in lastCheck:
        if k.isCheck != gameState.playerColor[0]:
          for i in piece.squares:
            if piece.type[1] == "K":
              if !simulateMove(piece.type, piece.file, piece.rank, i.x, i.y):
                if i.z == 0:
                  squares[i.x][i.y].setMoveable(true, false, showFrames)
                elif i.z == 4:
                  squares[i.x][i.y].setMoveable(true, true, showFrames)
      
    # if there is a single check on the player, only squares that either block or attack the attacker are allowed
    elif lastCheck.size() == 1:
      for k in lastCheck:
        if k.isCheck != gameState.playerColor[0]:
          for i in piece.squares:
            if piece.type[1] == "K":
              if !simulateMove(piece.type, piece.file, piece.rank, i.x, i.y):
                if i.z == 0:
                  squares[i.x][i.y].setMoveable(true, false, showFrames)
                elif i.z == 4:
                  squares[i.x][i.y].setMoveable(true, true, showFrames)
                  
            else: # not a king
              if i.x == k.file and i.y == k.rank:
                squares[i.x][i.y].setMoveable(true, true, showFrames)
              for j in k.checkLine:
                if i.x == j.x and i.y == j.y:
                  squares[j.x][j.y].setMoveable(true, false, showFrames)
    
    # if there is no check on the player, check the candidate squares to see if they create a check
    elif lastCheck.size() == 0:
      for i in piece.squares:
        if !simulateMove(piece.type, piece.file, piece.rank, i.x, i.y):
          if i.z == 0:
            squares[i.x][i.y].setMoveable(true, false, showFrames)
          elif i.z == 4 or i.z == 2:
            squares[i.x][i.y].setMoveable(true, true, showFrames)
            
    # make sure none of the possible attack squares can be tapped on
    for i in pieces:
      if piece.type[0] != i.type[0]:
        for j in piece.squares:
          if i.file == j.x and i.rank == j.y:
            i.setIgnoreTaps(true)

    # based on the move visibility state, and the currently drawn squares, draw any dots needing to be drawn
    if moveVisibility == Game.SHOW_ALL:
      for i in piece.allSquares:
        if !squares[i.x][i.y].isMoveable():
          dots[i.x][i.y].setVisible(true, i.z)
          
          

###################################################################################################################
      # simulateMove #
###################################################################################################################
  # Simulate moving from [oFile][oRank] to [dFile][dRank] to determine if check occurs
  #   
func simulateMove(type, oFile, oRank, dFile, dRank):
  var isCheck = false
  var isOccupied = false
  var capturedType = "zZ"
  var capturedFile = 9999
  var capturedRank = 9999
  var capturedState = 9999
  var capturedCount = 9999
  var capturedAnimation = 9999
  
  # make a back up of any piece that is to be captured, then remove it
  for i in pieces:
    if i.file == dFile and i.rank == dRank:
      if i.type[0] != type[0]:
        capturedType = i.type
        capturedFile = i.file
        capturedRank = i.rank
        capturedState = i.state
        capturedCount = i.count
        capturedAnimation = i.getTypeIcon()
        removePiece(capturedFile, capturedRank, false) # should be okay because we are only removing one
      else:
        isOccupied = true # flag whether the square is occupied by the player
        
  if !isOccupied:
    # find the desired piece and set it to the desired square
    for i in pieces:
      if i.file == oFile and i.rank == oRank:
        i.file = dFile
        i.rank = dRank
      
    # update all the affected pieces
    for i in pieces:
      var doUpdate = false
      for j in i.squares:
        if j.x == oFile and j.y == oRank:
          doUpdate = true
        if j.x == dFile and j.y == dRank:
          doUpdate = true
      if dFile == i.file and dRank == i.rank:
        doUpdate = true
      if doUpdate:
        i.updateSquareList(pieces)
        
        # test for check
        if i.type[0] != i.localPlayerColor:
          if testCheck(i.squares):
            isCheck = true
          
    # find piece at new square, then return piece to it's origin square
    for i in pieces:
      if i.file == dFile and i.rank == dRank:
        i.type = type
        i.file = oFile
        i.rank = oRank
        i.updateSquareList(pieces) # always update here incase a piece does not attack it's return square

    # restore removed piece
    if capturedType != "zZ":
      createPiece(capturedType, capturedFile, capturedRank, capturedCount, capturedState, capturedAnimation)
    
    # update all affected pieces again
    for i in pieces:
      var doUpdate = false
      for j in i.squares:
        if j.x == oFile and j.y == oRank:
          doUpdate = true
        if j.x == dFile and j.y == dRank:
          doUpdate = true
      if oFile == i.file and oRank == i.rank:
        doUpdate = true
      if doUpdate:
        i.updateSquareList(pieces)
  
  # return isCheck
  return isCheck
    
    
    
###################################################################################################################
      # dropPiece #
###################################################################################################################
  # Called when the player releases the left mouse button while holding a piece
  # This will test whether or not the dropped piece lands on a square
  # It will then either dispatch the drop, or cancle it
  #    
func dropPiece(piece):
  #check if the grabbed piece drops on a movable square
  var hasDropped = false
  if gameState.isTurn:
    for i in squares:
      for j in i:
        if j.moveable and j.mousedOver:
          hasDropped = true
          var wasAttack = removePiece(j.file, j.rank, true)
          moveReset()
          if !testForPromotion(piece, j.file, j.rank, wasAttack):
            updateTimer()
            var prevFile = piece.file
            var prevRank = piece.rank
            piece.position = j.position
            piece.file = j.file
            piece.rank = j.rank
            piece.updateSquareList(pieces)
            rpc("sendDrop", prevFile, prevRank, j.file, j.rank, "zZ", $PlayerTime.time_left, false)
            updateMoveHighlight(prevFile, prevRank, j.file, j.rank)
            updateMove(false, prevFile, prevRank, piece, wasAttack, "zZ", "zZ", false)
         
  #if not, put it back on it's origin square
  if hasDropped == false:
    cancleDrop(piece.file, piece.rank)
    
  
  
###################################################################################################################
      # testForPromotion #
###################################################################################################################
  # Test for a promotion and bring up the promotion window if available
  #    
func testForPromotion(piece, dFile, dRank, wasAttack):
  var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
  currentlyPromoting = false

  promotingPiece.type = piece.type
  promotingPiece.state = piece.state
  promotingPiece.count = piece.count
  promotingPiece.oFile = piece.file
  promotingPiece.oRank = piece.rank
  promotingPiece.dFile = dFile
  promotingPiece.dRank = dRank
  promotionWasAttack = wasAttack
  
  if piece.type[0] == "w" and dRank == 9:
    for i in whitePromotionSet:
      if i.type == piece.type:
        currentlyPromoting = true
        piece.position = squares[dFile][dRank].position
        hudNode.loadPromotionWhite(piece.type)
  if piece.type[0] == "b" and dRank == 0:
    for i in blackPromotionSet:
      if i.type == piece.type:
        currentlyPromoting = true
        piece.position = squares[dFile][dRank].position
        hudNode.loadPromotionBlack(piece.type)
    
  return currentlyPromoting
    
    
  
###################################################################################################################
      # setPromotion #
###################################################################################################################
  # Take the promotion return and handle accordingly
  #    
func setPromotion(index):
  if index == 0:
    dropPromotion("zZ")
  else:
    for i in pieces:
      if i.type == promotingPiece.type and i.file == promotingPiece.oFile and i.rank == promotingPiece.oRank:
        if promotingPiece.type[0] == "w":
          for j in whitePromotionSet:
            if j.type == promotingPiece.type:
              i.setType(j.promotionList[(index - 1)], gameState.playerColor[0])
              dropPromotion(j.promotionList[(index - 1)])
        elif promotingPiece.type[0] == "b":
          for j in blackPromotionSet:
            if j.type == promotingPiece.type:
              i.setType(j.promotionList[(index - 1)], gameState.playerColor[0])
              dropPromotion(j.promotionList[(index - 1)])
        
    
  
###################################################################################################################
      # dropPromotion #
###################################################################################################################
  # drop a promoted or unpromoted piece similar to how a mouse drop would
  # 
func dropPromotion(type):
  updateTimer()
  for i in pieces:
    if i.file == promotingPiece.oFile and i.rank == promotingPiece.oRank:
      var prevFile = i.file
      var prevRank = i.rank
      i.position = squares[promotingPiece.dFile][promotingPiece.dRank].position
      i.file = promotingPiece.dFile
      i.rank = promotingPiece.dRank
      i.updateSquareList(pieces)
      rpc("sendDrop", prevFile, prevRank, i.file, i.rank, type, $PlayerTime.time_left, true)
      updateMoveHighlight(prevFile, prevRank, i.file, i.rank)
      updateMove(false, prevFile, prevRank, i, promotionWasAttack, promotingPiece.type, type, true)
  
    
  
###################################################################################################################
      # cancleDrop #
###################################################################################################################
  # Set the piece back to it's square center, and hide the moveable squares
  #    
func cancleDrop(file, rank):
  for i in pieces:
    if i.file == file and i.rank == rank:
      i.position = squares[file][rank].position
  moveReset()
  
  
  
###################################################################################################################
      # moveReset #
###################################################################################################################
  # Hide the moveable square highlights
  #    
func moveReset():
  if !currentlySummoning:
    for i in pieces:
      i.setIgnoreTaps(false)
    for i in squares:
      for j in i:
        j.setMoveable(false, false, false)
    for i in dots:
      for j in i:
        j.setVisible(false, 0)
  


###################################################################################################################
      # castle #
###################################################################################################################
  # Castle the castle piece, updated interacted pieces, and test for check and mate
  #    
func castle(king, castleDirection):
  var mFile = 0
  var dFile = 0
  var mRank = 0
  var isCheck = false
  var isMate = false
  
  if king.type[0] == "w":
    mRank = 0
  else:
    mRank = 9
  if castleDirection == 0:
    mFile = 0
    dFile = 3
  else:
    mFile = 9
    dFile = 6

  for i in pieces:
    if i.type[1] == Game.CASTLE_TYPE and i.file == mFile and i.rank == mRank:
      i.position = squares[dFile][mRank].position
      i.file = dFile
      i.updateSquareList(pieces)
  
  # for all pieces that interact with the previous or new square, update their squares
  for i in pieces:
    var doUpdate = false
    for j in i.squares:
      if j.x == mFile and j.y == mRank:
        doUpdate = true
      if j.x == dFile and j.y == mRank:
        doUpdate = true
    if i.type[1] == Game.CASTLE_TYPE and i.file == dFile and i.rank == mRank:
      doUpdate = true
    if doUpdate:
      i.updateSquareList(pieces)
      
      # check for check and mate
      if testCheck(i.squares):
        isCheck = true
        lastCheck.push_back(Game.LastCheck.new())
        lastCheck.back().isCheck = i.type[0]
        lastCheck.back().type = i.type
        lastCheck.back().file = i.file
        lastCheck.back().rank = i.rank
        lastCheck.back().checkLine = i.checkLine
        if i.type[0] == "w":
          drawBlackKingDot(Game.RED)
        elif i.type[0] == "b":
          drawWhiteKingDot(Game.RED)
        
        if testMate(i.type, i.file, i.rank, i.checkLine, pieces):
          isMate = true
          gameEnd(Game.END_MATE, i.type[0])
          
  return [isCheck, isMate]
          
  
  
  
  
###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Game ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # takebackMove #
###################################################################################################################
  # Called by the HUD class. This will take back the last move
  # This is poorly implemented.
  # If I was to change it, I would just keep track of all the moves in a simplified list.
  # From there a loadPosition function could take in a board / piece configuration and set it up.
  # I wanted to avoid storing another list of objects, but I think now it would have been worth it.
  # 
func takebackMove():
  var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
  var marshallOFile = 0
  var marshallORank = 0
  var marshallDFile = 0
  currentlySummoning = false
  currentlyPromoting = false
  lastCheck = []
  whiteKingHighlight.hide()
  blackKingHighlight.hide()
  
  # return piece to it's original square
  if lastMove.type[1] == "K":
    # take back a white king's castle
    if lastMove.type[0] == "w" and lastMove.oFile == 5 and lastMove.oRank == 0:
      if lastMove.dFile == 2 or lastMove.dFile == 7:
        # determine marshall position
        marshallORank = 0
        if lastMove.dFile == 2:
          marshallOFile = 3
          marshallDFile = 0
        elif lastMove.dFile == 7:
          marshallOFile = 6
          marshallDFile = 9

        for i in pieces:
          # move king back
          if i.type == lastMove.type and i.file == lastMove.dFile and i.rank == lastMove.dRank:
            i.file = lastMove.oFile
            i.rank = lastMove.oRank
            i.count = lastMove.count
            i.state = lastMove.state
            i.position = squares[i.file][i.rank].position
            i.updateSquareList(pieces)
          # move marshall back
          if i.type[0] == "w" and i.type[1] == Game.CASTLE_TYPE and i.file == marshallOFile and i.rank == marshallORank:
            i.file = marshallDFile
            i.rank = marshallORank
            i.count = 0
            i.state = 0
            i.position = squares[i.file][i.rank].position
            i.updateSquareList(pieces)
    
    # take back a black king's castle
    elif lastMove.type[0] == "b" and lastMove.oFile == 5 and lastMove.oRank == 9:
      if lastMove.dFile == 2 or lastMove.dFile == 7:
        # determine marshall position
        marshallORank = 9
        if lastMove.dFile == 2:
          marshallOFile = 3
          marshallDFile = 0
        elif lastMove.dFile == 7:
          marshallOFile = 6
          marshallDFile = 9

        for i in pieces:
          # move king back
          if i.type == lastMove.type and i.file == lastMove.dFile and i.rank == lastMove.dRank:
            i.file = lastMove.oFile
            i.rank = lastMove.oRank
            i.count = lastMove.count
            i.state = lastMove.state
            i.position = squares[i.file][i.rank].position
            i.updateSquareList(pieces)
          # move marshall back
          if i.type[0] == "b" and i.type[1] == Game.CASTLE_TYPE and i.file == marshallOFile and i.rank == marshallORank:
            i.file = marshallDFile
            i.rank = marshallORank
            i.count = 0
            i.state = 0
            i.position = squares[i.file][i.rank].position
            i.updateSquareList(pieces)

    # update all interacted pieces
    for i in pieces:
      var doUpdate = false
      for j in i.squares:
        if j.x == lastMove.oFile and j.y == lastMove.oRank:
          doUpdate = true
        if j.x == lastMove.dFile and j.y == lastMove.dRank:
          doUpdate = true
        if marshallOFile == i.file and marshallORank == i.rank:
          doUpdate = true
        if marshallDFile == i.file and marshallORank == i.rank:
          doUpdate = true
      if doUpdate:
        i.updateSquareList(pieces)
        if testCheck(i.squares):
          lastCheck.push_back(Game.LastCheck.new())
          lastCheck.back().isCheck = i.type[0]
          lastCheck.back().type = i.type
          lastCheck.back().file = i.file
          lastCheck.back().rank = i.rank
          lastCheck.back().checkLine = i.checkLine
          if i.type[0] == "w":
            drawBlackKingDot(Game.RED)
          elif i.type[0] == "b":
            drawWhiteKingDot(Game.RED)
    
  else:
    # just a normal piece. return it
    if lastMove.type[1] == "I" and lastMove.wasPromotion:
      var _meow = removePiece(lastMove.dFile, lastMove.dRank, false)
      for i in pieces:
        if i.type[0] == lastMove.type[0] and i.type[1] == "T":
          i.count += 1
    else:
      for i in pieces:
        if i.type == lastMove.type and i.file == lastMove.dFile and i.rank == lastMove.dRank:
          i.file = lastMove.oFile
          i.rank = lastMove.oRank
          i.count = lastMove.count
          i.state = lastMove.state
          i.position = squares[i.file][i.rank].position
          i.updateSquareList(pieces)
          i.setTypeIcon(lastMove.animation)
    
    # restore any capture piece
    if lastCapture.type != "zZ":
    
      # revert mage charges if a pawn was captured by either the mage or their summon
      if lastCapture.type[1] == "P":
        if lastMove.type[1] == "T":
          for i in pieces:
            if i.type[0] == lastMove.type[0] and i.type[1] == "T":
              i.count -= 1
              i.state -= 1
        elif lastMove.type[1] == "I" and lastMove.wasPromotion:
          for i in pieces:
            if i.type[0] == lastMove.type[0] and i.type[1] == "T":
              i.count -= 1
              i.state -= 1
              if i.state == 0:
                i.setTypeIcon(MAGE_EMPTY)
              elif i.state <= 2:
                i.setTypeIcon(MAGE_HALF)
              else:
                i.setTypeIcon(MAGE_FULL)
              
      createPiece(
          lastCapture.type,
          lastCapture.dFile,
          lastCapture.dRank,
          lastCapture.count,
          lastCapture.state,
          lastCapture.animation)

    # update all interacted pieces
    for i in pieces:
      var doUpdate = false
      for j in i.squares:
        if j.x == lastMove.oFile and j.y == lastMove.oRank:
          doUpdate = true
        if j.x == lastMove.dFile and j.y == lastMove.dRank:
          doUpdate = true
      if lastMove.oFile == i.file and lastMove.oRank == i.rank:
        doUpdate = true
      if doUpdate:
        i.updateSquareList(pieces)
        if testCheck(i.squares):
          lastCheck.push_back(Game.LastCheck.new())
          lastCheck.back().isCheck = i.type[0]
          lastCheck.back().type = i.type
          lastCheck.back().file = i.file
          lastCheck.back().rank = i.rank
          lastCheck.back().checkLine = i.checkLine
          if i.type[0] == "w":
            drawBlackKingDot(Game.RED)
          elif i.type[0] == "b":
            drawWhiteKingDot(Game.RED)
  
  # revert hud changes
  hudNode.removeLastMoveFromMoveList()
  hudNode.endOfTurn(!gameState.isTurn)
  hudNode.disableTakeback()
  
  # revert the turn info
  if gameState.playerColor[0] == "w":
    if gameState.isTurn:
      gameState.turnCount -= 1
      for i in pieces:
        i.updateTurn(-1, pieces)
      lastMove.pTime -= gameState.increment
  elif gameState.playerColor[0] == "b":
    if !gameState.isTurn:
      gameState.turnCount -= 1
      for i in pieces:
        i.updateTurn(-1, pieces)
    else:
      lastMove.oTime -= gameState.increment
  for i in pieces:
    i.updateMove(-1, pieces)
    
  gameState.isTurn = !gameState.isTurn
  $PlayerTime.set_paused(!gameState.isTurn)
  $PlayerTime.start(lastMove.pTime)
  $OpponentTime.set_paused(gameState.isTurn)
  $OpponentTime.start(lastMove.oTime)



###################################################################################################################
      # updateTimer #
###################################################################################################################
  # Called by dropPiece. 
  # It's called sperate from updateTurn so only the moving player calls this
  #    
func updateTimer():
  $PlayerTime.set_paused(true)
  var timeLeft = $PlayerTime.time_left
  timeLeft += gameState.increment
  $PlayerTime.start(timeLeft)
  $OpponentTime.set_paused(false)
  
  
  
###################################################################################################################
      # giveTime #
###################################################################################################################
  # Called when the opponent gives you time
  #    
func giveTime():
  var timeLeft = $PlayerTime.time_left
  timeLeft += gameState.increment
  $PlayerTime.start(timeLeft)
  
  
  
###################################################################################################################
      # gaveTime #
###################################################################################################################
  # Called when you give the opponent time
  #    
func gaveTime():
  var timeLeft = $OpponentTime.time_left
  timeLeft += gameState.increment
  $OpponentTime.start(timeLeft)
      
      
      
###################################################################################################################
      # startGame #
###################################################################################################################
  # Load up the starting state after both players are ready
  #    
func startGame(hostTime, peerTime, increment, playerColor, playerIsHost):
  var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
  hudNode.newGame()

  gameState.isActive = true
  gameState.turnCount = 1
  gameState.increment = increment
  gameState.rule50MoveCount = 0
  gameState.playerIsHost = playerIsHost
  gameState.playerColor = playerColor
  currentlySummoning = false
  currentlyPromoting = false
  lastCheck = []
  lastCapture.type = "zZ"
  
  moveHighlightOrig.hide()
  moveHighlightDest.hide()
  whiteKingHighlight.hide()
  blackKingHighlight.hide()
  
  setTimerColor(Game.WHITE, Game.WHITE)
  $PlayerTime.set_paused(true)
  $PlayerTime.start(hostTime)
  $OpponentTime.set_paused(true)
  $OpponentTime.start(peerTime)
  
  for i in squares:
    for j in i:
      j.queue_free()
    i = []
  squares = [[]]
  
  for i in dots:
    for j in i:
      j.queue_free()
    i = []
  dots = [[]]
  
  for i in coordText:
    i.queue_free()
  coordText = []

  if gameState.playerColor == "white":
    gameState.isTurn = true
    loadWhitePromotionSet()
    loadWhiteSquares()
    loadWhiteCoordText()
    $PlayerTime.set_paused(false)
  elif gameState.playerColor == "black":
    gameState.isTurn = false
    loadBlackPromotionSet()
    loadBlackSquares()
    loadBlackCoordText()
    $OpponentTime.set_paused(false)
    
  loadPieceValues()
  loadPieces()

  
  
###################################################################################################################
      # updateMove #
###################################################################################################################
  # This is the last thing called before a move is finalized
  # Both players will run this command, and the turns will swap after it's done
  #    
func updateMove(isTurn, prevFile, prevRank, piece, wasAttack, promotionPrevious, promotionNew, wasPromotion):
  whiteKingHighlight.hide()
  blackKingHighlight.hide()
  var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
  var isCastle = "n"
  var isCheck = false
  var isMate = false
  currentlySummoning = false
  currentlyPromoting = false
  lastCheck = []
  
  # reset UI based options
  hudNode.endOfTurn(isTurn)
  
  # copy last move data for take backs
  lastMove.type = piece.type
  lastMove.oFile = prevFile
  lastMove.oRank = prevRank
  lastMove.dFile = piece.file
  lastMove.dRank = piece.rank
  lastMove.state = piece.state
  lastMove.count = piece.count
  lastMove.pTime = $PlayerTime.time_left
  lastMove.oTime = $OpponentTime.time_left
  lastMove.wasPromotion = wasPromotion
  
  # if a pawn or marashall have moved, set their state to indicate so
  if piece.type[1] == "P" or piece.type[1] == Game.CASTLE_TYPE:
    piece.state = 1
    
  # if a mage has killed a pawn, increase their state and count if possible
  elif piece.type[1] == "T" or promotionNew[1] == "I":
    if wasAttack[1] == "P":
      for i in pieces:
        if i.type[0] == piece.type[0] and i.type[1] == "T":
          if i.count < 4:
            if i.state < 4:
              i.state += 1
            i.count += 1
            if i.state == 0:
              i.setTypeIcon(MAGE_EMPTY)
            elif i.state <= 2:
              i.setTypeIcon(MAGE_HALF)
            else:
              i.setTypeIcon(MAGE_FULL)
        
  # if a king has moved, so their state to indicate so, and check if the move was a castle
  elif piece.type[1] == "K":
    piece.state = 1
    if piece.file == (prevFile - 3): # a castle left has occurred, move and update the piece seperately
      isCastle = "l"
      var meow = castle(piece, 0)
      isCheck = meow[0]
      isMate = meow[1]
    elif piece.file == (prevFile + 2):  # a castle right has occurred, move and update the piece seperately
      isCastle = "r"
      var meow = castle(piece, 1)
      isCheck = meow[0]
      isMate = meow[1]
  
  # update 50 move rule count
  if piece.type[1] == "P" or wasAttack != "zZ" or promotionWasAttack[1] != "zZ":
    gameState.rule50MoveCount = 0
  else:
    gameState.rule50MoveCount += 1
  lastMove.move50rule = gameState.rule50MoveCount
    
  # for all pieces that interact with the previous or new square, update their squares
  for i in pieces:
    var doUpdate = false
    for j in i.squares:
      if j.x == prevFile and j.y == prevRank:
        doUpdate = true
      if j.x == piece.file and j.y == piece.rank:
        doUpdate = true
    if piece.file == i.file and piece.rank == i.rank:
      doUpdate = true
    if doUpdate:
      i.updateSquareList(pieces)
      
      # check for check and mate
      if testCheck(i.squares):
        isCheck = true
        lastCheck.push_back(Game.LastCheck.new())
        lastCheck.back().isCheck = i.type[0]
        lastCheck.back().type = i.type
        lastCheck.back().file = i.file
        lastCheck.back().rank = i.rank
        lastCheck.back().checkLine = i.checkLine
        if i.type[0] == "w":
          drawBlackKingDot(Game.RED)
        elif i.type[0] == "b":
          drawWhiteKingDot(Game.RED)
        
        if testMate(i.type, i.file, i.rank, i.checkLine, pieces):
          isMate = true
          gameEnd(Game.END_MATE, i.type[0])

  # generate move string
  var moveString = ""
  if isCastle == "n":
    if promotionNew == "zZ":
      if piece.type[1] != "P":
        moveString += piece.type[1]
    elif promotionNew[1] == "I":
      moveString += "T"
    else:
      moveString += promotionPrevious[1]
    if wasAttack != "zZ":
      moveString += "x"
    moveString += Game.CHARS[piece.file] + String(piece.rank + 1)
  elif isCastle == "l":
    moveString = "O-O-O-O"
  elif isCastle == "r":
    moveString = "O-O-O"
    
  if promotionNew[1] == "I":
    moveString += "$" + promotionNew[1]
  elif promotionNew != "zZ":
    moveString += "=" + promotionNew[1]
    
  if isMate:
    moveString += "#"
  elif isCheck:
    hudNode.pushNotificationToChat("Check!")
    moveString += "+"
    
  # update game state and dispatch end of move / turn to pieces
  hudNode.addMoveToMoveList(moveString)
  gameState.isTurn = isTurn
  for i in pieces:
    i.updateMove(1, pieces)
    
  if piece.type[0] == "b": # a turn has passed
    gameState.turnCount += 1
    var meow = String(gameState.turnCount) + "."
    hudNode.addMoveToMoveList(meow)
    for i in pieces:
      i.updateTurn(1, pieces)
  
  # check for draw
  if testDraw():
    hudNode.addMoveToMoveList("1/2")
    hudNode.addMoveToMoveList("1/2")
    gameEnd(Game.END_DRAW, "z")
  
  # check for stalemate
  if testStalemate(piece):
    hudNode.addMoveToMoveList("1/2")
    hudNode.addMoveToMoveList("1/2")
    gameEnd(Game.END_STALEMATE, "z") 
    
    
    
###################################################################################################################
      # testCheck #
###################################################################################################################
  # Look up the check state for a square list
  #    
func testCheck(squareList):
  for i in squareList:
    if i.z == 2:
      return true
  return false
  
  
  
###################################################################################################################
      # testMate #
###################################################################################################################
  # Check if the king can escape, if not
  # Check if the checking piece can be attacked, if not
  # Check if the checkLine can be intercepted, if not
  # Checkmate!
  #
func testMate(type, file, rank, checkLine, pieceSet):
  # check if the king has any escape squares
  for i in pieces:
    if type[0] != i.type[0] and i.type[1] == "K":
      i.updateSquareList(pieces)
      for j in i.squares:
        if !simulateMove(type, file, rank, j.x, j.y):
          return false

  if lastCheck.size() == 1:
    #check if the checking piece can be attacked
    for i in pieceSet:
      if type[0] != i.type[0]:
        for j in i.squares:
          if file == j.x and rank == j.y:
            return false
      
    #check if the defender can move to any of the checkLine[] squares
    for i in pieceSet:
      if type[0] != i.type[0]:
        for j in i.squares:
          for k in checkLine:
            if j.x == k.x and j.y == k.y:
              return false
  
  #if all pass that is checkmate
  return true
  
  
  
###################################################################################################################
      # testDraw #
###################################################################################################################
  # testDraw
  #    
func testDraw():
  var isDraw = false
  # 50 move rule
  if gameState.rule50MoveCount >= 50:
    isDraw = true
    
  # insufficient mating material
  if Game.DRAW_MATERIAL_VALUE != 0:
    var canPromote = false
    var whiteValue = 0
    var blackValue = 0
    for i in pieces:
      if i.type[0] == "w":
        whiteValue += pieceValues[i.type[1]]
        for j in whitePromotionSet:
          if j.type == i.type:
            canPromote = true
      elif i.type[0] == "b":
        blackValue += pieceValues[i.type[1]]
        for j in blackPromotionSet:
          if j.type == i.type:
            canPromote = true
        
    if !canPromote and whiteValue <= Game.DRAW_MATERIAL_VALUE and blackValue <= Game.DRAW_MATERIAL_VALUE:
      isDraw = true
  
  # 3-5 fold repitiion
    # was not wanted for Game of War, coming with next version anyways
  
  # return
  return isDraw
  
  
  
###################################################################################################################
      # testStalemate #
###################################################################################################################
  # Loop through all the pieces for a specific color and check if their moveable square list is .size() > 0
  #    
func testStalemate(piece):
  var hasMoves = false
  for i in pieces:
    if i.type[0] != piece.type[0] and i.squares.size() > 0:
      hasMoves = true
  return !hasMoves
  
  
  
###################################################################################################################
      # gameEnd #
###################################################################################################################
  # End the game based on the type of end specified
  #    
func gameEnd(endType, winner):
  if gameState.isActive:
    for i in pieces:
      i.setLocked()
  
    if endType == Game.END_RESIGN:         # delcare winner
      showWinner(winner)
    elif endType == Game.END_MATE:         # delcare winner
      showWinner(winner)
    elif endType == Game.END_TIME:         # delcare winner
      showWinner(winner)
    elif endType == Game.END_DRAW:         # delcare no winner
      showDraw()
    elif endType == Game.END_STALEMATE:    # delcare no winner
      showDraw()
    elif endType == Game.END_FORFEIT:      # delcare winner
      showWinner(winner)
    gameState.isActive = false
      
    var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
    hudNode.endGame()
    
    
    
###################################################################################################################
      # opponentForfeit #
###################################################################################################################
  # Received when the opponent disconnects or leaves
  #   
func opponentForfeit():
  gameEnd(Game.END_FORFEIT, gameState.playerColor[0])
  
  
  
###################################################################################################################
      # opponentResign #
###################################################################################################################
  # Received when the opponent resigns
  #   
func opponentResign():
  gameEnd(Game.END_RESIGN, gameState.playerColor[0])
  
  
  
###################################################################################################################
      # selfResign #
###################################################################################################################
  # Received when the player clicks resign
  #   
func selfResign():
  if gameState.playerColor[0] == "w":
    gameEnd(Game.END_RESIGN, "b")
  elif gameState.playerColor[0] == "b":
    gameEnd(Game.END_RESIGN, "w")
    
    
    
###################################################################################################################
      # isGameActive #
###################################################################################################################
  # Return whether or not the game is active
  # This is used by the HUD to avoid sending invalid signals and messages
  #   
func isGameActive():
  return gameState.isActive
  
  
  
  
  
###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### UI ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # showWinnerCrown #
###################################################################################################################
  # Show the winner crown and put it on the kings head
  #    
func showWinnerCrown(winner):
  for i in pieces:
    if i.type[0] == winner and i.type[1] == "K":
      i.showCrown()
      
      
      
###################################################################################################################
      # showDoubleCrown #
###################################################################################################################
  # Both kings have kept their crown
  #    
func showDoubleCrown():
  for i in pieces:
    if i.type[1] == "K":
      i.showCrown()



###################################################################################################################
      # showWinner #
###################################################################################################################
  # Displays all the victory effects
  #    
func showWinner(winner):
  var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)

  # stop timers
  $PlayerTime.set_paused(true)
  $OpponentTime.set_paused(true)
  
  # winner specific stuff
  if winner == gameState.playerColor[0]:
    hudNode.setTimerColor(Game.GREEN, Game.DARK_GREY)
    var meow = hudNode.getPlayerName() + " has won the Match"
    hudNode.pushAnnouncementToChat(meow)
    hudNode.showPlayerCrown()
  else:
    hudNode.setTimerColor(Game.DARK_GREY, Game.GREEN)
    var meow = hudNode.getOpponentName() + " has won the Match"
    hudNode.pushAnnouncementToChat(meow)    
    hudNode.showOpponentCrown()
    
  showWinnerCrown(winner)
  
  # dots or highlights on kings
  if winner == "w":
    drawWhiteKingDot(Game.GREEN)
    drawBlackKingDot(Game.RED)
  elif winner == "b":
    drawBlackKingDot(Game.GREEN)
    drawWhiteKingDot(Game.RED)
  
  
  
###################################################################################################################
      # showDraw #
###################################################################################################################
  # Display all the draw effects
  #    
func showDraw():
  var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
  
  # pause the timers
  $PlayerTime.set_paused(true)
  $OpponentTime.set_paused(true)
  
  # double winner stuff
  setTimerColor(Game.GREEN, Game.GREEN)
  drawWhiteKingDot(Game.GREEN)
  drawBlackKingDot(Game.GREEN)
  showDoubleCrown()
  hudNode.showPlayerCrown()
  hudNode.showOpponentCrown()
  hudNode.pushAnnouncementToChat("A draw has been reached")



###################################################################################################################
      # updateMoveHighlight #
###################################################################################################################
  # Update the highlight after a move for origin and destination squares 
  #    
func updateMoveHighlight(oriFile, oriRank, destFile, destRank):
  moveHighlightOrig.show()
  var pos = squares[oriFile][oriRank].position
  pos.x -= (Game.SQUARE_SIZE / 2)
  pos.y -= (Game.SQUARE_SIZE / 2)
  moveHighlightOrig.set_position(pos)

  moveHighlightDest.show()
  pos = squares[destFile][destRank].position
  pos.x -= (Game.SQUARE_SIZE / 2)
  pos.y -= (Game.SQUARE_SIZE / 2)
  moveHighlightDest.set_position(pos)



###################################################################################################################
      # drawWhiteKingDot #
###################################################################################################################
  # Draw and color the white king's highlight dot
  #    
func drawWhiteKingDot(dotColor):
  for i in pieces:
    if i.type[0] == "w" and i.type[1] == "K":
      whiteKingHighlight.show()
      whiteKingHighlight.rect_position = (i.position + Vector2(-(Game.SQUARE_SIZE / 2), -(Game.SQUARE_SIZE / 2)))
      whiteKingHighlight.modulate = dotColor
      


###################################################################################################################
      # drawBlackKingDot #
###################################################################################################################
  # Draw and color the black king's highlight dot
  #    
func drawBlackKingDot(dotColor):
  for i in pieces:
    if i.type[0] == "b" and i.type[1] == "K":
      blackKingHighlight.show()
      blackKingHighlight.rect_position = (i.position + Vector2(-(Game.SQUARE_SIZE / 2), -(Game.SQUARE_SIZE / 2)))
      blackKingHighlight.modulate = dotColor

  
  
###################################################################################################################
      # updateTimeText #
###################################################################################################################
  # Send the updated timer count to the UI class
  #    
func updateTimeText():
  if gameState.isActive: 
    # check for time outs and send game over if so
    if $PlayerTime.time_left == 0:
      if gameState.playerColor[0] == "w":
        gameEnd(Game.END_TIME, "b")
      elif gameState.playerColor[0] == "b":
        gameEnd(Game.END_TIME, "w")
      rpc("timedOut")
        
    # otherwise, update the timer text
    var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
    hudNode.updatePlayerTime(ceil($PlayerTime.time_left))
    hudNode.updateOpponentTime(ceil($OpponentTime.time_left))
  
  
  
###################################################################################################################
      # setTimerColor #
###################################################################################################################
  # Set the player and opponent time color in the HUD class
  #    
func setTimerColor(playerColor, opponentColor):
  var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
  hudNode.setTimerColor(playerColor, opponentColor)
  
  
  
  
  
###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Board ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # showSummonSquares #
###################################################################################################################
  # Show the summonable squares for the player's mage
  #
func showSummonSquares():
  setPieceActive(false)
  currentlySummoning = true
  for i in pieces:
    if i.type[0] == gameState.playerColor[0] and i.type[1] == "T":
      if i.count == 0:
        setPieceActive(true)
        currentlySummoning = false
      else:
        i.updateMageSummonSquares(pieces)
        for j in i.checkLine:
          squares[j.x][j.y].setSummonable(true)


  
###################################################################################################################
      # hideSummonSquares #
###################################################################################################################
  # Hide the summonable squares for a mage
  #
func hideSummonSquares():
  for i in squares:
    for j in i:
      j.setSummonable(false)
  currentlySummoning = false
  setPieceActive(true)


  
###################################################################################################################
      # setMoveOption #
###################################################################################################################
  # Set the method of moving a piece
  #
func setMoveOption(index):
  moveMethod = index
  for i in pieces:
    i.setMoveOption(index)
    i.cancleSelf()
  moveReset()


  
###################################################################################################################
      # setMoveDrawOption #
###################################################################################################################
  # Handle the moveable square drawing option
  #
func setMoveDrawOption(index):
  moveVisibility = index
  for i in pieces:
    i.cancleSelf()
  moveReset()


  
###################################################################################################################
      # squareTap #
###################################################################################################################
  # Receive a square tap when in tap mode
  #
func squareTap(event):
  if event.pressed == true:
    for i in squares:
      for j in i:
        j.setTapMode(false)
      
  if event is InputEventScreenTouch:
    if event.pressed == true:
      for i in pieces:
        if i.tapped:
          i.dropSelf()
  elif event is InputEventMouseButton:
    if event.pressed == true and event.button_index == BUTTON_LEFT:
      for i in pieces:
        if i.tapped:
          i.dropSelf()
    elif event.pressed == true and event.button_index == BUTTON_RIGHT:
      for i in pieces:
        if i.tapped:
          i.cancleSelf()
          


###################################################################################################################
      # loadWhiteSquares #
###################################################################################################################
  # Get the square center and load up some basic info
  #    
func loadWhiteSquares():
  var x = (-1 * ((Game.BOARD_SIZE / 2) - (Game.SQUARE_SIZE / 2)))
  var y = ((Game.BOARD_SIZE / 2) - (Game.SQUARE_SIZE / 2))

  for file in Game.SQUARE_COUNT:
    squares.append([])
    dots.append([])
    for rank in Game.SQUARE_COUNT:
      squares[file].push_back(square_scene.instance())
      add_child(squares[file].back())
      squares[file].back().position = Vector2(x,y)
      squares[file].back().update()
      squares[file].back().file = file
      squares[file].back().rank = rank
      
      dots[file].push_back(dottie_scene.instance())
      add_child(dots[file].back())
      dots[file].back().position = Vector2(x,y)
    
      y -= Game.SQUARE_SIZE
      if y < (-1 * (Game.BOARD_SIZE / 2)):
        y = ((Game.BOARD_SIZE / 2) - (Game.SQUARE_SIZE / 2))
        x += Game.SQUARE_SIZE
        
            
        
###################################################################################################################
      # loadWhiteCoordText #
###################################################################################################################
  # Loop through bottom rank and right file to generate the coordinate text
  #
func loadWhiteCoordText():
  
  for i in Game.SQUARE_COUNT:
    coordText.push_back(coord_scene.instance())
    add_child(coordText.back())
    coordText.back().text = Game.CHARS[(squares[i][0].file)]
    coordText.back().rect_position = squares[i][0].position
    coordText.back().rect_position.x -= ((Game.SQUARE_SIZE / 2) - 4)
    coordText.back().rect_position.y += 15
    coordText.back().align = HALIGN_LEFT
    
  for i in squares[(Game.SQUARE_COUNT - 1)]:
    coordText.push_back(coord_scene.instance())
    add_child(coordText.back())
    coordText.back().text = String(i.rank + 1)
    coordText.back().rect_position = i.position
    coordText.back().rect_position.x -= (Game.SQUARE_SIZE / 2)
    coordText.back().rect_position.y -= (Game.SQUARE_SIZE / 2)
    coordText.back().align = HALIGN_RIGHT
        
        
        
###################################################################################################################
      # loadBlackSquares #
###################################################################################################################
  # Get the square center and load up some basic info
  #    
func loadBlackSquares():
  var x = ((Game.BOARD_SIZE / 2) - (Game.SQUARE_SIZE / 2))
  var y = (-1 * ((Game.BOARD_SIZE / 2) - (Game.SQUARE_SIZE / 2)))

  for file in Game.SQUARE_COUNT:
    squares.append([])
    dots.append([])
    for rank in Game.SQUARE_COUNT:
      squares[file].push_back(square_scene.instance())
      add_child(squares[file].back())
      squares[file].back().position = Vector2(x,y)
      squares[file].back().update()
      squares[file].back().file = file
      squares[file].back().rank = rank
      
      dots[file].push_back(dottie_scene.instance())
      add_child(dots[file].back())
      dots[file].back().position = Vector2(x,y)

      y += Game.SQUARE_SIZE
      if y > (Game.BOARD_SIZE / 2):
        y = (-1 * ((Game.BOARD_SIZE / 2) - (Game.SQUARE_SIZE / 2)))
        x -= Game.SQUARE_SIZE
        
        

###################################################################################################################
      # loadBlackCoordText #
###################################################################################################################
  # Loop through bottom rank and right file to generate the coordinate text
  #
func loadBlackCoordText():
  for i in Game.SQUARE_COUNT:
    coordText.push_back(coord_scene.instance())
    add_child(coordText.back())
    coordText.back().text = Game.CHARS[(squares[i][9].file)]
    coordText.back().rect_position = squares[i][9].position
    coordText.back().rect_position.x -= ((Game.SQUARE_SIZE / 2) - 4)
    coordText.back().rect_position.y += 15
    coordText.back().align = HALIGN_LEFT
    
  for i in squares[0]:
    coordText.push_back(coord_scene.instance())
    add_child(coordText.back())
    coordText.back().text = String(i.rank + 1)
    coordText.back().rect_position = i.position
    coordText.back().rect_position.x -= (Game.SQUARE_SIZE / 2)
    coordText.back().rect_position.y -= (Game.SQUARE_SIZE / 2)
    coordText.back().align = HALIGN_RIGHT
  
  
  
###################################################################################################################
      # setBoardTexture #
###################################################################################################################
  # Called from the HUD call when a new board is selected
  #
func setBoardTexture(texture):
  $BoardTexture.texture = texture
  
  
  
  

###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Remote ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # sendDrop #
###################################################################################################################
  # Receives the drop info after it is confirmed by opponent's dropPiece method
  #
remote func sendDrop(oFile, oRank, dFile, dRank, promotionNew, opponentTimeLeft, wasPromotion):
  for i in pieces:
    i.dropPiece()
  updateMoveHighlight(oFile, oRank, dFile, dRank)
  var wasAttack = removePiece(dFile, dRank, true)
  
  if promotionNew[1] == "I":
    createPiece(promotionNew, dFile, dRank)
    for i in pieces:
      if i.file == dFile and i.rank == dRank:
        print("created and found minion")
        var prevFile = i.file
        var prevRank = i.rank
        i.position = squares[dFile][dRank].position
        i.file = dFile
        i.rank = dRank
        i.updateSquareList(pieces)
        updateMoveHighlight(prevFile, prevRank, i.file, i.rank)
        updateMove(true, prevFile, prevRank, i, wasAttack, "zZ", promotionNew, wasPromotion)
    
  else:
    for i in pieces:
      if i.file == oFile and i.rank == oRank:
        var prevFile = i.file
        var prevRank = i.rank
        i.position = squares[dFile][dRank].position
        i.file = dFile
        i.rank = dRank
        var promotionPrevious = i.type
        if promotionNew != "zZ":
          i.setType(promotionNew, gameState.playerColor[0])
        i.updateSquareList(pieces)
        updateMove(true, prevFile, prevRank, i, wasAttack, promotionPrevious, promotionNew, wasPromotion)

  $OpponentTime.set_paused(true)
  $OpponentTime.start(opponentTimeLeft)
  $PlayerTime.set_paused(false)
  
  
  
###################################################################################################################
      # timedOut #
###################################################################################################################
  # Received when the opponent times out
  #
remote func timedOut():
  if gameState.playerColor[0] == "w":
    gameEnd(Game.END_TIME, "w")
  elif gameState.playerColor[0] == "b":
    gameEnd(Game.END_TIME, "b")
  
  
  
  

###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Debug ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # debug #
###################################################################################################################
  # Used by children classes to have easy access to the chat output for debug purposes
  # Useful for debugging once you've ported to Gotm.io
  # Not that I would ever need debug.... it's here for you. Yes that's it.
  #
func debug(t):
  var hudNode = $BoardTexture.get_parent().get_parent().get_child(0)
  hudNode.pushNotificationToChat(t)


