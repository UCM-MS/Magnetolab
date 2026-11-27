class_name LevelData
extends Resource
## Údaje o jednom leveli (resources/level_xx/level_xx.tres).
## Bádateľský postup: odhad (otázka v dialógu) -> pokus -> spätná väzba k tipu -> kartička.

## Čo je v leveli „pokusom“, po ktorom príde spätná väzba k tipu.
## Nové udalosti pridávaj na koniec (.tres si pamätá číslo).
enum GuessCheck {
	ITEM_PULLED, ## prvé pritiahnutie predmetu guess_check_item (A1)
	BOX_ON_PLATE, ## bedňa prvýkrát dorazí na tlačidlo (A2)
}

@export var level_name: String = ""
## Miestnosť, ktorá sa odomkne po dokončení tejto (napr. "A2"); prázdne = žiadna.
@export var next_level_id: String = ""
@export var guess_check: GuessCheck = GuessCheck.ITEM_PULLED
## Pri ITEM_PULLED: predmet, ktorého prvé pritiahnutie je pokusom.
@export var guess_check_item: ItemData
## Spätná väzba podľa odpovede na otázku: index = číslo zvolenej možnosti (od 0).
@export var guess_feedback: Array[DialogPage] = []
## Reakcie Magnetóna, keď rukavica zasiahne nemagnetický materiál (materiál -> dialóg).
## Každá sa v miestnosti ukáže len prvýkrát. Materiál bez textu = bez reakcie.
@export var material_reactions: Dictionary[Magnetism.MaterialType, DialogData] = {}
## Dialóg pri prvom zatvorení mreže (v A2 s otázkou „odhadni“). Prázdne = bez dialógu.
@export var gate_closed_dialog: DialogData
## Kartička „Čo si zistil“ po otvorení dverí – len zhrnutie, bez hodnotenia tipu.
@export var info_card: DialogPage
