class_name DialogData
extends Resource
## Dialóg = niekoľko strán, ktoré sa ukážu po sebe (napr. otázka a potom nápoveda).

@export var pages: Array[DialogPage] = []


## Dialóg z jedinej strany (napr. kartička alebo spätná väzba uložená v LevelData).
static func from_page(page: DialogPage) -> DialogData:
	var dialog := DialogData.new()
	dialog.pages.append(page)
	return dialog
