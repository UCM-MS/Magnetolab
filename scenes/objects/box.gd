class_name Box
extends GridObject
## Bedňa. Rukou sa dá tlačiť len drevená (o 1 políčko). Kovové sú príliš ťažké:
## železné a magnetické hýbe len rukavica, hliníkové a medené sa nepohnú vôbec.

## Dočasné farby podľa materiálu (kým grafici nedodajú sprity).
const MATERIAL_COLORS: Dictionary[Magnetism.MaterialType, Color] = {
	Magnetism.MaterialType.IRON: Color(0.45, 0.49, 0.54),
	Magnetism.MaterialType.WOOD: Color(0.62, 0.42, 0.22),
	Magnetism.MaterialType.ALUMINIUM: Color(0.85, 0.88, 0.93),
	Magnetism.MaterialType.COPPER: Color(0.82, 0.46, 0.26),
	Magnetism.MaterialType.PLASTIC: Color(0.55, 0.8, 0.9),
}
## O koľko svetlejšie/tmavšie sú steny kocky oproti základnej farbe.
const SHADE_AMOUNT: float = 0.2

@export var material_type: Magnetism.MaterialType = Magnetism.MaterialType.IRON
## Pól, ktorý bedňa ukazuje k hráčovi. NONE = obyčajná bedňa, S/J = permanentný magnet.
@export var pole: Magnetism.Pole = Magnetism.Pole.NONE


func _ready() -> void:
	super._ready()
	if pole != Magnetism.Pole.NONE and not Magnetism.is_magnetic(material_type):
		push_warning("%s: permanentný magnet musí byť zo železa, pól sa ignoruje." % name)
		pole = Magnetism.Pole.NONE
	_update_look()


## Rukou sa dá tlačiť len drevená bedňa – kovové sú príliš ťažké.
func can_be_pushed() -> bool:
	return material_type == Magnetism.MaterialType.WOOD


## Ako na bedňu pôsobí magnet s daným pólom (rozhoduje Magnetism).
func get_magnetic_force(magnet_pole: Magnetism.Pole) -> Magnetism.Force:
	return Magnetism.force(magnet_pole, material_type, pole)


## Prefarbí kocku podľa materiálu a zobrazí značku pólu.
func _update_look() -> void:
	var base: Color = MATERIAL_COLORS[material_type]
	$Top.color = base.lightened(SHADE_AMOUNT)
	$Left.color = base
	$Right.color = base.darkened(SHADE_AMOUNT)
	$PoleMark.visible = pole != Magnetism.Pole.NONE
	$PoleMark.color = Magnetism.POLE_COLORS[pole]
	$PoleMark/Letter.text = "S" if pole == Magnetism.Pole.S else "J"
