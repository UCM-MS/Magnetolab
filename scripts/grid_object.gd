class_name GridObject
extends Node2D
## Základ pre všetko, čo stojí na políčku mriežky (hráč, bedne, kľúče...).
## Pozíciu v editore stačí dať približne – pri štarte sa objekt prichytí na najbližšie políčko.

## Skupina, cez ktorú level na začiatku umiestni všetky objekty.
const GROUP: StringName = &"grid_objects"

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


## Presunie objekt na políčko: logika sa zmení hneď, animácia ju za `duration` dobehne.
## Volajúci si má predtým overiť, že je cieľ voľný.
func slide_to(target: Vector2i, duration: float) -> Tween:
	GridManager.move_object(self, target)
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "global_position", GridManager.cell_to_world(target), duration)
	return _move_tween
