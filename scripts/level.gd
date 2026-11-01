class_name Level
extends Node2D
## Spoločný skript pre všetky miestnosti: pri štarte načíta mriežku
## do GridManagera, umiestni na ňu všetky objekty a pospája signály s HUD.

## Krátke reakcie Magnetóna spoločné pre všetky levely.
const UI_TEXTS: UiTexts = preload("res://resources/ui_texts.tres")
## Skupina objektov, ktoré vedia vyžiadať dialóg (spúšťacie oblasti, tabule).
const DIALOG_SOURCES_GROUP: StringName = &"dialog_sources"

## Vrstva s podlahou, stenami a priepasťami (podľa príznakov dlaždíc).
@export var room_layer: TileMapLayer
@export var player: Player
@export var hud: Hud
## Údaje o leveli (spätná väzba k tipu, kartička „Čo si zistil“...).
@export var level_data: LevelData

## Reakcia na ťažkú bedňu sa ukáže len prvýkrát v leveli.
var _heavy_hint_shown: bool = false
## Ktorú možnosť hráč zvolil v otázke „odhadni“ (-1 = ešte netipoval).
var _guess_option: int = -1
## Spätná väzba k tipu sa ukáže len raz – po prvom pokuse.
var _guess_checked: bool = false


func _ready() -> void:
	_connect_signals()
	GridManager.setup(room_layer)
	get_tree().call_group(GridObject.GROUP, "place_on_grid")


## R = reštart miestnosti (načíta scénu znova od začiatku).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart"):
		get_tree().reload_current_scene()


## Objekty o sebe nevedia – level ich signály napojí na HUD.
func _connect_signals() -> void:
	player.inventory.changed.connect(hud.show_inventory)
	player.inventory.item_added.connect(_on_item_added)
	player.push_blocked.connect(_on_push_blocked)
	hud.dialog_box.question_answered.connect(_on_question_answered)
	for source: Node in get_tree().get_nodes_in_group(DIALOG_SOURCES_GROUP):
		source.dialog_requested.connect(hud.show_dialog)
	for node: Node in get_tree().get_nodes_in_group(GridObject.GROUP):
		if node is Door:
			node.locked_attempt.connect(hud.show_dialog.bind(UI_TEXTS.locked_door))
			node.opened.connect(_on_door_opened)


func _on_push_blocked(_box: Box) -> void:
	if _heavy_hint_shown:
		return
	_heavy_hint_shown = true
	hud.show_dialog(UI_TEXTS.heavy_box)


## Odhad z bádateľského postupu: zapamätáme si, čo hráč tipoval.
func _on_question_answered(_page: DialogPage, option_index: int) -> void:
	_guess_option = option_index


## Pokus: keď sa prvýkrát pritiahne skúmaný predmet, Magnetón povie, či tip sedel.
func _on_item_added(item: ItemData) -> void:
	if _guess_checked or item != level_data.guess_check_item or _guess_option < 0:
		return
	_guess_checked = true
	hud.show_dialog(DialogData.from_page(level_data.guess_feedback[_guess_option]))


func _on_door_opened() -> void:
	hud.show_dialog(DialogData.from_page(level_data.info_card))
