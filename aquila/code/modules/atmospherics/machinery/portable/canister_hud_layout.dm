// AQUILA: plik wygenerowany skryptem z prefabu TabCanister (Unitystation).
// Pozycje w pikselach HUD-u kanistra, lewy dolny róg, y w górę. Grafiki: aquila/icons/ui/canister_hud (CC BY-SA 3.0).

#define CANISTER_HUD_WIDTH 272
#define CANISTER_HUD_HEIGHT 453

/// Obrazki HUD-u: klucz, ikona, pozycja, rozmiar, warstwa i akcja strefy kliknięcia
/datum/canister_hud/proc/layout_images()
	return list(
		list("key" = "panel", "icon" = 'aquila/icons/ui/canister_hud/panel.png', "x" = 0, "y" = 0, "w" = 272, "h" = 453, "layer" = 1),
		list("key" = "body", "icon" = 'aquila/icons/ui/canister_hud/body.png', "x" = 0, "y" = 0, "w" = 272, "h" = 453, "layer" = 2),
		list("key" = "static", "icon" = 'aquila/icons/ui/canister_hud/static.png', "x" = 0, "y" = 0, "w" = 272, "h" = 453, "layer" = 3),
		list("key" = "wheel", "icon" = 'aquila/icons/ui/canister_hud/wheel.png', "x" = 74, "y" = 164, "w" = 202, "h" = 202, "layer" = 4),
		list("key" = "screw", "icon" = 'aquila/icons/ui/canister_hud/screw.png', "x" = 160, "y" = 250, "w" = 30, "h" = 30, "layer" = 5),
		list("key" = "lever_main", "icon" = 'aquila/icons/ui/canister_hud/lever_main.png', "x" = -27, "y" = 192, "w" = 126, "h" = 126, "layer" = 6),
		list("key" = "lever_tank", "icon" = 'aquila/icons/ui/canister_hud/lever_tank.png', "x" = -15, "y" = 57, "w" = 124, "h" = 124, "layer" = 6),
		list("key" = "led_red", "icon" = 'aquila/icons/ui/canister_hud/led_red.png', "x" = 96, "y" = 409, "w" = 26, "h" = 36, "layer" = 7),
		list("key" = "led_yellow", "icon" = 'aquila/icons/ui/canister_hud/led_yellow.png', "x" = 122, "y" = 409, "w" = 25, "h" = 36, "layer" = 7),
		list("key" = "led_green", "icon" = 'aquila/icons/ui/canister_hud/led_green.png', "x" = 147, "y" = 409, "w" = 26, "h" = 36, "layer" = 7),
		list("key" = "tank_empty", "icon" = 'aquila/icons/ui/canister_hud/tank_empty.png', "x" = 149, "y" = 65, "w" = 57, "h" = 59, "layer" = 7),
		list("key" = "tank_inserted", "icon" = 'aquila/icons/ui/canister_hud/tank_inserted.png', "x" = 149, "y" = 65, "w" = 57, "h" = 59, "layer" = 7),
		list("key" = "close", "icon" = 'aquila/icons/ui/canister_hud/close.png', "x" = 253, "y" = 434, "w" = 15, "h" = 15, "layer" = 8),
		list("key" = "hit_valve", "icon" = 'aquila/icons/ui/canister_hud/hit_valve.png', "x" = 1, "y" = 194, "w" = 71, "h" = 71, "layer" = 10, "hit" = "valve"),
		list("key" = "hit_tankvalve", "icon" = 'aquila/icons/ui/canister_hud/hit_tankvalve.png', "x" = 12, "y" = 59, "w" = 71, "h" = 70, "layer" = 10, "hit" = "tankvalve"),
		list("key" = "hit_wheel", "icon" = 'aquila/icons/ui/canister_hud/hit_wheel.png', "x" = 103, "y" = 192, "w" = 144, "h" = 145, "layer" = 10, "hit" = "wheel"),
		list("key" = "hit_minus", "icon" = 'aquila/icons/ui/canister_hud/hit_minus.png', "x" = 24, "y" = 292, "w" = 19, "h" = 20, "layer" = 10, "hit" = "minus"),
		list("key" = "hit_plus", "icon" = 'aquila/icons/ui/canister_hud/hit_plus.png', "x" = 74, "y" = 293, "w" = 19, "h" = 19, "layer" = 10, "hit" = "plus"),
		list("key" = "hit_edit", "icon" = 'aquila/icons/ui/canister_hud/hit_edit.png', "x" = 47, "y" = 304, "w" = 24, "h" = 22, "layer" = 10, "hit" = "edit"),
		list("key" = "hit_eject", "icon" = 'aquila/icons/ui/canister_hud/hit_eject.png', "x" = 146, "y" = 46, "w" = 64, "h" = 15, "layer" = 10, "hit" = "eject"),
		list("key" = "hit_tank", "icon" = 'aquila/icons/ui/canister_hud/hit_tank.png', "x" = 146, "y" = 64, "w" = 63, "h" = 61, "layer" = 10, "hit" = "tank"),
		list("key" = "hit_label", "icon" = 'aquila/icons/ui/canister_hud/hit_label.png', "x" = 147, "y" = 375, "w" = 103, "h" = 13, "layer" = 10, "hit" = "label"),
		list("key" = "hit_close", "icon" = 'aquila/icons/ui/canister_hud/hit_close.png', "x" = 253, "y" = 434, "w" = 15, "h" = 15, "layer" = 10, "hit" = "close")
	)

/// Napisy HUD-u: klucz obiektu z prefabu, pudełko, rozmiar czcionki, wyrównanie (0 lewo, 1 środek, 2 prawo), kolor, tekst z prefabu
/datum/canister_hud/proc/layout_texts()
	return list(
		list("key" = "Internal", "x" = 25, "y" = 372, "w" = 120, "h" = 13, "size" = 7.6, "align" = 0, "color" = "#3e454c"),
		list("key" = "Internal/ConnectionStatus/ConnectionStatusText", "x" = 162, "y" = 353, "w" = 85, "h" = 11, "size" = 6.3, "align" = 1, "color" = "#313131"),
		list("key" = "Internal/internalkPA/releasekPa", "x" = 127, "y" = 350, "w" = 25, "h" = 8, "size" = 7.6, "align" = 0, "color" = "#3e454c"),
		list("key" = "Internal/internalkPA/InternalPressure/1/center", "x" = 107, "y" = 350, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "Internal/internalkPA/InternalPressure/10/center", "x" = 92, "y" = 350, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "Internal/internalkPA/InternalPressure/100/center", "x" = 76, "y" = 350, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "Internal/internalkPA/InternalPressure/1000/center", "x" = 60, "y" = 350, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "Internal/internalkPA/InternalPressure/10k/center", "x" = 43, "y" = 350, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "Internal/internalkPA/InternalPressure/100k/center", "x" = 27, "y" = 350, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ExternalTank/SecondaryLeverGrouping/Valve", "x" = 43, "y" = 46, "w" = 77, "h" = 11, "size" = 7.6, "align" = 0, "color" = "#3e454c"),
		list("key" = "ExternalTank/SecondaryLeverGrouping/Tank", "x" = 45, "y" = 130, "w" = 69, "h" = 11, "size" = 7.6, "align" = 0, "color" = "#3e454c"),
		list("key" = "ExternalTank/TankStatusGroup/TankStatusText", "x" = 44, "y" = 150, "w" = 178, "h" = 14, "size" = 5.0, "align" = 1, "color" = "#313131"),
		list("key" = "ExternalTank/eject/Text", "x" = 146, "y" = 46, "w" = 64, "h" = 15, "size" = 8.5, "align" = 1, "color" = "#303030"),
		list("key" = "ExternalTank/externalkPA/releasekPa", "x" = 231, "y" = 129, "w" = 25, "h" = 8, "size" = 7.6, "align" = 0, "color" = "#3e454c"),
		list("key" = "ExternalTank/externalkPA/ExternalPressure/1/center", "x" = 210, "y" = 128, "w" = 16, "h" = 16, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ExternalTank/externalkPA/ExternalPressure/10/center", "x" = 195, "y" = 128, "w" = 15, "h" = 16, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ExternalTank/externalkPA/ExternalPressure/100/center", "x" = 179, "y" = 128, "w" = 15, "h" = 16, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ExternalTank/externalkPA/ExternalPressure/1000/center", "x" = 163, "y" = 128, "w" = 15, "h" = 16, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ExternalTank/externalkPA/ExternalPressure/10k/center", "x" = 146, "y" = 128, "w" = 15, "h" = 16, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ExternalTank/externalkPA/ExternalPressure/100k/center", "x" = 130, "y" = 128, "w" = 15, "h" = 16, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ReleaseValve", "x" = 25, "y" = 335, "w" = 120, "h" = 12, "size" = 7.6, "align" = 0, "color" = "#3e454c"),
		list("key" = "ReleaseValve/releasekPA/releasekPa", "x" = 94, "y" = 315, "w" = 25, "h" = 8, "size" = 7.6, "align" = 0, "color" = "#3e454c"),
		list("key" = "ReleaseValve/releasekPA/ReleasePressure/1/center", "x" = 75, "y" = 316, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ReleaseValve/releasekPA/ReleasePressure/10/center", "x" = 60, "y" = 316, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ReleaseValve/releasekPA/ReleasePressure/100/center", "x" = 44, "y" = 316, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ReleaseValve/releasekPA/ReleasePressure/1000/center", "x" = 28, "y" = 316, "w" = 15, "h" = 15, "size" = 10.1, "align" = 1, "color" = "#313131"),
		list("key" = "ReleaseValve/minus/Text", "x" = 24, "y" = 292, "w" = 19, "h" = 20, "size" = 8.5, "align" = 1, "color" = "#303030"),
		list("key" = "ReleaseValve/plus/Text", "x" = 74, "y" = 293, "w" = 19, "h" = 19, "size" = 8.5, "align" = 1, "color" = "#303030"),
		list("key" = "ReleaseValve/WheelGrouping/Closed (1)", "x" = 243, "y" = 235, "w" = 14, "h" = 10, "size" = 7.6, "align" = 1, "color" = "#3e454c"),
		list("key" = "ReleaseValve/WheelGrouping/Closed (2)", "x" = 96, "y" = 231, "w" = 14, "h" = 11, "size" = 7.6, "align" = 1, "color" = "#3e454c"),
		list("key" = "ReleaseValve/MainLeverGrouping/Open", "x" = 48, "y" = 266, "w" = 43, "h" = 8, "size" = 7.6, "align" = 0, "color" = "#3e454c"),
		list("key" = "ReleaseValve/MainLeverGrouping/Closed", "x" = 47, "y" = 200, "w" = 50, "h" = 8, "size" = 7.6, "align" = 0, "color" = "#3e454c"),
		list("key" = "LabelFrame/PropertyText", "x" = 149, "y" = 379, "w" = 99, "h" = 6, "size" = 5.7, "align" = 1, "color" = "#303030"),
		list("key" = "CloseWindowButton/Text", "x" = 253, "y" = 434, "w" = 19, "h" = 20, "size" = 11.0, "align" = 1, "color" = "#313131")
	)
