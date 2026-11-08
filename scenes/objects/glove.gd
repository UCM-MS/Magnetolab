class_name Glove
extends Node2D
## Magnetická rukavica (elektromagnet). Stavy: vypnutá / zapnutá S / zapnutá J.
## Ikonka nad hráčom: sivá výplň = vypnutá, farebná = zapnutá; obrys vždy ukazuje zvolený pól.

## Rukavica pritiahla malý predmet (hráč si ho vezme do inventára).
signal item_pulled(item: Item)
## Zmenilo sa, kam siaha lúč (prázdne pole = rukavica je vypnutá). Počúva ho zvýraznenie dosahu.
signal beam_changed(cells: Array[Vector2i], pole: Magnetism.Pole)

## Dosah rukavice v políčkach. Objekt ďalej nereaguje.
const GLOVE_RANGE: int = 4

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


## Zapnutá rukavica pôsobí z políčka `origin` smerom `direction` na PRVÝ objekt v rade,
## ale len do vzdialenosti GLOVE_RANGE. O tom, či priťahuje alebo odpudzuje,
## rozhoduje Magnetism.force() (cez objekt).
func act(origin: Vector2i, direction: Vector2i) -> void:
	if is_on:
		var target: GridObject = GridManager.find_first_object(origin, direction, GLOVE_RANGE)
		if target is Box:
			_act_on_box(target, origin, direction)
		elif target is Item:
			_act_on_item(target)
		# Iný objekt (dvere, tabuľa...) lúč zastaví a nič sa nestane.
	# Lúč počítame až po pôsobení – pritiahnutá bedňa už stojí na novom mieste.
	_update_beam(origin, direction)


## Oznámi, kam teraz siaha lúč. Vypnutá rukavica nesiaha nikam.
func _update_beam(origin: Vector2i, direction: Vector2i) -> void:
	var cells: Array[Vector2i] = []
	if is_on:
		cells = GridManager.get_beam_cells(origin, direction, GLOVE_RANGE)
	beam_changed.emit(cells, pole)


## `origin` = políčko hráča. Z neho počítame, ako ďaleko je bedňa a kam až ju pole dosiahne.
func _act_on_box(box: Box, origin: Vector2i, direction: Vector2i) -> void:
	var distance: int = GridManager.cell_distance(origin, box.cell)
	match box.get_magnetic_force(pole):
		Magnetism.Force.ATTRACT:
			# K hráčovi, kým nie je na susednom políčku alebo nenarazí.
			# (distance - 1 krokov ju dovedie presne vedľa hráča.)
			box.slide_until_blocked(-direction, distance - 1)
		Magnetism.Force.REPEL:
			# Od hráča, kým nenarazí na prekážku – ale najďalej na okraj dosahu rukavice.
			# Za okrajom už pole nepôsobí, takže bedňa tam zastane.
			box.slide_until_blocked(direction, GLOVE_RANGE - distance)
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
