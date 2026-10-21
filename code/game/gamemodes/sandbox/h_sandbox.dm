
// AQUILA EDIT - panel piaskownicy w TGUI (okno "SandboxPanel") zamiast HTML i Topic()

GLOBAL_VAR_INIT(hsboxspawn, TRUE)

/mob
	var/datum/hSB/sandbox = null
/mob/proc/CanBuild()
	sandbox = new/datum/hSB
	sandbox.owner = src.ckey
	if(src.client.holder)
		sandbox.admin = 1

	add_verb(/mob/proc/sandbox_panel)
/mob/proc/sandbox_panel()
	set name = "Sandbox Panel"
	set category = "Sandbox"
	if(sandbox)
		sandbox.update()

/datum/hSB
	var/owner = null
	var/admin = 0
	/// Otwarta lista przedmiotów: null, "clothing", "reagents" albo "other"
	var/browse_category

	/// Listy typów do spawnowania, liczone raz
	var/static/list/category_items
	//items that shouldn't spawn on the floor because they would bug or act weird
	var/static/list/spawn_forbidden = list(
		/obj/item/tk_grab, /obj/item/implant, // not implanter, the actual thing that is inside you
		/obj/item/assembly, /obj/item/onetankbomb,
		/obj/item/small_delivery, /obj/item/projectile,
		/obj/item/borg/sight, /obj/item/borg/stun, /obj/item/robot_module)

	/// Przyciski panelu: grupa -> lista (nazwa, komenda, ścieżka)
	var/static/list/buttons = list(
		"Sprzęt kosmiczny" = list(
			list("Załóż strój kosmiczny (z jetpackiem)", "hsbsuit", null),
			list("Maska gazowa", "hsbspawn", /obj/item/clothing/mask/gas),
			list("Awaryjna butla z powietrzem", "hsbspawn", /obj/item/tank/internals/emergency_oxygen/double),
		),
		"Narzędzia" = list(
			list("Latarka", "hsbspawn", /obj/item/flashlight),
			list("Skrzynka z narzędziami", "hsbspawn", /obj/item/storage/toolbox/mechanical),
			list("BSRPED (poziom 4)", "hsbspawn", /obj/item/storage/part_replacer/bluespace/tier4),
			list("Pas z narzędziami", "hsbspawn", /obj/item/storage/belt/utility/chief/full),
			list("Wymieniacz świetlówek", "hsbspawn", /obj/item/lightreplacer),
			list("Apteczka", "hsbspawn", /obj/item/storage/firstaid/regular),
			list("Karta z pełnym dostępem", "hsbaaid", null),
		),
		"Materiały budowlane" = list(
			list("50 drewna", "hsbwood", null),
			list("50 żelaza", "hsbiron", null),
			list("50 plastali", "hsbplasteel", null),
			list("50 szkła zbrojonego", "hsbrglass", null),
			list("50 szkła", "hsbglass", null),
			list("Pełny zwój kabla", "hsbspawn", /obj/item/stack/cable_coil),
			list("Ogniwo o hiperpojemności", "hsbspawn", /obj/item/stock_parts/cell/hyper),
			list("Ogniwo o nieskończonej pojemności", "hsbspawn", /obj/item/stock_parts/cell/infinite),
			list("RCD", "hsbrcd", null),
			list("Amunicja do RCD", "hsb_safespawn", /obj/item/rcd_ammo),
		),
		"Różne" = list(
			list("Odkurzacz powietrza", "hsbscrubber", null),
			list("Dysk technologiczny (debug)", "hsbspawn", /obj/item/disk/tech_disk/debug),
			list("Wszystkie materiały", "hsbspawn", /obj/structure/closet/syndicate/resources/everything),
			list("Zbiornik z wodą", "hsbspawn", /obj/structure/reagent_dispensers/watertank),
		),
		"Boty" = list(
			list("Cleanbot", "hsbspawn", /mob/living/simple_animal/bot/cleanbot),
			list("Floorbot", "hsbspawn", /mob/living/simple_animal/bot/floorbot),
			list("Medbot", "hsbspawn", /mob/living/simple_animal/bot/medbot),
		),
		"Kanistry" = list(
			list("Kanister O2", "hsbspawn", /obj/machinery/portable_atmospherics/canister/oxygen),
			list("Kanister z powietrzem", "hsbspawn", /obj/machinery/portable_atmospherics/canister/air),
		),
	)

	/// Przyciski tylko dla adminów
	var/static/list/admin_buttons = list(
		"Kanistry (admin)" = list(
			list("Kanister z plazmą", "hsbspawn", /obj/machinery/portable_atmospherics/canister/toxins),
			list("Kanister z CO2", "hsbspawn", /obj/machinery/portable_atmospherics/canister/carbon_dioxide),
			list("Kanister z azotem", "hsbspawn", /obj/machinery/portable_atmospherics/canister/nitrogen),
			list("Kanister z N2O", "hsbspawn", /obj/machinery/portable_atmospherics/canister/nitrous_oxide),
		),
	)

/datum/hSB/proc/update()
	ui_interact(usr)

/datum/hSB/ui_state(mob/user)
	return GLOB.always_state

/datum/hSB/ui_status(mob/user, datum/ui_state/state)
	if(!user || user.ckey != owner)
		return UI_CLOSE
	return ..()

/datum/hSB/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SandboxPanel")
		ui.open()

/datum/hSB/proc/get_category_items(category)
	if(!category_items)
		category_items = list()
		var/list/clothing = subtypesof(/obj/item/clothing)
		var/list/reagents = subtypesof(/obj/item/reagent_containers)
		var/list/other = subtypesof(/obj/item/) - typesof(/obj/item/clothing) - typesof(/obj/item/reagent_containers)
		for(var/typekey in spawn_forbidden)
			clothing -= typesof(typekey)
			reagents -= typesof(typekey)
			other -= typesof(typekey)
		category_items["clothing"] = reverseRange(clothing)
		category_items["reagents"] = reverseRange(reagents)
		category_items["other"] = reverseRange(other)
	return category_items[category]

/datum/hSB/proc/button_groups()
	var/list/groups = list()
	if(admin)
		for(var/group in admin_buttons)
			groups[group] = admin_buttons[group]
	for(var/group in buttons)
		groups[group] = buttons[group]
	return groups

/datum/hSB/ui_static_data(mob/user)
	var/list/data = list()
	data["admin"] = !!admin
	var/list/groups = list()
	var/list/all_groups = button_groups()
	for(var/group in all_groups)
		var/list/group_buttons = list()
		var/index = 0
		for(var/list/button as anything in all_groups[group])
			index++
			group_buttons += list(list("name" = button[1], "index" = index))
		groups += list(list("title" = group, "buttons" = group_buttons))
	data["groups"] = groups
	data["browse_category"] = browse_category
	var/list/items = list()
	if(browse_category)
		for(var/path in get_category_items(browse_category))
			items += "[path]"
	data["items"] = items
	return data

/datum/hSB/ui_data(mob/user)
	var/list/data = list()
	data["spawning_enabled"] = GLOB.hsboxspawn
	data["autoclose"] = CONFIG_GET(flag/sandbox_autoclose)
	return data

/datum/hSB/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!usr || usr.ckey != owner)
		return
	switch(action)
		if("button")
			if(!istext(params["group"]))
				return
			var/list/all_groups = button_groups()
			var/list/group = all_groups[params["group"]]
			var/index = text2num("[params["index"]]")
			if(!islist(group) || !index || index > length(group))
				return
			var/list/button = group[index]
			do_action(usr, button[2], button[3])
			return TRUE
		if("toggle_spawning")
			do_action(usr, "hsbtobj")
			return TRUE
		if("toggle_autoclose")
			do_action(usr, "hsbtac")
			return TRUE
		if("browse")
			var/category = params["category"]
			if(category && !(category in list("clothing", "reagents", "other")))
				return
			if(category && !GLOB.hsboxspawn)
				return
			browse_category = category
			update_static_data(usr, ui)
			return TRUE
		if("spawn_item")
			if(!browse_category)
				return
			var/typepath = text2path(params["path"])
			if(!typepath || !(typepath in get_category_items(browse_category)))
				return
			do_action(usr, "hsb_safespawn", typepath)
			if(CONFIG_GET(flag/sandbox_autoclose))
				browse_category = null
				update_static_data(usr, ui)
			return TRUE

/// Wykonuje akcję panelu piaskownicy (dawne Topic(), tylko ścieżki z whitelisty panelu)
/datum/hSB/proc/do_action(mob/user, command, typepath)
	switch(command)
		//
		// Admin: toggle spawning
		//
		if("hsbtobj")
			if(!admin) return
			if(GLOB.hsboxspawn)
				to_chat(world, "<span class='boldannounce'>Sandbox:</span> <b>\black[user.key] has disabled object spawning!</b>")
				GLOB.hsboxspawn = FALSE
				return
			else
				to_chat(world, "<span class='boldnotice'>Sandbox:</span> <b>\black[user.key] has enabled object spawning!</b>")
				GLOB.hsboxspawn = TRUE
				return
		//
		// Admin: Toggle auto-close
		//
		if("hsbtac")
			if(!admin) return
			var/sbac = CONFIG_GET(flag/sandbox_autoclose)
			if(sbac)
				to_chat(world, "<span class='boldnotice'>Sandbox:</span> <b>\black [user.key] has removed the object spawn limiter.</b>")
			else
				to_chat(world, "<span class='danger'>Sandbox:</span> <b>\black [user.key] has added a limiter to object spawning.  The window will now auto-close after use.</b>")
			CONFIG_SET(flag/sandbox_autoclose, !sbac)
			return
		//
		// Spacesuit with full air jetpack set as internals
		//
		if("hsbsuit")
			var/mob/living/carbon/human/P = user
			if(!istype(P)) return
			if(P.wear_suit)
				P.wear_suit.forceMove(P.drop_location())
				P.wear_suit.layer = initial(P.wear_suit.layer)
				P.wear_suit.plane = initial(P.wear_suit.plane)
				P.wear_suit = null
			P.wear_suit = new/obj/item/clothing/suit/space(P)
			P.wear_suit.layer = ABOVE_HUD_LAYER
			P.wear_suit.plane = ABOVE_HUD_PLANE
			P.update_inv_wear_suit()
			if(P.head)
				P.head.forceMove(P.drop_location())
				P.head.layer = initial(P.head.layer)
				P.head.plane = initial(P.head.plane)
				P.head = null
			P.head = new/obj/item/clothing/head/helmet/space(P)
			P.head.layer = ABOVE_HUD_LAYER
			P.head.plane = ABOVE_HUD_PLANE
			P.update_inv_head()
			if(P.wear_mask)
				P.wear_mask.forceMove(P.drop_location())
				P.wear_mask.layer = initial(P.wear_mask.layer)
				P.wear_mask.plane = initial(P.wear_mask.plane)
				P.wear_mask = null
			P.wear_mask = new/obj/item/clothing/mask/gas(P)
			P.wear_mask.layer = ABOVE_HUD_LAYER
			P.wear_mask.plane = ABOVE_HUD_PLANE
			P.update_inv_wear_mask()
			if(P.back)
				P.back.forceMove(P.drop_location())
				P.back.layer = initial(P.back.layer)
				P.back.plane = initial(P.back.plane)
				P.back = null
			P.back = new/obj/item/tank/jetpack/oxygen(P)
			P.back.layer = ABOVE_HUD_LAYER
			P.back.plane = ABOVE_HUD_PLANE
			P.update_inv_back()
			P.internal = P.back
			P.update_internals_hud_icon(1)

		if("hsbscrubber") // This is beyond its normal capability but this is sandbox and you spawned one, I assume you need it
			var/obj/hsb = new/obj/machinery/portable_atmospherics/scrubber{volume_rate=50*ONE_ATMOSPHERE;on=1}(user.loc)
			hsb.update_icon() // hackish but it wasn't meant to be spawned I guess?

		//
		// Stacked Materials
		//

		if("hsbrglass")
			new/obj/item/stack/sheet/rglass{amount=50}(user.loc)

		if("hsbiron")
			new/obj/item/stack/sheet/iron{amount=50}(user.loc)

		if("hsbplasteel")
			new/obj/item/stack/sheet/plasteel{amount=50}(user.loc)

		if("hsbglass")
			new/obj/item/stack/sheet/glass{amount=50}(user.loc)

		if("hsbwood")
			new/obj/item/stack/sheet/mineral/wood{amount=50}(user.loc)

		//
		// All access ID
		//
		if("hsbaaid")
			var/obj/item/card/id/gold/ID = new(user.loc)
			ID.registered_name = user.real_name
			ID.assignment = "Sandbox"
			ID.access = get_all_accesses()
			ID.update_label()

		//
		// RCD - starts with full clip
		// Spawn check due to grief potential (destroying floors, walls, etc)
		//
		if("hsbrcd")
			if(!GLOB.hsboxspawn) return

			new/obj/item/construction/rcd/combat(user.loc)

		//
		// Safespawn checks to see if spawning is disabled.
		//
		if("hsb_safespawn")
			if(!GLOB.hsboxspawn)
				return
			if(!ispath(typepath))
				return
			new typepath(user.loc)
		//
		// For everything else in the button list
		//
		if("hsbspawn")
			if(!ispath(typepath))
				return
			new typepath(user.loc)
