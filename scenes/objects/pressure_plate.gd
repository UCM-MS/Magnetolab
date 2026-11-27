class_name PressurePlate
extends Node2D
## Tlačidlo na podlahe. Je stlačené, kým na jeho políčku stojí hráč alebo bedňa.
## Nie je GridObject – nezaberá políčko, nič neblokuje, dá sa naň stúpiť (ako TriggerZone).
## Stav zisťuje len cez GridManager (signály o vstupe/odchode objektu), nie cez fyziku.

## Tlačidlo sa stlačilo / pustilo (vysiela sa len pri zmene stavu).
signal pressed
signal released

## Skupina, cez ktorú level nájde všetky tlačidlá a prepojí ich s mrežami.
const GROUP: StringName = &"pressure_plates"
## Dočasné farby (kým grafici nedodajú sprity).
const RELEASED_COLOR: Color = Color(0.75, 0.25, 0.2)
const PRESSED_COLOR: Color = Color(0.3, 0.75, 0.3)

## Mreža, ktorú tlačidlo ovláda. Signály prepojí level (_connect_signals).
@export var gate: Gate

var is_pressed: bool = false

@onready var _top: Polygon2D = $Top


func _ready() -> void:
	add_to_group(GROUP)
	GridManager.object_entered_cell.connect(_on_cell_changed)
	GridManager.object_left_cell.connect(_on_cell_changed)
	_update_look()
	# Prichytenie na políčko až po tom, čo level načíta mriežku (jeho _ready beží po našom).
	_place_on_floor.call_deferred()


## Prichytí tlačidlo na stred políčka a presunie ho na úroveň podlahy,
## aby sa hráč aj bedne kreslili nad ním.
func _place_on_floor() -> void:
	global_position = GridManager.cell_to_world(_get_cell())
	GridManager.move_to_floor(self)


func _get_cell() -> Vector2i:
	return GridManager.world_to_cell(global_position)


## Niečo vstúpilo na políčko alebo ho opustilo – ak je to naše políčko, prepočítame stav.
func _on_cell_changed(_obj: GridObject, cell: Vector2i) -> void:
	if cell == _get_cell():
		_set_pressed(_is_pressed_now())


## Tlačidlo stlačí hráč alebo bedňa, ktorá na ňom stojí. Bedňa v jame je odhlásená
## z mriežky (get_object_at ju nevráti); kým na políčko len padá, je to ešte priepasť.
func _is_pressed_now() -> bool:
	var cell: Vector2i = _get_cell()
	if GridManager.is_abyss(cell):
		return false
	var obj: GridObject = GridManager.get_object_at(cell)
	return obj is Player or obj is Box


func _set_pressed(value: bool) -> void:
	if value == is_pressed:
		return
	is_pressed = value
	_update_look()
	if is_pressed:
		pressed.emit()
	else:
		released.emit()


func _update_look() -> void:
	_top.color = PRESSED_COLOR if is_pressed else RELEASED_COLOR
