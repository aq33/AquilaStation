// Panel gangu w stylu panelu rewolucji i kultu krwi (mind_ui): przycisk po lewej stronie ekranu otwiera okno
// z miejscami członków, limitem gangu, terenem, wpływami, stanem dominatora i porównaniem z rywalem.

/// Ile miejsc pokazuje panel ponad maksymalny limit, zanim przestanie liczyć nadmiarowych
#define GANG_PANEL_OVERFLOW_SLOTS 4
#define GANG_PANEL_TEXT "#EADCF5"
#define GANG_PANEL_NUMBER(value) "<span style='color:#EEBC3A;'>[value]</span>"

/// Procent terenu stacji pod kontrolą gangu
/datum/team/gang/proc/territory_percent()
	return round(LAZYLEN(territories) / claimable_territories_cached() * 100, 1)

////////////////////////////////////////////////////////////////////
//					GANG - PRZYCISK PO LEWEJ					  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/gang
	uniqueID = "Gang"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/gang_open_panel,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/gang_panel,
		)
	display_with_parent = TRUE
	x = "LEFT"

/datum/mind_ui/gang/Valid()
	var/mob/M = mind.current
	return M && mind.has_antag_datum(/datum/antagonist/gang)

/obj/abstract/mind_ui_element/hoverable/gang_open_panel
	name = "Panel gangu"
	icon = 'aquila/icons/hud/gang_button.dmi'
	icon_state = "gang_panel"
	offset_x = 6
	offset_y = -128
	layer = MIND_UI_BUTTON
	tooltip_title = "Panel gangu"
	tooltip_content = "Pokazuje członków, limit gangu, teren, wpływy i dominatora."
	element_flags = MINDUI_FLAG_TOOLTIP

/obj/abstract/mind_ui_element/hoverable/gang_open_panel/Click()
	flick("gang_panel-click", src)
	var/datum/mind_ui/gang_panel/panel = locate() in parent.subUIs
	if(!panel)
		return
	if(panel.active)
		panel.Hide()
	else
		panel.Display()

////////////////////////////////////////////////////////////////////
//					GANG - GŁÓWNY PANEL						  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/gang_panel
	uniqueID = "Gang Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/gang_panel_background,
		/obj/abstract/mind_ui_element/hoverable/gang_panel_close,
		/obj/abstract/mind_ui_element/hoverable/movable/gang_panel_move,
		/obj/abstract/mind_ui_element/gang_slot_manager,
		/obj/abstract/mind_ui_element/hoverable/gang_cap,
		)
	display_with_parent = FALSE
	var/list/gang_slots = list()

/datum/mind_ui/gang_panel/Valid()
	var/mob/M = mind.current
	return M && mind.has_antag_datum(/datum/antagonist/gang)

/datum/mind_ui/gang_panel/SpawnElements()
	..()
	for(var/i in 1 to 8 + GANG_PANEL_OVERFLOW_SLOTS)
		var/obj/abstract/mind_ui_element/hoverable/gang_slot/new_slot = new(null, src)
		elements += new_slot
		gang_slots += new_slot

/datum/mind_ui/gang_panel/Display()
	..()
	if(active)
		var/obj/abstract/mind_ui_element/gang_slot_manager/slot_manager = locate() in elements
		slot_manager.UpdateIcon()

/obj/abstract/mind_ui_element/gang_panel_background
	name = "Panel gangu"
	icon = 'aquila/icons/hud/gang_panel_bg.dmi'
	icon_state = "background"
	offset_x = -160
	offset_y = -88
	alpha = 240
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/gang_panel_background/Click()
	parent.Hide()

/obj/abstract/mind_ui_element/hoverable/gang_panel_close
	name = "Zamknij"
	icon = 'aquila/icons/hud/gang_buttons.dmi'
	icon_state = "close"
	offset_x = 138
	offset_y = 63
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/gang_panel_close/Click()
	parent.Hide()

/obj/abstract/mind_ui_element/hoverable/movable/gang_panel_move
	name = "Przesuń interfejs (kliknij i przeciągnij)"
	icon = 'aquila/icons/hud/gang_buttons.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = 118
	offset_y = 63
	mouse_opacity = 1
	move_whole_ui = TRUE
	const_offset_y = -16
	const_offset_x = -16

/obj/abstract/mind_ui_element/hoverable/gang_cap
	name = "Limit gangu"
	icon = 'aquila/icons/hud/gang_panel.dmi'
	icon_state = "cap"
	layer = MIND_UI_BUTTON
	offset_y = -66
	tooltip_title = "Limit gangu"
	element_flags = MINDUI_FLAG_TOOLTIP

/// Rozkłada miejsca, znacznik limitu i opis; odświeża się co tick SSobj, gdy panel jest widoczny
/obj/abstract/mind_ui_element/gang_slot_manager
	name = "Miejsca w gangu"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	mouse_opacity = 0
	layer = MIND_UI_FRONT
	offset_x = -160
	offset_y = -88
	element_flags = MINDUI_FLAG_PROCESSING

/obj/abstract/mind_ui_element/gang_slot_manager/process()
	if(invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/gang_slot_manager/UpdateIcon()
	var/mob/user = GetUser()
	var/datum/antagonist/gang/own_datum = user?.mind?.has_antag_datum(/datum/antagonist/gang)
	var/datum/team/gang/team = own_datum?.gang
	if(!team)
		return
	var/datum/mind_ui/gang_panel/panel = parent
	team.update_gang_cap()
	var/list/living = team.living_members()

	overlays.len = 0
	String2Maptext("<b>GANG [uppertext(team.name)]</b>", font_size = "12pt", _color = team.color || GANG_PANEL_TEXT, _pixel_x = 40, _pixel_y = 146)
	String2Maptext("Członkowie: [GANG_PANEL_NUMBER("[length(living)] / [team.gang_cap]")]   Szefowie: [GANG_PANEL_NUMBER(length(team.leaders & living))]", _color = GANG_PANEL_TEXT, _pixel_x = 12, _pixel_y = 124)
	String2Maptext("Teren: [GANG_PANEL_NUMBER("[team.territory_percent()]%")]   Wpływy: [GANG_PANEL_NUMBER(team.influence)]", _color = GANG_PANEL_TEXT, _pixel_x = 12, _pixel_y = 111)
	var/dominator_text
	if(team.domination_time != NOT_DOMINATING)
		var/remaining = round(team.domination_time_remaining())
		dominator_text = "Dominator: przejęcie za [GANG_PANEL_NUMBER("[remaining / 60 >= 1 ? "[round(remaining / 60)] min " : ""][remaining % 60] s")]"
	else
		dominator_text = "Dominator: [team.dom_attempts ? "próby [GANG_PANEL_NUMBER(team.dom_attempts)], przejęcie ~[GANG_PANEL_NUMBER("[round(team.determine_domination_time() / 60, 0.1)] min")]" : "brak prób"]"
	String2Maptext(dominator_text, _color = GANG_PANEL_TEXT, _pixel_x = 12, _pixel_y = 98)
	for(var/datum/team/gang/rival in GLOB.gangs)
		if(rival == team)
			continue
		var/rival_text = "Rywal [rival.name]: teren [rival.territory_percent()]%"
		if(rival.domination_time != NOT_DOMINATING)
			rival_text += " - <b>PRZEJMUJE STACJĘ!</b>"
		String2Maptext(rival_text, _color = rival.domination_time != NOT_DOMINATING ? "#FF8C70" : (rival.color || GANG_PANEL_TEXT), _pixel_x = 12, _pixel_y = 85)
		break
	if(length(living) >= team.gang_cap)
		String2Maptext("Limit osiągnięty. Miejsca zwolnią się, gdy załoga urośnie.", _color = "#FF8C70", _pixel_x = 12, _pixel_y = 72)
	else
		String2Maptext("Można zwerbować jeszcze: [team.gang_cap - length(living)]", _color = "#8CDC78", _pixel_x = 12, _pixel_y = 72)

	var/obj/abstract/mind_ui_element/hoverable/gang_cap/cap_marker = locate() in panel.elements
	cap_marker.tooltip_content = "Gang może liczyć [team.gang_cap] żywych członków (z szefami). Limit rośnie z liczbą żywej załogi."
	var/x_pos = -146
	var/i = 1
	for(var/obj/abstract/mind_ui_element/hoverable/gang_slot/slot as anything in panel.gang_slots)
		slot.overlays.len = 0
		slot.locked = FALSE
		slot.overflow = FALSE
		slot.associated_mind = null
		if(i <= length(living))
			var/datum/mind/member = living[i]
			slot.associated_mind = member
			slot.base_icon_state = (member in team.leaders) ? "slot_head" : "slot_rev"
			slot.overflow = i > team.gang_cap
			if(slot.overflow)
				slot.overlays += image('aquila/icons/hud/gang_panel.dmi', "overflow")
			if(member == user.mind)
				slot.overlays += image('aquila/icons/hud/gang_panel.dmi', "you")
		else if(i <= 8)
			slot.locked = i > team.gang_cap
			slot.base_icon_state = slot.locked ? "slot_locked" : "slot_empty"
		else
			slot.invisibility = 101
			i++
			continue
		slot.icon_state = "[slot.base_icon_state][slot.hovering ? "-hover" : ""]"
		slot.invisibility = 0
		slot.offset_x = x_pos
		slot.UpdateUIScreenLoc()
		x_pos += 17
		if(i == team.gang_cap)
			cap_marker.offset_x = x_pos - 4
			cap_marker.UpdateUIScreenLoc()
			x_pos += 7
		i++

/obj/abstract/mind_ui_element/hoverable/gang_slot
	name = "Miejsce w gangu"
	icon = 'aquila/icons/hud/gang_panel.dmi'
	icon_state = "slot_empty"
	layer = MIND_UI_BUTTON
	offset_y = -66
	element_flags = MINDUI_FLAG_TOOLTIP
	var/datum/mind/associated_mind
	var/locked = FALSE
	var/overflow = FALSE

/obj/abstract/mind_ui_element/hoverable/gang_slot/StartHovering(location, control, params)
	if(associated_mind)
		tooltip_title = associated_mind.name
		if(associated_mind.has_antag_datum(/datum/antagonist/gang/boss/lieutenant))
			tooltip_content = "Porucznik gangu"
		else if(associated_mind.has_antag_datum(/datum/antagonist/gang/boss))
			tooltip_content = "Szef gangu"
		else
			tooltip_content = "Gangster"
		if(associated_mind.assigned_role)
			tooltip_content += "<br>[associated_mind.assigned_role]"
		if(overflow)
			tooltip_content += "<br><b>ponad limit!</b>"
	else if(locked)
		tooltip_title = "Zablokowane miejsce"
		tooltip_content = "To miejsce zwolni się, gdy żywa załoga na pokładzie jeszcze się powiększy."
	else
		tooltip_title = "Wolne miejsce"
		tooltip_content = "Szef albo porucznik może tu zwerbować nową osobę długopisem werbunkowym albo implantem."
	return ..()

#undef GANG_PANEL_OVERFLOW_SLOTS
#undef GANG_PANEL_TEXT
#undef GANG_PANEL_NUMBER
