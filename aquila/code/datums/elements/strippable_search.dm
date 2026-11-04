// AQUILA - przeszukiwanie bez rozbierania: Alt+klik na ubranie w oknie rozbierania (StripMenu) otwiera jego kieszenie
// albo schowek (kurtka, plecak, pas, kabura na mundurze), a przedmiot zostaje na człowieku.

/// Przeszukanie trwa połowę czasu zdejmowania przedmiotu, ale nie mniej niż sekundę
#define STRIP_SEARCH_MIN_DELAY (1 SECONDS)

/// Schowek, który da się przeszukać na kimś: własny przedmiotu albo dodatku przypiętego do munduru
/proc/get_strip_search_storage(obj/item/item)
	if(!istype(item))
		return null
	var/datum/component/storage/storage = item.GetComponent(/datum/component/storage)
	if(storage)
		return storage
	var/obj/item/clothing/under/uniform = item
	if(istype(uniform) && uniform.attached_accessory)
		return uniform.attached_accessory.GetComponent(/datum/component/storage)
	return null

/datum/strip_menu/ui_data(mob/user)
	var/list/data = ..()
	var/list/items = data["items"]
	for(var/strippable_key in items)
		var/list/result = items[strippable_key]
		if(!result || !result["name"])
			continue
		var/datum/strippable_item/item_data = strippable.items[strippable_key]
		if(get_strip_search_storage(item_data.get_item(owner)))
			result["searchable"] = TRUE
	return data

/datum/strip_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action != "search")
		return ..()
	// Te same warunki co w /datum/ui_act, bez przełącznika akcji z core
	if(!ui || ui.status != UI_INTERACTIVE)
		return TRUE
	. = TRUE
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/key = params["key"]
	var/datum/strippable_item/strippable_item = strippable.items[key]
	if(isnull(strippable_item) || !strippable_item.should_show(owner, user))
		return
	if(strippable_item.get_obscuring(owner) == STRIPPABLE_OBSCURING_COMPLETELY)
		return
	var/obj/item/item = strippable_item.get_item(owner)
	if(isnull(item) || HAS_TRAIT(item, TRAIT_NO_STRIP))
		return
	var/datum/component/storage/storage = get_strip_search_storage(item)
	if(!storage)
		to_chat(user, "<span class='warning'>[item] nie ma kieszeni do przeszukania.</span>")
		return
	if(LAZYACCESS(interactions, user))
		return
	if(user != owner)
		owner.visible_message(
			"<span class='warning'>[user] przeszukuje [item.name] u [owner].</span>",
			"<span class='userdanger'>[user] przeszukuje twój przedmiot: [item.name].</span>",
			ignored_mobs = user,
		)
		to_chat(user, "<span class='notice'>Przeszukujesz [item.name] u [owner]...</span>")
		owner.log_message("[key_name(owner)] is having [item.name] searched by [key_name(user)]", LOG_ATTACK, color="red")
		user.log_message("[key_name(owner)] is having [item.name] searched by [key_name(user)]", LOG_ATTACK, color="red", log_globally=FALSE)
	LAZYORASSOCLIST(interactions, user, key)
	SStgui.update_uis(src)
	var/searched = user == owner || do_after(user, max(STRIP_SEARCH_MIN_DELAY, item.strip_delay / 2), target = owner)
	if(QDELETED(src))
		return
	LAZYREMOVEASSOC(interactions, user, key)
	SStgui.update_uis(src)
	if(!searched || QDELETED(owner) || QDELETED(storage) || !user.Adjacent(owner))
		return
	// Przedmiot zmienił miejsce w trakcie przeszukania
	if(strippable_item.get_item(owner) != item)
		return
	storage.user_show_to_mob(user)

#undef STRIP_SEARCH_MIN_DELAY
