extends Control
## Hlavné menu: podobrazovky sú panely v jednej scéne a vždy je viditeľný len jeden.
## Vzhľad určuje Theme (resources/ui_theme.tres), texty sú v scéne main_menu.tscn.

## Cesta k scéne miestnosti podľa jej identifikátora ("A1" -> level_a1.tscn).
const LEVEL_SCENE_FORMAT: String = "res://scenes/levels/level_%s.tscn"
## Veľkosť tlačidla miestnosti vo Výbere miestnosti (px).
const LEVEL_BUTTON_SIZE: Vector2 = Vector2(120, 64)

## Miestnosti zobrazené vo Výbere miestnosti.
@export var level_ids: PackedStringArray = ["A1", "A2", "A3", "A4", "A5", "A6"]
## Ikona na zamknutej miestnosti (nastavuje sa v scéne, grafici ju môžu vymeniť).
@export var lock_icon: Texture2D

@onready var _main_panel: Control = %MainPanel
@onready var _variant_panel: Control = %VariantPanel
@onready var _level_panel: Control = %LevelPanel
@onready var _settings_panel: Control = %SettingsPanel
@onready var _credits_panel: Control = %CreditsPanel
@onready var _panels: Array[Control] = [_main_panel, _variant_panel, _level_panel, _settings_panel, _credits_panel]

@onready var _continue_button: Button = %ContinueButton
@onready var _level_grid: GridContainer = %LevelGrid
@onready var _level_notice: Label = %LevelNotice
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _fullscreen_toggle: CheckButton = %FullscreenToggle


func _ready() -> void:
	_continue_button.visible = SaveManager.has_save()
	_build_level_grid()
	_show_saved_settings()
	_connect_buttons()
	_show_panel(_main_panel)


## Pospája tlačidlá s tým, čo majú urobiť. bind() odovzdá funkcii, ktorý panel má ukázať.
func _connect_buttons() -> void:
	_continue_button.pressed.connect(_on_continue_pressed)
	%PlayButton.pressed.connect(_show_panel.bind(_variant_panel))
	%LevelsButton.pressed.connect(_show_panel.bind(_level_panel))
	%SettingsButton.pressed.connect(_show_panel.bind(_settings_panel))
	%CreditsButton.pressed.connect(_show_panel.bind(_credits_panel))
	%QuitButton.pressed.connect(_on_quit_pressed)
	%YoungButton.pressed.connect(_start_level.bind(SaveManager.FIRST_LEVEL_ID))
	%VariantBackButton.pressed.connect(_show_panel.bind(_main_panel))
	%LevelBackButton.pressed.connect(_show_panel.bind(_main_panel))
	%SettingsBackButton.pressed.connect(_show_panel.bind(_main_panel))
	%CreditsBackButton.pressed.connect(_show_panel.bind(_main_panel))
	_music_slider.value_changed.connect(SaveManager.set_music_volume)
	_sfx_slider.value_changed.connect(SaveManager.set_sfx_volume)
	_fullscreen_toggle.toggled.connect(SaveManager.set_fullscreen)


# --- Prepínanie panelov a fokus ---

## Ukáže jeden panel, ostatné skryje a dá fokus na jeho prvý aktívny prvok.
func _show_panel(target: Control) -> void:
	for panel: Control in _panels:
		panel.visible = panel == target
	_level_notice.visible = false
	var first_active: Control = _find_first_active(target)
	if first_active != null:
		first_active.grab_focus()


## Prejde uzly zhora nadol a vráti prvý viditeľný prvok, ktorý vie prijať fokus.
## Skryté tlačidlo (Pokračovať) aj neaktívne tlačidlá (FOCUS_NONE) tak preskočí.
func _find_first_active(parent: Node) -> Control:
	for child: Node in parent.get_children():
		var control: Control = child as Control
		if control == null or not control.visible:
			continue
		if control.focus_mode == Control.FOCUS_ALL:
			return control
		var found: Control = _find_first_active(control)
		if found != null:
			return found
	return null


# --- Spustenie hry ---

func _on_continue_pressed() -> void:
	_start_level(SaveManager.last_level)


func _start_level(id: String) -> void:
	SaveManager.set_current_level(id)
	get_tree().change_scene_to_file(_level_scene_path(id))


func _level_scene_path(id: String) -> String:
	return LEVEL_SCENE_FORMAT % id.to_lower()


func _on_quit_pressed() -> void:
	get_tree().quit()


# --- Výber miestnosti ---

## Vytvorí mriežku tlačidiel: odomknuté sú aktívne, zamknuté majú zámok.
func _build_level_grid() -> void:
	for id: String in level_ids:
		_level_grid.add_child(_create_level_button(id))


func _create_level_button(id: String) -> Button:
	var button := Button.new()
	button.text = id
	button.custom_minimum_size = LEVEL_BUTTON_SIZE
	if SaveManager.is_level_unlocked(id):
		button.pressed.connect(_on_level_pressed.bind(id))
	else:
		button.disabled = true
		button.focus_mode = Control.FOCUS_NONE # šípky zamknuté tlačidlo preskočia
		button.icon = lock_icon
	return button


## Odomknutá miestnosť ešte nemusí existovať – vtedy len ukážeme oznam.
func _on_level_pressed(id: String) -> void:
	if ResourceLoader.exists(_level_scene_path(id)):
		_start_level(id)
	else:
		_level_notice.visible = true


# --- Nastavenia ---

## Nastaví ovládacie prvky podľa uložených hodnôt. Verzia „no_signal“ nevyšle signál,
## takže sa pri otvorení menu zbytočne nič neukladá.
func _show_saved_settings() -> void:
	_music_slider.set_value_no_signal(SaveManager.music_volume)
	_sfx_slider.set_value_no_signal(SaveManager.sfx_volume)
	_fullscreen_toggle.set_pressed_no_signal(SaveManager.fullscreen)
