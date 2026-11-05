class_name Hud
extends CanvasLayer
## HUD: inventár (sloty s ikonami predmetov) a dialógové okno profesora Magnetóna.

## Hráč stlačil Esc – chce sa vrátiť do hlavného menu.
signal menu_requested

## Veľkosť jedného slotu inventára (px).
const SLOT_SIZE: Vector2 = Vector2(48, 48)
## Vzhľad slotu je v Theme (resources/ui_theme.tres) pod týmto názvom.
const SLOT_THEME_TYPE: StringName = &"InventorySlot"

## Ikony v slotoch (v poradí zľava).
var _slot_icons: Array[TextureRect] = []

@onready var dialog_box: DialogBox = $DialogBox
@onready var _slots: Container = $InventoryPanel/Margin/Content/Slots


func _ready() -> void:
	for i: int in Inventory.MAX_SLOTS:
		_slots.add_child(_create_slot())
	show_inventory([])


## Esc riešime tu, lebo HUD beží stále – Esc tak funguje aj pri otvorenom dialógu,
## keď je zvyšok hry pozastavený.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		menu_requested.emit()


## Prázdny slot: rámček s miestom na ikonu.
func _create_slot() -> Control:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.theme_type_variation = SLOT_THEME_TYPE
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
