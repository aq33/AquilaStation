/// AQUILA - astrometria na mapie hex (HexStarmap.tsx w trybie „astro”). Zaznaczasz kafel i widzisz jego układ i anomalie;
/// układ w zasięgu ASTROMETRICS_HEX_RANGE kafli (w tym samym sektorze) da się zeskanować, a po skanie układu jego
/// anomalie. Skan, anulowanie, informacje i transmisja na kanale nauki działają jak w core
/// (nsv13/code/modules/research/astrometrics.dm), który dostaje wybrany układ przez selected_system.
/// Konsola nie skacze: can_control_ship = FALSE blokuje akcje napędu mapy hex.

#define ASTROMETRICS_HEX_RANGE 3

/obj/machinery/computer/ship/navigation/astrometrics
	can_control_ship = FALSE

/obj/machinery/computer/ship/navigation/astrometrics/ui_interact(mob/user, datum/tgui/ui)
	if(!linked || !uses_hex_map())
		return ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(!hex_selected)
			hex_selected = linked.current_hex()
			sync_astrometrics_selection()
		ui = new(user, src, "HexStarmap")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/navigation/astrometrics/ui_data(mob/user)
	if(!uses_hex_map() || !has_overmap())
		return ..()
	var/list/data = hex_build_ui_data()
	data["mode"] = "astro"
	data["astro"] = astrometrics_hex_data()
	return data

/obj/machinery/computer/ship/navigation/astrometrics/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(action == "hex_select" && uses_hex_map())
		sync_astrometrics_selection()

/// Układ zaznaczonego kafla do skanu; pusty kafel i ukryty układ nie mają czego skanować
/obj/machinery/computer/ship/navigation/astrometrics/proc/sync_astrometrics_selection()
	var/datum/star_system/S = hex_selected?.system
	if(!S || S.hidden || istype(S, /datum/star_system/random/hex_empty))
		S = null
	selected_system = S
	screen = S ? 2 : 1

/obj/machinery/computer/ship/navigation/astrometrics/is_in_range(datum/star_system/current_system, datum/star_system/system)
	if(!GLOB.hexmap?.built)
		return ..()
	var/datum/hex/here = current_system ? GLOB.hexmap.hex_of_system(current_system) : null
	var/datum/hex/there = system ? GLOB.hexmap.hex_of_system(system) : null
	return here && there && GLOB.hexmap.distance(here, there) <= ASTROMETRICS_HEX_RANGE

/// Panel astrometrii w oknie mapy hex
/obj/machinery/computer/ship/navigation/astrometrics/proc/astrometrics_hex_data()
	var/list/out = list(
		"range" = ASTROMETRICS_HEX_RANGE,
		"scan_target" = scan_target ? "[scan_target]" : null,
		"scan_progress" = scan_progress,
		"scan_goal" = scan_goal,
		"can_cancel" = !!scan_target,
		"broadcast" = broadcast,
	)
	var/datum/star_system/S = selected_system
	if(!S)
		return out
	var/datum/hex/here = linked.current_hex()
	var/datum/hex/there = GLOB.hexmap.hex_of_system(S)
	var/distance = (here && there) ? GLOB.hexmap.distance(here, there) : INFINITY
	var/scanned = !!is_visited(S)
	out["system"] = list(
		"name" = S.name,
		"alignment" = capitalize(S.alignment),
		"scanned" = scanned,
		"type" = scanned ? S.system_type?["label"] : null,
		"distance" = distance == INFINITY ? -1 : distance,
		"can_scan" = !!is_in_range(linked.current_system, S),
		"anomalies" = scanned ? S.get_info() : list(),
	)
	return out

#undef ASTROMETRICS_HEX_RANGE
