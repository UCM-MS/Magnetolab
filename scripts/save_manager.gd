extends Node
## Autoload: pamäť hry medzi spusteniami – postup hráča a nastavenia.
## Údaje držíme v premenných a do súboru user://save.cfg ich zapisuje save_game().

const SAVE_PATH: String = "user://save.cfg"

## Sekcie a kľúče v uloženom súbore.
const SECTION_PROGRESS: String = "progress"
const SECTION_SETTINGS: String = "settings"
const KEY_UNLOCKED_LEVELS: String = "unlocked_levels"
const KEY_LAST_LEVEL: String = "last_level"
const KEY_MUSIC_VOLUME: String = "music_volume"
const KEY_SFX_VOLUME: String = "sfx_volume"
const KEY_FULLSCREEN: String = "fullscreen"

## Prvá miestnosť je odomknutá vždy.
const FIRST_LEVEL_ID: String = "A1"
## Hlasitosť je číslo od 0.0 (ticho) po 1.0 (naplno).
const DEFAULT_VOLUME: float = 1.0
const MUSIC_BUS: StringName = &"Music"
const SFX_BUS: StringName = &"SFX"

## Identifikátory odomknutých miestností, napr. ["A1", "A2"].
var unlocked_levels: PackedStringArray = [FIRST_LEVEL_ID]
## Posledná hraná miestnosť (prázdne = hráč ešte nehral).
var last_level: String = ""
var music_volume: float = DEFAULT_VOLUME
var sfx_volume: float = DEFAULT_VOLUME
var fullscreen: bool = false


## Autoload sa spustí pri štarte hry – hneď načítame uložené údaje.
func _ready() -> void:
	load_game()


# --- Uloženie a načítanie ---

## Existuje uložená hra? Súbor nestačí: vzniká už pri zmene nastavení,
## preto sa pýtame, či hráč už nejakú miestnosť hral.
func has_save() -> bool:
	return not last_level.is_empty()


## Zapíše všetky údaje do súboru.
func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION_PROGRESS, KEY_UNLOCKED_LEVELS, unlocked_levels)
	config.set_value(SECTION_PROGRESS, KEY_LAST_LEVEL, last_level)
	config.set_value(SECTION_SETTINGS, KEY_MUSIC_VOLUME, music_volume)
	config.set_value(SECTION_SETTINGS, KEY_SFX_VOLUME, sfx_volume)
	config.set_value(SECTION_SETTINGS, KEY_FULLSCREEN, fullscreen)
	var error: Error = config.save(SAVE_PATH)
	if error != OK:
		push_error("Hru sa nepodarilo uložiť (chyba %d)" % error)


## Načíta údaje zo súboru a použije nastavenia. Bez súboru ostanú predvolené hodnoty.
## Kľúče, ktoré už nepoužívame (napr. „variant“ zo starších verzií), sa jednoducho ignorujú
## a pri najbližšom uložení zo súboru zmiznú.
func load_game() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		unlocked_levels = config.get_value(SECTION_PROGRESS, KEY_UNLOCKED_LEVELS, PackedStringArray([FIRST_LEVEL_ID]))
		last_level = config.get_value(SECTION_PROGRESS, KEY_LAST_LEVEL, "")
		music_volume = config.get_value(SECTION_SETTINGS, KEY_MUSIC_VOLUME, DEFAULT_VOLUME)
		sfx_volume = config.get_value(SECTION_SETTINGS, KEY_SFX_VOLUME, DEFAULT_VOLUME)
		fullscreen = config.get_value(SECTION_SETTINGS, KEY_FULLSCREEN, false)
	_apply_settings()


# --- Postup hráča ---

func unlock_level(id: String) -> void:
	if not is_level_unlocked(id):
		unlocked_levels.append(id)
		save_game()


func is_level_unlocked(id: String) -> bool:
	return unlocked_levels.has(id)


## Hráč vstupuje do miestnosti: zapamätáme si ju (tlačidlo Pokračovať).
func set_current_level(id: String) -> void:
	last_level = id
	save_game()


## Vymaže postup hráča. Nastavenia (hlasitosť, celá obrazovka) ostanú.
func reset_progress() -> void:
	unlocked_levels = [FIRST_LEVEL_ID]
	last_level = ""
	save_game()


# --- Nastavenia: každá zmena sa hneď použije aj uloží ---

func set_music_volume(volume: float) -> void:
	music_volume = volume
	_apply_bus_volume(MUSIC_BUS, volume)
	save_game()


func set_sfx_volume(volume: float) -> void:
	sfx_volume = volume
	_apply_bus_volume(SFX_BUS, volume)
	save_game()


func set_fullscreen(enabled: bool) -> void:
	fullscreen = enabled
	_apply_fullscreen(enabled)
	save_game()


func _apply_settings() -> void:
	_apply_bus_volume(MUSIC_BUS, music_volume)
	_apply_bus_volume(SFX_BUS, sfx_volume)
	_apply_fullscreen(fullscreen)


func _apply_bus_volume(bus: StringName, volume: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus), volume)


func _apply_fullscreen(enabled: bool) -> void:
	var mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
