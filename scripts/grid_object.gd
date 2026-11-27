class_name GridObject
extends Node2D
## Základ pre všetko, čo stojí na políčku mriežky (hráč, bedne, kľúče...).
## Pozíciu v editore stačí dať približne – pri štarte sa objekt prichytí na najbližšie políčko.

## Posun objektu (slide_to) dobehol – objekt už stojí na novom políčku aj na obrazovke.
signal slide_finished

## Skupina, cez ktorú level na začiatku umiestni všetky objekty.
const GROUP: StringName = &"grid_objects"
## Trvanie posunu magnetom o jedno políčko (sekundy).
const SLIDE_DURATION_PER_CELL: float = 0.08
## Pád do priepasti: ako dlho trvá a ako objekt v jame stmavne (je v tieni diery).
const FALL_DURATION: float = 0.35
const FALLEN_COLOR: Color = Color(0.75, 0.75, 0.75)
## Ako vysoko nad podlahu siaha orezávací tvar diery (px). Musí byť vyšší než celý
## objekt, aby sa časť, ktorá je ešte nad podlahou, počas pádu neorezala.
const HOLE_CLIP_HEIGHT: float = 128.0

## Aktuálne políčko. Mení ho len GridManager.
var cell: Vector2i

## Práve bežiaca animácia posunu (aby sa dve animácie nebili).
var _move_tween: Tween


func _ready() -> void:
	add_to_group(GROUP)


## Volá level po načítaní mriežky: zistí políčko z pozície a zaregistruje sa.
func place_on_grid() -> void:
	var start_cell: Vector2i = GridManager.world_to_cell(global_position)
	global_position = GridManager.cell_to_world(start_cell)
	GridManager.register_object(self, start_cell)


## Hráč stojí pred objektom, pozerá sa naň a stlačil E. Predvolene sa nestane nič –
## objekty, ktoré niečo robia (dvere, tabuľa), túto funkciu prepíšu.
func interact(_player: Player) -> void:
	pass


## Spadne objekt do priepasti, keď sa naň posunie? Predvolene nie (okraj jamy ho zastaví).
## Bedňa túto funkciu prepíše – spadne do jamy a vyplní ju.
func can_fall_into_abyss() -> bool:
	return false


## Presunie objekt na políčko: logika sa zmení hneď, animácia ju za `duration` dobehne.
## Volajúci si má predtým overiť, že je cieľ voľný (GridManager.can_slide_into).
## Ak je cieľ priepasť, objekt do nej spadne: jama sa hneď v logike zmení na podlahu
## a po dokončení posunu sa prehrá animácia pádu.
func slide_to(target: Vector2i, duration: float) -> Tween:
	var falls: bool = GridManager.is_abyss(target)
	GridManager.move_object(self, target)
	if falls:
		GridManager.fill_abyss(target)
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "global_position", GridManager.cell_to_world(target), duration)
	_move_tween.finished.connect(slide_finished.emit)
	if falls:
		_move_tween.finished.connect(_play_fall_animation)
	return _move_tween


## Posúva objekt daným smerom, kým nenarazí na prekážku, najviac o `max_steps` políčok
## (používa rukavica aj magnet – magnet pôsobí len do určitej vzdialenosti).
## Bedňa, ktorá cestou príde k priepasti, do nej spadne a ďalej nejde.
func slide_until_blocked(direction: Vector2i, max_steps: int) -> void:
	var target: Vector2i = GridManager.find_slide_end(cell, direction, max_steps, can_fall_into_abyss())
	var distance: int = GridManager.cell_distance(cell, target)
	if distance > 0:
		slide_to(target, distance * SLIDE_DURATION_PER_CELL)


## O koľko pixelov musí objekt v jame klesnúť, aby bol jeho vrch zarovno s podlahou.
## Predvolene 0 – bedňa to prepíše podľa toho, čo práve kreslí (obrázok / polygóny).
func get_fall_depth() -> float:
	return 0.0


## Objekt zapadne do jamy: plynulo klesne (zrýchľuje ako pri páde), až je jeho vrch
## zarovno s podlahou, a stmavne. Počas pádu je v orezávacej „diere“, ktorá stojí medzi
## objektmi (Y Sort) – bedňa ešte trčí nad podlahu, tak sa kreslí ako každý objekt.
## Po dopade dieru presunieme na úroveň podlahy, aby sa Kubo aj zvýraznenie rukavice
## kreslili nad zasypanou jamou.
func _play_fall_animation() -> void:
	var hole: Polygon2D = _create_hole_clip()
	get_parent().add_child(hole)
	hole.global_position = GridManager.cell_to_world(cell)
	reparent(hole) # reparent zachová polohu na obrazovke
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(self, "position:y", position.y + get_fall_depth(), FALL_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", FALLEN_COLOR, FALL_DURATION)
	tween.finished.connect(GridManager.move_to_floor.bind(hole))


## Orezávací tvar diery (clip_children): kosoštvorec políčka (64 × 32) predĺžený nahor.
## Čo je ešte nad podlahou, vidno celé. Čo klesne pod podlahu, vidno len cez otvor jamy –
## predné (spodné) hrany kosoštvorca to orežú, takže sa to nekreslí cez dlaždice pred jamou.
func _create_hole_clip() -> Polygon2D:
	var half: Vector2 = Vector2(GridManager.get_tile_size()) * 0.5
	var hole := Polygon2D.new()
	hole.name = "AbyssHole"
	hole.polygon = PackedVector2Array([
		Vector2(-half.x, 0.0), # ľavý roh jamy
		Vector2(0.0, half.y), # predný (spodný) roh jamy
		Vector2(half.x, 0.0), # pravý roh jamy
		Vector2(half.x, -HOLE_CLIP_HEIGHT), # odtiaľ zvislo nahor – nad podlahou sa nič neoreže
		Vector2(-half.x, -HOLE_CLIP_HEIGHT),
	])
	# Samotný tvar sa nekreslí, len oreže svoje deti (bedňu).
	hole.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	return hole
