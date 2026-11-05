GLOBAL_LIST_EMPTY(custom_outfits) //Admin created outfits

/client/proc/outfit_manager()
	set category = "Debug"
	set name = "Outfit Manager"

	if(!check_rights(R_DEBUG))
		return
	holder.outfit_manager(usr)

// AQUILA: menedżer strojów jako okno TGUI (port z tg: OutfitManager)
/datum/admins/proc/outfit_manager(mob/admin)
	var/datum/outfit_manager/manager = new()
	manager.ui_interact(admin)

/datum/admins/proc/save_outfit(mob/admin,datum/outfit/O)
	O.save_to_file(admin)

/datum/admins/proc/delete_outfit(mob/admin,datum/outfit/O)
	GLOB.custom_outfits -= O
	qdel(O)
	to_chat(admin,"<span class='notice'>Strój usunięty.</span>")

/datum/admins/proc/load_outfit(mob/admin)
	var/outfit_file = input("Wybierz plik JSON ze strojem:", "Plik") as null|file
	if(!outfit_file)
		return
	var/filedata = file2text(outfit_file)
	var/json = json_decode(filedata)
	if(!json)
		to_chat(admin,"<span class='warning'>Błąd dekodowania JSON.</span>")
		return
	var/otype = text2path(json["outfit_type"])
	if(!ispath(otype,/datum/outfit))
		to_chat(admin,"<span class='warning'>Uszkodzony lub przestarzały plik.</span>")
		return
	var/datum/outfit/O = new otype
	if(!O.load_from(json))
		to_chat(admin,"<span class='warning'>Uszkodzony lub przestarzały plik.</span>")
		return
	GLOB.custom_outfits += O

/datum/outfit_manager

/datum/outfit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OutfitManager")
		ui.open()

/datum/outfit_manager/ui_close(mob/user, datum/tgui/tgui)
	qdel(src)

/datum/outfit_manager/proc/entry(datum/outfit/outfit)
	var/vv = FALSE
	var/datum/outfit/varedit/varoutfit = outfit
	if(istype(varoutfit))
		vv = length(varoutfit.vv_values)
	return list(
		"name" = "[outfit.name][vv ? " (VV)" : ""]",
		"ref" = REF(outfit),
	)

/datum/outfit_manager/ui_data(mob/user)
	var/list/data = list()

	var/list/outfits = list()
	for(var/datum/outfit/custom_outfit in GLOB.custom_outfits)
		outfits += list(entry(custom_outfit))
	data["outfits"] = outfits

	return data

/datum/outfit_manager/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/client/admin = usr?.client
	if(!admin?.holder || !check_rights(R_DEBUG))
		return
	. = TRUE

	switch(action)
		if("new")
			admin.open_outfit_editor(new /datum/outfit)
			return
		if("load")
			admin.holder.load_outfit(usr)
			return
		if("copy")
			var/datum/outfit/outfit = tgui_input_list(usr, "Wybierz strój do skopiowania", "Menedżer strojów", subtypesof(/datum/outfit))
			if(isnull(outfit) || !ispath(outfit))
				return
			admin.open_outfit_editor(outfit)
			return

	var/datum/outfit/target_outfit = locate(params["outfit"]) in GLOB.custom_outfits
	if(!istype(target_outfit))
		return
	switch(action)
		if("edit")
			admin.open_outfit_editor(target_outfit)
		if("save")
			admin.holder.save_outfit(usr, target_outfit)
		if("delete")
			admin.holder.delete_outfit(usr, target_outfit)

/client/proc/open_outfit_editor(datum/outfit/target)
	var/datum/outfit_editor/editor = new(usr, target)
	editor.ui_interact(usr)

#define OUTFIT_EDITOR_NAME "Outfit-O-Tron 9000"
#define OUTFIT_EDITOR_SLOTS list("head", "glasses", "ears", "neck", "mask", "uniform", "suit", "gloves", "suit_store", "belt", "id", "l_hand", "back", "r_hand", "l_pocket", "shoes", "r_pocket")

// AQUILA: edytor strojów jako okno TGUI (port z tg: OutfitEditor), zastępuje stary formularz HTML create_outfit
/datum/outfit_editor
	var/client/owner

	var/dummy_key

	var/datum/outfit/drip

/datum/outfit_editor/New(user, datum/outfit/target)
	owner = CLIENT_FROM_VAR(user)

	if(ispath(target, /datum/outfit))
		// kopia do zwykłego /datum/outfit, żeby pre_equip/post_equip podtypu nie nadpisywały zmian z edytora
		var/datum/outfit/source = new target
		drip = new /datum/outfit
		drip.name = source.name
		for(var/slot in OUTFIT_EDITOR_SLOTS)
			drip.vars[slot] = source.vars[slot]
		drip.toggle_helmet = source.toggle_helmet
		drip.internals_slot = source.internals_slot
		drip.box = source.box
		drip.backpack_contents = source.backpack_contents?.Copy()
		drip.implants = source.implants?.Copy()
		drip.accessory = source.accessory
		qdel(source)
	else if(istype(target))
		drip = target
	else
		drip = new /datum/outfit
		drip.name = "Nowy strój"

/datum/outfit_editor/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_editor/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(drip))
		return UI_CLOSE
	return ..()

/datum/outfit_editor/ui_close(mob/user, datum/tgui/tgui)
	unset_busy_human_dummy(dummy_key)
	qdel(src)

/datum/outfit_editor/proc/init_dummy()
	dummy_key = "outfit_editor_[owner]"
	generate_dummy_lookalike(dummy_key, owner?.mob)
	unset_busy_human_dummy(dummy_key)

/datum/outfit_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OutfitEditor", OUTFIT_EDITOR_NAME)
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/outfit_editor/proc/entry(data)
	if(ispath(data, /obj/item))
		var/obj/item/item = data
		return list(
			"path" = item,
			"name" = initial(item.name),
			"desc" = initial(item.desc),
			"sprite" = icon2base64(icon(initial(item.icon), initial(item.icon_state), frame = 1)),
		)

	return data

/datum/outfit_editor/proc/serialize_outfit()
	. = list("name" = drip.name)
	for(var/slot in OUTFIT_EDITOR_SLOTS)
		.[slot] = entry(drip.vars[slot])

/datum/outfit_editor/ui_data(mob/user)
	var/list/data = list()

	data["outfit"] = serialize_outfit()
	data["saveable"] = !GLOB.custom_outfits.Find(drip)

	if(!dummy_key)
		init_dummy()
	var/icon/dummysprite = get_flat_human_icon(null, null, null, dummy_key, list(SOUTH), drip)
	data["dummy64"] = icon2base64(dummysprite)

	return data

/datum/outfit_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!check_rights(R_DEBUG))
		return
	. = TRUE

	var/slot = params["slot"]
	if(slot && !(slot in OUTFIT_EDITOR_SLOTS))
		return
	switch(action)
		if("click")
			choose_item(slot)
		if("ctrlClick")
			choose_any_item(slot)
		if("clear")
			if(slot)
				drip.vars[slot] = null
		if("rename")
			var/newname = tgui_input_text(usr, "Jak chcesz nazwać ten strój?", OUTFIT_EDITOR_NAME, drip.name, MAX_NAME_LEN)
			if(newname)
				drip.name = newname
		if("save")
			GLOB.custom_outfits |= drip
			SStgui.update_user_uis(owner.mob)
		if("delete")
			GLOB.custom_outfits -= drip
			SStgui.update_user_uis(owner.mob)
		if("vv")
			owner.debug_variables(drip)

/datum/outfit_editor/proc/set_item(slot, obj/item/choice)
	if(!choice || !slot)
		return
	if(!ispath(choice, /obj/item))
		tgui_alert(owner, "Nieprawidłowy przedmiot", OUTFIT_EDITOR_NAME, list("No trudno"))
		return
	if(initial(choice.icon_state) == null) //hacky check copied from experimentor code
		var/msg = "Uwaga: ten przedmiot nie ma icon_state, więc najpewniej nie nadaje się do użycia."
		if(tgui_alert(owner, msg, OUTFIT_EDITOR_NAME, list("Użyj mimo to", "Anuluj")) != "Użyj mimo to")
			return

	drip.vars[slot] = choice

/datum/outfit_editor/proc/choose_any_item(slot)
	var/obj/item/choice = pick_closest_path(FALSE)

	if(!choice)
		return

	set_item(slot, choice)

//this proc will try to give a good selection of items that the user can choose from
//it does *not* give a selection of all items that can fit in a slot because lag;
//most notably the hand and pocket slots because they accept pretty much anything
//also stuff that fits in the belt and back slots are scattered pretty much all over the place
/datum/outfit_editor/proc/choose_item(slot)
	var/list/options = list()

	switch(slot)
		if("head")
			options = typesof(/obj/item/clothing/head)
		if("glasses")
			options = typesof(/obj/item/clothing/glasses)
		if("ears")
			options = typesof(/obj/item/radio/headset)

		if("neck")
			options = typesof(/obj/item/clothing/neck)
		if("mask")
			options = typesof(/obj/item/clothing/mask)

		if("uniform")
			options = typesof(/obj/item/clothing/under)
		if("suit")
			options = typesof(/obj/item/clothing/suit)
		if("gloves")
			options = typesof(/obj/item/clothing/gloves)

		if("suit_store")
			var/obj/item/clothing/suit/suit = drip.suit
			if(suit)
				suit = new suit //initial() doesn't like lists
				options = suit.allowed?.Copy()
				qdel(suit)
			if(!length(options)) //nothing will happen, but don't let the user think it's broken
				to_chat(owner, "<span class='warning'>Brak dostępnych opcji dla obecnego stroju wierzchniego.</span>")

		if("belt")
			options = typesof(/obj/item/storage/belt)
		if("id")
			options = typesof(/obj/item/card/id)

		if("back")
			options = typesof(/obj/item/storage/backpack)
			for(var/obj/item/mod/control/pre_equipped/potential_mod as anything in subtypesof(/obj/item/mod/control/pre_equipped))
				if(!(initial(potential_mod.slot_flags) == ITEM_SLOT_BACK))
					continue
				options |= potential_mod

		if("shoes")
			options = typesof(/obj/item/clothing/shoes)

		if("l_hand", "r_hand", "l_pocket", "r_pocket")
			choose_any_item(slot)
			return

	if(!length(options))
		return
	var/option = tgui_input_list(owner, "Wybierz przedmiot", OUTFIT_EDITOR_NAME, options)
	if(isnull(option))
		return
	set_item(slot, option)

#undef OUTFIT_EDITOR_SLOTS
#undef OUTFIT_EDITOR_NAME
