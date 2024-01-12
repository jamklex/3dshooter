extends Object

class_name GameItem

enum GameItemType {UNDEFINIED,MODULE,WEAPON}

var id: String
var name = "NOT_INITIALIZED" as String
var description = "NOT_INITIALIZED" as String
var image: CompressedTexture2D
var tradeable: bool
var type:GameItemType
