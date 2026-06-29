extends PanelContainer
class_name ShopUi
var player_instance: InventorySyetem
var merchant_instance: InventorySyetem
@onready var player_container: VBoxContainer = %PlayerItemContainer
@onready var merchant_container: VBoxContainer = %MerchantItemContainer
@onready var m_item_panel_container: PanelContainer = %MItemPanelContainer
@onready var p_item_panel_container: PanelContainer = %PItemPanelContainer
@onready var sell_button: Button = %SellButton
@onready var player_item_label: Label = %PlayerItemLabel
@onready var buy_button: Button = %BuyButton
@onready var mer_chant_item_laber: Label = %MerChantItemLaber
@onready var p_gold_label: Label = %PGoldLabel
@onready var m_glod_label: Label = %MGlodLabel
@onready var deal_popup_box: DealPopupBox = $DealPopupBox
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var merchant_scroll_container: ScrollContainer = %MerchantScrollContainer
@onready var player_scroll_container: ScrollContainer = %PlayerScrollContainer

var open: bool = false

var current_item: ItemInstance
var player: Player
var merchant: Character2d
var chosed_item: Array[ItemInstance] = []
var input_quantity: int = 0
var shop_system: ShopSystem = ShopSystem.new()
var buying: bool = false

signal on_shop_closed
var sum: int = 0


func _ready() -> void:
	self.size = Vector2(
		Global.screen_size.x * 2/3, 
		Global.screen_size.y * 2/3
	)
	self.position = (Global.screen_size - self.size) / 2
	p_item_panel_container.custom_minimum_size = self.size * 1/2
	m_item_panel_container.custom_minimum_size = self.size * 1/2
	player_scroll_container.follow_focus = true
	merchant_scroll_container.follow_focus = true

## 打开库存
func open_bag(inventory_p: Player, inventory_m: Character2d) -> void:
	player = inventory_p
	merchant = inventory_m
	player_instance = inventory_p.inventory
	merchant_instance = inventory_m.inventory
	player_update(player_instance)
	merchant_update(merchant_instance)

func close() -> void:
	queue_free()

## 初始化
func initialize(_player: Player, _merchant: Character2d) -> void:
	player = _player
	merchant = _merchant
	#self.size = Vector2(
		#Global.screen_size.x * 2/3, 
		#Global.screen_size.y * 2/3
	#)
	call_deferred("set_size", Vector2(
		Global.screen_size.x * 2/3, 
		Global.screen_size.y * 2/3
	))
	
	self.position = (Global.screen_size - self.size) / 2
	p_item_panel_container.custom_minimum_size = self.size * 1/2
	m_item_panel_container.custom_minimum_size = self.size * 1/2
	player_instance = _player.inventory
	merchant_instance = _merchant.inventory
	player_update(player_instance)
	merchant_update(merchant_instance)
	



func updata_label(label: Label, price) -> void:
	label.text = ""
	label.text += (tr("ui_quantity") + str(current_item.quantity))
	label.text += (" " + tr("ui_price") + str(price))




func merchant_update(inventory: InventorySyetem) -> void:
	merchant_instance = inventory
	for child in merchant_container.get_children():
		child.queue_free()

	if inventory.base.is_empty():
		for i in range(inventory.base_size):
			var item_button: Button = Button.new()
			item_button.text = tr("ui_empty_slot")
			merchant_container.add_child(item_button)
		m_glod_label.text = tr("ui_gold_label") + str(inventory.gold)
		return		
	for item_key: String in inventory.base:
		var item_button: Button = Button.new()
		item_button.text = inventory.base[item_key].template.display_name
		merchant_container.add_child(item_button)
		item_button.pressed.connect(_on_merchant_item_button_pressed.bind(item_key))
		item_button.focus_entered.connect(_on_merchant_item_button_focus_entered)
	merchant_container.get_child(0).grab_focus()
	m_glod_label.text = tr("ui_gold_label") + str(inventory.gold)
	
	


func player_update(inventory: InventorySyetem) -> void:
	player_instance = inventory
	for child in player_container.get_children():
		child.queue_free()

	if inventory.base.is_empty():
		for i in range(inventory.base_size):
			var item_button: Button = Button.new()
			item_button.text = tr("ui_empty_slot")
			player_container.add_child(item_button)
		p_gold_label.text = tr("ui_gold_label") + str(inventory.gold)
		return		
	for item_key: String in inventory.base:
		var item_button: Button = Button.new()
		item_button.text = inventory.base[item_key].template.display_name
		player_container.add_child(item_button)
		item_button.pressed.connect(_on_player_item_button_pressed.bind(item_key))

	p_gold_label.text = tr("ui_gold_label") + str(inventory.gold)


func clear() -> void:
	
	pass


var can_sell_array: Array = [
	"red_herb", "blue_herb",
]



func _on_player_item_button_pressed(template_id: String) -> void:
	
	current_item = player_instance.base[template_id]
	var price: int = shop_system.calculate_sell_price(current_item.get_price())
	updata_label(player_item_label, price)
	sell_button.disabled = true
	for item in can_sell_array:
		if current_item.get_template_id() == item:
			sell_button.disabled = false
			break
	
	buy_button.disabled = true


func _on_merchant_item_button_pressed(template_id: String) -> void:
	current_item = merchant_instance.base[template_id]
	var price: int = shop_system.calculate_buy_price(current_item.get_price())
	updata_label(mer_chant_item_laber, price)
	sell_button.disabled = true
	buy_button.disabled = false
	
func _on_merchant_item_button_focus_entered() -> void:
	#merchant_scroll_container.sroll_to
	pass


func _on_close_button_pressed() -> void:
	on_shop_closed.emit(sum)
	audio_stream_player_2d.play()
	Global.check_consume()
	InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)
	self.queue_free()




func buy() -> void:
	## 返回单价
	if current_item == null:
		return
	var id: String = current_item.get_template_id()
	var cost: int = input_quantity * shop_system.calculate_buy_price(current_item.get_price())
	## 判断玩家钱够不够
	if cost > player_instance.gold:
		LogManager.add_entry(tr("shop_gold_insufficient"))
		return
	if current_item.quantity < input_quantity:
		LogManager.add_entry(tr("shop_quantity_insufficient"))
		return
	## 判断背包够不够
	var new_item: ItemInstance = ItemFactory.create_item(id, input_quantity)
	if player_instance.add_item(new_item):
		player_instance.gold -= cost
		merchant_instance.gold += cost
		merchant_instance.reduce_item(id, input_quantity)
		update_shop()
		sum += cost
	else:
		LogManager.add_entry(tr("shop_inventory_full"))
		return
	
	## 刷新显示


func update_shop() -> void:
	#await get_tree().create_timer(1).timeout
	mer_chant_item_laber.text = ""
	m_glod_label.text = ""	
	player_item_label.text = ""
	p_gold_label.text = ""
	input_quantity = 0
	#player_instance = player.inventory
	#merchant_instance = merchant.inventory
	player_update(player_instance)
	merchant_update(merchant_instance)



func sell() -> void:
	if current_item == null:
		return
	## 返回单价
	var id: String = current_item.get_template_id()
	var cost: int = input_quantity * shop_system.calculate_sell_price(current_item.get_price())
	## 判断商人钱够不够
	if cost > merchant_instance.gold:
		LogManager.add_entry(tr("shop_gold_insufficient"))
		return
	## 判断物品数量够不够
	if current_item.quantity < input_quantity:
		LogManager.add_entry(tr("shop_quantity_insufficient"))
		return
	if current_item.is_equipped:
		LogManager.add_entry(tr("shop_equipped_cannot_sell"))
		return
	## 判断背包够不够
	var new_item: ItemInstance = ItemFactory.create_item(id, input_quantity)
	if merchant_instance.add_item(new_item):
		merchant_instance.gold -= cost
		player_instance.gold += cost		
		player_instance.reduce_item(id, input_quantity)
		update_shop()
		sum += cost
		
	else :
		
		
		return
	

func _on_buy_button_pressed() -> void:
	buying = true
	deal_popup_box.popupWindow()
	deal_popup_box.grab_edit()
	
	

func _on_sell_button_pressed() -> void:
	buying = false
	deal_popup_box.popupWindow()
	
	

func _on_deal_popup_box_on_button_confimed_input(input: int) -> void:
	input_quantity = input
	if buying:
		buy()
		buy_button.grab_focus()
	else:
		sell()
		sell_button.grab_focus()
	
	SignalManager.on_player_ui_update.emit(player)







#
### 测试使用的数据
#var merchant_data: Array = [
	#"healing_potion", "yellow_key", "red_herb", "blue_key"
#]
#
#
### 测试使用的数据
#var player_data: Array = [
	#"healing_potion", "yellow_key", "blue_key"
#]
#var test_p: InventorySyetem = InventorySyetem.new()
#var test_m: InventorySyetem = InventorySyetem.new()
#
#func test() -> void:
	### 对character进行初始化，导入数据
	#CharacterFactory.initialize()
	#if CharacterFactory.get_template("ghost"):
		#print("人物模板初始化完成")	
	#ItemFactory.initialize()
	#if ItemFactory.get_template("healing_potion"):
		#print("物品模板初始化完成")	
	#for id1 in merchant_data:
		#var new_item: ItemInstance = ItemFactory.create_item(id1, 10)
		#test_m.add_item(new_item)
	#for id2 in player_data:
		#var new_item: ItemInstance = ItemFactory.create_item(id2, 10)
		#test_p.add_item(new_item) 
	#test_p.gold = 1000
	#test_m.gold = 10000
	#
	#initialize(test_p, test_m)
	#merchant_update(test_m)
	#player_update(test_p)
