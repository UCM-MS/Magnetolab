class_name Box
extends GridObject
## Bedňa. Rukou sa dá tlačiť len drevená (o 1 políčko). Kovové sú príliš ťažké:
## železné a magnetické hýbe len rukavica, hliníkové, medené a zlaté sa nepohnú vôbec.

## Dočasné farby podľa materiálu (kým grafici nedodajú sprity).
const MATERIAL_COLORS: Dictionary[Magnetism.MaterialType, Color] = {
	Magnetism.MaterialType.IRON: Color(0.45, 0.49, 0.54),
	Magnetism.MaterialType.WOOD: Color(0.62, 0.42, 0.22),
	Magnetism.MaterialType.ALUMINIUM: Color(0.85, 0.88, 0.93),
	Magnetism.MaterialType.COPPER: Color(0.82, 0.46, 0.26),
	Magnetism.MaterialType.PLASTIC: Color(0.55, 0.8, 0.9),
	Magnetism.MaterialType.GOLD: Color("#e8c547"), # jasne žltá, aby sa nepomýlila s meďou
}
## Obrázky od grafikov. Materiál, ktorý tu nie je (hliník, meď...), sa kreslí polygónmi.
## Stred políčka je v obrázku 64x64 na (32, 48), preto má Sprite2D v box.tscn offset (0, -16).
const MATERIAL_TEXTURES: Dictionary[Magnetism.MaterialType, Texture2D] = {
	Magnetism.MaterialType.WOOD: preload("res://art/objects/box_wood.png"),
	Magnetism.MaterialType.IRON: preload("res://art/objects/box_iron.png"),
}
## O koľko svetlejšie/tmavšie sú steny kocky oproti základnej farbe.
const SHADE_AMOUNT: float = 0.2
## Výška vrchu kocky nad stredom políčka (px) = o koľko bedňa v jame klesne, aby bol
## jej vrch zarovno s podlahou. Obrázok od grafikov má kocku vyššiu než dočasné polygóny
## (polygón Top v box.tscn má stred na y = -24).
const SPRITE_TOP_HEIGHT: float = 32.0
const POLYGON_TOP_HEIGHT: float = 24.0
## Malá kocka = bedňa zmenšená na polovicu. Polygóny sa zmenšia okolo stredu políčka (0, 0),
## takže kocka stojí na strede políčka.
const SMALL_SCALE: float = 0.5

@export var material_type: Magnetism.MaterialType = Magnetism.MaterialType.IRON
## Pól, ktorý bedňa ukazuje k hráčovi. NONE = obyčajná bedňa, S/J = permanentný magnet.
@export var pole: Magnetism.Pole = Magnetism.Pole.NONE
## Malá kocka: menší vzhľad, inak sa správa ako bedňa (padá do jamy, stláča tlačidlo,
## kovová sa rukou nedá tlačiť).
@export var is_small: bool = false


func _ready() -> void:
	super._ready()
	if pole != Magnetism.Pole.NONE and not Magnetism.is_magnetic(material_type):
		push_warning("%s: permanentný magnet musí byť zo železa, pól sa ignoruje." % name)
		pole = Magnetism.Pole.NONE
	_update_look()


## Rukou sa dá tlačiť len drevená bedňa – kovové sú príliš ťažké.
func can_be_pushed() -> bool:
	return material_type == Magnetism.MaterialType.WOOD


## Bedňa, ktorá sa posunie na priepasť (rukavicou, magnetom aj rukou), do nej spadne
## a vyplní ju – vznikne z nej podlaha (most).
func can_fall_into_abyss() -> bool:
	return true


## Bedňa v jame klesne o celú svoju výšku – podľa toho, či sa kreslí obrázok alebo polygóny
## (malá kocka je nižšia, preto klesne menej).
func get_fall_depth() -> float:
	if $Sprite2D.visible:
		return SPRITE_TOP_HEIGHT
	return POLYGON_TOP_HEIGHT * _get_look_scale()


## Zmenšenie vzhľadu: malá kocka je polovičná, bedňa v plnej veľkosti.
func _get_look_scale() -> float:
	return SMALL_SCALE if is_small else 1.0


## Ako na bedňu pôsobí magnet s daným pólom (rozhoduje Magnetism).
func get_magnetic_force(magnet_pole: Magnetism.Pole) -> Magnetism.Force:
	return Magnetism.force(magnet_pole, material_type, pole)


## Nastaví vzhľad bedne: obrázok, ak ho materiál má a bedňa nemá pól ani nie je malá,
## inak prefarbené polygóny (malá kocka zmenšené). Zobrazí aj značku pólu.
func _update_look() -> void:
	var texture: Texture2D = MATERIAL_TEXTURES.get(material_type)
	# Obrázok malej kocky zatiaľ nie je – kreslí sa polygónmi.
	var use_sprite: bool = texture != null and pole == Magnetism.Pole.NONE and not is_small
	$Sprite2D.texture = texture
	$Sprite2D.visible = use_sprite
	var look_scale: Vector2 = Vector2.ONE * _get_look_scale()
	for face: Polygon2D in [$Left, $Right, $Top, $PoleMark]:
		face.scale = look_scale
	for face: Polygon2D in [$Left, $Right, $Top]:
		face.visible = not use_sprite

	var base: Color = MATERIAL_COLORS[material_type]
	$Top.color = base.lightened(SHADE_AMOUNT)
	$Left.color = base
	$Right.color = base.darkened(SHADE_AMOUNT)
	$PoleMark.visible = pole != Magnetism.Pole.NONE
	$PoleMark.color = Magnetism.POLE_COLORS[pole]
	$PoleMark/Letter.text = "S" if pole == Magnetism.Pole.S else "J"
