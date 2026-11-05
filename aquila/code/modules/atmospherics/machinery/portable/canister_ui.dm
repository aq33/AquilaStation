/// AQUILA: okno kanistra w wyglądzie z Unitystation (grafiki CC BY-SA 3.0, aquila/icons/ui/canister/LICENSE.md)
/datum/asset/simple/aquila_canister
	assets = list(
		"us_canister_baseline_edit_white_18dp_313131.png" = 'aquila/icons/ui/canister/us_canister_baseline_edit_white_18dp_313131.png',
		"us_canister_bgpanelraised_32x32_cecece.png" = 'aquila/icons/ui/canister/us_canister_bgpanelraised_32x32_cecece.png',
		"us_canister_externaltankempty.png" = 'aquila/icons/ui/canister/us_canister_externaltankempty.png',
		"us_canister_externaltankinserted.png" = 'aquila/icons/ui/canister/us_canister_externaltankinserted.png',
		"us_canister_gascontainerbggrayscale.png" = 'aquila/icons/ui/canister/us_canister_gascontainerbggrayscale.png',
		"us_canister_gascontainerdirectionindicator.png" = 'aquila/icons/ui/canister/us_canister_gascontainerdirectionindicator.png',
		"us_canister_gascontainerfieldborder.png" = 'aquila/icons/ui/canister/us_canister_gascontainerfieldborder.png',
		"us_canister_gascontainerinnerbg_a3a3a3.png" = 'aquila/icons/ui/canister/us_canister_gascontainerinnerbg_a3a3a3.png',
		"us_canister_gascontainerinnerbg_ffebe5.png" = 'aquila/icons/ui/canister/us_canister_gascontainerinnerbg_ffebe5.png',
		"us_canister_gascontainerleverbottom.png" = 'aquila/icons/ui/canister/us_canister_gascontainerleverbottom.png',
		"us_canister_gascontainerlevertop.png" = 'aquila/icons/ui/canister/us_canister_gascontainerlevertop.png',
		"us_canister_gascontainerwheelbase.png" = 'aquila/icons/ui/canister/us_canister_gascontainerwheelbase.png',
		"us_canister_gascontainerwheelcenterbump.png" = 'aquila/icons/ui/canister/us_canister_gascontainerwheelcenterbump.png',
		"us_canister_gascontainerwheelcenterscrew.png" = 'aquila/icons/ui/canister/us_canister_gascontainerwheelcenterscrew.png',
		"us_canister_gascontainerwheelrimbump.png" = 'aquila/icons/ui/canister/us_canister_gascontainerwheelrimbump.png',
		"us_canister_squarebuttonv216x16.png" = 'aquila/icons/ui/canister/us_canister_squarebuttonv216x16.png',
	)

/obj/machinery/portable_atmospherics/canister/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/aquila_canister))

/// Kolor obudowy w oknie: pierwszy kolor z greyscale_colors kanistra
/obj/machinery/portable_atmospherics/canister/ui_data()
	. = ..()
	.["canisterColor"] = length(greyscale_colors) >= 7 ? copytext(greyscale_colors, 1, 8) : "#9aa1ad"
	.["canisterName"] = format_text(name)
