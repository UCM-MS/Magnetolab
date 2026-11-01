class_name Door
extends GridObject
## Zamknuté dvere. Otvorí ich hráč, ktorý má kľúč v inventári:
## stojí pred dverami, pozerá sa na ne a stlačí E. Kľúč sa z inventára odstráni.

signal opened
## Hráč skúsil otvoriť dvere bez kľúča.
signal locked_attempt

var is_open: bool = false


func interact(player: Player) -> void:
	if is_open:
		return
	var key: ItemData = player.inventory.find_key()
	if key == null:
		locked_attempt.emit()
		return
	player.inventory.remove(key)
	_open()


## Otvorené dvere sa odhlásia z mriežky – políčko je potom voľné.
func _open() -> void:
	is_open = true
	GridManager.unregister_object(self)
	$Closed.visible = false
	$Open.visible = true
	opened.emit()
