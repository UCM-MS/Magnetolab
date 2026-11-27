class_name Level
extends Node2D
## Spoločný skript pre všetky miestnosti: pri štarte načíta mriežku
## do GridManagera, umiestni na ňu všetky objekty a pospája signály s HUD.

## Krátke reakcie Magnetóna spoločné pre všetky levely.
const UI_TEXTS: UiTexts = preload("res://resources/ui_texts.tres")
## Skupina objektov, ktoré vedia vyžiadať dialóg (spúšťacie oblasti, tabule).
const DIALOG_SOURCES_GROUP: StringName = &"dialog_sources"
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
## Zvýraznenie dosahu rukavice – level ho vloží sám, netreba ho pridávať do každej scény.
const GLOVE_HIGHLIGHT_SCENE: PackedScene = preload("res://scenes/objects/glove_range_highlight.tscn")
## Steny v atlase (tools/build_tileset_atlas.gd): levely kreslia len vysokú stenu,
## pri načítaní sa podľa okolia zmení na lem (nízku stenu) alebo sa nekreslí vôbec.
const TILE_SOURCE_ID: int = 0
const HIGH_WALL_ATLAS: Vector2i = Vector2i(1, 0)
const TRIM_WALL_ATLAS: Vector2i = Vector2i(4, 0)
## Políčka za stenou (na obrazovke nad ňou – stena ich zakrýva) a pred stenou (pod ňou).
const CELLS_BEHIND_WALL: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1)]
const CELLS_IN_FRONT_OF_WALL: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
## Všetkých 8 susedov (vrátane bočných rohov (1,-1) a (-1,1)).
const ALL_NEIGHBORS: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1, 0), Vector2i(1, 0),
	Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
]

## Ako sa stena nakreslí (štýl „zadná stena + lem“, pravidlo v CLAUDE.md, sekcia Grafika).
enum WallLook { HIGH, TRIM, HIDDEN }

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
## Materiály, ku ktorým už Magnetón v tejto miestnosti povedal reakciu (raz pre každý).
var _shown_material_reactions: Array[Magnetism.MaterialType] = []
## Dialóg k prvému zatvoreniu mreže sa ukáže len raz.
var _gate_closed_seen: bool = false


func _ready() -> void:
	_add_glove_highlight()
	_connect_signals()
	_choose_wall_looks()
	GridManager.setup(room_layer)
	get_tree().call_group(GridObject.GROUP, "place_on_grid")


## R = reštart miestnosti (načíta scénu znova od začiatku).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart"):
		get_tree().reload_current_scene()


## Každej stene vyberie vzhľad podľa okolia: vysoká zadná stena, lem alebo nič.
## Mení sa len kreslenie. Pre logiku ostáva každé z týchto políčok stenou: lem je
## v TileSete „solid“ a zmazané políčko nie je podlaha ani priepasť (GridManager.is_wall).
## Pri reštarte (R) sa scéna načíta nanovo s vysokými stenami a výber prebehne znova.
func _choose_wall_looks() -> void:
	# Najprv rozhodneme o všetkých stenách, až potom meníme mapu – rozhodnutie
	# sa musí robiť podľa pôvodnej mapy, nie podľa už zmazaných políčok.
	var looks: Dictionary[Vector2i, WallLook] = {}
	for wall: Vector2i in room_layer.get_used_cells_by_id(TILE_SOURCE_ID, HIGH_WALL_ATLAS):
		looks[wall] = _get_wall_look(wall)
	for wall: Vector2i in looks:
		match looks[wall]:
			WallLook.TRIM:
				room_layer.set_cell(wall, TILE_SOURCE_ID, TRIM_WALL_ATLAS)
			WallLook.HIDDEN:
				room_layer.erase_cell(wall)
			WallLook.HIGH:
				pass # levely už kreslia vysokú stenu


## Štyri kroky pravidla („otvorené“ = podlaha alebo priepasť):
## 1. otvorené políčko ZA stenou -> lem (vysoká stena by ho zakryla),
## 2. inak otvorené políčko PRED stenou -> vysoká zadná stena,
## 3. inak otvorený niektorý z 8 susedov (bočný roh miestnosti) -> lem, aby v rohu nebola diera,
## 4. inak (vnútro hrubého bloku stien) -> nekreslí sa.
func _get_wall_look(wall: Vector2i) -> WallLook:
	if _has_open_cell(wall, CELLS_BEHIND_WALL):
		return WallLook.TRIM
	if _has_open_cell(wall, CELLS_IN_FRONT_OF_WALL):
		return WallLook.HIGH
	if _has_open_cell(wall, ALL_NEIGHBORS):
		return WallLook.TRIM
	return WallLook.HIDDEN


## Je aspoň na jednom z políčok wall + offset podlaha alebo priepasť (nie stena, nie mimo mapy)?
func _has_open_cell(wall: Vector2i, offsets: Array[Vector2i]) -> bool:
	for offset: Vector2i in offsets:
		var data: TileData = room_layer.get_cell_tile_data(wall + offset)
		if data != null and not data.get_custom_data(GridManager.SOLID_DATA):
			return true
	return false


## Zvýraznenie vložíme hneď za vrstvu miestnosti: kreslí sa po podlahe,
## ale pred objektmi, takže bedne a hráč sú vždy nad ním.
func _add_glove_highlight() -> void:
	var highlight: GloveRangeHighlight = GLOVE_HIGHLIGHT_SCENE.instantiate()
	room_layer.add_sibling(highlight)
	player.glove.beam_changed.connect(highlight.show_beam)


## Objekty o sebe nevedia – level ich signály napojí na HUD.
func _connect_signals() -> void:
	player.inventory.changed.connect(hud.show_inventory)
	player.inventory.item_added.connect(_on_item_added)
	player.push_blocked.connect(_on_push_blocked)
	player.glove.no_effect.connect(_on_glove_no_effect)
	hud.menu_requested.connect(_return_to_menu)
	hud.dialog_box.question_answered.connect(_on_question_answered)
	for source: Node in get_tree().get_nodes_in_group(DIALOG_SOURCES_GROUP):
		source.dialog_requested.connect(hud.show_dialog)
	for node: Node in get_tree().get_nodes_in_group(GridObject.GROUP):
		if node is Door:
			node.locked_attempt.connect(hud.show_dialog.bind(UI_TEXTS.locked_door))
			node.opened.connect(_on_door_opened)
		elif node is Gate:
			node.closed.connect(_on_gate_closed)
	# Tlačidlo na podlahe -> mreža: stlačenie ju otvorí, pustenie zatvorí.
	for node: Node in get_tree().get_nodes_in_group(PressurePlate.GROUP):
		var plate: PressurePlate = node as PressurePlate
		if plate.gate == null:
			push_warning("%s: tlačidlo nemá nastavenú mrežu (gate)." % plate.name)
			continue
		plate.pressed.connect(plate.gate.open)
		plate.pressed.connect(_on_plate_pressed.bind(plate))
		plate.released.connect(plate.gate.close)


func _on_push_blocked(_box: Box) -> void:
	if _heavy_hint_shown:
		return
	_heavy_hint_shown = true
	hud.show_dialog(UI_TEXTS.heavy_box)


## Rukavica zasiahla nemagnetický materiál: ak má level k nemu text a ešte ho neukázal,
## Magnetón ho povie. Rukavica pôsobí po každom kroku, preto len prvýkrát.
func _on_glove_no_effect(target: GridObject) -> void:
	if level_data == null:
		return
	var material: Magnetism.MaterialType
	if target is Box:
		material = (target as Box).material_type
	elif target is Item:
		material = (target as Item).data.material_type
	else:
		return
	if material in _shown_material_reactions or not level_data.material_reactions.has(material):
		return
	_shown_material_reactions.append(material)
	hud.show_dialog(level_data.material_reactions[material])


## Odhad z bádateľského postupu: zapamätáme si, čo hráč tipoval.
func _on_question_answered(_page: DialogPage, option_index: int) -> void:
	_guess_option = option_index


## Pokus v A1: prvé pritiahnutie skúmaného predmetu.
func _on_item_added(item: ItemData) -> void:
	var is_check_event: bool = level_data.guess_check == LevelData.GuessCheck.ITEM_PULLED
	if is_check_event and item == level_data.guess_check_item:
		_show_guess_feedback()


## Pokus v A2: na tlačidlo dorazila bedňa (hráč sa nepočíta). Spätnú väzbu ukážeme,
## až keď bedňa dobehne – aby dialóg nezastavil hru uprostred posunu.
func _on_plate_pressed(plate: PressurePlate) -> void:
	if level_data.guess_check != LevelData.GuessCheck.BOX_ON_PLATE:
		return
	var box: Box = GridManager.get_object_at(plate.get_cell()) as Box
	if box != null:
		box.slide_finished.connect(_show_guess_feedback, CONNECT_ONE_SHOT)


## Po prvom pokuse Magnetón povie, či tip sedel. Ak hráč ešte netipoval, preskočí sa.
func _show_guess_feedback() -> void:
	if _guess_checked or _guess_option < 0:
		return
	_guess_checked = true
	hud.show_dialog(DialogData.from_page(level_data.guess_feedback[_guess_option]))


## Prvé zatvorenie mreže: Magnetón sa môže opýtať, ako ju udržať otvorenú.
func _on_gate_closed() -> void:
	if _gate_closed_seen:
		return
	_gate_closed_seen = true
	if level_data.gate_closed_dialog != null:
		hud.show_dialog(level_data.gate_closed_dialog)


## Otvorené dvere = dokončený level: odomkne sa ďalšia miestnosť, ukáže sa kartička
## a po jej zatvorení sa hráč vráti do menu.
func _on_door_opened() -> void:
	if not level_data.next_level_id.is_empty():
		SaveManager.unlock_level(level_data.next_level_id)
	hud.dialog_box.closed.connect(_return_to_menu, CONNECT_ONE_SHOT)
	hud.show_dialog(DialogData.from_page(level_data.info_card))


## Scénu meníme až na konci snímku (call_deferred): volá sa to počas spracovania
## klávesu a uzly, ktoré ho spracúvajú, musia dovtedy ostať v strome.
func _return_to_menu() -> void:
	get_tree().change_scene_to_file.call_deferred(MAIN_MENU_SCENE)
