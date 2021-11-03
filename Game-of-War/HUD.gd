###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### HUD Scene ### by Fenxy
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
extends CanvasLayer



###################################################################################################################
      # Preload #
###################################################################################################################
  #  
onready var iconEiviexx = preload("res://assets/eve.png")
onready var iconFenxy = preload("res://assets/tlynx_s.png")

onready var iconWT = preload("res://assets/pieces/theme1/white/t-white-small.png")
onready var iconWA = preload("res://assets/pieces/theme1/white/A.png")
onready var iconWG = preload("res://assets/pieces/theme1/white/G.png")
onready var iconWX = preload("res://assets/pieces/theme1/white/X.png")
onready var iconWD = preload("res://assets/pieces/theme1/white/D.png")
onready var iconWH = preload("res://assets/pieces/theme1/white/H.png")
onready var iconWO = preload("res://assets/pieces/theme1/white/O.png")
onready var iconWZ = preload("res://assets/pieces/theme1/white/Z.png")
onready var iconWM = preload("res://assets/pieces/theme1/white/M.png")
onready var iconWP = preload("res://assets/pieces/theme1/white/P.png")
onready var iconWR = preload("res://assets/pieces/theme1/white/R.png")
onready var iconWE = preload("res://assets/pieces/theme1/white/E.png")
onready var iconWN = preload("res://assets/pieces/theme1/white/N.png")
onready var iconWL = preload("res://assets/pieces/theme1/white/C-1.png")

onready var iconBT = preload("res://assets/pieces/theme1/black/t-black-small.png")
onready var iconBA = preload("res://assets/pieces/theme1/black/A.png")
onready var iconBG = preload("res://assets/pieces/theme1/black/G.png")
onready var iconBX = preload("res://assets/pieces/theme1/black/X.png")
onready var iconBD = preload("res://assets/pieces/theme1/black/D.png")
onready var iconBH = preload("res://assets/pieces/theme1/black/H.png")
onready var iconBO = preload("res://assets/pieces/theme1/black/O.png")
onready var iconBZ = preload("res://assets/pieces/theme1/black/Z.png")
onready var iconBM = preload("res://assets/pieces/theme1/black/M.png")
onready var iconBP = preload("res://assets/pieces/theme1/black/P.png")
onready var iconBR = preload("res://assets/pieces/theme1/black/R.png")
onready var iconBE = preload("res://assets/pieces/theme1/black/E.png")
onready var iconBN = preload("res://assets/pieces/theme1/black/N.png")
onready var iconBL = preload("res://assets/pieces/theme1/black/C-1.png")



###################################################################################################################
      # Classes #
###################################################################################################################
  #  
class PlayerProfile:
  var pName: String
  var pNameColor: Color



###################################################################################################################
      # Variables #
###################################################################################################################
  # 
var peer: NetworkedMultiplayerENet
var gameIsActive = false

var playerName = "Player Name"
var playerNameColor = Game.WHITE
var playerTeamColor = "meow"
var playerIsHost = false
var playerIsConnected = false
var playerPeerID = 0

var hostTeamColor = 1
var hostTimeMinute = 15
var hostTimeIncrement = 15
var hostReadyState = false
var hostProfile = PlayerProfile.new()

var peerReadyState = false
var peerProfile = PlayerProfile.new()

var boarders = []
var boards = []
var tutorialImages = []
var tutorialButtons = []



###################################################################################################################
      # _ready #
###################################################################################################################
  # Called when the node enters the scene tree for the first time
  #   
func _ready():
  $PromotionList.hide()
  $ThemePanel.hide()
  $TutorialPanel.hide()
  $OptionPanel.hide()
  
  $VersionLabel.text = Game.VERSION  
  
  $StartPanel/ColorPicker.hide()
  $StartPanel/ColorPickerPanel.hide()
  $StartPanel/HostColorList.add_item("white")
  $StartPanel/HostColorList.add_item("random")
  $StartPanel/HostColorList.add_item("black")
  $StartPanel/NameEdit.placeholder_text = playerName
  $StartPanel/HostColorList.select(hostTeamColor)
  $StartPanel/HostTimeMinuteEdit.placeholder_text = String(hostTimeMinute)
  $StartPanel/HostTimeIncrementEdit.placeholder_text = String(hostTimeIncrement)
  $StartPanel/StatusLabel.text = "Ready"
  $StartPanel/StatusLabel.modulate = Game.GREEN

  $GamePanel/GiveTimeButton.disabled = true
  $GamePanel/DrawButton.disabled = true
  $GamePanel/DrawYes.hide()
  $GamePanel/DrawNo.hide()
  $GamePanel/TakeBackButton.disabled = true
  $GamePanel/TakebackYes.hide()
  $GamePanel/TakebackNo.hide()
  $GamePanel/ResignButton.disabled = true
  
  $OptionPanel/MoveOption.add_item("Drag to move")  
  $OptionPanel/MoveOption.add_item("Click to move")
  $OptionPanel/MoveDrawOption.add_item("Show all piece squares")
  $OptionPanel/MoveDrawOption.add_item("Show only moveable squares")
  $OptionPanel/MoveDrawOption.add_item("Don't show any move hints")
  
  hidePlayerCrown()
  hideOpponentCrown()
  loadBoards()
  loadBoarders()
  loadTutorialImages()
  
  var _err
  _err = get_tree().connect("connected_to_server", self, "_on_connected_to_server")
  _err = get_tree().connect("connection_failed", self, "_on_connection_failed")
  _err = get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
  _err = get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
  _err = get_tree().connect("server_disconnected", self, "_on_server_disconnected")

  var rng = RandomNumberGenerator.new()
  rng.randomize()
  var firstPlayer = rng.randi_range(0, 1)
  if firstPlayer == 0:
    $GamePanel/SpecialButton.icon = iconEiviexx
  elif firstPlayer == 1:  
    $GamePanel/SpecialButton.icon = iconFenxy
    
    
    
    
  
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
      # formatTime #
###################################################################################################################
  #  Takes a timer value in seconds and formats it for display
  #
func formatTime(time):
  var minutes = floor(time / 60)
  var seconds = floor(int(time) % 60)
  var meow = "meow"
  if seconds < 10:
    meow = String(minutes) + ":0" + String(seconds)
  else:
    meow = String(minutes) + ":" + String(seconds)
  return meow



###################################################################################################################
      # updatePlayerTime / updateOpponentTime #
###################################################################################################################
  #  Received once a frame from the board scene to update the player time text
  #
func updatePlayerTime(t):
  $GamePanel/PlayerTimeLabel.text = formatTime(t)
  
func updateOpponentTime(t):
  $GamePanel/OpponentTimeLabel.text = formatTime(t)
  
  

###################################################################################################################
      # setTimerColor #
###################################################################################################################
  #  Sets the time colors for both player and opponent
  #
func setTimerColor(pColor, oColor):
  $GamePanel/PlayerTimeLabel.modulate = pColor
  $GamePanel/OpponentTimeLabel.modulate = oColor
  
  

###################################################################################################################
      # addMoveToMoveList #
###################################################################################################################
  #  Takes in a move string, adds it to the move list, then scrolls to the bottom
  #
func addMoveToMoveList(move):
  $GamePanel/MoveItemList.add_item(move, null, false)
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  $GamePanel/MoveItemList.get_v_scroll().value = $GamePanel/MoveItemList.get_v_scroll().max_value
  $GamePanel/MoveItemList.get_v_scroll().value -= 7
  
  

###################################################################################################################
      # removeLastMoveFromMoveList #
###################################################################################################################
  # Removes the last move from the move list
  # Also removes turn numbers to match the needed format in the board scene
  #
func removeLastMoveFromMoveList():
  var meow = $GamePanel/MoveItemList.get_item_text(($GamePanel/MoveItemList.get_item_count() - 1))
  if meow[(meow.length() - 1)] == ".":
    $GamePanel/MoveItemList.remove_item(($GamePanel/MoveItemList.get_item_count() - 1))
  $GamePanel/MoveItemList.remove_item(($GamePanel/MoveItemList.get_item_count() - 1))
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  $GamePanel/MoveItemList.get_v_scroll().value = $GamePanel/MoveItemList.get_v_scroll().max_value
  $GamePanel/MoveItemList.get_v_scroll().value -= 7
  
  

###################################################################################################################
      # getPlayerName / getOpponentName #
###################################################################################################################
  # Returns the player and opponent names
  # 
func getPlayerName():
  return playerName
  
func getOpponentName():
  if playerIsHost:
    return peerProfile.pName
  else:
    return hostProfile.pName
  
  

###################################################################################################################
      # showPlayerCrown / hidePlayerCrown / showOpponentCrown / hideOpponentCrown #
###################################################################################################################
  # Set the winner crown visibility
  # 
func showPlayerCrown():
  $GamePanel/PlayerCrown.show()
  
func hidePlayerCrown():
  $GamePanel/PlayerCrown.hide()
  
func showOpponentCrown():
  $GamePanel/OpponentCrown.show()
  
func hideOpponentCrown():
  $GamePanel/OpponentCrown.hide()
  
  

###################################################################################################################
      # endOfTurn #
###################################################################################################################
  # Resets visibility after a turn
  # 
func endOfTurn(isTurn):
  $GamePanel/DrawButton.show()
  $GamePanel/DrawButton.disabled = false
  $GamePanel/DrawYes.hide()
  $GamePanel/DrawNo.hide()
  $GamePanel/TakeBackButton.show()
  $GamePanel/TakebackYes.hide()
  $GamePanel/TakebackNo.hide()
  if isTurn:
    $GamePanel/TakeBackButton.disabled = true
  else:
    $GamePanel/TakeBackButton.disabled = false
  
  

###################################################################################################################
      # newGame #
###################################################################################################################
  # Resets state for a new game
  # 
func newGame():
  gameIsActive = true
  hidePlayerCrown()
  hideOpponentCrown()
  $GamePanel/MoveItemList.clear()
  $GamePanel/DrawButton.disabled = false
  $GamePanel/ResignButton.disabled = false
  $GamePanel/GiveTimeButton.disabled = false
  $GamePanel/TakeBackButton.disabled = true
  addMoveToMoveList("1.")
  
  

###################################################################################################################
      # endGame #
###################################################################################################################
  # This signals the end of a game to prepare for a rematch
  # 
func endGame():
  gameIsActive = false
  $GamePanel/ReadyButton.disabled = false
  $GamePanel/DrawButton.disabled = true
  $GamePanel/ResignButton.disabled = true
  $GamePanel/GiveTimeButton.disabled = true
  $GamePanel/TakeBackButton.disabled = true
  
  

###################################################################################################################
      # _on_ResignButton_button_down #
###################################################################################################################
  # Dispatches resign to opponent after the resignation button has been pressed
  # 
func _on_ResignButton_button_down():
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  if boardNode.isGameActive():
    pushNotificationToChat("Player has resigned")
    rpc_id(playerPeerID, "playerResign")
    boardNode.selfResign()
  
  

###################################################################################################################
      # _on_GiveTimeButton_button_down #
###################################################################################################################
  # Dispatches some time to opponent after the give time button has been pressed
  # 
func _on_GiveTimeButton_button_down():
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  boardNode.gaveTime()
  rpc_id(playerPeerID, "giveTime")
  
  

###################################################################################################################
      # _on_SpecialButton_button_down #
###################################################################################################################
  # The player wishes to use a special ability
  # 
func _on_SpecialButton_button_down():
  if !gameIsActive:
    pushAnnouncementToChat("Game concept, game art, and themes by Eiviex")
    pushAnnouncementToChat("Application, and game implementation by Fenxy")
    if $GamePanel/SpecialButton.icon == iconEiviexx:
      $GamePanel/SpecialButton.icon = iconFenxy
    elif $GamePanel/SpecialButton.icon == iconFenxy:  
      $GamePanel/SpecialButton.icon = iconEiviexx
  else:
    var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
    boardNode.specialButtonReceived()
    
  

###################################################################################################################
      # giveTime #
###################################################################################################################
  # Received when the opponent has given you some time
  # 
remote func giveTime():
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  boardNode.giveTime()
  
  

###################################################################################################################
      # playerResign #
###################################################################################################################
  # Received when the opponent has resigned
  # 
remote func playerResign():
  pushNotificationToChat("Opponent has resigned")
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  boardNode.opponentResign()
  
  

###################################################################################################################
      # updateForfeit #
###################################################################################################################
  # Called on a disconnection from either play
  # Might as well call it a win, your opponent won't know
  # 
func updateForfeit():
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  if boardNode.isGameActive():
    pushNotificationToChat("Claiming victory because who is going to stop you.")
    boardNode.opponentForfeit()
  


 

###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Game setup ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # _on_connected_to_server #
###################################################################################################################
  # Received when the peer has successfully connected to the host
  # 
func _on_connected_to_server():
    UpdateStatusText("Connected to Server", Game.GREEN)



###################################################################################################################
      # _on_connection_failed #
###################################################################################################################
  # Received when the peer has failed to connected to the host
  # 
func _on_connection_failed():
  pushNotificationToChat("Connection failed")
  UpdateStatusText("Connection failed", Game.RED)



###################################################################################################################
      # _on_network_peer_connected #
###################################################################################################################
  # Received when the host successfully receives a connection
  # 
func _on_network_peer_connected(id):
  get_tree().set_refuse_new_network_connections(true)
  playerPeerID = id
  playerIsConnected = true
  UpdateStatusText("Peer connected", Game.GREEN)
  rpc_id(playerPeerID,"updatePlayerInfo", playerName, playerNameColor)



###################################################################################################################
      # _on_network_peer_disconnected #
###################################################################################################################
  # Received when the host loses connection with the peer
  # 
func _on_network_peer_disconnected(_id):
  pushNotificationToChat("Network peer has disconnected")
  playerIsConnected = false
  updateForfeit()



###################################################################################################################
      # _on_server_disconnected #
###################################################################################################################
  # Received when the peer loses connection with the host
  # 
func _on_server_disconnected():
  pushNotificationToChat("Server has disconnected")
  playerIsConnected = false
  updateForfeit()



###################################################################################################################
      # _on_HostGameButton_button_down #
###################################################################################################################
  # The host game button has been pressed, start up the server
  # 
func _on_HostGameButton_button_down():
  peer = NetworkedMultiplayerENet.new()
  peer.always_ordered = true
  if !peer.create_server(Game.GAME_PORT, 1):
    UpdateStatusText("Server listening...", Game.GREEN)
    playerIsHost = true
  else:
    UpdateStatusText("Error creating server", Game.RED)
  get_tree().network_peer = peer



###################################################################################################################
      # _on_JoinGameButton_button_down #
###################################################################################################################
  # The join game button has been pressed, attempt to connect with the provided server info
  # 
func _on_JoinGameButton_button_down():
  peer = NetworkedMultiplayerENet.new()
  peer.always_ordered = true
  if !peer.create_client(Game.GAME_IP, Game.GAME_PORT):
    UpdateStatusText("Connecting to server...", Game.GREEN)
  else:
    UpdateStatusText("Error creating client", Game.RED)
  get_tree().network_peer = peer   
  $StartPanel/HostColorLabel.hide()
  $StartPanel/HostColorList.hide()
  $StartPanel/HostTimeTitleLabal.hide()
  $StartPanel/HostTimePlusLabel.hide()
  $StartPanel/HostTimeMinuteEdit.hide()
  $StartPanel/HostTimeIncrementEdit.hide()



###################################################################################################################
      # UpdateStatusText #
###################################################################################################################
  # Set the text and text color for the connection status text
  # 
func UpdateStatusText(text, c):
  $StartPanel/StatusLabel.text = text
  $StartPanel/StatusLabel.modulate = c



###################################################################################################################
      # dispatchGameStart #
###################################################################################################################
  # Called by the host when both players are ready
  # 
func dispatchGameStart():
  #fill out the starting game state
  var hostTime = (hostTimeMinute * 60)
  var peerTime = (hostTimeMinute * 60)
  var increment = hostTimeIncrement
  
  #determine first player
  var hostColor = "meow"
  var peerColor = "meow"
  if $GamePanel/ReadyButton.text == "Ready": # first game, use the chosen first color
    if hostTeamColor == 1:
      var rng = RandomNumberGenerator.new()
      rng.randomize()
      var firstPlayer = rng.randi_range(0, 1)
      if firstPlayer == 0:
        hostTeamColor = 0
      elif firstPlayer == 1:  
        hostTeamColor = 2
        
    if hostTeamColor == 0:
      hostColor = "white"
      peerColor = "black"
    elif hostTeamColor == 2:
      hostColor = "black"
      peerColor = "white"
      
  else: # not the first game. just swap colors
    if playerTeamColor == "white":
      hostColor = "black"
      peerColor = "white"
    else:
      hostColor = "white"
      peerColor = "black"
  
  #send game state to peer
  rpc_id(playerPeerID,"startGame",hostTime,peerTime,increment,peerColor,false)
  
  # prep UI
  hostReadyState = false
  peerReadyState = false
  $StartPanel.hide()
  $GamePanel/ReadyButton.modulate = Game.WHITE
  $GamePanel/ReadyButton.text = "Rematch"
  $GamePanel/ReadyButton.disabled = true
  $GamePanel/TakeBackButton.disabled = true
  $GamePanel/TakeBackButton.show()
  $GamePanel/TakebackYes.hide()
  $GamePanel/TakebackNo.hide()
  
  #start
  playerTeamColor = hostColor
  setSpecialColor(hostColor)
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  boardNode.startGame(hostTime,peerTime,increment,hostColor,playerIsHost)



###################################################################################################################
      # _on_ReadyButton_button_down #
###################################################################################################################
  # Tell the other player you are ready
  # If the player is the host and both players are ready, start the game
  # 
func _on_ReadyButton_button_down():
  if playerIsConnected:
    if playerIsHost:
      hostReadyState = !hostReadyState
      if hostReadyState:
        $GamePanel/ReadyButton.modulate = Game.GREEN
      else:
        $GamePanel/ReadyButton.modulate = Game.WHITE
      rpc_id(playerPeerID, "updateReadyState", hostReadyState)
      var meow = playerName + " has set their ready status to " + String(hostReadyState)
      pushNotificationToChat(meow)
    else:
      peerReadyState = !peerReadyState
      if peerReadyState:
        $GamePanel/ReadyButton.modulate = Game.GREEN
      else:
        $GamePanel/ReadyButton.modulate = Game.WHITE
      rpc_id(playerPeerID, "updateReadyState", peerReadyState)
      var meow = playerName + " has set their ready status to " + String(peerReadyState)
      pushNotificationToChat(meow)
    
    if hostReadyState and peerReadyState:
      dispatchGameStart()



###################################################################################################################
      # _on_ColorPicker_color_changed #
###################################################################################################################
  # Update the players name color
  # 
func _on_ColorPicker_color_changed(color):
  playerNameColor = color
  $StartPanel/NameEdit.add_color_override("font_color", color)
  $GamePanel/PlayerNameLabel.modulate = playerNameColor
  $GamePanel/PlayerNameLabel.text = playerName
  if playerIsConnected:
    rpc_id(playerPeerID,"updatePlayerInfo", playerName, playerNameColor)



###################################################################################################################
      # _on_ColorBotton_button_down #
###################################################################################################################
  # Toggle the color picker for the players name text
  # 
func _on_ColorBotton_button_down():
  if $StartPanel/ColorPicker.visible:
    $StartPanel/ColorPicker.hide()
    $StartPanel/ColorPickerPanel.hide()
  else:
    $StartPanel/ColorPicker.show()
    $StartPanel/ColorPickerPanel.show()



###################################################################################################################
      # _on_NameEdit_text_entered #
###################################################################################################################
  # Update the players name on enter
  # 
func _on_NameEdit_text_entered(new_text):
  playerName = new_text
  $StartPanel/NameEdit.release_focus()
  $GamePanel/PlayerNameLabel.modulate = playerNameColor
  $GamePanel/PlayerNameLabel.text = playerName
  if playerIsConnected:
    rpc_id(playerPeerID,"updatePlayerInfo", playerName, playerNameColor)



###################################################################################################################
      # _on_HostColorList_item_selected #
###################################################################################################################
  # Update which player gets to play white / black
  # 
func _on_HostColorList_item_selected(index):
  hostTeamColor = index
  $StartPanel/HostColorList.release_focus()



###################################################################################################################
      # _on_HostTimeMinuteEdit_text_entered #
###################################################################################################################
  # Update the game time in minutes
  # 
func _on_HostTimeMinuteEdit_text_entered(new_text):
  hostTimeMinute = new_text.to_int()
  $StartPanel/HostTimeMinuteEdit.text = String(hostTimeMinute)
  $StartPanel/HostTimeMinuteEdit.release_focus()



###################################################################################################################
      # _on_HostTimeIncrementEdit_text_entered #
###################################################################################################################
  # Update the game increment in seconds
  # 
func _on_HostTimeIncrementEdit_text_entered(new_text):
  hostTimeIncrement = new_text.to_int()
  $StartPanel/HostTimeIncrementEdit.text = String(hostTimeMinute)
  if hostTimeMinute == 0:
    hostTimeMinute = 1
    $StartPanel/HostTimeIncrementEdit.text = String(hostTimeMinute)
  $StartPanel/HostTimeIncrementEdit.release_focus()
  


###################################################################################################################
      # _on_NameEdit_text_changed #
###################################################################################################################
  # Update the players name on edit
  # 
func _on_NameEdit_text_changed(new_text):
  playerName = new_text
  $GamePanel/PlayerNameLabel.modulate = playerNameColor
  $GamePanel/PlayerNameLabel.text = playerName
  if playerIsConnected:
    rpc_id(playerPeerID,"updatePlayerInfo", playerName, playerNameColor)



###################################################################################################################
      # _on_HostTimeMinuteEdit_text_changed #
###################################################################################################################
  # Update the game time in minutes
  # 
func _on_HostTimeMinuteEdit_text_changed(new_text):
  if new_text.length() > 0:
    hostTimeMinute = new_text.to_int()
    if hostTimeMinute > 60:
      hostTimeMinute = 60
    elif hostTimeMinute == 0:
      hostTimeMinute = 1
    $StartPanel/HostTimeMinuteEdit.text = String(hostTimeMinute)
    $StartPanel/HostTimeMinuteEdit.caret_position = 100
  else:
    $StartPanel/HostTimeMinuteEdit.text = ""
  


###################################################################################################################
      # _on_HostTimeIncrementEdit_text_changed #
###################################################################################################################
  # Update the game increment in seconds
  # 
func _on_HostTimeIncrementEdit_text_changed(new_text):
  if new_text.length() > 0:
    hostTimeIncrement = new_text.to_int()
    if hostTimeIncrement > 60:
      hostTimeIncrement = 60
    elif hostTimeIncrement == 0:
      hostTimeIncrement = 1
    $StartPanel/HostTimeIncrementEdit.text = String(hostTimeIncrement)
    $StartPanel/HostTimeIncrementEdit.caret_position = 100
  else:
    $StartPanel/HostTimeIncrementEdit.text = ""



###################################################################################################################
      # updateReadyState #
###################################################################################################################
  # Received when the opponent has changed their ready status
  # 
remote func updateReadyState(s):
  var name = "meow"
  if playerIsHost:
    name = peerProfile.pName
    peerReadyState = s
  else:
    name = hostProfile.pName
  var meow = "meow"
  meow = name + " has set their ready status to " + String(s)
  pushNotificationToChat(meow)
  if playerIsHost and hostReadyState and peerReadyState:
    dispatchGameStart()



###################################################################################################################
      # updatePlayerInfo #
###################################################################################################################
  # Received when the opponent has changed their player info
  # 
remote func updatePlayerInfo(pName, pNameColor):
  if playerIsHost:
    peerProfile.pName = pName
    peerProfile.pNameColor = pNameColor
  else:
    hostProfile.pName = pName
    hostProfile.pNameColor = pNameColor
  $GamePanel/OpponentNameLabel.modulate = pNameColor
  $GamePanel/OpponentNameLabel.text = pName



###################################################################################################################
      # startGame #
###################################################################################################################
  # Received by the peer when the host dispatches the game start
  # 
remote func startGame(hostTime, peerTime, increment, peerColor, isHost):
  # prep UI
  hostReadyState = false
  peerReadyState = false
  $StartPanel.hide()
  $GamePanel/ReadyButton.modulate = Game.WHITE
  $GamePanel/ReadyButton.text = "Rematch"
  $GamePanel/ReadyButton.disabled = true
  $GamePanel/TakeBackButton.disabled = true
  $GamePanel/TakeBackButton.show()
  $GamePanel/TakebackYes.hide()
  $GamePanel/TakebackNo.hide()

  #start
  playerTeamColor = peerColor
  setSpecialColor(peerColor)
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  boardNode.startGame(hostTime, peerTime, increment, peerColor, isHost)



###################################################################################################################
      # setSpecialColor #
###################################################################################################################
  # Set the special ability icon to the appropriate color
  # 
func setSpecialColor(c):
  if c == "white":
    $GamePanel/SpecialButton.icon = iconWT
  else:
    $GamePanel/SpecialButton.icon = iconBT
    




###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Draw ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # declineDraw # x
###################################################################################################################
  # Received when the opponent declines your draw
  # 
remote func declineDraw():
  pushNotificationToChat("Draw declined")



###################################################################################################################
      # allowDraw # x
###################################################################################################################
  # Received when the opponent allows your draw
  # 
remote func allowDraw():
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  pushNotificationToChat("Draw allowed")
  boardNode.gameEnd(Game.END_DRAW, "z")
  
  

###################################################################################################################
      # requestDraw # x
###################################################################################################################
  # Received when the opponent requests a draw
  # 
remote func requestDraw():
  pushNotificationToChat("Your opponent has requested a draw")
  pushNotificationToChat("Will you allow it?")
  $GamePanel/DrawButton.hide()
  $GamePanel/DrawButton.disabled = true
  $GamePanel/DrawYes.show()
  $GamePanel/DrawNo.show()



###################################################################################################################
      # _on_DrawButton_button_down # x
###################################################################################################################
  # Dispatches draw request to opponent after the draw button has been pressed
  # 
func _on_DrawButton_button_down():
  if playerIsConnected:
    $GamePanel/DrawButton.disabled = true
    pushNotificationToChat("Requesting draw")
    rpc_id(playerPeerID, "requestDraw")
    
    
    
###################################################################################################################
      # _on_DrawYes_button_down # x
###################################################################################################################
  # Allows the opponents draw request
  # 
func _on_DrawYes_button_down():
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  rpc_id(playerPeerID, "allowDraw")
  $GamePanel/DrawButton.show()
  $GamePanel/DrawButton.disabled = true
  $GamePanel/DrawYes.hide()
  $GamePanel/DrawNo.hide()
  pushNotificationToChat("Draw allowed")
  boardNode.gameEnd(Game.END_DRAW, "z")
  
  
  
###################################################################################################################
      # _on_DrawNo_button_down #
###################################################################################################################
  # Declines the opponents draw request
  # 
func _on_DrawNo_button_down():
  rpc_id(playerPeerID, "declineDraw")
  $GamePanel/DrawButton.show()
  $GamePanel/DrawYes.hide()
  $GamePanel/DrawNo.hide()
  pushNotificationToChat("Draw declined")





###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Take back ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # declineTakeback #
###################################################################################################################
  # Received when the opponent declines your take back
  # 
remote func declineTakeback():
  $GamePanel/TakeBackButton.disabled = true
  pushNotificationToChat("Take back declined")



###################################################################################################################
      # allowTakeback #
###################################################################################################################
  # Received when the opponent allows your take back
  # 
remote func allowTakeback():
  $GamePanel/TakeBackButton.disabled = true
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  pushNotificationToChat("Take back allowed")
  boardNode.takebackMove()



###################################################################################################################
      # requestTakeback #
###################################################################################################################
  # Received when the opponent requests a take back
  # 
remote func requestTakeback():
  pushNotificationToChat("Your opponent has requested a take back")
  pushNotificationToChat("Will you allow it?")
  $GamePanel/TakeBackButton.hide()
  $GamePanel/TakeBackButton.disabled = true
  $GamePanel/TakebackYes.show()
  $GamePanel/TakebackNo.show()



###################################################################################################################
      # _on_TakeBackButton_button_down #
###################################################################################################################
  # Request a take back with the opponent
  # 
func _on_TakeBackButton_button_down():
  if playerIsConnected:
    $GamePanel/TakeBackButton.disabled = true
    pushNotificationToChat("Requesting take back")
    rpc_id(playerPeerID, "requestTakeback")



###################################################################################################################
      # _on_TakebackYes_button_down #
###################################################################################################################
  # Allow the opponents take back request
  # 
func _on_TakebackYes_button_down():
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  rpc_id(playerPeerID, "allowTakeback")
  $GamePanel/TakeBackButton.show()
  $GamePanel/TakeBackButton.disabled = true
  $GamePanel/TakebackYes.hide()
  $GamePanel/TakebackNo.hide()
  pushNotificationToChat("Take back allowed")
  boardNode.takebackMove()



###################################################################################################################
      # _on_TakebackNo_button_down #
###################################################################################################################
  # Decline the opponents take back request
  # 
func _on_TakebackNo_button_down():
  rpc_id(playerPeerID, "declineTakeback")
  $GamePanel/TakeBackButton.show()
  $GamePanel/TakebackYes.hide()
  $GamePanel/TakebackNo.hide()
  pushNotificationToChat("Take back declined")



###################################################################################################################
      # disableTakeback #
###################################################################################################################
  # Used by the board class to hide the take back button after a take back has occurred
  # 
func disableTakeback():
  $GamePanel/TakeBackButton.disabled = true
  
  
  
  
  
###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Tutorial ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # addTutorialButton #
###################################################################################################################
  # Add a button to the tutorial window and link it to an image in the folder
  # 
func addTutorialButton(text, r):  
  var t = Theme.new()
  t.set_color("font_color", "Button", Color(0.9, 0.9, 0.9))
  t.set_color("font_color_hover", "Button", Color(0.9, 0.9, 0.9))
  
  var s = StyleBoxFlat.new()
  s.corner_detail = 8
  s.border_width_bottom = 1
  s.border_width_top = 1
  s.border_width_left = 1
  s.border_width_right = 1
  s.border_color = Color(0, 0, 0, 1)
  s.bg_color = Color(r, 0.0, 0.60, 1)
  s.border_blend = true
  s.corner_radius_top_left = 4
  s.corner_radius_top_right = 4
  s.corner_radius_bottom_left = 4
  s.corner_radius_bottom_right = 4
  s.anti_aliasing = false
  t.set_stylebox("normal", "Button", s)
  t.set_stylebox("focus", "Button", s)
  t.set_stylebox("disabled", "Button", s)
  
  var h = StyleBoxFlat.new()
  h.corner_detail = 8
  h.border_width_bottom = 1
  h.border_width_top = 1
  h.border_width_left = 1
  h.border_width_right = 1
  h.border_color = Color(0, 0, 0, 1)
  h.bg_color = Color(r, 0.0, 0.60, 1)
  h.border_blend = true
  h.corner_radius_top_left = 4
  h.corner_radius_top_right = 4
  h.corner_radius_bottom_left = 4
  h.corner_radius_bottom_right = 4
  h.anti_aliasing = false
  h.bg_color = Color((r - 0.15), 0.0, 0.40, 1)
  t.set_stylebox("hover", "Button", h)
  t.set_stylebox("pressed", "Button", h)

  var vOffset = ((tutorialButtons.size() * 20) + 29)
  tutorialButtons.push_back(Button.new())
  $TutorialPanel.add_child(tutorialButtons.back())
  tutorialButtons.back().rect_position = Vector2(5,vOffset)
  tutorialButtons.back().rect_size = Vector2(125,20)
  var buttonText = text.insert(2,". ")
  tutorialButtons.back().text = "  " + buttonText
  tutorialButtons.back().align = HALIGN_LEFT
  tutorialButtons.back().clip_text = true
  tutorialButtons.back().set_theme(t)
  tutorialButtons.back().connect("button_down", self, "newTutorialSelection", [text])
  
  
  
###################################################################################################################
      # newTutorialSelection #
###################################################################################################################
  # A selection button has been pressed, set the linked image to the texture
  #
func newTutorialSelection(t):
  t = t.replace(" ", "")
  for i in tutorialImages:
    var fName = i.load_path.get_file()
    var dot = fName.find(".",0)
    fName = fName.substr(0,dot)
    if t == fName:
      $TutorialPanel/Page.texture = i
  
  
  
###################################################################################################################
      # loadTutorialImages #
###################################################################################################################
  # Load and store all the tutorial images and buttons
  #
func loadTutorialImages():
  var path = "res://assets/tutorial/"
  var dir = Directory.new()
  dir.open(path)
  dir.list_dir_begin()
  var r = 0.62
  while true:
    r -= 0.02
    var fileName = dir.get_next()
    fileName = fileName.replace(".import", "")
    if fileName == "":
      break
    elif !fileName.begins_with(".") and !fileName.ends_with(".import"):
      tutorialImages.append(load(path + fileName))
      addTutorialButton(fileName.get_basename(), r)
  dir.list_dir_end()
  
  $TutorialPanel/Page.texture = tutorialImages[0]
  
  
  
###################################################################################################################
      # _on_TutorialClose_button_down #
###################################################################################################################
  # Close the tutorial window
  #
func _on_TutorialClose_button_down():
  $TutorialPanel.hide()
  
  
  
###################################################################################################################
      # _on_HelpButton_button_down #
###################################################################################################################
  # Open the tutorial window
  #
func _on_HelpButton_button_down():
  $TutorialPanel.show()
   




###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Promotion ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # _on_PromotionList_item_selected #
###################################################################################################################
  # A promotion has been selected, send the choice to the board class
  #
func _on_PromotionList_item_selected(index):
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  $PromotionList.hide()
  boardNode.setPromotion(index)



###################################################################################################################
      # alignPromotionWindow #
###################################################################################################################
  # Set the promotion window to the mouse position, but keep it in the view port
  #
func alignPromotionWindow():
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  $PromotionList.rect_position = get_viewport().get_mouse_position()
  $PromotionList.rect_position.x = clamp(
      $PromotionList.rect_position.x,
      0,
      ($PromotionList.get_viewport_rect().size.x - $PromotionList.rect_size.x))
  $PromotionList.rect_position.y = clamp(
      $PromotionList.rect_position.y,
      0,
      ($PromotionList.get_viewport_rect().size.y - $PromotionList.rect_size.y))



###################################################################################################################
      # loadPromotionWhite #
###################################################################################################################
  # Load up one of whites promotion sets
  #
func loadPromotionWhite(promotingType):
  if promotingType == "wP":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconWP, true)
    $PromotionList.add_icon_item(iconWR, true)
    alignPromotionWindow()
  elif promotingType == "wM":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconWM, true)
    $PromotionList.add_icon_item(iconWA, true)
    alignPromotionWindow()
  elif promotingType == "wE":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconWE, true)
    $PromotionList.add_icon_item(iconWZ, true)
    alignPromotionWindow()
  elif promotingType == "wG":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconWG, true)
    $PromotionList.add_icon_item(iconWX, true)
    alignPromotionWindow()
  elif promotingType == "wD":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconWD, true)
    $PromotionList.add_icon_item(iconWL, true)
    alignPromotionWindow()
  elif promotingType == "wH":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconWH, true)
    $PromotionList.add_icon_item(iconWO, true)
    alignPromotionWindow()
  elif promotingType == "wN":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconWN, true)
    $PromotionList.add_icon_item(iconWX, true)
    alignPromotionWindow()



###################################################################################################################
      # loadPromotionWhite #
###################################################################################################################
  # Load up one of whites promotion sets
  #
func loadPromotionBlack(promotingType):
  if promotingType == "bP":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconBP, true)
    $PromotionList.add_icon_item(iconBR, true)
    alignPromotionWindow()
  elif promotingType == "bM":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconBM, true)
    $PromotionList.add_icon_item(iconBA, true)
    alignPromotionWindow()
  elif promotingType == "bE":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconBE, true)
    $PromotionList.add_icon_item(iconBZ, true)
    alignPromotionWindow()
  elif promotingType == "bG":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconBG, true)
    $PromotionList.add_icon_item(iconBX, true)
    alignPromotionWindow()
  elif promotingType == "bD":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconBD, true)
    $PromotionList.add_icon_item(iconBL, true)
    alignPromotionWindow()
  elif promotingType == "bH":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconBH, true)
    $PromotionList.add_icon_item(iconBO, true)
    alignPromotionWindow()
  elif promotingType == "bN":
    $PromotionList.clear()
    $PromotionList.show()
    $PromotionList.add_icon_item(iconBN, true)
    $PromotionList.add_icon_item(iconBX, true)
    alignPromotionWindow()





###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Themes ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # loadBoards #
###################################################################################################################
  # Load all the boards in the directory and store them
  #
func loadBoards():
  var path = "res://assets/boards/"
  var dir = Directory.new()
  dir.open(path)
  dir.list_dir_begin()
  while true:
    var fileName = dir.get_next()
    fileName = fileName.replace(".import", "")
    if fileName == "":
      break
    elif !fileName.begins_with(".") and !fileName.ends_with(".import"):
      boards.append(load(path + fileName))
  dir.list_dir_end()
  
  for i in boards:
    $ThemePanel/BoardList.add_icon_item(i, true)
    
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  boardNode.setBoardTexture(boards[0])



###################################################################################################################
      # loadBoarders #
###################################################################################################################
  # Load all the boarders in the directory and store them
  #
func loadBoarders():
  var path = "res://assets/layout/"
  var dir = Directory.new()
  dir.open(path)
  dir.list_dir_begin()
  while true:
    var fileName = dir.get_next()
    fileName = fileName.replace(".import", "")
    if fileName == "":
      break
    elif !fileName.begins_with(".") and !fileName.ends_with(".import"):
      boarders.append(load(path + fileName))
  dir.list_dir_end()
  
  for i in boarders:
    $ThemePanel/BoarderList.add_icon_item(i, true) 

  $BoarderTexture.texture = boarders[0]
  
  

###################################################################################################################
      # _on_ThemesButton_button_down #
###################################################################################################################
  # Toggle the visibility of the themes window
  #
func _on_ThemesButton_button_down():
  if $ThemePanel.visible:
    $ThemePanel.hide()
  else:
    $ThemePanel.show()
    


###################################################################################################################
      # _on_ThemeCloseButton_button_down #
###################################################################################################################
  # Close the themes window
  #
func _on_ThemeCloseButton_button_down():
  $ThemePanel.hide()
    


###################################################################################################################
      # _on_BoardList_item_selected #
###################################################################################################################
  # A new board theme has been selected
  #
func _on_BoardList_item_selected(index):
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  boardNode.setBoardTexture(boards[index])
    


###################################################################################################################
      # _on_BoarderList_item_selected #
###################################################################################################################
  # A new boarder theme has been selected
  #
func _on_BoarderList_item_selected(index):
  $BoarderTexture.texture = boarders[index]
  
  
  


###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Chat ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # pushToChat #
###################################################################################################################
  # Display a message in the chat window
  #
func pushToChat(msg):
  $GamePanel/ChatRichTextLabel.push_color(playerNameColor)
  $GamePanel/ChatRichTextLabel.add_text("<" + playerName + "> ")
  $GamePanel/ChatRichTextLabel.push_color(Game.WHITE)
  $GamePanel/ChatRichTextLabel.add_text(msg + "\n")
  


###################################################################################################################
      # pushToChatRemote #
###################################################################################################################
  # The opponent has sent a chat message
  #
remote func pushToChatRemote(msg):
  var name = "meow"
  var color = Game.WHITE
  if playerIsHost:
    name = peerProfile.pName
    color = peerProfile.pNameColor
  else:
    name = hostProfile.pName
    color = hostProfile.pNameColor
  $GamePanel/ChatRichTextLabel.push_color(color)
  $GamePanel/ChatRichTextLabel.add_text("<" + name + "> ")
  $GamePanel/ChatRichTextLabel.push_color(Game.WHITE)
  $GamePanel/ChatRichTextLabel.add_text(msg + "\n")
  


###################################################################################################################
      # pushNotificationToChat #
###################################################################################################################
  # Send a grey notification to chat
  #
func pushNotificationToChat(msg):
  $GamePanel/ChatRichTextLabel.push_color(Game.LIGHT_GREY)
  $GamePanel/ChatRichTextLabel.add_text(msg + "\n")
  $GamePanel/ChatRichTextLabel.push_color(Game.WHITE)
  


###################################################################################################################
      # pushAnnouncementToChat #
###################################################################################################################
  # Send a fancy yellow announcement to chat
  #
func pushAnnouncementToChat(msg):
  $GamePanel/ChatRichTextLabel.push_color(Game.YELLOW)
  $GamePanel/ChatRichTextLabel.add_text("[" + msg + "]\n")
  $GamePanel/ChatRichTextLabel.push_color(Game.WHITE)
  


###################################################################################################################
      # _on_ChatLineEdit_text_entered #
###################################################################################################################
  # The player has entered a chat message, display it and dispatch it
  #
func _on_ChatLineEdit_text_entered(new_text):
  if new_text.length() > 0:
    $GamePanel/ChatLineEdit.text = ""
    pushToChat(new_text)
    if playerIsConnected:
      rpc_id(playerPeerID, "pushToChatRemote", new_text)
  
  
  


###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Chat ###
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
###################################################################################################################
      # _on_OptionsXButton_button_down #
###################################################################################################################
  # Close the options window
  #
func _on_OptionsXButton_button_down():
  $OptionPanel.hide()
  


###################################################################################################################
      # _on_OptionsButton_button_down #
###################################################################################################################
  # Show the options window
  #
func _on_OptionsButton_button_down():
  $OptionPanel.show()
  


###################################################################################################################
      # _on_MoveOption_item_set #
###################################################################################################################
  # Handle the move option selection
  #
func _on_MoveOption_item_set(index):
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  boardNode.setMoveOption(index)
  


###################################################################################################################
      # _on_DrawOption_item_set #
###################################################################################################################
  # Handle the moveable square drawing option
  #
func _on_MoveDrawOption_item_set(index):
  var boardNode = $StartPanel.get_parent().get_parent().get_child(1)
  boardNode.setMoveDrawOption(index)


