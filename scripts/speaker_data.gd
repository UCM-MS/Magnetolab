class_name SpeakerData
extends Resource
## Postava, ktorá hovorí v dialógovom okne: meno a portréty podľa výrazu.

## Výraz tváre na portréte. Nové pridávaj len na koniec (súbory si pamätajú číslo).
enum Mood { NEUTRAL, HAPPY, SURPRISED }

@export var display_name: String = ""
@export var portrait_neutral: Texture2D
@export var portrait_happy: Texture2D
@export var portrait_surprised: Texture2D


func get_portrait(mood: Mood) -> Texture2D:
	match mood:
		Mood.HAPPY:
			return portrait_happy
		Mood.SURPRISED:
			return portrait_surprised
	return portrait_neutral
