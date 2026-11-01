class_name InfoCardData
extends Resource
## Koniec miestnosti: spätná väzba k tipu hráča a kartička „Čo si zistil“.
## Všetko povie profesor Magnetón cez dialógové okno.

## Spätná väzba podľa toho, či Kubo na začiatku tipoval správne.
@export var guess_correct: DialogPage
@export var guess_wrong: DialogPage
## Samotná kartička (nadpis „Čo si zistil“ a zhrnutie).
@export var card: DialogPage


## Poskladá dialóg na koniec miestnosti: najprv spätná väzba (ak hráč tipoval), potom kartička.
func build_dialog(has_guess: bool, guess_was_correct: bool) -> DialogData:
	var dialog := DialogData.new()
	if has_guess:
		dialog.pages.append(guess_correct if guess_was_correct else guess_wrong)
	dialog.pages.append(card)
	return dialog
