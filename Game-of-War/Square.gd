###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Square Scene ### by Fenxy
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
var file = 0
var rank = 0
var moveable = false
var mousedOver = false
var summonMode = false
var tapMode = false



###################################################################################################################
      # _ready #
###################################################################################################################
  # Called when the node enters the scene tree for the first time
  #   
func _ready():
  $CollisionShape2D.shape.extents = Vector2((Game.SQUARE_SIZE / 2), (Game.SQUARE_SIZE / 2))
  show()
  hideFrames()
  

  
###################################################################################################################
      # showTappedHighlight #
###################################################################################################################
  # Either shows the moveable highlights for a square or hides it's frames
  #   
func showTappedHighlight(s):
  hideFrames()
  if s:
    $TextureRect.show()
    $TextureRect.modulate = Game.GREEN
  

  
###################################################################################################################
      # setMovable #
###################################################################################################################
  # Either shows the moveable highlights for a square or hides it's frames
  #   
func setMoveable(m, isAttack, showFrames):
  moveable = m
  if moveable and showFrames:
    if isAttack:
      $TextureRect.show()
      $TextureRect.modulate = Game.RED
      $ColorRect.hide()
    else:
      $TextureRect.show()
      $TextureRect.modulate = Game.YELLOW
      $ColorRect.show()
  else:
    hideFrames()


  
###################################################################################################################
      # hideFrames #
###################################################################################################################
  # Hide both the visible frames
  #   
func hideFrames():
  $ColorRect.hide()
  $TextureRect.hide()
  
  
  
###################################################################################################################
      # setSummonable #
###################################################################################################################
  # Shows the square frame, drawing it's highlights and allowing it to be clicked for summons
  #   
func setSummonable(summonable):
  summonMode = summonable
  if summonMode:
    $TextureRect.show()
    $TextureRect.modulate = Game.PURPLE
    $ColorRect.show()
  else:
    hideFrames()


  
###################################################################################################################
      # setTapMode #
###################################################################################################################
  # Set whether or not a piece has been tapped and to wait for a click
  #   
func setTapMode(t):
  tapMode = t


  
###################################################################################################################
      # isMoveable #
###################################################################################################################
  # Returns the moveability state
  #   
func isMoveable():
  return moveable
  


###################################################################################################################
      # _on_Square_mouse_entered / _on_Square_mouse_exited #
###################################################################################################################
  # Detects when the mouse enters the collision shape
  #  
func _on_Square_mouse_entered():
  mousedOver = true
func _on_Square_mouse_exited():
  mousedOver = false
 
  
  
###################################################################################################################
      # _on_Square_input_event #
###################################################################################################################
  # This is registered with the CollisionShape2D
  # There cannot be any control classes above it in the parent class, otherwise their input must be ignored
  #
func _on_Square_input_event(_viewport, event, _shape_idx):
  var boardNode = $CollisionShape2D.get_parent().get_parent()
  if summonMode:
    if event is InputEventScreenTouch:
      if event.pressed == true:
        boardNode.summonReceived(file, rank)

    elif event is InputEventMouseButton:
      if event.pressed == true and event.button_index == BUTTON_LEFT:
        boardNode.summonReceived(file, rank)
      elif event.pressed == true and event.button_index == BUTTON_RIGHT:
        boardNode.summonReceived(file, rank)
  
  elif tapMode:
    if event is InputEventScreenTouch or event is InputEventMouseButton:
      boardNode.squareTap(event)


