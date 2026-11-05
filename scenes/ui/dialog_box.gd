class_name DialogBox
extends PanelContainer
## Jednotné dialógové okno: portrét vľavo, meno postavy, nadpis, text a prípadne možnosti odpovede.
## Cez toto okno hovorí profesor Magnetón všetko – nápovedy, otázky, spätnú väzbu aj kartičky.
## Kým je okno otvorené, hra stojí (get_tree().paused); okno beží stále (process_mode = Always).

## Hráč odpovedal na otázku.
signal question_answered(page: DialogPage, option_index: int)
## Okno sa zatvorilo – dočítal sa posledný dialóg a žiadny ďalší nečaká.
signal closed

## Klávesy 1, 2, 3... vyberajú možnosti odpovede.
const FIRST_OPTION_KEY: Key = KEY_1

## Kto hovorí (meno a portréty). Zatiaľ vždy profesor Magnetón.
@export var speaker: SpeakerData

## Dialógy čakajúce na zobrazenie (ak príde nový, kým je otvorený iný).
var _queue: Array[DialogData] = []
var _pages: Array[DialogPage] = []
var _page_index: int = 0

@onready var _portrait: TextureRect = $Margin/Row/PortraitFrame/Portrait
@onready var _name: Label = $Margin/Row/Content/Name
@onready var _title: Label = $Margin/Row/Content/Title
@onready var _text: Label = $Margin/Row/Content/Text
@onready var _options: Container = $Margin/Row/Content/Options
@onready var _continue_hint: Control = $Margin/Row/Content/ContinueHint


func _ready() -> void:
	visible = false
	_name.text = speaker.display_name


## Ak sa scéna zmení počas otvoreného dialógu, nesmie hra ostať navždy pozastavená.
func _exit_tree() -> void:
	if visible:
		get_tree().paused = false


## Zaradí dialóg na zobrazenie (ak je otvorený iný, ukáže sa po ňom).
func show_dialog(dialog: DialogData) -> void:
	_queue.append(dialog)
	if not visible:
		_start_next_dialog()


func is_open() -> bool:
	return visible


func _start_next_dialog() -> void:
	visible = not _queue.is_empty()
	get_tree().paused = visible
	if _queue.is_empty():
		closed.emit()
		return
	_pages = _queue.pop_front().pages
	_page_index = 0
	_show_page()


func _show_page() -> void:
	var page: DialogPage = _pages[_page_index]
	_portrait.texture = speaker.get_portrait(page.mood)
	_title.text = page.title
	_title.visible = not page.title.is_empty()
	_text.text = page.text
	for button: Node in _options.get_children():
		button.queue_free()
	for i: int in page.options.size():
		_options.add_child(_create_option_button(i, page.options[i]))
	_options.visible = page.is_question()
	_continue_hint.visible = not page.is_question()


func _create_option_button(index: int, option_text: String) -> Button:
	var button := Button.new()
	button.text = "%d) %s" % [index + 1, option_text]
	button.focus_mode = Control.FOCUS_NONE # aby medzerník omylom nevybral odpoveď
	button.pressed.connect(_choose_option.bind(index))
	return button


func _choose_option(index: int) -> void:
	question_answered.emit(_pages[_page_index], index)
	_next_page()


func _next_page() -> void:
	_page_index += 1
	if _page_index < _pages.size():
		_show_page()
	else:
		_start_next_dialog()


## E / medzerník posúva text; pri otázke sa odpovedá klávesmi 1–3 (alebo myšou).
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var page: DialogPage = _pages[_page_index]
	if page.is_question():
		var index: int = _option_index_from_key(event)
		if index >= 0 and index < page.options.size():
			_choose_option(index)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"dialog_next"):
		_next_page()
		# Spracovaný kláves už nedostane hráč (medzerník by inak zapol rukavicu).
		get_viewport().set_input_as_handled()


## Vráti index možnosti podľa stlačeného čísla (1 -> 0), inak -1.
func _option_index_from_key(event: InputEvent) -> int:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return -1
	return key_event.physical_keycode - FIRST_OPTION_KEY
