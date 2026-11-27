extends Node
## Autoload: jediný zdroj pravdy o mriežke.
## Vie, ktoré políčka sú podlaha (priechodné) a čo stojí na ktorom políčku.
## Izometria je len vykreslenie – logika pracuje výhradne s Vector2i.

## Objekt sa ocitol na políčku (pri štarte levelu aj po každom posune).
## Počúvajú ho napr. spúšťacie oblasti.
signal object_entered_cell(obj: GridObject, cell: Vector2i)
## Objekt opustil políčko (posun, odlet predmetu, pád do jamy, otvorenie dverí/mreže).
## Počúvajú ho napr. tlačidlá na podlahe a mreže, ktoré čakajú na uvoľnenie políčka.
signal object_left_cell(obj: GridObject, cell: Vector2i)

## Názvy vlastných vrstiev dát v TileSete.
const SOLID_DATA: String = "solid"   # stena – nedá sa na ňu vstúpiť a zastaví lúč
const ABYSS_DATA: String = "abyss"   # priepasť – nedá sa na ňu vstúpiť, lúč cez ňu prejde
## Názvy vlastných dát v TileSete značiek stien (resources/wall_edges_tileset.tres, vrstva Walls).
const WALL_LEFT_DATA: String = "wall_left" # stena na ľavej hrane: medzi (x-1, y) a (x, y)
const WALL_UP_DATA: String = "wall_up"     # stena na hornej hrane: medzi (x, y-1) a (x, y)

## Vrstva dlaždíc aktuálnej miestnosti (kvôli prevodu políčko <-> pixel).
var _layer: TileMapLayer
## Políčka, na ktoré sa dá v princípe vstúpiť (podlaha).
var _floor_cells: Dictionary[Vector2i, bool] = {}
## Políčka priepasti.
var _abyss_cells: Dictionary[Vector2i, bool] = {}
## Čo stojí na ktorom políčku (hráč, bedne...). Na jednom políčku max. jeden objekt.
var _objects: Dictionary[Vector2i, GridObject] = {}
## Steny na hranách medzi dvoma susednými políčkami (štýl The Sims).
## Kľúč hrany je súčet oboch políčok – pozri edge_key(). Hodnota je jedno z políčok
## (druhé = kľúč − hodnota), aby kreslenie stien vedelo, medzi ktorými políčkami stena stojí.
var _walls: Dictionary[Vector2i, Vector2i] = {}


## Načíta miestnosť z TileMapLayer podľa príznakov dlaždíc „solid“ a „abyss“.
## Staré steny-políčka („solid“) sa pre logiku správajú ako prázdno mimo miestnosti.
## Steny na hranách sa načítajú z vrstvy so značkami `wall_layer`. Level bez nej
## (null) nemá žiadne steny na hranách – funguje ako doteraz.
func setup(layer: TileMapLayer, wall_layer: TileMapLayer = null) -> void:
	_layer = layer
	_floor_cells.clear()
	_abyss_cells.clear()
	_objects.clear()
	_walls.clear()
	for cell: Vector2i in layer.get_used_cells():
		var data: TileData = layer.get_cell_tile_data(cell)
		if data.get_custom_data(ABYSS_DATA):
			_abyss_cells[cell] = true
		elif not data.get_custom_data(SOLID_DATA):
			_floor_cells[cell] = true
	if wall_layer != null:
		_load_walls(wall_layer)


## Prečíta značky stien: každá značka na políčku (x, y) postaví stenu na jeho ľavú
## a/alebo hornú hranu (stenu na pravej či dolnej strane nesie značka suseda).
func _load_walls(wall_layer: TileMapLayer) -> void:
	for cell: Vector2i in wall_layer.get_used_cells():
		var data: TileData = wall_layer.get_cell_tile_data(cell)
		if data.get_custom_data(WALL_LEFT_DATA):
			add_wall(cell, cell + Vector2i(-1, 0))
		if data.get_custom_data(WALL_UP_DATA):
			add_wall(cell, cell + Vector2i(0, -1))


# --- Prevod súradníc (izometria rieši TileMapLayer) ---

func cell_to_world(cell: Vector2i) -> Vector2:
	return _layer.to_global(_layer.map_to_local(cell))


func world_to_cell(world_pos: Vector2) -> Vector2i:
	return _layer.local_to_map(_layer.to_local(world_pos))


## Presunie uzol hneď za vrstvu dlaždíc: kreslí sa nad podlahou, ale pod zvýraznením
## dosahu rukavice a pod všetkými objektmi (napr. bedňa, ktorá zapadla do jamy).
## Poloha na obrazovke sa nezmení.
func move_to_floor(node: Node2D) -> void:
	var room: Node = _layer.get_parent()
	node.reparent(room)
	room.move_child(node, _layer.get_index() + 1)


## Veľkosť dlaždice v pixeloch (64 × 32) – podľa TileSetu aktuálnej miestnosti.
func get_tile_size() -> Vector2i:
	return _layer.tile_set.tile_size


# --- Dotazy na mriežku ---

## Patrí políčko do miestnosti? (podlaha alebo priepasť). Ostatné políčka sú prázdno
## mimo miestnosti – nedá sa na ne vstúpiť a lúč nimi neprejde.
func is_open(cell: Vector2i) -> bool:
	return _floor_cells.has(cell) or _abyss_cells.has(cell)


## Všetky políčka miestnosti (podlaha + priepasť). Podľa nich sa dopočíta obvodová stena.
func get_open_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = _floor_cells.keys()
	cells.append_array(_abyss_cells.keys())
	return cells


func is_abyss(cell: Vector2i) -> bool:
	return _abyss_cells.has(cell)


func get_object_at(cell: Vector2i) -> GridObject:
	return _objects.get(cell)


## Dá sa na políčko vstúpiť alebo naň posunúť objekt? (podlaha a nič na nej nestojí)
## Priepasť sem nepatrí – hráč na ňu nevstúpi (bedňa do nej môže spadnúť, pozri can_slide_into).
func is_free(cell: Vector2i) -> bool:
	return _floor_cells.has(cell) and not _objects.has(cell)


# --- Steny na hranách ---

## Kľúč hrany medzi susednými políčkami `a` a `b` = ich súčet. Pre každú dvojicu susedov
## vyjde iný súčet (vodorovná hrana má nepárne x, zvislá nepárne y) a nezáleží na poradí.
static func edge_key(a: Vector2i, b: Vector2i) -> Vector2i:
	return a + b


## Postaví stenu na hranu medzi susednými políčkami `a` a `b` (volá ju _load_walls).
func add_wall(a: Vector2i, b: Vector2i) -> void:
	_walls[edge_key(a, b)] = a


## Všetky nakreslené steny: kľúč hrany -> jedno z políčok (druhé políčko = kľúč − hodnota).
## Kópia – kto ju dostane, nemôže zmeniť evidenciu stien. Používa ju kreslenie stien.
func get_walls() -> Dictionary[Vector2i, Vector2i]:
	return _walls.duplicate()


## Je medzi susednými políčkami `a` a `b` stena? Stena zastaví hráča, posun bedne aj lúč.
func has_wall_between(a: Vector2i, b: Vector2i) -> bool:
	return _walls.has(edge_key(a, b))


## Môže hráč prejsť z políčka `from` o krok smerom `direction`?
## Cieľ musí byť voľná podlaha a medzi políčkami nesmie byť stena.
func can_enter(from: Vector2i, direction: Vector2i) -> bool:
	var target: Vector2i = from + direction
	return is_free(target) and not has_wall_between(from, target)


## Dá sa objekt posunúť z políčka `from` o krok smerom `direction`? Stena medzi nimi ho
## zastaví. Na voľnú podlahu áno. Na priepasť len objekt, ktorý do nej spadne a vyplní ju
## (`falls_into_abyss` = bedňa) – nič nelevituje nad jamou.
func can_slide_into(from: Vector2i, direction: Vector2i, falls_into_abyss: bool) -> bool:
	var target: Vector2i = from + direction
	if has_wall_between(from, target):
		return false
	if falls_into_abyss and is_abyss(target):
		return not _objects.has(target)
	return is_free(target)


## Posledné políčko, kam sa objekt dostane, keď ide zo `start` smerom `direction`
## až po prekážku, ale najviac o `max_steps` políčok. Ak hneď vedľa je prekážka
## (alebo max_steps je 0), vráti `start`.
## Ak objekt do priepasti padá (`falls_into_abyss`), na políčko priepasti ešte vojde
## a tam sa zastaví – ďalej už nejde. Inak ho okraj priepasti zastaví ako stena.
func find_slide_end(start: Vector2i, direction: Vector2i, max_steps: int,
		falls_into_abyss: bool = false) -> Vector2i:
	var current: Vector2i = start
	for step: int in max_steps:
		if not can_slide_into(current, direction, falls_into_abyss):
			break
		current += direction
		if is_abyss(current):
			break # spadol do jamy
	return current


## Vzdialenosť dvoch políčok v krokoch po mriežke (bez uhlopriečok).
func cell_distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


## Políčka, kam dosiahne lúč z `origin` smerom `direction` (najviac `max_distance` políčok).
## Lúč zastaví prekážka pred políčkom (to políčko sa už nepočíta) alebo objekt na políčku
## (jeho políčko sa počíta). Cez priepasť lúč prechádza.
func get_beam_cells(origin: Vector2i, direction: Vector2i, max_distance: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var current: Vector2i = origin
	for step: int in max_distance:
		var next: Vector2i = current + direction
		if _beam_blocked_before(current, next):
			break
		cells.append(next)
		if _beam_stops_at(next):
			break
		current = next
	return cells


## Pravidlá lúča na JEDNOM mieste (keď sa bude meniť, čo lúč prepustí, mení sa len tu).
## Zastaví lúč niečo na ceste z políčka `from` na susedné `to`? Herné pravidlo:
## prázdno mimo miestnosti a stena na hrane lúč zastavia.
func _beam_blocked_before(from: Vector2i, to: Vector2i) -> bool:
	return not is_open(to) or has_wall_between(from, to)


## Skončí lúč na políčku `cell`? Zatiaľ ho zastaví každý objekt (aj nemagnetický).
func _beam_stops_at(cell: Vector2i) -> bool:
	return _objects.has(cell)


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
		object_left_cell.emit(obj, obj.cell)


## Presunie objekt v evidencii. Volajúci si má predtým overiť is_free() / can_slide_into().
func move_object(obj: GridObject, to: Vector2i) -> void:
	unregister_object(obj)
	register_object(obj, to)


## Objekt spadol do priepasti a vyplnil ju: z políčka je odteraz podlaha (most).
## Objekt v jame odhlásime z mriežky – políčko je voľné, dá sa po ňom chodiť
## a lúč cez neho ide ako cez podlahu. Bedňa v jame už na nič nereaguje.
## Dlaždice v TileMapLayer nemeníme, takže reštart (R) vráti jamu do pôvodného stavu.
func fill_abyss(cell: Vector2i) -> void:
	_abyss_cells.erase(cell)
	_floor_cells[cell] = true
	var obj: GridObject = _objects.get(cell)
	if obj != null:
		unregister_object(obj)
