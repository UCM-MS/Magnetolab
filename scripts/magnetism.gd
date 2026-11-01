class_name Magnetism
extends RefCounted
## Fyzikálne pravidlá magnetizmu na JEDNOM mieste.
## Rukavica ani bedne o fyzike nerozhodujú samy – pýtajú sa funkcie force().

## Magnetické póly. S = severný, J = južný. NONE = objekt nie je magnet.
enum Pole { NONE, S, J }

## Materiály objektov. Nové pridávaj len na koniec (scény si pamätajú číslo).
enum MaterialType { IRON, WOOD, ALUMINIUM, COPPER, PLASTIC }

## Výsledok pôsobenia magnetu na objekt.
enum Force { NONE, ATTRACT, REPEL }

## Farby pólov (dohodnutá konvencia: severný červený, južný modrý).
const POLE_COLORS: Dictionary[Pole, Color] = {
	Pole.NONE: Color(0.55, 0.55, 0.55),
	Pole.S: Color(0.9, 0.2, 0.2),
	Pole.J: Color(0.2, 0.4, 0.95),
}


## Na magnet reaguje len železo (oceľ). Drevo, plast, hliník ani meď nie.
static func is_magnetic(material: MaterialType) -> bool:
	return material == MaterialType.IRON


## Ako pôsobí magnet s pólom magnet_pole na objekt z daného materiálu s daným pólom.
static func force(magnet_pole: Pole, material: MaterialType, object_pole: Pole) -> Force:
	if magnet_pole == Pole.NONE or not is_magnetic(material):
		return Force.NONE
	# Obyčajné (nezmagnetizované) železo priťahujú OBA póly, nikdy sa neodpudzuje.
	if object_pole == Pole.NONE:
		return Force.ATTRACT
	# Permanentný magnet: opačné póly sa priťahujú, rovnaké odpudzujú.
	if object_pole != magnet_pole:
		return Force.ATTRACT
	return Force.REPEL
