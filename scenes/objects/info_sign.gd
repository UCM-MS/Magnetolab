class_name InfoSign
extends GridObject
## Tabuľa s textom. Hráč ju prečíta klávesom E (stojí pred ňou a pozerá sa na ňu).

signal dialog_requested(dialog: DialogData)

@export var dialog: DialogData


func _ready() -> void:
	super._ready()
	add_to_group(Level.DIALOG_SOURCES_GROUP)


func interact(_player: Player) -> void:
	dialog_requested.emit(dialog)
