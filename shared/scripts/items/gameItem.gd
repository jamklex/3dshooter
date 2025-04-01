extends Object

class_name GameItem

enum GameItemType {UNDEFINIED,MODULE,WEAPON,BLUEPRINT,RESOURCE,AMMO}
enum Rarity {UNDEFINIED,COMMON,UNCOMMON,RARE}

var id: String
var name = "NOT_INITIALIZED" as String
var description = "NOT_INITIALIZED" as String
var image: CompressedTexture2D
var tradeable: bool
var type:GameItemType
var rarity:Rarity
