class_name Gate
extends GridObject
## Mreža ovládaná tlačidlom na podlahe. Zatvorená blokuje cestu aj lúč rukavice
## (zaberá políčko ako každý GridObject). Otvorená sa odhlási z mriežky – ako otvorené dvere.
## Mreža o tlačidle nevie: open() a close() na signály tlačidla napojí level.

signal opened
signal closed

var is_open: bool = false
## Mreža sa má zatvoriť, ale čaká, kým sa jej políčko uvoľní (stojí v nej hráč, bedňa...).
var _close_pending: bool = false


func _ready() -> void:
	super._ready()
	GridManager.object_left_cell.connect(_on_object_left_cell)


## Ak mrežu otvorilo tlačidlo už pri štarte (bedňa naň položená v editore) skôr,
## než sa mreža zaregistrovala, hneď sa z mriežky zase odhlási.
func place_on_grid() -> void:
	super.place_on_grid()
	if is_open:
		GridManager.unregister_object(self)


func open() -> void:
	_close_pending = false
	if is_open:
		return
	is_open = true
	GridManager.unregister_object(self)
	_update_look()
	opened.emit()


## Zatvorenie počkáme do konca snímku (call_deferred): keď hráč zíde z tlačidla a v tom istom
## kroku naň stúpi iný objekt (alebo bedňu z tlačidla odtlačí do mreže), rozhodne sa až podľa
## konečného stavu – mreža zbytočne necvakne ani sa nezatvorí pod bedňou.
func close() -> void:
	_close_pending = true
	_try_close.call_deferred()


## Zatvorí mrežu, len ak je jej políčko voľné. Inak čaká na signál object_left_cell.
func _try_close() -> void:
	if not _close_pending or not is_open:
		return
	if not GridManager.is_free(cell):
		return
	_close_pending = false
	is_open = false
	GridManager.register_object(self, cell)
	_update_look()
	closed.emit()


## Niečo opustilo políčko mreže – ak čaká na zatvorenie, skúsi to znova.
func _on_object_left_cell(obj: GridObject, left_cell: Vector2i) -> void:
	if _close_pending and obj != self and left_cell == cell:
		_try_close.call_deferred()


func _update_look() -> void:
	$Bars.visible = not is_open
	$OpenSlot.visible = is_open
