class_name DialogPage
extends Resource
## Jedna strana dialógu: buď obyčajný text, alebo otázka s možnosťami.

## Nadpis nad textom (napr. „Odhadni“, „Čo si zistil“). Prázdny = bez nadpisu.
@export var title: String = ""
@export_multiline var text: String = ""
## Výraz hovoriacej postavy na portréte.
@export var mood: SpeakerData.Mood = SpeakerData.Mood.NEUTRAL
## Možnosti odpovede. Prázdne = obyčajná strana (pokračuje sa klávesom E / Enter).
@export var options: PackedStringArray = []
## Index správnej možnosti (od 0). Pri obyčajnej strane sa nepoužíva.
@export var correct_option: int = -1


func is_question() -> bool:
	return not options.is_empty()
