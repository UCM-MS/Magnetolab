class_name Player
extends GridObject
## Hráč: chodí po políčkach, posun medzi políčkami je animovaný Tweenom.

## Hráč sa pokúsil tlačiť bedňu, ktorá sa rukou nepohne (kovová).
signal push_blocked(box: Box)

## Trvanie posunu o jedno políčko (sekundy).
const STEP_DURATION: float = 0.15
## Kam (nad hlavu hráča) priletí pritiahnutý predmet, kým zmizne v inventári.
const PICKUP_OFFSET: Vector2 = Vector2(0, -24)
## Pauza po otočení na mieste, kým sa pri držaní klávesu začne hráč pohybovať (sekundy).
const TURN_DELAY: float = 0.15

## Vstupná akcia -> smer na mriežke. Kvôli izometrii ide každý kláves
## po uhlopriečke obrazovky (W = hore-vpravo, D = dole-vpravo, S = dole-vľavo, A = hore-vľavo).
const INPUT_DIRECTIONS: Dictionary[StringName, Vector2i] = {
	&"move_up": Vector2i(0, -1),
	&"move_right": Vector2i(1, 0),
	&"move_down": Vector2i(0, 1),
	&"move_left": Vector2i(-1, 0),
}

## Smer, ktorým sa hráč pozerá (neskôr v ňom bude pôsobiť rukavica).
var facing: Vector2i = Vector2i(1, 0)

## Počas animácie kroku nečítame vstup – hráč je vždy presne na políčku.
var _is_moving: bool = false
## Zostávajúci čas pauzy po otočení; kým je > 0, hráč nekráča.
var _turn_timer: float = 0.0

@onready var _facing_marker: Node2D = $FacingMarker
@onready var glove: Glove = $Glove
@onready var inventory: Inventory = $Inventory


func _ready() -> void:
	super._ready()
	glove.item_pulled.connect(_collect)


func place_on_grid() -> void:
	super.place_on_grid()
	_set_facing(facing)


## Iný smer než facing = len otočenie na mieste. Rovnaký smer = krok
## (pri držaní klávesu až po uplynutí pauzy TURN_DELAY od otočenia).
func _process(delta: float) -> void:
	if _is_moving:
		return
	_turn_timer = maxf(_turn_timer - delta, 0.0)
	var direction: Vector2i = _read_input_direction()
	if direction == Vector2i.ZERO:
		# Kláves pustený: ďalšie stlačenie v smere pohľadu kráča hneď.
		_turn_timer = 0.0
	elif direction != facing:
		_set_facing(direction)
		_turn_timer = TURN_DELAY
		_use_glove()
	elif _turn_timer == 0.0:
		try_step(direction)


## Medzerník = rukavica zap/vyp, Q = prepnutie pólu, E = interakcia s objektom pred hráčom.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"glove_toggle"):
		toggle_glove()
	elif event.is_action_pressed(&"glove_pole"):
		switch_glove_pole()
	elif event.is_action_pressed(&"interact"):
		interact_ahead()


## Interakcia s objektom na políčku, na ktoré sa hráč pozerá (dvere, tabuľa...).
func interact_ahead() -> void:
	var target: GridObject = GridManager.get_object_at(cell + facing)
	if target != null:
		target.interact(self)


func toggle_glove() -> void:
	glove.toggle()
	_use_glove()


func switch_glove_pole() -> void:
	glove.switch_pole()
	_use_glove()


## Pritiahnutý malý predmet preletí k hráčovi a uloží sa do inventára.
## Ak je inventár plný, predmet ostane ležať.
func _collect(item: Item) -> void:
	if inventory.is_full():
		return
	var tween: Tween = item.fly_to(global_position + PICKUP_OFFSET)
	tween.finished.connect(_store_in_inventory.bind(item))


func _store_in_inventory(item: Item) -> void:
	inventory.add(item.data)
	item.queue_free()


## Elektromagnet pôsobí stále, kým je zapnutý – preto ho „použijeme“ po každej zmene
## (zapnutie, prepnutie pólu, otočenie, krok). Vypnutá rukavica nerobí nič.
func _use_glove() -> void:
	glove.act(cell, facing)


## Vráti smer podľa práve držaného klávesu (alebo ZERO).
func _read_input_direction() -> Vector2i:
	for action: StringName in INPUT_DIRECTIONS:
		if Input.is_action_pressed(action):
			return INPUT_DIRECTIONS[action]
	return Vector2i.ZERO


## Otočí sa a ak je cieľové políčko voľné (alebo sa bedňa dá odtlačiť), prejde naň.
func try_step(direction: Vector2i) -> void:
	_set_facing(direction)
	var target: Vector2i = cell + direction
	_try_push(target, direction)
	if not GridManager.is_free(target):
		return
	# Najprv sa zmení logika (okamžite), animácia ju len dobehne.
	_is_moving = true
	var tween: Tween = slide_to(target, STEP_DURATION)
	tween.finished.connect(func() -> void: _is_moving = false)
	_use_glove()


## Tlačenie rukou (ako Sokoban): bedňu na `target` posunie o 1 políčko, ak je za ňou voľno.
## Len drevené bedne; pri kovovej sa vyšle signál push_blocked (level ukáže hlášku).
func _try_push(target: Vector2i, direction: Vector2i) -> void:
	var box: Box = GridManager.get_object_at(target) as Box
	if box == null:
		return
	if not box.can_be_pushed():
		push_blocked.emit(box)
		return
	var behind: Vector2i = target + direction
	if GridManager.is_free(behind):
		box.slide_to(behind, STEP_DURATION)


## Uloží smer pohľadu a natočí šípku pod hráčom na obrazovke.
func _set_facing(direction: Vector2i) -> void:
	facing = direction
	var screen_dir: Vector2 = GridManager.cell_to_world(cell + direction) - GridManager.cell_to_world(cell)
	_facing_marker.rotation = screen_dir.angle()
