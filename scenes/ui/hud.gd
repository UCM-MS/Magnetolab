class_name Hud
extends CanvasLayer
## HUD: inventár (sloty s ikonami predmetov) a dialógové okno profesora Magnetóna.

## Veľkosť jedného slotu inventára (px).
const SLOT_SIZE: Vector2 = Vector2(48, 48)
const SLOT_STYLE: StyleBox = preload("res://scenes/ui/inventory_slot_style.tres")

## Ikony v slotoch (v poradí zľava).
var _slot_icons: Array[TextureRect] = []

@onready var dialog_box: DialogBox = $DialogBox
@onready var _slots: Container = $InventoryPanel/Margin/Content/Slots


func _ready() -> void:
	for i: int in Inventory.MAX_SLOTS:
		_slots.add_child(_create_slot())
	show_inventory([])


## Prázdny slot: rámček s miestom na ikonu.
func _create_slot() -> Control:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.add_theme_stylebox_override("panel", SLOT_STYLE)
	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	slot.add_child(icon)
	_slot_icons.append(icon)
	return slot


## Prekreslí sloty podľa obsahu inventára (prázdne sloty ostanú prázdne).
func show_inventory(items: Array[ItemData]) -> void:
	for i: int in _slot_icons.size():
		var has_item: bool = i < items.size()
		_slot_icons[i].texture = items[i].icon if has_item else null
		_slot_icons[i].tooltip_text = items[i].display_name if has_item else ""


## Všetky texty pre hráča idú cez dialógové okno.
func show_dialog(dialog: DialogData) -> void:
	dialog_box.show_dialog(dialog)
