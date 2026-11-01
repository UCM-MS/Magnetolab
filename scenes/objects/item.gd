class_name Item
extends GridObject
## Malý predmet na zemi (kľúč, minca, kocka...). Kým leží, zaberá políčko ako bedňa.
## Železný predmet rukavica pritiahne – preletí (aj ponad priepasť) k hráčovi do inventára.

## Ako dlho trvá prelet predmetu k hráčovi (sekundy).
const FLY_DURATION: float = 0.35

@export var data: ItemData


func _ready() -> void:
	super._ready()
	$Sprite2D.texture = data.icon


## Ako na predmet pôsobí magnet (rozhoduje Magnetism; malé predmety nemajú póly).
func get_magnetic_force(magnet_pole: Magnetism.Pole) -> Magnetism.Force:
	return Magnetism.force(magnet_pole, data.material_type, Magnetism.Pole.NONE)


## Predmet opustí mriežku a preletí na pozíciu `target`. Letí priamo, nie po políčkach –
## preto mu priepasť nevadí. Vráti Tween, aby volajúci vedel, kedy prelet skončil.
func fly_to(target: Vector2) -> Tween:
	GridManager.unregister_object(self)
	$Shadow.visible = false
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "global_position", target, FLY_DURATION)
	return _move_tween
