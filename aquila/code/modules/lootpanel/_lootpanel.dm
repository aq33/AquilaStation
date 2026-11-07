// AQUILA - RPG Loot: Revisited z tgstation/tgstation#82533 (stan tg z listopada 2026, z poprawkami #82680, #82722,
// #82765, #83401, #84513, #84621, #85208 i #89114 po stronie okna). Alt+klik na kafelek albo leżący przedmiot otwiera
// okno z zawartością kafelka zamiast zakładki kafelka w panelu statystyk. Różnice względem tg: bez komunikatu
// o starym BYOND (gramy tylko na 516), CanReach zamiast IsReachableBy, typy z własną akcją Alt+klik nie otwierają
// okna (alt_click_actions.dm) zamiast refaktoru tgstation/tgstation#82656.

/**
 * ## Loot panel
 * A datum that stores info containing the contents of a turf.
 * Handles opening the lootpanel UI and searching the turf for items.
 */
/datum/lootpanel
	/// The owner of the panel
	var/client/owner
	/// The list of all search objects indexed.
	var/list/datum/search_object/contents = list()
	/// The list of search_objects needing processed
	var/list/datum/search_object/to_image = list()
	/// The turf being searched
	var/turf/source_turf

/datum/lootpanel/New(client/owner)
	. = ..()
	src.owner = owner

/datum/lootpanel/Destroy(force)
	SSlooting.backlog -= src
	SSlooting.processing -= src
	reset_contents()
	if(source_turf)
		UnregisterSignal(source_turf, COMSIG_ATOM_ENTERED)
	owner = null
	source_turf = null
	return ..()

/datum/lootpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LootPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/lootpanel/ui_host(mob/user)
	return source_turf

/datum/lootpanel/ui_close(mob/user)
	. = ..()
	if(source_turf)
		UnregisterSignal(source_turf, COMSIG_ATOM_ENTERED)
	source_turf = null
	reset_contents()

/datum/lootpanel/ui_data(mob/user)
	var/list/data = list()
	data["contents"] = get_contents()
	data["searching"] = length(to_image)
	return data

/datum/lootpanel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("grab")
			return grab(usr, params)
	return FALSE

/datum/lootpanel/ui_state(mob/user)
	return GLOB.always_state

/datum/lootpanel/ui_status(mob/user, datum/ui_state/state)
	if(!source_turf || !(user in viewers(source_turf)) || (user.movement_type & VENTCRAWLING))
		return UI_CLOSE

	if(isliving(user))
		var/mob/living/living_user = user
		if(!(living_user.mobility_flags & (MOBILITY_USE|MOBILITY_PICKUP)))
			return UI_UPDATE

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.dna?.check_mutation(/datum/mutation/telekinesis))
			return tkMaxRangeCheck(user, source_turf) ? UI_INTERACTIVE : UI_UPDATE

	if(!user.CanReach(source_turf, user.get_active_held_item()))
		return (get_dist(user, source_turf) >= 3 && user.is_blind()) ? UI_CLOSE : UI_UPDATE

	return UI_INTERACTIVE

/// Okno kafelka dla tego klienta, tworzone przy pierwszym Alt+kliku
/client/var/datum/lootpanel/loot_panel

/client/Destroy()
	QDEL_NULL(loot_panel)
	return ..()

/client/proc/get_loot_panel()
	if(!loot_panel)
		loot_panel = new(src)
	return loot_panel

// Klient testowy z unit testów potrzebuje moba (jak w tg)
/datum/client_interface/var/mob/mob
