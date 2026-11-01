class_name Inventory
extends Node
## Inventár hráča: malé predmety (kľúče, mince...), ktoré pritiahla rukavica.
## Pamätá si len druh predmetu (ItemData) – samotný uzol predmetu po zdvihnutí zmizne.

## Zmenil sa obsah inventára (HUD prekreslí sloty).
signal changed(items: Array[ItemData])
## Pribudol predmet (level podľa toho napr. ukáže spätnú väzbu k tipu).
signal item_added(item: ItemData)

## Počet slotov v inventári.
const MAX_SLOTS: int = 6

var items: Array[ItemData] = []


func is_full() -> bool:
	return items.size() >= MAX_SLOTS


func add(item: ItemData) -> void:
	items.append(item)
	changed.emit(items)
	item_added.emit(item)


func remove(item: ItemData) -> void:
	items.erase(item)
	changed.emit(items)


## Prvý kľúč v inventári, alebo null.
func find_key() -> ItemData:
	for item: ItemData in items:
		if item.is_key:
			return item
	return null
