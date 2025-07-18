extends Node

var player: Player = Player.new()
var player_cam: Camera3D
var currentWindow
var currentDialog: Dialog
var currentTrade: Trade
var current_prg: ProceduralRoomGenerator
var loadingScreenScene = preload("res://shared/ui/loading_screen.tscn")
var loadingScreen = null
var menuScene = preload("res://shared/menu/menu.tscn")
var loadingDoneChecker = Timer.new()
var missions: Array[Mission] = []
var deathScreen = preload("res://shared/ui/death_screen/death_screen.tscn")

const missionsSavePath: String = "user://missions.json"
const questsSavePath: String = "user://quests.json"

func _enter_tree():
	add_child(player)
	loadingScreen = loadingScreenScene.instantiate()
	add_child(loadingScreen)

func createDialog(npc_id:String, dialog_data_path:String) -> Dialog:
	if !currentDialog:
		currentDialog = Dialog.new_instance(dialog_data_path, Callable(WorldUtil, "closeCurrentWindow"))
		add_quest_dialogs(npc_id, currentDialog)
		currentDialog.load_dialog_data()
		add_child(currentDialog)
		currentWindow = currentDialog
	return currentDialog

func add_quest_dialogs(npc_id, _currentDialog):
	for _quest in QuestLoader.get_quests():
		if _quest.status != Quest.Status.ACTIVE:
			continue
		var _tasks = _quest.get_active_tasks()
		if _tasks.is_empty():
			continue
		for _t in _tasks:
			var additional_dialog = _t.dialog as TaskDialog
			if !additional_dialog or additional_dialog.npc != npc_id or !additional_dialog.conditions_met():
				continue
			_currentDialog.add_options(additional_dialog.source, additional_dialog.get_dialog_key(), additional_dialog.as_dialog_options())

func get_map_rng_visibility() -> bool:
	return current_prg == null || current_prg.next_loot_visible()

func addKillCounter(enemy_id: String, amount: int):
	for mission in missions:
		if mission:
			mission.addKillCounter(enemy_id, amount)
	player.addKillCounter(enemy_id, amount)
	save()

func getSavedMissions() -> Array[Mission]:
	var _missions = []
	var saves = FileUtil.getContentAsJson(missionsSavePath, false) as Dictionary
	for key in saves.keys():
		_missions.push_back(Mission.from(saves[key]))
	missions.clear()
	missions.append_array(_missions)
	return missions

func save_mission(mission: Mission):
	var missions = FileUtil.getContentAsJson(missionsSavePath, false) as Dictionary
	missions[mission.getSeed()] = mission.toDict()
	FileUtil.saveJsonContent(missionsSavePath, missions)

func remove_mission(mission: Mission):
	var missions = FileUtil.getContentAsJson(missionsSavePath, false) as Dictionary
	missions.erase(mission.getSeed())
	FileUtil.saveJsonContent(missionsSavePath, missions)
	mission.queue_free()

var enemy_died_callbacks: Array[Callable] = []

func enemy_died(enemy_type: Enemy.ENEMY_TYPE):
	for enemy_died_callback in enemy_died_callbacks:
		enemy_died_callback.call(enemy_type)
	
func add_on_enemy_died_callback(callback: Callable):
	enemy_died_callbacks.append(callback)
	
func remove_on_enemy_died_callback(callback: Callable):
	enemy_died_callbacks.erase(callback)

# generic methods under this line #
###################################

func hasUnlocked(payload: Array):
	for key in payload:
		if !player.unlocks.has(key):
			return false
	return true

func openStorage():
	if currentTrade:
		return null
	currentTrade = Trade.new_instance(player.inventory, player.storage,
		onStorageAction, "Inventory", "Storage")
	add_child(currentTrade)
	currentWindow = currentTrade
	return currentTrade

func onStorageAction(action: Trade.Actions, payload: Array = []):
	if action != Trade.Actions.SAVE_TRADE and action != Trade.Actions.CANCEL_PRESSED:
		return
	if action == Trade.Actions.SAVE_TRADE:
		player.inventory = payload[0]
		player.storage = payload[1]
	return true
	
func openShop(payload: Array):
	if currentTrade:
		return null
	var shopDetails = FileUtil.getContentAsJson(payload[0])
	var priceList = FileUtil.getContentAsJson(payload[1])
	var playerInv = Inventory.from({
		Inventory.GOLD_ITEM: player.inventory.count(Inventory.GOLD_ITEM)
	})
	var shopInv = ShopInventory.createForItemIds(shopDetails["items"])
	currentTrade = Trade.new_instance(playerInv, shopInv,
		onShopAction, "Shopping cart", shopDetails["name"], priceList, true)
	add_child(currentTrade)
	currentWindow = currentTrade
	return currentTrade
	
func openCrafting():
	var crafting = load("res://shared/crafting/crafting.tscn").instantiate() as Crafting
	add_child(crafting)
	currentWindow = crafting
	
func onShopAction(action: Trade.Actions, payload: Array = []):
	if action != Trade.Actions.SAVE_TRADE and action != Trade.Actions.CANCEL_PRESSED:
		return
	if action == Trade.Actions.SAVE_TRADE and not savePlayerTrade(payload[0]):
		return false
	return true
	
func savePlayerTrade(shoppingCart:Inventory):
	var newPlayerGold = shoppingCart.count(Inventory.GOLD_ITEM)
	if newPlayerGold < 0:
		return false
	shoppingCart.moveAllItems(player.inventory)
	player.inventory.set_total(Inventory.GOLD_ITEM, newPlayerGold)
	return true

func openSellLoot(payload: Array):
	if currentTrade:
		return null
	currentTrade = Trade.new_instance(player.inventory, Inventory.empty(),
		 onSellLootAction, "Inventory", "Your sell items",
		FileUtil.getContentAsJson(payload[0]))
	add_child(currentTrade)
	currentWindow = currentTrade
	return currentTrade

func openMissionBoard(payload: Array):
	var mission_board = load("res://shared/mission/missions.tscn").instantiate()
	add_child(mission_board)
	currentWindow = mission_board
	return mission_board

func onSellLootAction(action: Trade.Actions, payload: Array = []):
	if action != Trade.Actions.SAVE_TRADE and action != Trade.Actions.CANCEL_PRESSED:
		return
	if action == Trade.Actions.SAVE_TRADE:
		player.inventory = payload[0]
	return true

func teleportToMissionMap(payload: Array):
	await loadingScreen.fade_in()
	player.save()
	player.bodyStartPos = Vector3.ZERO
	remove_child(current_prg)
	current_prg = ProceduralRoomGenerator.from_seed(str(payload[0]))
	var enemies = payload[1] if payload.size() > 1 else {}
	current_prg.set_enemies(enemies)
	var additionalItems = payload[2] if payload.size() > 2 else {}
	current_prg.set_additional_items(additionalItems)
	add_child(current_prg)
	player.setInMission(true)
	loadingScreen.fade_out()
	closeCurrentWindow()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func removeAllEnemies():
	var enemies = get_tree().get_nodes_in_group("enemies") as Array[Enemy]
	for enemy in enemies:
		enemy.queue_free()

func teleportToLowerShip(_payload: Array = []):
	await loadingScreen.fade_in()
	removeAllEnemies()
	player.setInMission(false)
	player.teleport("ship", Vector3(-1,-3,-12))
	loadingScreen.fade_out()
	closeCurrentWindow()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func removeFromPlayerInventory(payload: Array = []) -> bool:
	var result = player.inventory.remove(payload[0], payload[1])
	player.body.refresh_inventory_output()
	player.save()
	return result

func addToPlayerInventory(payload: Array):
	player.inventory.add(payload[0], payload[1])
	player.body.refresh_inventory_output()
	player.save()

func checkPlayerInventory(payload: Array):
	return player.inventory.check(payload[0], payload[1])
	
func hasStoreInventoryItems(_payload: Array = []):
	return !player.salvager.is_empty()

func quitGame():
	save()
	get_tree().quit()

func save():
	player.save()
	
func showMenu():
	var menu = menuScene.instantiate()
	add_child(menu)
	currentWindow = menu
	return menu
	
func respawn():
	player.inventory = Inventory.empty()
	teleportToLowerShip()
	
func setCurrentWindow(new_current_window):
	if currentWindow:
		return
	currentWindow = new_current_window
	add_child(currentWindow)

func closeCurrentWindow():
	if not currentWindow:
		return
	if currentWindow.has_method("on_close"):
		currentWindow.on_close()
	currentWindow.queue_free()
	currentWindow = null
	currentTrade = null
	currentDialog = null
	
func player_died():
	WorldUtil.player.clearMissionInventories()
	WorldUtil.setCurrentWindow(deathScreen.instantiate())
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func movePlayerCamera(relative_x: float, relative_y: float):
	if not player or not player.body:
		return
	player.body.moveCamera(relative_x, -relative_y)
