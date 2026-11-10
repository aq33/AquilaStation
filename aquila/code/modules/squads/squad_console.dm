// Konsola drużyn XO (i program na tablecie): cztery kolumny drużyn, przydział załogi, funkcje,
// stan i sprzęt członków, rozkazy na ekran, znaczniki z mapy taktycznej, kamera pancerza (tylko konsola).

/// Załoga bez drużyny (żywi ludzie z przydzielonym zawodem)
/proc/aq_unassigned_crew_data()
	. = list()
	for(var/mob/living/carbon/human/crew in GLOB.alive_mob_list)
		if(crew.squad || !crew.mind?.assigned_role || !crew.ckey)
			continue
		. += list(list(
			"ref" = REF(crew),
			"name" = crew.real_name,
			"job" = crew.mind.assigned_role,
		))

/proc/aq_squad_loans_data()
	. = list()
	for(var/datum/squad_loan/loan as anything in GLOB.squad_loans)
		. += list(list(
			"name" = loan.owner_name,
			"squad" = loan.squad_name,
			"kit" = loan.kit_name,
			"missing" = loan.outstanding_names(),
			"minutes" = round((world.time - loan.issued_at) / (1 MINUTES)),
			"lost" = !loan.owner,
			"ref" = REF(loan),
			"reported" = loan.aq_reported,
		))

/// Wspólne dane okna konsoli i programu
/proc/aq_squad_console_data(mob/user, selected_z, has_camera, datum/aq_squad_bodycam/bodycam)
	var/list/data = list()
	var/list/squads_data = list()
	var/list/levels = list()
	for(var/datum/squad/squad as anything in GLOB.squad_manager.squads)
		squads_data += list(squad.aq_squad_data())
		levels |= squad.aq_active_levels()
	data["squads"] = squads_data
	data["unassigned"] = aq_unassigned_crew_data()
	data["loans"] = aq_squad_loans_data()
	data["positions"] = list(
		list("id" = SQUAD_POSITION_SOLDIER, "name" = squad_position_pl(SQUAD_POSITION_SOLDIER)),
		list("id" = SQUAD_POSITION_MEDIC, "name" = squad_position_pl(SQUAD_POSITION_MEDIC)),
		list("id" = SQUAD_POSITION_ENGINEER, "name" = squad_position_pl(SQUAD_POSITION_ENGINEER)),
	)
	data["marker_types"] = aq_marker_types_data()
	data["map"] = aq_squad_map_data(user, selected_z, levels)
	data["has_camera"] = has_camera
	data["camera_target"] = bodycam?.target ? list("ref" = REF(bodycam.target), "name" = bodycam.target.real_name, "active" = bodycam.target.aq_has_squad_bodycam()) : null
	data["map_ref"] = bodycam?.map_name
	var/mob/living/living_user = user
	data["order_cooldown"] = istype(living_user) ? round(max(0, living_user.aq_next_squad_order - world.time) / 10) : 0
	return data

/// Wspólna obsługa akcji; zwraca TRUE, gdy coś się zmieniło. state to lista stanu okna (wybrany poziom mapy, odstęp drukowania).
/proc/aq_squad_console_act(action, list/params, mob/living/user, atom/source, datum/aq_squad_bodycam/bodycam, list/state)
	var/datum/squad/squad = locate(params["squad_id"]) in GLOB.squad_manager.squads
	var/mob/living/carbon/human/member = locate(params["ref"])
	if(member && !istype(member))
		member = null
	// Przedrostek aq_ tam, gdzie stary ui_act konsoli z NSV13 (wołany przez ..()) ma akcję o tej samej nazwie:
	// inaczej obie wersje wykonują się po kolei, a przełącznik wraca do stanu sprzed kliknięcia
	switch(action)
		if("select_z")
			state["z"] = text2num(params["z"])
			return TRUE
		if("assign")
			if(!member || !squad)
				return FALSE
			if(member.squad == squad)
				return FALSE
			log_game("[key_name(user)] assigned [key_name(member)] to squad [squad]")
			if(member.squad)
				member.squad.remove_member(member)
			if(params["position"] in SQUAD_POSITIONS)
				member.squad_position = params["position"]
			squad.add_member(member)
			return TRUE
		if("unassign")
			if(!member?.squad)
				return FALSE
			log_game("[key_name(user)] removed [key_name(member)] from squad [member.squad]")
			to_chat(member, "<span class='warning'>Zostajesz usunięty z drużyny [member.squad].</span>")
			member.squad.remove_member(member)
			member.squad = null
			return TRUE
		if("set_position")
			if(!member?.squad)
				return FALSE
			return member.squad.aq_set_position(member, params["position"])
		if("aq_set_leader")
			if(!member?.squad)
				return FALSE
			log_game("[key_name(user)] made [key_name(member)] the leader of squad [member.squad]")
			member.squad.set_leader(member)
			return TRUE
		if("aq_demote_leader")
			if(!member?.squad)
				return FALSE
			member.squad.unset_leader(member)
			return TRUE
		if("retask")
			if(!squad)
				return FALSE
			var/new_role = input_squad_role(user)
			if(!new_role || !(squad in GLOB.squad_manager.squads))
				return FALSE
			log_game("[key_name(user)] retasked squad [squad] to [new_role]")
			squad.retask(new_role)
			for(var/mob/living/carbon/human/squad_member as anything in squad.members)
				to_chat(squad_member, "<span class='sciradio'>[squad.primary_objective]</span>")
			return TRUE
		if("aq_secondary_objective")
			if(!squad)
				return FALSE
			var/orders = stripped_input(user, "Ustaw cel dodatkowy drużyny [squad]:", "Cel dodatkowy", squad.secondary_objective, MAX_BROADCAST_LEN)
			if(isnull(orders))
				return FALSE
			squad.secondary_objective = orders
			log_game("[key_name(user)] set the secondary objective of squad [squad]: [orders]")
			if(length(orders))
				for(var/mob/living/carbon/human/squad_member as anything in squad.members)
					to_chat(squad_member, "<span class='sciradio'>Dodatkowy cel drużyny: [orders]</span>")
			return TRUE
		if("order")
			if(!squad)
				return FALSE
			var/message = tgui_input_text(user, "Rozkaz dla drużyny [squad] (do [SQUAD_ORDER_MAX_LEN] znaków). Drużyna zobaczy go na ekranie z twoim portretem.", "Rozkaz z CIC", max_length = SQUAD_ORDER_MAX_LEN, multiline = TRUE, encode = FALSE)
			if(!message)
				return FALSE
			return squad.aq_issue_order(user, message, from_console = TRUE)
		if("aq_toggle_access")
			if(!squad)
				return FALSE
			squad.access_enabled = !squad.access_enabled
			log_game("[key_name(user)] set elevated access of squad [squad] to [squad.access_enabled]")
			squad.broadcast(squad, squad.access_enabled ? "Przyznano drużynie rozszerzony dostęp." : "Odebrano drużynie rozszerzony dostęp.", list('nsv13/sound/effects/notice2.ogg'))
			return TRUE
		if("aq_toggle_beararms")
			if(!squad)
				return FALSE
			squad.weapons_clearance = !squad.weapons_clearance
			log_game("[key_name(user)] set weapons clearance of squad [squad] to [squad.weapons_clearance]")
			return TRUE
		if("aq_toggle_hidden")
			if(!squad)
				return FALSE
			squad.hidden = !squad.hidden
			return TRUE
		if("aq_print_pass")
			if(!squad || !source || world.time < state["next_print"])
				return FALSE
			state["next_print"] = world.time + 5 SECONDS
			new /obj/item/clothing/neck/squad(get_turf(source), squad)
			playsound(source, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
			return TRUE
		if("aq_create_squad")
			if(!source)
				return FALSE
			var/new_name = tgui_input_text(user, "Nazwa nowej drużyny (do 20 znaków):", "Nowa drużyna", max_length = 20)
			if(!new_name)
				return FALSE
			var/new_colour = input(user, "Kolor nowej drużyny:", "Nowa drużyna", "#3cb371") as color|null
			if(!new_colour)
				return FALSE
			var/datum/squad/created = GLOB.squad_manager.aq_create_squad(new_name, new_colour)
			if(!created)
				to_chat(user, "<span class='warning'>Nie da się utworzyć drużyny: nazwa jest zajęta albo niepoprawna, albo drużyn jest już za dużo.</span>")
				return FALSE
			log_game("[key_name(user)] created squad [created.name]")
			return TRUE
		if("aq_delete_squad")
			if(!squad)
				return FALSE
			if(!GLOB.squad_manager.aq_delete_squad(squad, user))
				to_chat(user, "<span class='warning'>Ostatniej drużyny nie da się rozwiązać.</span>")
				return FALSE
			return TRUE
		if("aq_toggle_heavy_armor")
			if(!squad)
				return FALSE
			squad.aq_heavy_armor = !squad.aq_heavy_armor
			log_game("[key_name(user)] set squad [squad] armor to [squad.aq_heavy_armor ? "heavy" : "light"]")
			return TRUE
		if("aq_rename_squad")
			if(!squad)
				return FALSE
			var/new_name = tgui_input_text(user, "Nowa nazwa drużyny [squad.name] (do 20 znaków):", "Nazwa drużyny", squad.name, max_length = 20)
			if(!new_name)
				return FALSE
			if(!squad.aq_rename(new_name, user))
				to_chat(user, "<span class='warning'>Tej nazwy nie da się użyć: jest zajęta albo niepoprawna.</span>")
				return FALSE
			return TRUE
		if("aq_recolour_squad")
			if(!squad)
				return FALSE
			var/new_colour = input(user, "Kolor drużyny [squad.name]:", "Kolor drużyny", squad.colour) as color|null
			if(!new_colour)
				return FALSE
			return squad.aq_recolour(new_colour, user)
		if("aq_report_gear")
			var/datum/squad_loan/loan = locate(params["loan"]) in GLOB.squad_loans
			if(!loan)
				return FALSE
			return loan.aq_report(user)
		if("place_marker")
			if(!squad)
				return FALSE
			return squad.aq_place_marker_from_map(user, params, from_console = TRUE)
		if("clear_marker")
			if(!squad)
				return FALSE
			return squad.aq_clear_marker(params["marker"])
		if("view_cam")
			if(!bodycam || !member?.squad)
				return FALSE
			bodycam.set_target(member)
			return TRUE
		if("close_cam")
			if(!bodycam)
				return FALSE
			bodycam.set_target(null)
			return TRUE
	return FALSE

// Konsola
/obj/machinery/computer/squad_manager
	// w NSV13 było req_one_access = ACCESS_HEADS (liczba, nie lista): length() z liczby to 0, więc allowed() przepuszczało każdego
	req_one_access = list(ACCESS_HEADS)
	var/datum/aq_squad_bodycam/aq_bodycam
	/// Stan okna: wybrany poziom mapy, odstęp drukowania smyczy
	var/list/aq_state = list()

/obj/machinery/computer/squad_manager/Initialize(mapload)
	. = ..()
	aq_bodycam = new("squad_console_[REF(src)]_map")

/obj/machinery/computer/squad_manager/Destroy()
	QDEL_NULL(aq_bodycam)
	return ..()

// Pełne nadpisania (LEGACY_OVERRIDES.md): nowe okno konsoli
/obj/machinery/computer/squad_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		aq_bodycam.register_viewer(user)
		ui = new(user, src, "SquadManager", "Zarządzanie drużynami")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/squad_manager/ui_close(mob/user)
	. = ..()
	aq_bodycam.unregister_viewer(user)

/obj/machinery/computer/squad_manager/ui_data(mob/user)
	if(aq_bodycam.target)
		aq_bodycam.update_view()
	return aq_squad_console_data(user, aq_state["z"], TRUE, aq_bodycam)

/obj/machinery/computer/squad_manager/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!isliving(usr))
		return FALSE
	// req_one_access konsoli nie działa sam w ui_act: zarządzanie drużynami tylko z dostępem dowództwa
	if(!(action in list("select_z", "close_cam")) && !allowed(usr))
		to_chat(usr, "<span class='warning'>Brak dostępu: zarządzanie drużynami wymaga dostępu dowództwa.</span>")
		return FALSE
	if(aq_squad_console_act(action, params, usr, src, aq_bodycam, aq_state))
		ui_update()
		return TRUE

// Program na tablecie (bez kamery)
/datum/computer_file/program/squad_manager
	var/list/aq_state = list()

/datum/computer_file/program/squad_manager/ui_data(mob/user)
	return aq_squad_console_data(user, aq_state["z"], FALSE, null)

/datum/computer_file/program/squad_manager/ui_act(action, params)
	if(..())
		return TRUE
	if(!isliving(usr))
		return FALSE
	if(aq_squad_console_act(action, params, usr, computer, null, aq_state))
		return TRUE

// Kamera pancerza: widok wokół członka drużyny, który ma założony pancerz drużyny
/datum/aq_squad_bodycam
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
	var/list/cam_plane_masters
	var/atom/movable/screen/background/cam_background
	var/mob/living/carbon/human/target
	var/list/viewers = list()

/datum/aq_squad_bodycam/New(map_name)
	src.map_name = map_name
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/instance = new plane()
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE
	show_static()

/datum/aq_squad_bodycam/Destroy()
	set_target(null)
	for(var/mob/viewer as anything in viewers)
		viewer.client?.clear_map(map_name)
	viewers.Cut()
	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(cam_background)
	return ..()

/datum/aq_squad_bodycam/proc/register_viewer(mob/user)
	if(!user?.client)
		return
	viewers |= user
	user.client.register_map_obj(cam_screen)
	for(var/plane in cam_plane_masters)
		user.client.register_map_obj(plane)
	user.client.register_map_obj(cam_background)

/datum/aq_squad_bodycam/proc/unregister_viewer(mob/user)
	viewers -= user
	user?.client?.clear_map(map_name)
	if(!length(viewers))
		set_target(null)

/datum/aq_squad_bodycam/proc/set_target(mob/living/carbon/human/new_target)
	if(target)
		UnregisterSignal(target, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	target = new_target
	if(target)
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_moved))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))
	update_view()

/datum/aq_squad_bodycam/proc/on_target_moved(datum/source)
	SIGNAL_HANDLER
	update_view()

/datum/aq_squad_bodycam/proc/on_target_deleted(datum/source)
	SIGNAL_HANDLER
	set_target(null)

/datum/aq_squad_bodycam/proc/update_view()
	if(!target || !target.aq_has_squad_bodycam() || !get_turf(target))
		show_static()
		return
	var/list/visible_turfs = list()
	for(var/turf/visible in view(7, get_turf(target)))
		visible_turfs += visible
	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, bbox[3] - bbox[1] + 1, bbox[4] - bbox[2] + 1)

/datum/aq_squad_bodycam/proc/show_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, 15, 15)
