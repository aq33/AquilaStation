// Panel rewolucji w stylu panelu kultu krwi (mind_ui): przycisk po lewej stronie ekranu otwiera okno
// z miejscami rewolucjonistów i dynamicznym limitem konwersji, liczonym tak jak limit kultystów.

/// Ile miejsc pokazuje panel ponad maksymalny limit, zanim przestanie liczyć nadmiarowych
#define REV_PANEL_OVERFLOW_SLOTS 5

/datum/team/revolution
	/// Ilu żywych rewolucjonistów (z przywódcami) może być naraz. Rośnie z liczbą żywej załogi, nigdy nie spada.
	var/rev_cap = 0
	var/min_rev_cap = 5
	var/max_rev_cap = 12

/// Przelicza limit tak jak kult: 1/3 żywych graczy, w granicach min-max, i tylko w górę
/datum/team/revolution/proc/update_rev_cap()
	var/living_players = 0
	for(var/mob/M in GLOB.player_list)
		if(!M.client || isnewplayer(M) || M.stat == DEAD)
			continue
		living_players++
	var/new_cap = clamp(round(living_players / 3), min_rev_cap, max_rev_cap)
	if(new_cap <= rev_cap)
		return
	var/announce = rev_cap > 0
	rev_cap = new_cap
	if(!announce)
		return
	for(var/datum/mind/member in members)
		to_chat(member.current, "<span class='danger'>Załoga jest teraz na tyle liczna, że rewolucja może liczyć <span class='userdanger'>[rev_cap]</span> towarzyszy.</span>")

/// Żywi członkowie rewolucji, przywódcy pierwsi
/datum/team/revolution/proc/living_revs()
	. = list()
	var/list/heads = head_revolutionaries()
	for(var/datum/mind/member in heads + (members - heads))
		if(member.current && member.current.stat != DEAD && member.has_antag_datum(/datum/antagonist/rev))
			. += member

/datum/team/revolution/proc/can_convert()
	update_rev_cap()
	return length(living_revs()) < rev_cap

/datum/team/revolution/update_heads()
	update_rev_cap()
	return ..()

/datum/antagonist/rev/on_gain()
	. = ..()
	rev_team?.update_rev_cap()
	owner.current?.DisplayUI("Revolution")

/datum/antagonist/rev/on_removal()
	var/mob/living/old_body = owner.current
	. = ..()
	old_body?.HideUI("Revolution")

// Konwersja przemową sprawdza limit przed i po przemowie

/datum/antagonist/rev/head
	/// TRUE w trakcie konwersji przemową, tylko ona podlega limitowi (admini i tryb gry dodają bez ograniczeń)
	var/speech_conversion = FALSE

/obj/effect/proc_holder/spell/targeted/revolution_convert/cast(list/targets, mob/user)
	var/datum/antagonist/rev/head/rev_datum = user.mind?.has_antag_datum(/datum/antagonist/rev/head)
	if(rev_datum?.rev_team && !rev_datum.rev_team.can_convert())
		to_chat(user, "<span class='warning'>Rewolucja osiągnęła limit [rev_datum.rev_team.rev_cap] towarzyszy. Kolejne miejsca zwolnią się, gdy załoga się powiększy albo ktoś z was zginie.</span>")
		return
	if(rev_datum)
		rev_datum.speech_conversion = TRUE
	. = ..()
	if(rev_datum)
		rev_datum.speech_conversion = FALSE

/datum/antagonist/rev/head/add_revolutionary(datum/mind/rev_mind, stun = TRUE)
	// Limit mógł się zapełnić w trakcie przemowy
	if(speech_conversion && rev_team && !rev_team.can_convert())
		return FALSE
	return ..()

////////////////////////////////////////////////////////////////////
//					REWOLUCJA - PRZYCISK PO LEWEJ				  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/revolution
	uniqueID = "Revolution"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/revolution_open_panel,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/revolution_panel,
		)
	display_with_parent = TRUE
	x = "LEFT"

/datum/mind_ui/revolution/Valid()
	var/mob/M = mind.current
	return M && mind.has_antag_datum(/datum/antagonist/rev)

/obj/abstract/mind_ui_element/hoverable/revolution_open_panel
	name = "Panel rewolucji"
	icon = 'aquila/icons/hud/revolution_button.dmi'
	icon_state = "rev_panel"
	offset_x = 6
	offset_y = -128
	layer = MIND_UI_BUTTON
	tooltip_title = "Panel rewolucji"
	tooltip_content = "Pokazuje towarzyszy i limit, ilu jeszcze można przekonać."
	element_flags = MINDUI_FLAG_TOOLTIP

/obj/abstract/mind_ui_element/hoverable/revolution_open_panel/Click()
	flick("rev_panel-click", src)
	var/datum/mind_ui/revolution_panel/panel = locate() in parent.subUIs
	if(!panel)
		return
	if(panel.active)
		panel.Hide()
	else
		panel.Display()

////////////////////////////////////////////////////////////////////
//					REWOLUCJA - GŁÓWNY PANEL					  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/revolution_panel
	uniqueID = "Revolution Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/revolution_panel_background,
		/obj/abstract/mind_ui_element/hoverable/revolution_panel_close,
		/obj/abstract/mind_ui_element/hoverable/movable/revolution_panel_move,
		/obj/abstract/mind_ui_element/revolution_slot_manager,
		/obj/abstract/mind_ui_element/hoverable/revolution_cap,
		)
	display_with_parent = FALSE
	var/list/rev_slots = list()

/datum/mind_ui/revolution_panel/Valid()
	var/mob/M = mind.current
	return M && mind.has_antag_datum(/datum/antagonist/rev)

/datum/mind_ui/revolution_panel/SpawnElements()
	..()
	var/datum/team/revolution/team = locate_team(/datum/team/revolution)
	var/slot_count = (team ? team.max_rev_cap : 12) + REV_PANEL_OVERFLOW_SLOTS
	for(var/i in 1 to slot_count)
		var/obj/abstract/mind_ui_element/hoverable/revolution_slot/new_slot = new(null, src)
		elements += new_slot
		rev_slots += new_slot

/datum/mind_ui/revolution_panel/Display()
	..()
	if(active)
		var/obj/abstract/mind_ui_element/revolution_slot_manager/slot_manager = locate() in elements
		slot_manager.UpdateIcon()

/obj/abstract/mind_ui_element/revolution_panel_background
	name = "Panel rewolucji"
	icon = 'aquila/icons/bloodcult/bloodcult/362x229.dmi'
	icon_state = "background"
	offset_x = -165
	offset_y = -93
	alpha = 240
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/revolution_panel_background/Click()
	parent.Hide()

/obj/abstract/mind_ui_element/hoverable/revolution_panel_close
	name = "Zamknij"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "close"
	offset_x = 181
	offset_y = 120
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/revolution_panel_close/Click()
	parent.Hide()

/obj/abstract/mind_ui_element/hoverable/movable/revolution_panel_move
	name = "Przesuń interfejs (kliknij i przeciągnij)"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = -165
	offset_y = 120
	mouse_opacity = 1
	move_whole_ui = TRUE
	const_offset_y = -16
	const_offset_x = -16

/obj/abstract/mind_ui_element/hoverable/revolution_cap
	name = "Limit rewolucjonistów"
	icon = 'aquila/icons/bloodcult/bloodcult/16x32.dmi'
	icon_state = "cultist_cap"
	layer = MIND_UI_BUTTON
	offset_y = -32
	tooltip_title = "Limit rewolucjonistów"
	element_flags = MINDUI_FLAG_TOOLTIP

/// Rozkłada miejsca, znacznik limitu i opis; odświeża się co tick SSobj, gdy panel jest widoczny
/obj/abstract/mind_ui_element/revolution_slot_manager
	name = "Miejsca rewolucjonistów"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "blank"
	mouse_opacity = 0
	layer = MIND_UI_FRONT
	offset_x = -140
	offset_y = 28
	element_flags = MINDUI_FLAG_PROCESSING

/obj/abstract/mind_ui_element/revolution_slot_manager/process()
	if(invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/revolution_slot_manager/UpdateIcon()
	var/mob/user = GetUser()
	var/datum/antagonist/rev/own_datum = user?.mind?.has_antag_datum(/datum/antagonist/rev)
	var/datum/team/revolution/team = own_datum?.rev_team
	if(!team)
		return
	var/datum/mind_ui/revolution_panel/panel = parent
	team.update_rev_cap()
	var/list/living = team.living_revs()
	var/list/heads = team.head_revolutionaries()

	var/heads_left = 0
	for(var/datum/objective/mutiny/objective in team.objectives)
		if(!objective.check_completion())
			heads_left++

	overlays.len = 0
	String2Maptext("REWOLUCJA", font_size = "12pt", _color = "#FF4444", _pixel_y = 60)
	String2Maptext("Towarzysze: [length(living)] / [team.rev_cap]", _pixel_y = 34)
	String2Maptext("Przywódcy: [length(heads & living)]", _pixel_y = 22)
	String2Maptext("Szefowie do obalenia: [heads_left]", _pixel_y = 10)
	if(length(living) >= team.rev_cap)
		String2Maptext("Limit osiągnięty. Nowe miejsca zwolnią się, gdy załoga urośnie.", _color = "#FF8888", _pixel_y = -2)
	else
		String2Maptext("Można przekonać jeszcze: [team.rev_cap - length(living)]", _color = "#88FF88", _pixel_y = -2)

	var/obj/abstract/mind_ui_element/hoverable/revolution_cap/cap_marker = locate() in panel.elements
	cap_marker.tooltip_content = "Rewolucja może liczyć [team.rev_cap] żywych towarzyszy (z przywódcami). Limit rośnie z liczbą żywej załogi, najwyżej do [team.max_rev_cap]."
	var/x_pos = -150
	var/i = 1
	for(var/obj/abstract/mind_ui_element/hoverable/revolution_slot/slot as anything in panel.rev_slots)
		slot.overlays.len = 0
		slot.locked = FALSE
		slot.overflow = FALSE
		slot.associated_mind = null
		if(i <= length(living))
			var/datum/mind/member = living[i]
			slot.associated_mind = member
			slot.base_icon_state = (member in heads) ? "slot_head" : "slot_rev"
			slot.overflow = i > team.rev_cap
			if(slot.overflow)
				slot.overlays += image('aquila/icons/bloodcult/bloodcult/16x32.dmi', "overflow")
			if(member == user.mind)
				slot.overlays += image('aquila/icons/bloodcult/bloodcult/16x32.dmi', "you")
		else if(i <= team.max_rev_cap)
			slot.base_icon_state = "slot_empty"
			slot.locked = i > team.rev_cap
			if(slot.locked)
				slot.overlays += image('aquila/icons/bloodcult/bloodcult/16x32.dmi', "locked")
		else
			slot.invisibility = 101
			i++
			continue
		slot.icon_state = "[slot.base_icon_state][slot.hovering ? "-hover" : ""]"
		slot.invisibility = 0
		slot.offset_x = x_pos
		slot.UpdateUIScreenLoc()
		x_pos += 17
		if(i == team.rev_cap)
			cap_marker.offset_x = x_pos - 4
			cap_marker.UpdateUIScreenLoc()
			x_pos += 7
		i++

/obj/abstract/mind_ui_element/hoverable/revolution_slot
	name = "Miejsce rewolucjonisty"
	icon = 'aquila/icons/hud/revolution_panel.dmi'
	icon_state = "slot_empty"
	layer = MIND_UI_BUTTON
	offset_y = -32
	element_flags = MINDUI_FLAG_TOOLTIP
	var/datum/mind/associated_mind
	var/locked = FALSE
	var/overflow = FALSE

/obj/abstract/mind_ui_element/hoverable/revolution_slot/StartHovering(location, control, params)
	if(associated_mind)
		tooltip_title = associated_mind.name
		tooltip_content = associated_mind.has_antag_datum(/datum/antagonist/rev/head) ? "Przywódca rewolucji" : "Rewolucjonista"
		if(associated_mind.assigned_role)
			tooltip_content += "<br>[associated_mind.assigned_role]"
		if(overflow)
			tooltip_content += "<br><b>ponad limit!</b>"
	else if(locked)
		tooltip_title = "Zablokowane miejsce"
		tooltip_content = "To miejsce zwolni się, gdy żywa załoga na pokładzie jeszcze się powiększy."
	else
		tooltip_title = "Wolne miejsce"
		tooltip_content = "Przywódca rewolucji może przekonać tu nową osobę przemową."
	return ..()

#undef REV_PANEL_OVERFLOW_SLOTS
