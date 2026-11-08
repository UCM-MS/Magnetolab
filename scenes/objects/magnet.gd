class_name Magnet
extends GridObject
## Tyčový magnet položený na podlahe. Priťahuje obyčajné železo (bedne, kľúče, sponky...),
## ktoré je v rade vedľa neho najviac `range_cells` políčok ďaleko. Ďalej jeho pole nesiaha.
## Dva magnety s rôznym dosahom sa dajú porovnať (miestnosť A5 „Ktorý magnet je silnejší?“).

## Štyri smery na mriežke – magnet pôsobí okolo seba na všetky strany.
const DIRECTIONS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

## Dosah magnetu v políčkach (silnejší magnet = väčší dosah).
@export_range(1, 10) var range_cells: int = 2


## Po umiestnení na mriežku pritiahne železo, ktoré je už v dosahu, a odteraz sleduje,
## či sa do dosahu niečo nedostane. CONNECT_DEFERRED: reagujeme až po dokončení posunu,
## nie uprostred neho (posun iného objektu môže spustiť ďalší posun).
func place_on_grid() -> void:
	super.place_on_grid()
	GridManager.object_entered_cell.connect(_on_object_entered_cell, CONNECT_DEFERRED)
	attract_in_range()


func _on_object_entered_cell(_obj: GridObject, _cell: Vector2i) -> void:
	attract_in_range()


## V každom smere nájde prvý objekt v dosahu. Ak je to obyčajné železo, pritiahne ho
## k sebe (posúva sa, kým nie je na susednom políčku alebo nenarazí; priepasť ho zastaví).
## Najviac (vzdialenosť - 1) krokov – to ho dovedie presne vedľa magnetu.
func attract_in_range() -> void:
	for direction: Vector2i in DIRECTIONS:
		var target: GridObject = GridManager.find_first_object(cell, direction, range_cells)
		if _is_plain_iron(target) and not _is_held_by_magnet(target):
			target.slide_until_blocked(-direction, GridManager.cell_distance(cell, target.cell) - 1)


## Obyčajné (nezmagnetizované) železo priťahujú OBA póly – tak ho spoznáme bez toho,
## aby sme riešili, ktorým pólom je magnet otočený. Bedne s pólom neťahá – v dosahu
## Magnetu ich podľa pravidiel návrhu levelov (CLAUDE.md) ani nesmie byť.
func _is_plain_iron(target: GridObject) -> bool:
	if not (target is Box or target is Item):
		return false
	return target.get_magnetic_force(Magnetism.Pole.S) == Magnetism.Force.ATTRACT \
		and target.get_magnetic_force(Magnetism.Pole.J) == Magnetism.Force.ATTRACT


## Železo, ktoré už prilieplo k nejakému magnetu, ostane tam. Bez tejto kontroly by si
## ho dva magnety mohli donekonečna preťahovať.
func _is_held_by_magnet(target: GridObject) -> bool:
	for direction: Vector2i in DIRECTIONS:
		if GridManager.get_object_at(target.cell + direction) is Magnet:
			return true
	return false
