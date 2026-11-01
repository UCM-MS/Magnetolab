class_name LevelData
extends Resource
## Údaje o jednom leveli (resources/level_xx/level_xx.tres).
## Bádateľský postup: odhad (otázka v dialógu) -> pokus -> spätná väzba k tipu -> kartička.

@export var level_name: String = ""
## Predmet, ktorého prvé pritiahnutie je „pokusom“ – vtedy príde spätná väzba k tipu.
@export var guess_check_item: ItemData
## Spätná väzba podľa odpovede na otázku: index = číslo zvolenej možnosti (od 0).
@export var guess_feedback: Array[DialogPage] = []
## Kartička „Čo si zistil“ po otvorení dverí – len zhrnutie, bez hodnotenia tipu.
@export var info_card: DialogPage
