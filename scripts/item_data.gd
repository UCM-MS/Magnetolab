class_name ItemData
extends Resource
## Údaje o druhu malého predmetu (kľúč, minca, kocka...). Jeden .tres na druh predmetu.

## Meno, ktoré sa ukáže v HUD („V rukavici: …“).
@export var display_name: String = ""
@export var material_type: Magnetism.MaterialType = Magnetism.MaterialType.IRON
## Dá sa ním odomknúť dvere?
@export var is_key: bool = false
## Obrázok predmetu na zemi aj v HUD.
@export var icon: Texture2D
