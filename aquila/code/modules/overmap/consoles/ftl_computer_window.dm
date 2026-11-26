/// AQUILA - okno starego komputera FTL (FTLComputer.tsx) w wyglądzie konsoli rozpoznania: stan napędu, rozkręcanie,
/// skok awaryjny, śledzone okręty i położenie okrętu na mapie hex. Skacze się z konsoli nawigacji (mapa hex, trasa,
/// koszt i chłodzenie skoku), więc tu nie ma wyboru celu. Akcje (toggle_power, emergency_jump) obsługuje ui_act z core.

/obj/machinery/computer/ship/ftl_computer/ui_data(mob/user)
	var/list/data = list()
	var/list/ships = list()
	for(var/X in tracking)
		ships += list(list(
			"name" = tracking[X]["name"],
			"current_system" = tracking[X]["current_system"],
			"target_system" = tracking[X]["target_system"],
		))
	data["ftl"] = list(
		"kind" = "legacy",
		"can_control" = TRUE,
		"name" = name,
		"powered" = active,
		"progress" = progress,
		"goal" = spoolup_time,
		"state" = ftl_state,
		"ready" = (ftl_state == FTL_STATE_READY),
		"allowed" = !!allowed(user),
		"await_emergency_ftl_confirm" = (await_emergency_ftl_confirm > world.time && linked?.ftl_safety_override),
		"tracking" = ships,
	)
	data["safety_override"] = !!linked?.ftl_safety_override
	data["position"] = ftl_position_data()
	return data

/// Położenie okrętu: układ, kafel i sektor mapy hex, a w trakcie skoku cel
/obj/machinery/computer/ship/ftl_computer/proc/ftl_position_data()
	var/list/position = list()
	var/datum/star_system/S = linked?.current_system
	position["system"] = S?.name
	var/datum/hex/H = S ? GLOB.hexmap?.hex_of_system(S) : null
	if(H)
		position["hex"] = H.display_name()
		position["sector"] = hex_sector_name(H.sector)
	var/list/info = linked ? SSstar_system.ships[linked] : null
	var/datum/star_system/target = info?["target_system"]
	if(target)
		position["target"] = target.name
	return position
