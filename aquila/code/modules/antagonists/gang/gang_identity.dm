// Szef wybiera nazwę gangu i mundur w oknie w stylu panelu gangu (tgui/packages/tgui/interfaces/GangIdentity.tsx).
// Zestawy mundurów pochodzą z gotowych gangów, bez tych, które noszą już rywale.

/datum/team/gang
	/// Otwarte okno wyboru nazwy i munduru
	var/datum/gang_identity_picker/identity_picker

/datum/team/gang/proc/choose_identity(datum/mind/boss_mind)
	var/mob/user = boss_mind?.current
	if(!user?.client)
		return
	if(!identity_picker)
		identity_picker = new(src, boss_mind)
	identity_picker.ui_interact(user)

/// Zmienia nazwę i mundur gangu. Zwraca tekst błędu albo null, gdy się udało.
/datum/team/gang/proc/apply_identity(new_name, datum/team/gang/preset)
	new_name = reject_bad_text(new_name, 24, ascii_only = FALSE)
	if(new_name && new_name != name)
		for(var/datum/team/gang/other as anything in GLOB.gangs)
			if(other != src && lowertext(other.name) == lowertext(new_name))
				return "Rywale już noszą tę nazwę."
	if(preset)
		if(!ispath(preset, /datum/team/gang) || uniform_taken(initial(preset.outfit)))
			return "Rywale już noszą ten mundur."
		outfit = initial(preset.outfit)
		hat = initial(preset.hat)
		suit = initial(preset.suit)
	if(new_name)
		name = new_name
	var/obj/item/clothing/under/outfit_type = outfit
	var/obj/item/clothing/head/hat_type = hat
	message_gang("Gang nazywa się teraz <b>[name]</b>. Mundur: [initial(outfit_type.name)] i [initial(hat_type.name)].")
	return null

/datum/gang_identity_picker
	var/datum/team/gang/gang
	var/datum/mind/boss_mind
	/// Komunikat z ostatniej nieudanej próby
	var/error

/datum/gang_identity_picker/New(datum/team/gang/gang, datum/mind/boss_mind)
	. = ..()
	src.gang = gang
	src.boss_mind = boss_mind

/datum/gang_identity_picker/Destroy()
	if(gang?.identity_picker == src)
		gang.identity_picker = null
	gang = null
	boss_mind = null
	return ..()

/datum/gang_identity_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/gang_identity_picker/ui_status(mob/user, datum/ui_state/state)
	if(!boss_mind || user.mind != boss_mind || QDELETED(gang))
		return UI_CLOSE
	return ..()

/datum/gang_identity_picker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GangIdentity", "Tożsamość gangu")
		ui.open()

/// Ikona typu przedmiotu dla okien TGUI (base64 PNG). Kombinezony mają w .dmi tylko szary szablon,
/// więc kolor bierzemy z greyscale_colors albo z color, tak jak przedmiot w grze.
/proc/aq_item_type_icon(obj/item/item_type)
	var/config = initial(item_type.greyscale_config)
	var/colors = initial(item_type.greyscale_colors)
	var/icon/source = (config && colors) ? SSgreyscale.GetColoredIconByType(config, colors) : initial(item_type.icon)
	var/icon/result = icon(source, initial(item_type.icon_state), SOUTH, 1)
	var/tint = initial(item_type.color)
	if(istext(tint))
		result.Blend(tint, ICON_MULTIPLY)
	return icon2base64(result)

/// Ikony zestawów liczone raz na rundę (base64 PNG kombinezonu i nakrycia głowy)
/proc/aq_gang_uniform_sets()
	var/static/list/sets
	if(sets)
		return sets
	sets = list()
	for(var/datum/team/gang/preset as anything in subtypesof(/datum/team/gang))
		var/obj/item/clothing/under/preset_outfit = initial(preset.outfit)
		var/obj/item/clothing/head/preset_hat = initial(preset.hat)
		if(!preset_outfit || !preset_hat)
			continue
		sets += list(list(
			"path" = "[preset]",
			"outfit" = "[preset_outfit]",
			"uniform_name" = initial(preset_outfit.name),
			"hat_name" = initial(preset_hat.name),
			"uniform_icon" = aq_item_type_icon(preset_outfit),
			"hat_icon" = aq_item_type_icon(preset_hat),
		))
	return sets

/datum/gang_identity_picker/ui_static_data(mob/user)
	var/list/data = list()
	data["sets"] = aq_gang_uniform_sets()
	return data

/datum/gang_identity_picker/ui_data(mob/user)
	var/list/data = list()
	data["gang_name"] = gang.name
	data["gang_color"] = gang.color
	data["current_outfit"] = "[gang.outfit]"
	data["error"] = error
	var/list/taken = list()
	for(var/datum/team/gang/other as anything in GLOB.gangs)
		if(other != gang && other.outfit)
			taken += "[other.outfit]"
	data["taken"] = taken
	return data

/datum/gang_identity_picker/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action != "confirm")
		return
	var/datum/team/gang/preset = text2path(params["set"])
	error = gang.apply_identity(params["name"], preset)
	if(error)
		return TRUE
	SStgui.close_uis(src)
	qdel(src)
	return TRUE
