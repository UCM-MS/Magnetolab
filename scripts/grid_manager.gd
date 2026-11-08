extends Node
## Autoload: jediný zdroj pravdy o mriežke.
## Vie, ktoré políčka sú podlaha (priechodné) a čo stojí na ktorom políčku.
## Izometria je len vykreslenie – logika pracuje výhradne s Vector2i.

## Objekt sa ocitol na políčku (pri štarte levelu aj po každom posune).
## Počúvajú ho napr. spúšťacie oblasti.
signal object_entered_cell(obj: GridObject, cell: Vector2i)

## Názvy vlastných vrstiev dát v TileSete.
const SOLID_DATA: String = "solid"   # stena – nedá sa na ňu vstúpiť a zastaví lúč
const ABYSS_DATA: String = "abyss"   # priepasť – nedá sa na ňu vstúpiť, lúč cez ňu prejde

## Vrstva dlaždíc aktuálnej miestnosti (kvôli prevodu políčko <-> pixel).
var _layer: TileMapLayer
## Políčka, na ktoré sa dá v princípe vstúpiť (podlaha).
var _floor_cells: Dictionary[Vector2i, bool] = {}
## Políčka priepasti.
var _abyss_cells: Dictionary[Vector2i, bool] = {}
## Čo stojí na ktorom políčku (hráč, bedne...). Na jednom políčku max. jeden objekt.
var _objects: Dictionary[Vector2i, GridObject] = {}


## Načíta miestnosť z TileMapLayer podľa príznakov dlaždíc „solid“ a „abyss“.
func setup(layer: TileMapLayer) -> void:
	_layer = layer
	_floor_cells.clear()
	_abyss_cells.clear()
	_objects.clear()
	for cell: Vector2i in layer.get_used_cells():
		var data: TileData = layer.get_cell_tile_data(cell)
		if data.get_custom_data(ABYSS_DATA):
			_abyss_cells[cell] = true
		elif not data.get_custom_data(SOLID_DATA):
			_floor_cells[cell] = true


# --- Prevod súradníc (izometria rieši TileMapLayer) ---

func cell_to_world(cell: Vector2i) -> Vector2:
	return _layer.to_global(_layer.map_to_local(cell))


func world_to_cell(world_pos: Vector2) -> Vector2i:
	return _layer.local_to_map(_layer.to_local(world_pos))


## Veľkosť dlaždice v pixeloch (64 × 32) – podľa TileSetu aktuálnej miestnosti.
func get_tile_size() -> Vector2i:
	return _layer.tile_set.tile_size


# --- Dotazy na mriežku ---

## Stena alebo políčko mimo mapy (zastaví lúč rukavice).
func is_wall(cell: Vector2i) -> bool:
	return not _floor_cells.has(cell) and not _abyss_cells.has(cell)


func is_abyss(cell: Vector2i) -> bool:
	return _abyss_cells.has(cell)


func get_object_at(cell: Vector2i) -> GridObject:
	return _objects.get(cell)


## Dá sa na políčko vstúpiť alebo naň posunúť objekt? (podlaha a nič na nej nestojí)
## Priepasť sem nepatrí – preto sa na ňu nedá vstúpiť ani do nej strčiť bedňu.
func is_free(cell: Vector2i) -> bool:
	return _floor_cells.has(cell) and not _objects.has(cell)


## Posledné voľné políčko, kam sa objekt dostane, keď ide zo `start` smerom `direction`
## až po prekážku, ale najviac o `max_steps` políčok. Ak hneď vedľa je prekážka
## (alebo max_steps je 0), vráti `start`.
func find_slide_end(start: Vector2i, direction: Vector2i, max_steps: int) -> Vector2i:
	var current: Vector2i = start
	for step: int in max_steps:
		if not is_free(current + direction):
			break
		current += direction
	return current


## Vzdialenosť dvoch políčok v krokoch po mriežke (bez uhlopriečok).
func cell_distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


## Políčka, kam dosiahne lúč z `origin` smerom `direction` (najviac `max_distance` políčok).
## Lúč zastaví stena (to políčko sa už nepočíta) alebo prvý objekt (jeho políčko sa počíta).
## Cez priepasť lúč prechádza.
func get_beam_cells(origin: Vector2i, direction: Vector2i, max_distance: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var current: Vector2i = origin
	for step: int in max_distance:
		current += direction
		if is_wall(current):
			break
		cells.append(current)
		if _objects.has(current):
			break
	return cells


## Prvý objekt v rade od `origin` smerom `direction`, najviac `max_distance` políčok ďaleko
## (samotné `origin` sa nepočíta). Ak lúč zastaví stena alebo nič nenájde, vráti null.
func find_first_object(origin: Vector2i, direction: Vector2i, max_distance: int) -> GridObject:
	var cells: Array[Vector2i] = get_beam_cells(origin, direction, max_distance)
	if cells.is_empty():
		return null
	return _objects.get(cells.back())


# --- Zmeny obsadenosti ---

func register_object(obj: GridObject, cell: Vector2i) -> void:
	if _objects.has(cell):
		push_error("Políčko %s je už obsadené objektom %s" % [cell, _objects[cell].name])
		return
	_objects[cell] = obj
	obj.cell = cell
	object_entered_cell.emit(obj, cell)


func unregister_object(obj: GridObject) -> void:
	if _objects.get(obj.cell) == obj:
		_objects.erase(obj.cell)


## Presunie objekt v evidencii. Volajúci si má predtým overiť is_free().
func move_object(obj: GridObject, to: Vector2i) -> void:
	unregister_object(obj)
	register_object(obj, to)
