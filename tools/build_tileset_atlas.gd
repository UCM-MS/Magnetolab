@tool
extends EditorScript
## Poskladá dlaždice od grafikov do jedného obrázka art/tiles/tileset_atlas.png
## a podľa rozmerov obrázkov nastaví TileSet resources/placeholder_tileset.tres.
## Súradnice dlaždíc v atlase sa nemenia, preto sa levely (level_a1.tscn,
## test_room.tscn) nemusia prekresľovať.
##
## Spustenie: otvor tento súbor v editore skriptov a daj File > Run (Ctrl+Shift+X).
## Treba ho spustiť znova vždy, keď grafici zmenia niektorý obrázok dlaždice.
##
## Rozloženie atlasu (bunka = 64x32 px, vysoká dlaždica zaberie viac buniek pod sebou):
##   (0,0) podlaha (floor_2.png)   (1,0) stena   (2,0) priepasť   (3,0) podlaha s magnetom
##
## Ako sa počíta vysoká dlaždica (stena), napr. obrázok 64 x 44 px:
##   1. Počet buniek na výšku: rows = ceil(44 / 32) = 2  -> size_in_atlas = (1, 2).
##      Oblasť dlaždice v atlase je teda 64 x 64 px.
##   2. Obrázok sa vloží do oblasti zarovnaný NADOL (hore ostane 64 - 44 = 20 px prázdnych).
##      Spodných 32 px obrázka je kosoštvorec podlahy, jeho stred je 16 px nad spodkom oblasti.
##   3. Godot kreslí stred oblasti na stred políčka. Stred oblasti je rows * 32 / 2 px
##      od vrchu, stred kosoštvorca rows * 32 - 16 px od vrchu. Rozdiel je posun:
##      texture_origin.y = rows * 32 - 16 - rows * 32 / 2 = (rows - 1) * 16
##      (pre rows = 2 je to 16, pre plochú dlaždicu rows = 1 je to 0).
##   Spodok steny tak vždy sedí na políčku, nech je obrázok akokoľvek vysoký.

## Veľkosť jednej bunky atlasu = veľkosť dlaždice v TileSete.
const CELL_SIZE: Vector2i = Vector2i(64, 32)
const OUTPUT_PATH: String = "res://art/tiles/tileset_atlas.png"
const TILESET_PATH: String = "res://resources/placeholder_tileset.tres"
## Id zdroja (atlasu) v TileSete, ktorý levely používajú.
const SOURCE_ID: int = 0
## Ktorý obrázok patrí na ktoré súradnice v atlase (horná bunka dlaždice).
const TILES: Dictionary[String, Vector2i] = {
	"res://art/tiles/floor_2.png": Vector2i(0, 0),
	"res://art/tiles/wall.png": Vector2i(1, 0),
	"res://art/tiles/abyss.png": Vector2i(2, 0),
	"res://art/tiles/floor.png": Vector2i(3, 0),
}


func _run() -> void:
	if build_atlas() != OK:
		return
	# Editor musí nový obrázok naimportovať skôr, než TileSet zmeníme
	# (inak by TileSet ešte videl starý, možno menší atlas).
	EditorInterface.get_resource_filesystem().reimport_files(PackedStringArray([OUTPUT_PATH]))
	update_tileset()


## Koľko buniek na výšku zaberie obrázok danej výšky (zaokrúhlené nahor).
static func rows_for_height(height: int) -> int:
	return ceili(float(height) / CELL_SIZE.y)


## Posun textúry, aby stred spodného kosoštvorca sedel na strede políčka (pozri hore).
static func texture_origin_for_rows(rows: int) -> Vector2i:
	return Vector2i(0, (rows - 1) * CELL_SIZE.y / 2)


## Načíta obrázok dlaždice priamo z PNG (nie importovanú textúru, aby sa nestratila kvalita).
static func load_tile(path: String) -> Image:
	var tile: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if tile == null:
		push_error("Atlas: nepodarilo sa načítať %s" % path)
		return null
	if tile.get_width() != CELL_SIZE.x:
		push_error("Atlas: %s musí mať šírku %d px" % [path, CELL_SIZE.x])
		return null
	tile.convert(Image.FORMAT_RGBA8)
	return tile


## Poskladá atlas a uloží ho. Je statická, aby sa dala zavolať aj mimo editora.
static func build_atlas() -> Error:
	var tiles: Dictionary[String, Image] = {}
	var atlas_cells: Vector2i = Vector2i.ZERO
	for path: String in TILES:
		var tile: Image = load_tile(path)
		if tile == null:
			return ERR_FILE_CANT_OPEN
		tiles[path] = tile
		var coords: Vector2i = TILES[path]
		atlas_cells.x = maxi(atlas_cells.x, coords.x + 1)
		atlas_cells.y = maxi(atlas_cells.y, coords.y + rows_for_height(tile.get_height()))

	var atlas_size: Vector2i = CELL_SIZE * atlas_cells
	var atlas: Image = Image.create_empty(atlas_size.x, atlas_size.y, false, Image.FORMAT_RGBA8)
	for path: String in tiles:
		var tile: Image = tiles[path]
		var region_height: int = rows_for_height(tile.get_height()) * CELL_SIZE.y
		# Zarovnanie nadol: prázdne miesto ostane nad obrázkom.
		var top_gap: int = region_height - tile.get_height()
		var destination: Vector2i = TILES[path] * CELL_SIZE + Vector2i(0, top_gap)
		atlas.blit_rect(tile, Rect2i(Vector2i.ZERO, tile.get_size()), destination)

	var error: Error = atlas.save_png(OUTPUT_PATH)
	if error == OK:
		print("Atlas uložený: %s (%d x %d px)" % [OUTPUT_PATH, atlas_size.x, atlas_size.y])
	else:
		push_error("Atlas: uloženie zlyhalo (%s)" % error_string(error))
	return error


## Nastaví v TileSete veľkosť (size_in_atlas) a posun (texture_origin) každej dlaždice
## podľa výšky jej obrázka a TileSet uloží. Custom data (solid, abyss) sa nemenia.
static func update_tileset() -> Error:
	var tileset: TileSet = load(TILESET_PATH)
	var source: TileSetAtlasSource = tileset.get_source(SOURCE_ID)
	for path: String in TILES:
		var tile: Image = load_tile(path)
		if tile == null:
			return ERR_FILE_CANT_OPEN
		var coords: Vector2i = TILES[path]
		var size: Vector2i = Vector2i(1, rows_for_height(tile.get_height()))
		if source.get_tile_size_in_atlas(coords) != size:
			if not source.has_room_for_tile(coords, size, source.get_tile_animation_columns(coords),
					source.get_tile_animation_separation(coords), 1, coords):
				push_error("Atlas: dlaždica %s sa nezmestí (atlas ešte nie je naimportovaný?)" % coords)
				return ERR_CANT_CREATE
			source.move_tile_in_atlas(coords, coords, size)
		source.get_tile_data(coords, 0).texture_origin = texture_origin_for_rows(size.y)
	var error: Error = ResourceSaver.save(tileset, TILESET_PATH)
	if error == OK:
		print("TileSet uložený: %s" % TILESET_PATH)
	return error
