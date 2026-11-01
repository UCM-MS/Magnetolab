class_name TriggerZone
extends Node2D
## Spúšťacia oblasť: keď do nej hráč prvýkrát vstúpi, požiada o zobrazenie dialógu.
## Oblasť je obdĺžnik políčok – ľavý horný roh je políčko, kde zóna stojí, veľkosť je `size`.
## Nezaberá políčko (nie je GridObject), takže nič neblokuje.

signal dialog_requested(dialog: DialogData)

@export var size: Vector2i = Vector2i.ONE
@export var dialog: DialogData

## Každá oblasť sa spustí len raz.
var _fired: bool = false


func _ready() -> void:
	add_to_group(Level.DIALOG_SOURCES_GROUP)
	GridManager.object_entered_cell.connect(_on_object_entered_cell)


func _on_object_entered_cell(obj: GridObject, cell: Vector2i) -> void:
	if _fired or not obj is Player:
		return
	var area := Rect2i(GridManager.world_to_cell(global_position), size)
	if area.has_point(cell):
		_fired = true
		dialog_requested.emit(dialog)
