###################################################################################################################
#                                         _    /")   (V)   [-]   \^/   \+/                                        #
#                                        ( )   ' (   ) (   | |   ) (   ) (                                        #
#                                       /___\ /___\ /___\ /___\ /___\ /___\                                       #
###################################################################################################################
#                 ### Game Singleton ### by Fenxy
###################################################################################################################
#                                        \+/   \^/   [-]   (V)   ("\    _                                         #
#                                        )#(   )#(   |#|   )#(   )#'   (#)                                        #
#                                       /###\ /###\ /###\ /###\ /###\ /###\                                       #
###################################################################################################################
extends Node



###################################################################################################################
      # Config #
###################################################################################################################
  # 
const VERSION = "v1.13"  

const SQUARE_COUNT = 10
const CASTLE_TYPE = "M"
const DRAW_MATERIAL_VALUE = 3.5



###################################################################################################################
      # Classes #
###################################################################################################################
  #   
class GameState:
  var isActive: bool
  var isTurn: bool
  var turnCount: int
  var increment: int
  var rule50MoveCount: int
  var playerIsHost: bool
  var playerColor: String
  
class LastCheck:
  var isCheck: String
  var type: String
  var file: int
  var rank: int
  var checkLine: PoolVector2Array
  
class PieceMove:
  var type: String
  var state: int
  var count: int
  var oFile: int
  var oRank: int
  var dFile: int
  var dRank: int
  var pTime: int
  var oTime: int
  var move50rule: int
  var animation: int
  var wasPromotion: bool

class PromotionSet:
  var type: String
  var promotionList: Array



###################################################################################################################
      # Variables #
###################################################################################################################
const CHARS = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
    "u", "v", "w", "x", "y", "z"]
  
const BOARD_SIZE = 1000.0
var SQUARE_SIZE: float

const WINDOW_SIZE = Vector2(825, 550)
const BOARD_WINDOW_SIZE = 500.0
const BOARDER_WIDTH = 25.0
const MENU_WIDTH = 275.0

const GAME_PORT = 8070
const GAME_IP = "127.0.0.1"
  
const END_RESIGN = 1
const END_MATE = 2
const END_TIME = 3
const END_DRAW = 4
const END_STALEMATE = 5
const END_FORFEIT = 6

const CASTLE_LEFT = 1
const CASTLE_RIGHT = 2

const SHOW_ALL = 0
const SHOW_VALID = 1
const SHOW_NONE = 2

const MOVE_DRAG = 0
const MOVE_CLICK = 1

const WHITE = Color(1, 1, 1, 1)
const DARK_GREY = Color(0.35, 0.35, 0.35, 1.0)
const LIGHT_GREY = Color(0.75, 0.75, 0.75, 1.0)
const GREEN = Color(0, 1, 0, 1)
const RED = Color(1, 0, 0, 1)
const GOLD = "#ffd700"
const YELLOW = Color(1, 1, 0, 1)
const PURPLE = Color(1, 0, 1, 1)



###################################################################################################################
      # _ready #
###################################################################################################################
  # Called when the node enters the scene tree for the first time
  #   
func _ready():
  SQUARE_SIZE = (BOARD_SIZE / SQUARE_COUNT)
  
  
