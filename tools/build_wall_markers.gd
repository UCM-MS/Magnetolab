@tool
extends EditorScript
## Vyrobí TileSet so značkami stien resources/wall_edges_tileset.tres pre vrstvu „Walls“.
## Značka je len pomôcka pre level designéra: ukazuje, na ktorej hrane políčka stojí stena.
## Hru kreslí kód (neskôr), preto obrázok značiek nie je v art/ – je uložený priamo v TileSete.
##
## Spustenie: otvor tento súbor v editore skriptov a daj File > Run (Ctrl+Shift+X).
## Stačí raz (alebo keď sa tu zmení vzhľad značiek). Súradnice značiek sa nesmú meniť –
## levely sa na ne odkazujú.
##
## Značky (políčko „vlastní“ svoje dve zadné hrany):
##   (0,0) ľavá hrana  – stena medzi (x-1, y) a (x, y), na obrazovke hore vľavo „/“
##   (1,0) horná hrana – stena medzi (x, y-1) a (x, y), na obrazovke hore vpravo „\“
##   (2,0) obe hrany   – roh

## Veľkosť dlaždice = rovnaká ako v TileSete miestnosti, aby vrstvy na seba sedeli.
const TILE_SIZE: Vector2i = Vector2i(64, 32)
const TILESET_PATH: String = "res://resources/wall_edges_tileset.tres"
## Názvy vlastných dát – číta ich GridManager (WALL_LEFT_DATA, WALL_UP_DATA).
const WALL_LEFT_DATA: String = "wall_left"
const WALL_UP_DATA: String = "wall_up"
## Súradnice značiek v atlase.
const LEFT_COORDS: Vector2i = Vector2i(0, 0)
const UP_COORDS: Vector2i = Vector2i(1, 0)
const BOTH_COORDS: Vector2i = Vector2i(2, 0)

## Výrazná farba, ktorá sa nepomýli s podlahou ani s pólmi rukavice (červená/modrá).
const LINE_COLOR: Color = Color(1.0, 0.0, 1.0) # purpurová
## Tmavý lem pod čiarou, aby bola vidno aj na svetlej podlahe.
const OUTLINE_COLOR: Color = Color(0.15, 0.0, 0.15)
## Hrúbka čiary a lemu v pixeloch (merané kolmo od hrany dovnútra políčka).
const LINE_WIDTH: float = 3.0
const OUTLINE_WIDTH: float = 1.5
## Polovica izometrickej dlaždice – hrana kosoštvorca je úsečka so sklonom 1 : 2.
## Kolmú vzdialenosť bodu od takej hrany treba deliť dĺžkou normály sqrt(1² + 2²).
const EDGE_NORMAL_LENGTH: float = sqrt(5.0)


func _run() -> void:
	build()


## Nakreslí obrázok značiek, vytvorí TileSet a uloží ho. Statická, aby sa dala
## zavolať aj mimo editora (napr. z testovacieho skriptu).
static func build() -> Error:
	var image: Image = Image.create_empty(TILE_SIZE.x * 3, TILE_SIZE.y, false, Image.FORMAT_RGBA8)
	_draw_marker(image, LEFT_COORDS, true, false)
	_draw_marker(image, UP_COORDS, false, true)
	_draw_marker(image, BOTH_COORDS, true, true)

	var source := TileSetAtlasSource.new()
	# Obrázok je súčasťou TileSetu (ImageTexture), netreba samostatný PNG v art/.
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = TILE_SIZE

	var tileset := TileSet.new()
	tileset.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tileset.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN # rovnako ako miestnosť
	tileset.tile_size = TILE_SIZE
	tileset.add_custom_data_layer()
	tileset.set_custom_data_layer_name(0, WALL_LEFT_DATA)
	tileset.set_custom_data_layer_type(0, TYPE_BOOL)
	tileset.add_custom_data_layer()
	tileset.set_custom_data_layer_name(1, WALL_UP_DATA)
	tileset.set_custom_data_layer_type(1, TYPE_BOOL)
	tileset.add_source(source, 0)

	_create_marker_tile(source, LEFT_COORDS, true, false)
	_create_marker_tile(source, UP_COORDS, false, true)
	_create_marker_tile(source, BOTH_COORDS, true, true)

	var error: Error = ResourceSaver.save(tileset, TILESET_PATH)
	if error == OK:
		print("TileSet so značkami stien uložený: %s" % TILESET_PATH)
	else:
		push_error("Značky stien: uloženie zlyhalo (%s)" % error_string(error))
	return error


## Dlaždica značky + príznaky, na ktorých hranách je stena.
static func _create_marker_tile(source: TileSetAtlasSource, coords: Vector2i,
		left: bool, up: bool) -> void:
	source.create_tile(coords)
	var data: TileData = source.get_tile_data(coords, 0)
	data.set_custom_data(WALL_LEFT_DATA, left)
	data.set_custom_data(WALL_UP_DATA, up)


## Nakreslí čiaru tesne pozdĺž zvolenej hrany kosoštvorca – zvnútra políčka, takže končí
## presne na hrane. Body kosoštvorca 64 × 32: ľavý (0,16), horný (32,0), pravý (64,16).
static func _draw_marker(image: Image, coords: Vector2i, left: bool, up: bool) -> void:
	var origin: Vector2i = coords * TILE_SIZE
	for y: int in TILE_SIZE.y:
		for x: int in TILE_SIZE.x:
			var point := Vector2(x + 0.5, y + 0.5) # stred pixelu
			if not _is_inside_diamond(point):
				continue # pri rohoch by čiara inak vytŕčala do susedného políčka
			var distance: float = INF
			if left and point.x <= TILE_SIZE.x / 2.0:
				distance = minf(distance, _distance_inside_left_edge(point))
			if up and point.x >= TILE_SIZE.x / 2.0:
				distance = minf(distance, _distance_inside_up_edge(point))
			if distance < LINE_WIDTH:
				image.set_pixel(origin.x + x, origin.y + y, LINE_COLOR)
			elif distance < LINE_WIDTH + OUTLINE_WIDTH:
				image.set_pixel(origin.x + x, origin.y + y, OUTLINE_COLOR)


## Leží bod vnútri kosoštvorca dlaždice? (|dx| / polovica šírky + |dy| / polovica výšky <= 1)
static func _is_inside_diamond(point: Vector2) -> bool:
	var half: Vector2 = Vector2(TILE_SIZE) / 2.0
	return absf(point.x - half.x) / half.x + absf(point.y - half.y) / half.y <= 1.0


## Kolmá vzdialenosť od ľavej hornej hrany (z (0,16) do (32,0)); kladná = vnútri políčka.
## Priamka hrany: x + 2y − 32 = 0.
static func _distance_inside_left_edge(point: Vector2) -> float:
	return (point.x + 2.0 * point.y - TILE_SIZE.x / 2.0) / EDGE_NORMAL_LENGTH


## Kolmá vzdialenosť od pravej hornej hrany (z (32,0) do (64,16)); kladná = vnútri políčka.
## Priamka hrany: −x + 2y + 32 = 0.
static func _distance_inside_up_edge(point: Vector2) -> float:
	return (-point.x + 2.0 * point.y + TILE_SIZE.x / 2.0) / EDGE_NORMAL_LENGTH
