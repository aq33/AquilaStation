//Engineering Mesons

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_RAD "radiation"
#define MODE_SHUTTLE "shuttle"

/obj/item/clothing/glasses/meson/engine
	name = "inżynieryjne gogle skanujące"
	desc = "Gogle używane przez inżynierów. Tryb mezonowy pozwala widzieć przez ściany podstawowy układ konstrukcji i terenu, tryb T-ray pokazuje obiekty pod podłogą, takie jak kable i rury, a tryb radiacyjny pokazuje obiekty skażone promieniowaniem."
	icon_state = "trayson-meson"
	item_state = "trayson-meson"
	actions_types = list(/datum/action/item_action/toggle_mode)

	vision_flags = NONE
	darkness_view = 2
	lighting_alpha = null
	invis_view = SEE_INVISIBLE_LIVING

	var/list/modes = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_RAD, MODE_RAD = MODE_NONE)
	var/mode = MODE_NONE
	var/range = 1

/obj/item/clothing/glasses/meson/engine/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/clothing/glasses/meson/engine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/meson/engine/proc/toggle_mode(mob/user, voluntary)
	mode = modes[mode]
	to_chat(user, "<span class='[voluntary ? "notice":"warning"]'>[voluntary ? "Przełączasz gogle":"Gogle przełączają się"] [mode ? "w tryb [mode]":"na wyłączone"][voluntary ? ".":"!"]</span>")

	switch(mode)
		if(MODE_MESON)
			vision_flags = SEE_TURFS
			darkness_view = 1
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

		if(MODE_TRAY) //undoes the last mode, meson
			vision_flags = NONE
			darkness_view = 2
			lighting_alpha = null

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			H.update_sight()

	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/glasses/meson/engine/attack_self(mob/user)
	toggle_mode(user, TRUE)

/obj/item/clothing/glasses/meson/engine/process()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/user = loc
	if(user.glasses != src || !user.client)
		return
	switch(mode)
		if(MODE_TRAY)
			t_ray_scan(user, 8, range)
		if(MODE_RAD)
			show_rads()
		if(MODE_SHUTTLE)
			show_shuttle()

/obj/item/clothing/glasses/meson/engine/proc/show_rads()
	var/mob/living/carbon/human/user = loc
	var/list/rad_places = list()
	for(var/datum/component/radioactive/thing in SSradiation.processing)
		var/atom/owner = thing.parent
		var/turf/place = get_turf(owner)
		if(rad_places[place])
			rad_places[place] += thing.strength
		else
			rad_places[place] = thing.strength

	for(var/i in rad_places)
		var/turf/place = i
		if(get_dist(user, place) >= range*5)	//Rads are easier to see than wires under the floor
			continue
		var/strength = round(rad_places[i] / 1000, 0.1)
		var/image/pic = image(loc = place)
		var/mutable_appearance/MA = new()
		MA.maptext = MAPTEXT("[strength]k")
		MA.color = "#04e66d"
		MA.layer = RAD_TEXT_LAYER
		MA.plane = GAME_PLANE
		pic.appearance = MA
		flick_overlay(pic, list(user.client), 10)

/obj/item/clothing/glasses/meson/engine/proc/show_shuttle()
	var/mob/living/carbon/human/user = loc
	var/obj/docking_port/mobile/port = SSshuttle.get_containing_shuttle(user)
	if(!port)
		return
	var/list/shuttle_areas = port.shuttle_areas
	for(var/r in shuttle_areas)
		var/area/region = r
		for(var/turf/place in region.contents)
			if(get_dist(user, place) > 7)
				continue
			var/image/pic
			if(isshuttleturf(place))
				pic = new('icons/turf/overlays.dmi', place, "greenOverlay", AREA_LAYER)
			else
				pic = new('icons/turf/overlays.dmi', place, "redOverlay", AREA_LAYER)
			flick_overlay(pic, list(user.client), 8)

/obj/item/clothing/glasses/meson/engine/update_icon()
	icon_state = "trayson-[mode]"
	update_mob()

/obj/item/clothing/glasses/meson/engine/proc/update_mob()
	item_state = icon_state
	if(isliving(loc))
		var/mob/living/user = loc
		if(user.get_item_by_slot(ITEM_SLOT_EYES) == src)
			user.update_inv_glasses()
		else
			user.update_inv_hands()

/obj/item/clothing/glasses/meson/engine/tray //atmos techs have lived far too long without tray goggles while those damned engineers get their dual-purpose gogles all to themselves
	name = "optyczny skaner T-ray"
	icon_state = "trayson-t-ray"
	item_state = "trayson-t-ray"
	desc = "Używany przez inżynierów do oglądania obiektów pod podłogą, takich jak kable i rury."
	range = 2

	modes = list(MODE_NONE = MODE_TRAY, MODE_TRAY = MODE_NONE)

/obj/item/clothing/glasses/meson/engine/shuttle
	name = "skaner obszaru promu"
	icon_state = "trayson-shuttle"
	item_state = "trayson-shuttle"
	desc = "Służy do oglądania granic obszarów promów."

	modes = list(MODE_NONE = MODE_SHUTTLE, MODE_SHUTTLE = MODE_NONE)

#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_RAD
#undef MODE_SHUTTLE
