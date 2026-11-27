class_name RoomWalls
extends Node2D
## Kreslí steny miestnosti na hranách medzi políčkami (štýl The Sims) – zatiaľ dočasnými
## polygónmi, kým grafičky nenakreslia obrázky. KDE steny sú, rozhoduje GridManager
## (obvod miestnosti z podlahy + nakreslené priečky); tento uzol ich len nakreslí.
##
## Každý úsek steny (jedna hrana) a každý stĺpik je samostatný uzol. Uzol stojí v strede
## hrany, takže ho Y Sort zaradí medzi objekty: objekt na políčku ZA stenou sa kreslí
## pred ňou (stena ho prekryje), objekt na políčku PRED stenou až po nej.
##
## Súradnice v tomto skripte sú „súradnice mriežky“ ako Vector2 – aj s polovicami
## (stred hrany, roh políčka). Na obrazovku ich prevedie _grid_to_local().

# --- Výšky stien v pixeloch nad podlahou: JEDINÉ miesto, kde sa menia (rozhodnú grafičky) ---
## Vysoká zadná stena – obvod miestnosti vzadu (na obrazovke hore vľavo a hore vpravo).
const BACK_WALL_HEIGHT: float = 64.0
## Lem – nízka stena na prednom obvode (nezakrýva Kuba ani bedne pred ňou).
const FRONT_WALL_HEIGHT: float = 8.0
## Priečka vo vnútri miestnosti.
const PARTITION_HEIGHT: float = 8.0

## Hrúbka steny v políčkach (1/8 políčka = 4 px na šírku obrazovky).
const WALL_THICKNESS: float = 0.125
## Stĺpik je o kúsok vyšší než najvyššia stena, ktorá v ňom končí – zakryje spoj stien.
const POST_EXTRA_HEIGHT: float = 2.0

## Smery k susedom na mriežke.
const DIRECTIONS: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1)]
## Obvodová stena v týchto smeroch je vzadu (za políčkom) – tá je vysoká. Ostatné sú lem.
const BACK_DIRECTIONS: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(0, -1)]

## Smer steny (os). Stena na ľavej/pravej hrane leží pozdĺž osi y mriežky („/“ na obrazovke),
## stena na hornej/dolnej hrane pozdĺž osi x („\“). Čísla sú bity, aby sa dali spájať.
const AXIS_SLASH: int = 1     # „/“ – hrana v smere ±x
const AXIS_BACKSLASH: int = 2 # „\“ – hrana v smere ±y

## Dočasné farby (svetlo zľava hore: plocha natočená doprava je tmavšia).
const FACE_SLASH_COLOR: Color = Color(0.66, 0.68, 0.74)
const FACE_BACKSLASH_COLOR: Color = Color(0.83, 0.85, 0.9)
const TOP_COLOR: Color = Color(0.45, 0.47, 0.53)

## Údaje o vrcholoch (rohy políčok), kde končia steny – podľa nich sa postavia stĺpiky.
## Kľúč = vrchol v dvojnásobných súradniciach mriežky (aby bol celočíselný).
var _vertex_heights: Dictionary[Vector2i, float] = {}
var _vertex_axes: Dictionary[Vector2i, int] = {}
var _vertex_wall_counts: Dictionary[Vector2i, int] = {}


## Postaví všetky steny a stĺpiky. Volá level po načítaní mriežky (GridManager.setup).
func build() -> void:
	_build_perimeter()
	_build_partitions()
	_build_posts()


## Obvod: stena na každej hrane medzi políčkom miestnosti a prázdnom. Level designér ju
## nekreslí – dopočíta sa z podlahy. Hrúbka ide von z miestnosti, aby nezakrývala podlahu.
func _build_perimeter() -> void:
	for cell: Vector2i in GridManager.get_open_cells():
		for direction: Vector2i in DIRECTIONS:
			if GridManager.is_open(cell + direction):
				continue
			var height: float = BACK_WALL_HEIGHT if direction in BACK_DIRECTIONS else FRONT_WALL_HEIGHT
			_add_wall(cell, direction, height, 0.0, WALL_THICKNESS)


## Priečky: nakreslené steny, ktoré majú na oboch stranách políčko miestnosti.
## (Stena na obvode je už nakreslená v _build_perimeter.) Priečka stojí presne na hrane –
## hrúbka ide napoly do oboch políčok.
func _build_partitions() -> void:
	var walls: Dictionary[Vector2i, Vector2i] = GridManager.get_walls()
	for key: Vector2i in walls:
		var a: Vector2i = walls[key]
		var b: Vector2i = key - a
		if not GridManager.is_open(a) or not GridManager.is_open(b):
			continue
		_add_wall(a, b - a, PARTITION_HEIGHT, -WALL_THICKNESS / 2.0, WALL_THICKNESS / 2.0)


## Jeden úsek steny na hrane políčka `cell` v smere `direction`. Stena je hranol: jej
## pôdorys je pás pozdĺž hrany, posunutý v smere `direction` od `near` po `far` (v políčkach).
func _add_wall(cell: Vector2i, direction: Vector2i, height: float, near: float, far: float) -> void:
	var along: Vector2 = Vector2(direction.y, direction.x) * 0.5 # od stredu hrany k jej koncu
	var edge_center: Vector2 = Vector2(cell) + Vector2(direction) * 0.5
	var segment := Node2D.new()
	segment.name = "Wall"
	segment.position = _grid_to_local(edge_center) # bod pre Y Sort = stred hrany
	add_child(segment)

	# Pôdorys: dve čiary pozdĺž hrany – bližšia (near) a vzdialenejšia (far) od políčka.
	var near_line: Array[Vector2] = _shifted_edge(edge_center, along, direction, near)
	var far_line: Array[Vector2] = _shifted_edge(edge_center, along, direction, far)
	# Kamera pozerá „zdola“ (od +x, +y): vidno tú zvislú stranu, ktorá je bližšie ku kamere.
	var front_line: Array[Vector2] = far_line if direction.x + direction.y > 0 else near_line
	var axis: int = AXIS_SLASH if direction.x != 0 else AXIS_BACKSLASH
	var face_color: Color = FACE_SLASH_COLOR if axis == AXIS_SLASH else FACE_BACKSLASH_COLOR
	var up := Vector2(0.0, -height)

	_add_polygon(segment, [front_line[0], front_line[1], front_line[1] + up, front_line[0] + up], face_color)
	_add_polygon(segment, [near_line[0] + up, near_line[1] + up, far_line[1] + up, far_line[0] + up],
		TOP_COLOR)

	# Zapamätáme si oba konce hrany (rohy políčka) pre stĺpiky.
	var doubled_center: Vector2i = cell * 2 + direction
	var doubled_along: Vector2i = Vector2i(direction.y, direction.x)
	_register_vertex(doubled_center + doubled_along, axis, height)
	_register_vertex(doubled_center - doubled_along, axis, height)


## Konce hrany posunuté o `offset` políčka v smere `direction`, prevedené do súradníc uzla
## úseku steny (relatívne k stredu hrany).
func _shifted_edge(edge_center: Vector2, along: Vector2, direction: Vector2i, offset: float) -> Array[Vector2]:
	var shift: Vector2 = Vector2(direction) * offset
	var origin: Vector2 = _grid_to_local(edge_center)
	return [
		_grid_to_local(edge_center + along + shift) - origin,
		_grid_to_local(edge_center - along + shift) - origin,
	]


func _register_vertex(vertex: Vector2i, axis: int, height: float) -> void:
	_vertex_heights[vertex] = maxf(_vertex_heights.get(vertex, 0.0), height)
	_vertex_axes[vertex] = _vertex_axes.get(vertex, 0) | axis
	_vertex_wall_counts[vertex] = _vertex_wall_counts.get(vertex, 0) + 1


## Stĺpik stojí tam, kde stena končí (koniec priečky pri priechode) alebo mení smer (roh).
## Kde dve steny pokračujú rovno za sebou, stĺpik netreba.
func _build_posts() -> void:
	for vertex: Vector2i in _vertex_heights:
		var is_straight: bool = _vertex_wall_counts[vertex] == 2 \
			and _vertex_axes[vertex] != (AXIS_SLASH | AXIS_BACKSLASH)
		if not is_straight:
			_add_post(vertex, _vertex_heights[vertex] + POST_EXTRA_HEIGHT)


## Stĺpik = malý hranol so štvorcovým pôdorysom (na obrazovke kosoštvorec) okolo rohu.
## Je široký ako dve hrúbky steny, takže prekryje konce všetkých stien v rohu.
func _add_post(doubled_vertex: Vector2i, height: float) -> void:
	var center: Vector2 = Vector2(doubled_vertex) * 0.5
	var size: float = WALL_THICKNESS
	var post := Node2D.new()
	post.name = "Post"
	# Y Sort: steny v rohu majú stred o štvrť dlaždice nad alebo pod rohom. Stĺpik zaradíme
	# tesne za ne, aby prekryl ich spoj (objekty na políčku pod rohom sú ešte nižšie).
	var sort_offset := Vector2(0.0, GridManager.get_tile_size().y * 0.25 + 0.5)
	post.position = _grid_to_local(center) + sort_offset
	add_child(post)

	var origin: Vector2 = post.position
	var corner := func(dx: float, dy: float) -> Vector2:
		return _grid_to_local(center + Vector2(dx, dy) * size) - origin
	var up := Vector2(0.0, -height)
	# Viditeľné sú dve strany ku kamere (+x a +y) a vrch.
	_add_polygon(post, [corner.call(1, -1), corner.call(1, 1), corner.call(1, 1) + up,
		corner.call(1, -1) + up], FACE_SLASH_COLOR)
	_add_polygon(post, [corner.call(-1, 1), corner.call(1, 1), corner.call(1, 1) + up,
		corner.call(-1, 1) + up], FACE_BACKSLASH_COLOR)
	_add_polygon(post, [corner.call(-1, -1) + up, corner.call(1, -1) + up, corner.call(1, 1) + up,
		corner.call(-1, 1) + up], TOP_COLOR)


func _add_polygon(parent: Node2D, points: Array[Vector2], color: Color) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array(points)
	polygon.color = color
	parent.add_child(polygon)


## Súradnice mriežky (aj s polovicami) -> pozícia v tomto uzle. Izometria „diamond down“:
## krok +x na mriežke = (+polovica šírky, +polovica výšky) dlaždice na obrazovke,
## krok +y = (−polovica šírky, +polovica výšky).
func _grid_to_local(grid: Vector2) -> Vector2:
	var half: Vector2 = Vector2(GridManager.get_tile_size()) * 0.5
	var origin: Vector2 = to_local(GridManager.cell_to_world(Vector2i.ZERO))
	return origin + Vector2((grid.x - grid.y) * half.x, (grid.x + grid.y) * half.y)
