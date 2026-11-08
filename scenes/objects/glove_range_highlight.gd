class_name GloveRangeHighlight
extends Node2D
## Jemné zvýraznenie políčok, kam siaha lúč zapnutej rukavice (placeholder: polopriehľadná
## farba pólu). Level ho vloží hneď nad podlahu, takže bedne a hráč sú vždy nad ním.
## O tom, ktoré políčka to sú, rozhoduje rukavica – sem prídu cez signál beam_changed.

## Priehľadnosť výplne (0 = neviditeľná, 1 = plná farba).
const FILL_ALPHA: float = 0.25
## Kosoštvorec je o trochu menší než dlaždica, aby bolo vidno hranice políčok.
const CELL_SCALE: float = 0.85

## Políčka, ktoré práve vykresľujeme, a ich farba.
var _cells: Array[Vector2i] = []
var _color: Color = Color.TRANSPARENT


## Napojí sa na signál rukavice: glove.beam_changed.connect(highlight.show_beam)
func show_beam(cells: Array[Vector2i], pole: Magnetism.Pole) -> void:
	_cells = cells
	_color = Magnetism.POLE_COLORS[pole]
	_color.a = FILL_ALPHA
	queue_redraw()


## Každé políčko nakreslí ako izometrický kosoštvorec okolo jeho stredu.
func _draw() -> void:
	var half: Vector2 = Vector2(GridManager.get_tile_size()) * 0.5 * CELL_SCALE
	for cell: Vector2i in _cells:
		var center: Vector2 = to_local(GridManager.cell_to_world(cell))
		var diamond := PackedVector2Array([
			center + Vector2(0, -half.y),
			center + Vector2(half.x, 0),
			center + Vector2(0, half.y),
			center + Vector2(-half.x, 0),
		])
		draw_colored_polygon(diamond, _color)
