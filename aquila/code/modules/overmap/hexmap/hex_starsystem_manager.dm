/// AQUILA - admiński menedżer układów na mapie hex (HexStarmap.tsx w trybie „admin”). Mapę i zaznaczenie liczy ukryta
/// konsola nawigacji podpięta pod okręt gracza (te same dane co w nawigacji, bez sterowania), a panel boczny pokazuje
/// floty i obiekty układu na zaznaczonym kaflu z akcjami z core (nsv13/code/datums/starsystem_manager.dm: fleetAct,
/// objectAct, createFleet, createObject, hideSystem, systemVV).

/// Konsola tylko do liczenia danych mapy dla menedżera układów (nie stoi na mapie, nie steruje okrętem)
/obj/machinery/computer/ship/navigation/admin_view
	name = "widok admina mapy hex"
	can_control_ship = FALSE

// Okręt podpina menedżer (get_hex_view), konsola w nullspace sama by go nie znalazła
/obj/machinery/computer/ship/navigation/admin_view/LateInitialize()
	return

/obj/machinery/computer/ship/navigation/admin_view/has_overmap()
	return linked

/datum/starsystem_manager
	/// Ukryta konsola, która liczy dane mapy hex
	var/obj/machinery/computer/ship/navigation/admin_view/hex_view

/datum/starsystem_manager/Destroy()
	QDEL_NULL(hex_view)
	return ..()

/// Konsola widoku podpięta pod okręt gracza; null bez mapy hex albo okrętu
/datum/starsystem_manager/proc/get_hex_view()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!GLOB.hexmap?.built || !main)
		return null
	if(QDELETED(hex_view))
		hex_view = new
	hex_view.linked = main
	if(!hex_view.hex_selected)
		hex_view.hex_selected = main.current_hex()
	return hex_view

/datum/starsystem_manager/ui_interact(mob/user, datum/tgui/ui)
	if(!get_hex_view())
		return ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HexStarmap")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/starsystem_manager/ui_static_data(mob/user)
	var/obj/machinery/computer/ship/navigation/admin_view/view = get_hex_view()
	return view ? view.ui_static_data(user) : ..()

/datum/starsystem_manager/ui_data(mob/user)
	var/obj/machinery/computer/ship/navigation/admin_view/view = get_hex_view()
	if(!view)
		return ..()
	var/list/data = view.hex_build_ui_data()
	data["mode"] = "admin"
	data["admin"] = admin_hex_system_data(view.hex_selected?.system)
	return data

/datum/starsystem_manager/ui_act(action, params)
	if(action == "hex_select")
		var/obj/machinery/computer/ship/navigation/admin_view/view = get_hex_view()
		var/datum/hex/H = GLOB.hexmap?.hex_by_id(params["hex"])
		if(view && H)
			view.hex_selected = H
		return TRUE
	if(action in list("hex_jump", "hex_cancel", "hex_nuke", "hex_chip_bonus"))
		return TRUE
	return ..()

/// Floty i obiekty układu na zaznaczonym kaflu, w formacie akcji core (identyfikatory \ref)
/datum/starsystem_manager/proc/admin_hex_system_data(datum/star_system/S)
	if(!S)
		return null
	var/list/fleets = list()
	for(var/datum/fleet/F in S.fleets)
		fleets += list(list("name" = F.name, "id" = "\ref[F]", "alignment" = F.alignment))
	var/list/objects = list()
	for(var/obj/object in S.system_contents)
		var/obj/structure/overmap/OM = object
		if(istype(OM) && OM.fleet)
			continue
		objects += list(list("name" = object.name, "id" = "\ref[object]", "faction" = istype(OM) ? OM.faction : null))
	return list(
		"name" = S.name,
		"sys_id" = "\ref[S]",
		"hidden" = !!S.hidden,
		"alignment" = S.alignment,
		"empty_hex" = istype(S, /datum/star_system/random/hex_empty),
		"fleets" = fleets,
		"objects" = objects,
	)
