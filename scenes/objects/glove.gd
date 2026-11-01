class_name Glove
extends Node2D
## Magnetická rukavica (elektromagnet). Stavy: vypnutá / zapnutá S / zapnutá J.
## Ikonka nad hráčom: sivá výplň = vypnutá, farebná = zapnutá; obrys vždy ukazuje zvolený pól.

## Rukavica pritiahla malý predmet (hráč si ho vezme do inventára).
signal item_pulled(item: Item)

## Poloha a veľkosť ikonky nad hlavou hráča.
const ICON_OFFSET: Vector2 = Vector2(0, -38)
const ICON_RADIUS: float = 5.0
const ICON_OUTLINE_WIDTH: float = 2.0
const OFF_COLOR: Color = Color(0.3, 0.3, 0.3)

## Tečie prúd? (elektromagnet funguje len so zapnutým prúdom)
var is_on: bool = false
## Pól, ktorý rukavica vytvára. Q ho prepína aj vo vypnutom stave (predvoľba).
var pole: Magnetism.Pole = Magnetism.Pole.S


func toggle() -> void:
	is_on = not is_on
	queue_redraw()


func switch_pole() -> void:
	pole = Magnetism.Pole.J if pole == Magnetism.Pole.S else Magnetism.Pole.S
	queue_redraw()


## Zapnutá rukavica pôsobí z políčka `origin` smerom `direction` na PRVÝ objekt v rade.
## O tom, či priťahuje alebo odpudzuje, rozhoduje Magnetism.force() (cez objekt).
func act(origin: Vector2i, direction: Vector2i) -> void:
	if not is_on:
		return
	var target: GridObject = GridManager.find_first_object(origin, direction)
	if target is Box:
		_act_on_box(target, direction)
	elif target is Item:
		_act_on_item(target)
	# Iný objekt (dvere, tabuľa...) lúč zastaví a nič sa nestane.


func _act_on_box(box: Box, direction: Vector2i) -> void:
	match box.get_magnetic_force(pole):
		Magnetism.Force.ATTRACT:
			# K hráčovi, kým nie je na susednom políčku alebo nenarazí.
			box.slide_until_blocked(-direction)
		Magnetism.Force.REPEL:
			# Od hráča, kým nenarazí na prekážku.
			box.slide_until_blocked(direction)
		Magnetism.Force.NONE:
			pass # nemagnetický materiál lúč zastaví, nič sa nestane


## Malý predmet sa nehýbe po zemi – ak ho magnet priťahuje, oznámime to hráčovi.
## Železo priťahujú oba póly; drevo, plast... nereagujú.
func _act_on_item(item: Item) -> void:
	if item.get_magnetic_force(pole) == Magnetism.Force.ATTRACT:
		item_pulled.emit(item)


func _draw() -> void:
	var pole_color: Color = Magnetism.POLE_COLORS[pole]
	draw_circle(ICON_OFFSET, ICON_RADIUS, pole_color if is_on else OFF_COLOR)
	draw_circle(ICON_OFFSET, ICON_RADIUS, pole_color, false, ICON_OUTLINE_WIDTH)
