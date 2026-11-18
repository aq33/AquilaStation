// AQUILA - okno NIF (NifPanel.tsx). Port z Monkestation (nifs_tgui.dm), bez przełącznika „zachowaj między rundami” i punktów nagród.

/obj/item/organ/cyberimp/brain/nif
	/// Motywy okna do wyboru
	var/static/list/ui_themes = list(
		"default",
		"abductor",
		"hackerman",
		"malfunction",
		"ntos",
		"ntos_darkmode",
		"ntos_terminal",
		"retro",
		"syndicate",
		"wizard",
	)
	/// Obecny motyw okna
	var/current_theme = "default"

/obj/item/organ/cyberimp/brain/nif/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NifPanel", name)
		ui.set_autoupdate(TRUE) // energia i krew zmieniają się co cykl
		ui.open()

/obj/item/organ/cyberimp/brain/nif/ui_state(mob/user)
	return GLOB.conscious_state

// Implant siedzi w nullspace, więc zwykłe sprawdzanie odległości by nie przeszło: okno ma tylko nosiciel
/obj/item/organ/cyberimp/brain/nif/ui_status(mob/user, datum/ui_state/state)
	if(user != linked_mob || owner != linked_mob)
		return UI_CLOSE
	return state.can_use_topic(src, user)

/obj/item/organ/cyberimp/brain/nif/ui_static_data(mob/user)
	var/list/data = list()

	data["loaded_nifsofts"] = list()
	for(var/datum/nifsoft/nifsoft as anything in loaded_nifsofts)
		data["loaded_nifsofts"] += list(list(
			"name" = nifsoft.program_name,
			"desc" = nifsoft.program_desc,
			"active" = nifsoft.active,
			"active_mode" = nifsoft.active_mode,
			"activation_cost" = nifsoft.activation_cost,
			"active_cost" = nifsoft.active_cost,
			"reference" = REF(nifsoft),
			"ui_icon" = nifsoft.ui_icon,
		))

	data["ui_themes"] = ui_themes
	data["max_nifsofts"] = max_nifsofts
	data["max_durability"] = max_durability
	data["max_power"] = max_power_level
	data["max_blood_level"] = BLOOD_VOLUME_NORMAL
	data["product_notes"] = manufacturer_notes
	return data

/obj/item/organ/cyberimp/brain/nif/ui_data(mob/user)
	var/list/data = list()
	data["linked_mob_name"] = linked_mob?.name
	data["current_theme"] = current_theme

	data["power_level"] = power_level
	data["power_usage"] = power_usage

	data["nutrition_drain"] = nutrition_drain
	data["nutrition_level"] = linked_mob?.nutrition
	data["minimum_nutrition"] = minimum_nutrition

	data["blood_level"] = linked_mob?.blood_volume
	data["blood_drain"] = blood_drain
	data["minimum_blood_level"] = minimum_blood_level

	data["durability"] = durability

	var/datum/component/nif_examine/examine_datum = linked_mob?.GetComponent(/datum/component/nif_examine)
	data["examine_text"] = examine_datum ? html_decode(examine_datum.nif_examine_text) : ""
	return data

/obj/item/organ/cyberimp/brain/nif/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_nutrition_drain")
			toggle_nutrition_drain()
			return TRUE

		if("toggle_blood_drain")
			toggle_blood_drain()
			return TRUE

		if("change_examine_text")
			var/datum/component/nif_examine/examine_datum = linked_mob.GetComponent(/datum/component/nif_examine)
			if(!examine_datum)
				return FALSE

			var/text_to_use = trim(copytext_char("[params["new_text"]]", 1, MAX_MESSAGE_LEN))
			if(length_char(text_to_use) <= 6)
				examine_datum.nif_examine_text = NIF_DEFAULT_EXAMINE_TEXT
				return TRUE

			examine_datum.nif_examine_text = html_encode(text_to_use)
			return TRUE

		if("uninstall_nifsoft")
			var/datum/nifsoft/nifsoft_to_remove = locate(params["nifsoft_to_remove"]) in loaded_nifsofts
			if(!nifsoft_to_remove)
				return FALSE

			remove_nifsoft(nifsoft_to_remove)
			return TRUE

		if("change_theme")
			var/target_theme = params["target_theme"]
			if(!target_theme || !(target_theme in ui_themes))
				return FALSE

			current_theme = target_theme
			for(var/datum/nifsoft/installed_nifsoft as anything in loaded_nifsofts)
				installed_nifsoft.update_theme()
			return TRUE

		if("activate_nifsoft")
			var/datum/nifsoft/activated_nifsoft = locate(params["activated_nifsoft"]) in loaded_nifsofts
			if(!activated_nifsoft)
				return FALSE

			activated_nifsoft.activate()
			return TRUE
