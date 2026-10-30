#define GLOW_MODE 3
#define LIGHT_MODE 2
#define REMOVE_MODE 1

/*
CONTAINS:
RCD
ARCD
RLD
*/

/obj/item/construction
	name = "nie do użytku w grze"
	desc = "Urządzenie do szybkiej budowy i rozbiórki. Uzupełnisz je żelazem, plastalą, szkłem albo wkładami ze skompresowaną materią."
	opacity = 0
	density = FALSE
	anchored = FALSE
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=100000)
	req_access_txt = "11"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 0, "bleed" = 0)
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 100
	var/sheetmultiplier	= 4 //Controls the amount of matter added for each glass/iron sheet, triple for plasteel
	var/plasteelmultiplier = 3 //Plasteel is worth 3 times more than glass or iron
	var/plasmarglassmultiplier = 2 //50% less plasma than in plasteel
	var/rglassmultiplier = 1.5 //One iron sheet, half a glass sheet
	var/no_ammo_message = "<span class='warning'>Lampka „Mało amunicji” na urządzeniu miga na żółto.</span>"
	var/has_ammobar = FALSE	//controls whether or not does update_icon apply ammo indicator overlays
	var/ammo_sections = 10	//amount of divisions in the ammo indicator overlay/number of ammo indicator states
	var/upgrade = FALSE
	var/datum/component/remote_materials/silo_mats //remote connection to the silo
	var/silo_link = FALSE //switch to use internal or remote storage

/obj/item/construction/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		silo_mats = AddComponent(/datum/component/remote_materials, "RCD", FALSE)

/obj/item/construction/examine(mob/user)
	. = ..()
	. += "[src]. Obecnie zawiera [matter]/[max_matter] jednostek materii."
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		. += "[src]. Stan połączenia ze zdalnym magazynem: [silo_link ? "[silo_mats.on_hold() ? "WSTRZYMANE" : "WŁ."]" : "WYŁ."]."
		if(silo_link && !silo_mats.on_hold() && silo_mats.mat_container)
			. += "[src]. Zdalne połączenie ma żelazo odpowiadające [silo_mats.mat_container.get_material_amount(/datum/material/iron)/500] jednostkom RCD." // 1 matter for 1 floortile, as 4 tiles are produced from 1 iron

/obj/item/construction/Destroy()
	QDEL_NULL(spark_system)
	silo_mats = null
	return ..()

/obj/item/construction/attackby(obj/item/W, mob/user, params)
	if(iscyborg(user))
		return
	var/loaded = 0
	if(istype(W, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/R = W
		var/load = min(R.ammoamt, max_matter - matter)
		if(load <= 0)
			to_chat(user, "<span class='warning'>[src] nie pomieści więcej jednostek materii!</span>")
			return
		R.ammoamt -= load
		if(R.ammoamt <= 0)
			qdel(R)
		matter += load
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		loaded = 1
	else if(istype(W, /obj/item/stack/sheet/iron) || istype(W, /obj/item/stack/sheet/glass))
		loaded = loadwithsheets(W, sheetmultiplier, user)
	else if(istype(W, /obj/item/stack/sheet/plasteel))
		loaded = loadwithsheets(W, plasteelmultiplier*sheetmultiplier, user) //12 matter for 1 plasteel sheet
	else if(istype(W, /obj/item/stack/sheet/plasmarglass))
		loaded = loadwithsheets(W, plasmarglassmultiplier*sheetmultiplier, user) //8 matter for one plasma rglass sheet
	else if(istype(W, /obj/item/stack/sheet/rglass))
		loaded = loadwithsheets(W, rglassmultiplier*sheetmultiplier, user) //6 matter for one rglass sheet
	else if(istype(W, /obj/item/stack/rods))
		loaded = loadwithsheets(W, sheetmultiplier * 0.5, user) // 2 matter for 1 rod, as 2 rods are produced from 1 iron
	else if(istype(W, /obj/item/stack/tile/plasteel))
		loaded = loadwithsheets(W, sheetmultiplier * 0.25, user) // 1 matter for 1 floortile, as 4 tiles are produced from 1 iron
	if(loaded)
		to_chat(user, "<span class='notice'>[src] zawiera teraz [matter]/[max_matter] jednostek materii.</span>")
	else if(istype(W, /obj/item/rcd_upgrade))
		var/obj/item/rcd_upgrade/rcd_up = W
		if(!(upgrade & rcd_up.upgrade))
			upgrade |= rcd_up.upgrade
			if((rcd_up.upgrade & RCD_UPGRADE_SILO_LINK) && !silo_mats)
				silo_mats = AddComponent(/datum/component/remote_materials, "RCD", FALSE, FALSE)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			qdel(W)
	else
		return ..()
	update_icon()	//ensures that ammo counters (if present) get updated

/obj/item/construction/proc/loadwithsheets(obj/item/stack/sheet/S, value, mob/user)
	var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(S.amount, maxsheets)
		S.use(amount_to_use)
		matter += value*amount_to_use
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='notice'>Wkładasz arkusze ([S.name], [amount_to_use] szt.) do [src]. </span>")
		return 1
	to_chat(user, "<span class='warning'>Nie możesz włożyć do [src] więcej arkuszy ([S.name])!</span>")
	return 0

/obj/item/construction/proc/activate()
	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)

/obj/item/construction/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if(prob(20))
		spark_system.start()

/obj/item/construction/proc/useResource(amount, mob/user)
	if(!silo_mats || !silo_link)
		if(matter < amount)
			if(user)
				to_chat(user, no_ammo_message)
			return FALSE
		matter -= amount
		update_icon()
		return TRUE
	else
		var/list/matlist = list(getmaterialref(/datum/material/iron) = 500)
		if(silo_mats.on_hold())
			if(user)
				to_chat(user, "Dostęp do minerałów jest wstrzymany, skontaktuj się z kwatermistrzem.")
			return FALSE
		if(!silo_mats.mat_container?.has_materials(matlist, amount))
			if(user)
				to_chat(user, no_ammo_message)
			return FALSE

		silo_mats.mat_container.use_materials(matlist, amount)
		silo_mats.silo_log(src, "consume", -amount, "build", matlist)
		return TRUE

/obj/item/construction/proc/checkResource(amount, mob/user)
	if(!silo_mats || !silo_link)
		. = matter >= amount
	else
		if(silo_mats.on_hold())
			if(user)
				to_chat(user, "Dostęp do minerałów jest wstrzymany, skontaktuj się z kwatermistrzem.")
			return FALSE
		. = silo_mats.mat_container?.has_materials(list(getmaterialref(/datum/material/iron) = 500), amount)
	if(!. && user)
		to_chat(user, no_ammo_message)
		if(has_ammobar)
			flick("[icon_state]_empty", src)	//somewhat hacky thing to make RCDs with ammo counters actually have a blinking yellow light
	return .

/obj/item/construction/proc/range_check(atom/A, mob/user)
	if(!(user in viewers(7, get_turf(A))))
		to_chat(user, "<span class='warning'>Lampka „Poza zasięgiem” na [src] miga na czerwono.</span>")
		return FALSE
	else
		return TRUE

/obj/item/construction/proc/prox_check(proximity)
	if(proximity)
		return TRUE
	else
		return FALSE

/obj/item/construction/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

#define RCD_DESTRUCTIVE_SCAN_RANGE 10
#define RCD_HOLOGRAM_FADE_TIME (15 SECONDS)
#define RCD_DESTRUCTIVE_SCAN_COOLDOWN (RCD_HOLOGRAM_FADE_TIME + 1 SECONDS)

/obj/item/construction/rcd
	name = "szybki konstruktor (RCD)"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_price = 150
	max_matter = 160
	slot_flags = ITEM_SLOT_BELT
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	has_ammobar = TRUE
	actions_types = list(/datum/action/item_action/rcd_scan)
	var/mode = RCD_FLOORWALL
	var/ranged = FALSE
	var/computer_dir = 1
	var/airlock_type = /obj/machinery/door/airlock
	var/airlock_glass = FALSE // So the floor's rcd_act knows how much ammo to use
	var/window_type = /obj/structure/window/fulltile
	var/advanced_airlock_setting = 1 //Set to 1 if you want more paintjobs available
	var/delay_mod = 1
	var/canRturf = FALSE //Variable for R walls to deconstruct them
	/// Integrated airlock electronics for setting access to a newly built airlocks
	var/obj/item/electronics/airlock/airlock_electronics
	/// AQUILA: otwarta zakładka okna TGUI ("construction" albo "access")
	var/rcd_ui_root = "construction"

	COOLDOWN_DECLARE(destructive_scan_cooldown)

GLOBAL_VAR_INIT(icon_holographic_wall, init_holographic_wall())
GLOBAL_VAR_INIT(icon_holographic_window, init_holographic_window())

// `initial` does not work here. Neither does instantiating a wall/whatever
// and referencing that. I don't know why.
/proc/init_holographic_wall()
	return getHologramIcon(
		icon('nsv13/icons/turf/interior_wall.dmi', "solid"),
		opacity = 1,
	)

/proc/init_holographic_window()
	var/icon/grille_icon = icon('icons/obj/structures.dmi', "grille")
	var/icon/window_icon = icon('icons/obj/smooth_structures/reinforced_window.dmi', "r_window")

	grille_icon.Blend(window_icon, ICON_OVERLAY)

	return getHologramIcon(grille_icon)

/obj/item/construction/rcd/ui_action_click(mob/user, actiontype)
	if(!istype(actiontype, /datum/action/item_action/rcd_scan))
		return ..()
	if (!COOLDOWN_FINISHED(src, destructive_scan_cooldown))
		to_chat(user, "<span class='warning'>[src] cicho brzęczy.</span>")
		return

	COOLDOWN_START(src, destructive_scan_cooldown, RCD_DESTRUCTIVE_SCAN_COOLDOWN)
	rcd_scan(src)

/**
 * Global proc that generates RCD hologram in a range.
 *
 * Arguments:
 * * source - The atom the scans originate from
 * * scan_range - The range of turfs we grab from the source
 * * fade_time - The time for RCD holograms to fade
 */
/proc/rcd_scan(atom/source, scan_range = RCD_DESTRUCTIVE_SCAN_RANGE, fade_time = RCD_HOLOGRAM_FADE_TIME)
	playsound(source, 'sound/items/rcdscan.ogg', 50, vary = TRUE, pressure_affected = FALSE)

	var/turf/source_turf = get_turf(source)
	for(var/turf/open/surrounding_turf in RANGE_TURFS(scan_range, source_turf))
		var/rcd_memory = surrounding_turf.rcd_memory
		if(!rcd_memory)
			continue

		var/skip_to_next_turf = FALSE

		for(var/atom/content_of_turf as anything in surrounding_turf.contents)
			if (content_of_turf.density)
				skip_to_next_turf = TRUE
				break

		if(skip_to_next_turf)
			continue

		var/hologram_icon
		switch(rcd_memory)
			if(RCD_MEMORY_WALL)
				hologram_icon = GLOB.icon_holographic_wall
			if(RCD_MEMORY_WINDOWGRILLE)
				hologram_icon = GLOB.icon_holographic_window

		var/obj/effect/rcd_hologram/hologram = new(surrounding_turf)
		hologram.icon = hologram_icon
		animate(hologram, alpha = 0, time = fade_time, easing = CIRCULAR_EASING | EASE_IN)

/obj/effect/rcd_hologram
	name = "hologram"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/rcd_hologram/Initialize(mapload)
	. = ..()
	QDEL_IN(src, RCD_HOLOGRAM_FADE_TIME)

#undef RCD_DESTRUCTIVE_SCAN_COOLDOWN
#undef RCD_DESTRUCTIVE_SCAN_RANGE
#undef RCD_HOLOGRAM_FADE_TIME

/obj/item/construction/rcd/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] ustawia RCD na „Ściana” i kieruje go sobie do gardła! Wygląda na to, że próbuje popełnić samobójstwo..</span>")
	return (BRUTELOSS)

/obj/item/construction/rcd/verb/toggle_window_type_verb()
	set name = "RCD : Toggle Window Type"
	set category = "Object"
	set src in view(1)

	if(!usr.canUseTopic(src, BE_CLOSE))
		return

	toggle_window_type(usr)

/obj/item/construction/rcd/proc/toggle_window_type(mob/user)
	var/window_type_name
	if (window_type == /obj/structure/window/fulltile)
		window_type = /obj/structure/window/reinforced/fulltile/ship/interior //NSV13
		window_type_name = "szkło zbrojone"
	else
		window_type = /obj/structure/window/fulltile
		window_type_name = "szkło"

	to_chat(user, "<span class='notice'>Zmieniasz tryb okien [src] na: [window_type_name].</span>")

/obj/item/construction/rcd/proc/toggle_silo_link(mob/user)
	if(silo_mats)
		silo_link = !silo_link
		to_chat(user, "<span class='notice'>Zmieniasz stan połączenia [src] ze zdalnym magazynem: [silo_link ? "WŁ." : "WYŁ."].</span>")
	else
		to_chat(user, "<span class='warning'>\t[src] nie ma połączenia ze zdalnym magazynem.</span>")

/obj/item/construction/rcd/proc/get_airlock_image(airlock_type)
	var/obj/machinery/door/airlock/proto = airlock_type
	var/ic = initial(proto.icon)
	var/co = initial(proto.color) //NSV13 allows airlocks with color vars (mining airlocks) to be colored
	var/mutable_appearance/MA = mutable_appearance(ic, "closed")
	if(!initial(proto.glass))
		MA.overlays += "fill_closed"
	MA.color = co //NSV13 colors airlocks
	//Not scaling these down to button size because they look horrible then, instead just bumping up radius.
	return MA

/obj/item/construction/rcd/proc/change_computer_dir(mob/user)
	if(!user)
		return
	var/list/computer_dirs = list(
		"PÓŁNOC" = image(icon = 'icons/mob/radial.dmi', icon_state = "cnorth"),
		"WSCHÓD" = image(icon = 'icons/mob/radial.dmi', icon_state = "ceast"),
		"POŁUDNIE" = image(icon = 'icons/mob/radial.dmi', icon_state = "csouth"),
		"ZACHÓD" = image(icon = 'icons/mob/radial.dmi', icon_state = "cwest")
		)
	var/computerdirs = show_radial_menu(user, src, computer_dirs, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(computerdirs)
		if("PÓŁNOC")
			computer_dir = 1
		if("WSCHÓD")
			computer_dir = 4
		if("POŁUDNIE")
			computer_dir = 2
		if("ZACHÓD")
			computer_dir = 8
/* NSV13 We don't use these airlocks. See nsv13/code/game/object/items/RCD.dm for NSV airlocks
/obj/item/construction/rcd/proc/change_airlock_setting(mob/user)
	if(!user)
		return

	var/list/solid_or_glass_choices = list(
		"Solid" = get_airlock_image(/obj/machinery/door/airlock),
		"Glass" = get_airlock_image(/obj/machinery/door/airlock/glass)
	)

	var/list/solid_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/public),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/engineering),
		"Atmospherics" = get_airlock_image(/obj/machinery/door/airlock/atmos),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/security),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/command),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/medical),
		"Research" = get_airlock_image(/obj/machinery/door/airlock/research),
		"Freezer" = get_airlock_image(/obj/machinery/door/airlock/freezer),
		"Science" = get_airlock_image(/obj/machinery/door/airlock/science),
		"Virology" = get_airlock_image(/obj/machinery/door/airlock/virology),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/mining),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance),
		"External" = get_airlock_image(/obj/machinery/door/airlock/external),
		"External Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/external),
		"Airtight Hatch" = get_airlock_image(/obj/machinery/door/airlock/hatch),
		"Maintenance Hatch" = get_airlock_image(/obj/machinery/door/airlock/maintenance_hatch)
	)

	var/list/glass_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock/glass),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/public/glass),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/engineering/glass),
		"Atmospherics" = get_airlock_image(/obj/machinery/door/airlock/atmos/glass),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/security/glass),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/command/glass),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/medical/glass),
		"Research" = get_airlock_image(/obj/machinery/door/airlock/research/glass),
		"Science" = get_airlock_image(/obj/machinery/door/airlock/science/glass),
		"Virology" = get_airlock_image(/obj/machinery/door/airlock/virology/glass),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/mining/glass),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/glass),
		"External" = get_airlock_image(/obj/machinery/door/airlock/external/glass),
		"External Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/external/glass)
	)

	var/airlockcat = show_radial_menu(user, src, solid_or_glass_choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(airlockcat)
		if("Solid")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src, solid_choices, radius = 42, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock
					if("Public")
						airlock_type = /obj/machinery/door/airlock/public
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research
					if("Freezer")
						airlock_type = /obj/machinery/door/airlock/freezer
					if("Science")
						airlock_type = /obj/machinery/door/airlock/science
					if("Virology")
						airlock_type = /obj/machinery/door/airlock/virology
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance
					if("External")
						airlock_type = /obj/machinery/door/airlock/external
					if("External Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/external
					if("Airtight Hatch")
						airlock_type = /obj/machinery/door/airlock/hatch
					if("Maintenance Hatch")
						airlock_type = /obj/machinery/door/airlock/maintenance_hatch
				airlock_glass = FALSE
			else
				airlock_type = /obj/machinery/door/airlock
				airlock_glass = FALSE

		if("Glass")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src , glass_choices, radius = 42, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock/glass
					if("Public")
						airlock_type = /obj/machinery/door/airlock/public/glass
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering/glass
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos/glass
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security/glass
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command/glass
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical/glass
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research/glass
					if("Science")
						airlock_type = /obj/machinery/door/airlock/science/glass
					if("Virology")
						airlock_type = /obj/machinery/door/airlock/virology/glass
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining/glass
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/glass
					if("External")
						airlock_type = /obj/machinery/door/airlock/external/glass
					if("External Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/external/glass
				airlock_glass = TRUE
			else
				airlock_type = /obj/machinery/door/airlock/glass
				airlock_glass = TRUE
		else
			airlock_type = /obj/machinery/door/airlock
			airlock_glass = FALSE
*/
/obj/item/construction/rcd/proc/rcd_create(atom/A, mob/user)
	var/list/rcd_results = A.rcd_vals(user, src)
	if(!rcd_results)
		return FALSE
	var/delay = rcd_results["delay"] * delay_mod
	var/obj/effect/constructing_effect/rcd_effect = new(get_turf(A), delay, src.mode)
	if(checkResource(rcd_results["cost"], user))
		if(do_after(user, delay, target = A))
			if(checkResource(rcd_results["cost"], user))
				if(A.rcd_act(user, src, rcd_results["mode"]))
					rcd_effect.end_animation()
					useResource(rcd_results["cost"], user)
					activate()
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					return TRUE
	qdel(rcd_effect)

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	airlock_electronics = new(src)
	airlock_electronics.name = "Kontrola dostępu"
	airlock_electronics.holder = src
	GLOB.rcd_list += src

/obj/item/construction/rcd/Destroy()
	QDEL_NULL(airlock_electronics)
	GLOB.rcd_list -= src
	. = ..()

/obj/item/construction/rcd/attack_self(mob/user)
	..()
	ui_interact(user)

// Okno TGUI z tg (RapidConstructionDevice) zamiast menu radialnego.
// Projekty to u nas tryby i ustawienia RCD (śluza, okno, kierunek komputera).
#define RCD_ROOT_CONSTRUCTION "construction"
#define RCD_ROOT_ACCESS "access"

/obj/item/construction/rcd/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/construction/rcd/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RapidConstructionDevice", name)
		ui.open()

/// Zwraca listę kategorii: nazwa kategorii = lista projektów (title, icon, mode + ustawienia)
/obj/item/construction/rcd/proc/get_rcd_designs()
	var/list/designs = list()
	var/list/structures = list(
		list("title" = "podłogi i ściany", "icon" = "border-all", "mode" = RCD_FLOORWALL),
		list("title" = "demontaż", "icon" = "trash", "mode" = RCD_DECONSTRUCT),
	)
	if(upgrade & RCD_UPGRADE_FRAMES)
		structures += list(list("title" = "drabina", "icon" = "stairs", "mode" = RCD_LADDER))
	designs["Konstrukcje"] = structures

	designs["Okna"] = list(
		list("title" = "kratka i szyba", "icon" = "border-none", "mode" = RCD_WINDOWGRILLE, "window_type" = /obj/structure/window/fulltile),
		list("title" = "kratka i wzmocniona szyba", "icon" = "border-style", "mode" = RCD_WINDOWGRILLE, "window_type" = /obj/structure/window/reinforced/fulltile/ship/interior), //NSV13
	)

	var/list/airlocks = list()
	var/list/airlock_types = get_rcd_airlock_types()
	for(var/airlock_name in airlock_types)
		var/list/airlock_info = airlock_types[airlock_name]
		airlocks += list(list("title" = airlock_name, "icon" = airlock_info[2] ? "door-open" : "door-closed", "mode" = RCD_AIRLOCK, "airlock_type" = airlock_info[1], "airlock_glass" = airlock_info[2]))
	designs["Śluzy"] = airlocks

	if(upgrade & RCD_UPGRADE_FRAMES)
		designs["Maszyny"] = list(
			list("title" = "rama maszyny", "icon" = "server", "mode" = RCD_MACHINE),
			list("title" = "rama komputera (północ)", "icon" = "desktop", "mode" = RCD_COMPUTER, "computer_dir" = NORTH),
			list("title" = "rama komputera (wschód)", "icon" = "desktop", "mode" = RCD_COMPUTER, "computer_dir" = EAST),
			list("title" = "rama komputera (południe)", "icon" = "desktop", "mode" = RCD_COMPUTER, "computer_dir" = SOUTH),
			list("title" = "rama komputera (zachód)", "icon" = "desktop", "mode" = RCD_COMPUTER, "computer_dir" = WEST),
		)
	return designs

/// Czy projekt odpowiada obecnym ustawieniom RCD
/obj/item/construction/rcd/proc/is_selected_design(list/design)
	if(design["mode"] != mode)
		return FALSE
	if(design["window_type"] && design["window_type"] != window_type)
		return FALSE
	if(design["airlock_type"] && design["airlock_type"] != airlock_type)
		return FALSE
	if(design["computer_dir"] && design["computer_dir"] != computer_dir)
		return FALSE
	return TRUE

/obj/item/construction/rcd/proc/get_matter_left(mob/user)
	return matter

/obj/item/construction/rcd/borg/get_matter_left(mob/user)
	var/mob/living/silicon/robot/borgy = user
	if(!istype(borgy) || !borgy.cell)
		return 0
	return round(borgy.cell.charge / energyfactor)

/obj/item/construction/rcd/ui_static_data(mob/user)
	var/list/data = airlock_electronics?.ui_static_data(user) || list()
	data["root_categories"] = list(RCD_ROOT_CONSTRUCTION, RCD_ROOT_ACCESS)
	data["silo_upgraded"] = !!(upgrade & RCD_UPGRADE_SILO_LINK)
	data["display_tabs"] = TRUE
	return data

/obj/item/construction/rcd/ui_data(mob/user)
	var/list/data = airlock_electronics?.ui_data(user) || list()
	data["matterLeft"] = get_matter_left(user)
	data["silo_enabled"] = silo_link
	data["selected_root"] = rcd_ui_root
	var/list/categories = list()
	var/list/designs = get_rcd_designs()
	data["selected_category"] = null
	data["selected_design"] = null
	for(var/category in designs)
		var/list/category_designs = list()
		for(var/list/design as anything in designs[category])
			category_designs += list(list("title" = design["title"], "icon" = design["icon"]))
			if(!data["selected_design"] && is_selected_design(design))
				data["selected_category"] = category
				data["selected_design"] = design["title"]
		categories += list(list("cat_name" = category, "designs" = category_designs))
	data["categories"] = categories
	return data

/obj/item/construction/rcd/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("root_category")
			var/new_root = params["root_category"]
			if(new_root in list(RCD_ROOT_CONSTRUCTION, RCD_ROOT_ACCESS))
				rcd_ui_root = new_root
			return TRUE
		if("toggle_silo")
			toggle_silo_link(usr)
			return TRUE
		if("design")
			var/list/designs = get_rcd_designs()
			var/list/category = designs[params["category"]]
			var/index = text2num(params["index"])
			if(!islist(category) || !index || index < 1 || index > length(category))
				return
			var/list/design = category[index]
			mode = design["mode"]
			if(design["window_type"])
				window_type = design["window_type"]
			if(design["airlock_type"])
				airlock_type = design["airlock_type"]
				airlock_glass = design["airlock_glass"]
			if(design["computer_dir"])
				computer_dir = design["computer_dir"]
			playsound(src, 'sound/effects/pop.ogg', 50, 0)
			return TRUE
	// Reszta akcji to ustawienia dostępu wbudowanej elektroniki śluzy
	if(airlock_electronics)
		return airlock_electronics.ui_act(action, params, ui, state)

#undef RCD_ROOT_CONSTRUCTION
#undef RCD_ROOT_ACCESS

/obj/item/construction/rcd/proc/target_check(atom/A, mob/user) // only returns true for stuff the device can actually work with
	if((isturf(A) && A.density && mode==RCD_DECONSTRUCT) || (isturf(A) && !A.density) || (istype(A, /obj/machinery/door/airlock) && mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/grille) || (istype(A, /obj/structure/window) && mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/girder || istype(A, /obj/structure/ladder)))
		return TRUE
	else
		return FALSE

/obj/item/construction/rcd/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!prox_check(proximity))
		return
	rcd_create(A, user)

/// Port Bee #11899: prawy klik RCD zawsze demontuje, niezależnie od wybranego trybu
/obj/item/construction/rcd/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if(!prox_check(proximity_flag))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	rcd_deconstruct(target, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/construction/rcd/proc/rcd_deconstruct(atom/target, mob/user)
	var/old_mode = mode
	mode = RCD_DECONSTRUCT
	. = rcd_create(target, user)
	if(mode == RCD_DECONSTRUCT)
		mode = old_mode

/obj/item/construction/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] zaczyna wibrować i głośno brzęczeć!</b></span>","<span class='danger'><b>[src] zaczyna gwałtownie wibrować!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, PROC_REF(detonate_pulse_explode)), 50)

/obj/item/construction/rcd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1)
	qdel(src)

/obj/item/construction/rcd/update_icon()
	..()
	if(has_ammobar)
		var/ratio = CEILING((matter / max_matter) * ammo_sections, 1)
		cut_overlays()	//To prevent infinite stacking of overlays
		add_overlay("[icon_state]_charge[ratio]")

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/construction/rcd/borg
	no_ammo_message = "<span class='warning'>Za mało ładunku.</span>"
	desc = "Urządzenie do szybkiej budowy ścian i podłóg."
	canRturf = TRUE
	var/energyfactor = 72


/obj/item/construction/rcd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.use(amount * energyfactor) //borgs get 1.3x the use of their RCDs
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.charge >= (amount * energyfactor)
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/syndicate
	icon_state = "ircd"
	item_state = "ircd"
	energyfactor = 66

/obj/item/construction/rcd/loaded
	matter = 160

/obj/item/construction/rcd/combat
	name = "przemysłowy RCD"
	icon_state = "ircd"
	item_state = "ircd"
	max_matter = 500
	matter = 500
	canRturf = TRUE

/obj/item/rcd_ammo
	name = "wkład ze skompresowaną materią"
	desc = "Silnie skompresowana materia do RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	w_class = WEIGHT_CLASS_TINY
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	materials = list(/datum/material/iron=12000, /datum/material/glass=8000)
	var/ammoamt = 40

/obj/item/rcd_ammo/large
	materials = list(/datum/material/iron=48000, /datum/material/glass=32000)
	ammoamt = 160


/obj/item/construction/rcd/combat/admin
	name = "RCD admina"
	max_matter = INFINITY
	matter = INFINITY
	delay_mod = 0.1
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS

// Ranged RCD


/obj/item/construction/rcd/arcd
	name = "zaawansowany szybki konstruktor (ARCD)"
	desc = "Prototypowy RCD działający na odległość i o zwiększonej pojemności. Uzupełnisz go żelazem, plastalą, szkłem albo wkładami ze skompresowaną materią."
	max_matter = 300
	matter = 300
	delay_mod = 0.6
	ranged = TRUE
	icon_state = "arcd"
	item_state = "oldrcd"
	has_ammobar = FALSE

/obj/item/construction/rcd/arcd/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A,user))
		return
	if(target_check(A,user))
		user.Beam(A,icon_state="rped_upgrade",time=30)
	rcd_create(A,user)

/obj/item/construction/rcd/arcd/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if(!range_check(target,user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	user.Beam(target,icon_state="rped_upgrade",time=30)
	rcd_deconstruct(target, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN



// RAPID LIGHTING DEVICE



/obj/item/construction/rld
	name = "szybki oświetlacz (RLD)"
	desc = "Urządzenie do szybkiego rozmieszczania źródeł światła. Uzupełnisz je żelazem, plastalą, szkłem albo wkładami ze skompresowaną materią."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld-5"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	matter = 200
	max_matter = 200
	var/mode = LIGHT_MODE
	slot_flags = ITEM_SLOT_BELT
	actions_types = list(/datum/action/item_action/pick_color)

	var/wallcost = 10
	var/floorcost = 15
	var/launchcost = 5
	var/deconcost = 10

	var/walldelay = 10
	var/floordelay = 10
	var/decondelay = 15

	var/color_choice = null


/obj/item/construction/rld/ui_action_click(mob/user, var/datum/action/A)
	if(istype(A, /datum/action/item_action/pick_color))
		color_choice = input(user,"","Wybierz kolor",color_choice) as color
	else
		..()

/obj/item/construction/rld/update_icon()
	icon_state = "rld-[round(matter/35)]"
	..()


/obj/item/construction/rld/attack_self(mob/user)
	..()
	switch(mode)
		if(REMOVE_MODE)
			mode = LIGHT_MODE
			to_chat(user, "<span class='notice'>Zmieniasz tryb RLD na „Stałe źródło światła”.</span>")
		if(LIGHT_MODE)
			mode = GLOW_MODE
			to_chat(user, "<span class='notice'>Zmieniasz tryb RLD na „Wyrzutnia świateł”.</span>")
		if(GLOW_MODE)
			mode = REMOVE_MODE
			to_chat(user, "<span class='notice'>Zmieniasz tryb RLD na „Rozbiórka”.</span>")


/obj/item/construction/rld/proc/checkdupes(var/target)
	. = list()
	var/turf/checking = get_turf(target)
	for(var/obj/machinery/light/dupe in checking)
		if(istype(dupe, /obj/machinery/light))
			. |= dupe


/obj/item/construction/rld/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A,user))
		return
	var/turf/start = get_turf(src)
	switch(mode)
		if(REMOVE_MODE)
			if(istype(A, /obj/machinery/light/))
				if(checkResource(deconcost, user))
					to_chat(user, "<span class='notice'>Zaczynasz rozbierać [A]...</span>")
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, decondelay, target = A))
						if(!useResource(deconcost, user))
							return 0
						activate()
						qdel(A)
						return TRUE
				return FALSE
		if(LIGHT_MODE)
			if(iswallturf(A))
				var/turf/closed/wall/W = A
				if(checkResource(floorcost, user))
					to_chat(user, "<span class='notice'>Zaczynasz budować lampę ścienną...</span>")
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 0)
					if(do_after(user, floordelay, target = A))
						if(!istype(W))
							return FALSE
						var/list/candidates = list()
						var/turf/open/winner = null
						var/winning_dist = null
						for(var/direction in GLOB.cardinals)
							var/turf/C = get_step(W, direction)
							var/list/dupes = checkdupes(C)
							if(start.CanAtmosPass(C) && !dupes.len)
								candidates += C
						if(!candidates.len)
							to_chat(user, "<span class='warning'>Nie znaleziono prawidłowego celu...</span>")
							playsound(src.loc, 'sound/misc/compiler-failure.ogg', 30, 1)
							return FALSE
						for(var/turf/open/O in candidates)
							if(istype(O))
								var/x0 = O.x
								var/y0 = O.y
								var/contender = cheap_hypotenuse(start.x, start.y, x0, y0)
								if(!winner)
									winner = O
									winning_dist = contender
								else
									if(contender < winning_dist) // lower is better
										winner = O
										winning_dist = contender
						activate()
						if(!useResource(wallcost, user))
							return FALSE
						var/light = get_turf(winner)
						var/align = get_dir(winner, A)
						var/obj/machinery/light/L = new /obj/machinery/light(light)
						L.setDir(align)
						L.color = color_choice
						L.light_color = L.color
						return TRUE
				return FALSE

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(checkResource(floorcost, user))
					to_chat(user, "<span class='notice'>Zaczynasz budować lampę podłogową...</span>")
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 1)
					if(do_after(user, floordelay, target = A))
						if(!istype(F))
							return 0
						if(!useResource(floorcost, user))
							return 0
						activate()
						var/destination = get_turf(A)
						var/obj/machinery/light/floor/FL = new /obj/machinery/light/floor(destination)
						FL.color = color_choice
						FL.light_color = FL.color
						return TRUE
				return FALSE

		if(GLOW_MODE)
			if(useResource(launchcost, user))
				activate()
				to_chat(user, "<span class='notice'>Wystrzeliwujesz świecący patyk!</span>")
				var/obj/item/flashlight/glowstick/G  = new /obj/item/flashlight/glowstick(start)
				G.color = color_choice
				G.light_color = G.color
				G.throw_at(A, 9, 3, user)
				G.on = TRUE
				G.update_brightness()
				return TRUE
			return FALSE

// AQ EDIT - the plumbing constructor lives in aquila/code/modules/plumbing/plumbing_constructor.dm

#define GENERIC_PLUMBING_RCD_COST 15
#define GENERIC_PLUMBING_RCD_DELAY 20

#undef GENERIC_PLUMBING_RCD_COST
#undef GENERIC_PLUMBING_RCD_DELAY

/*
	Upgrades
*/
/obj/item/rcd_upgrade
	name = "dysk zaawansowanych projektów RCD"
	desc = "Wygląda na pusty."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	var/upgrade

/obj/item/rcd_upgrade/frames
	desc = "Zawiera projekty ram maszyn i ram komputerów."
	upgrade = RCD_UPGRADE_FRAMES

/obj/item/rcd_upgrade/simple_circuits
	desc = "Zawiera projekty układów grodzi przeciwpożarowych, alarmów powietrza, alarmów pożarowych, APC i kiepskich ogniw zasilania."
	upgrade = RCD_UPGRADE_SIMPLE_CIRCUITS

/obj/item/rcd_upgrade/silo_link
	desc = "Zawiera ulepszenie RCD o bezpośrednie połączenie z silosem."
	upgrade = RCD_UPGRADE_SILO_LINK

/datum/action/item_action/rcd_scan
	name = "Skan zniszczeń"
	desc = "Skanuje okolicę w poszukiwaniu zniszczeń. Zeskanowane konstrukcje odbudowuje się znacznie szybciej."

#undef GLOW_MODE
#undef LIGHT_MODE
#undef REMOVE_MODE
