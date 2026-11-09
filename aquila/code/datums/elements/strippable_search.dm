// AQUILA - przeszukiwanie bez rozbierania: Alt+klik na ubranie w oknie rozbierania (StripMenu) otwiera jego kieszenie
// albo schowek (kurtka, plecak, pas, kabura na mundurze), a przedmiot zostaje na człowieku.
// Każdy przedmiot wyjęty z cudzego schowka znowu kosztuje czas i ostrzega właściciela, tak jak zdejmowanie,
// a okno schowka zamyka się, gdy przeszukiwany odejdzie.

/// Przeszukanie i wyjęcie przedmiotu trwa połowę czasu zdejmowania, ale nie mniej niż sekundę
#define STRIP_SEARCH_MIN_DELAY (1 SECONDS)

/// Schowek, który da się przeszukać na kimś. Dodatek z kieszeniami (kabura) przy przypięciu oddaje swój schowek mundurowi.
/proc/get_strip_search_storage(obj/item/item)
	if(!istype(item))
		return null
	return item.GetComponent(/datum/component/storage)

/// Ile trwa przeszukanie albo wyjęcie przedmiotu
/proc/strip_search_delay(obj/item/item)
	return max(STRIP_SEARCH_MIN_DELAY, item.strip_delay / 2)

/datum/strip_menu
	/// Kto ma otwarty schowek przeszukiwanego (mob -> schowek), żeby zamknąć go, gdy przeszukiwany odejdzie
	var/list/searching_users

/datum/strip_menu/Destroy()
	for(var/mob/user as anything in searching_users)
		UnregisterSignal(user, COMSIG_PARENT_QDELETING)
	searching_users = null
	return ..()

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
	// Kieszeń to już przeszukiwanie: Alt+klik opróżnia ją tak samo jak zwykły klik, zamiast „nie ma kieszeni”.
	// Pustej kieszeni nie ruszamy: „use” włożyłby do niej przedmiot z ręki przeszukującego.
	var/datum/strippable_item/pocket = strippable.items[params["key"]]
	if(istype(pocket, /datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket))
		if(isnull(pocket.get_item(owner)))
			return TRUE
		return ..("use", params, ui, state)
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
		if(istype(strippable_item, /datum/strippable_item/mob_item_slot/jumpsuit))
			to_chat(user, "<span class='warning'>Kieszenie munduru to osobne pola w tym oknie: kliknij kieszeń, żeby ją opróżnić bez zdejmowania munduru.</span>")
		else
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
	var/searched = user == owner || do_after(user, strip_search_delay(item), target = owner)
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
	if(user != owner && user.active_storage == storage)
		watch_search(user, storage)

/// Zamyka schowek przeszukującemu, gdy przeszukiwany odejdzie (sam przeszukujący zamyka go sobie w /mob/living/Move)
/datum/strip_menu/proc/watch_search(mob/user, datum/component/storage/storage)
	if(!length(searching_users))
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	if(!(user in searching_users))
		RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(forget_searcher))
	LAZYSET(searching_users, user, storage)

/datum/strip_menu/proc/on_owner_moved(datum/source)
	SIGNAL_HANDLER

	for(var/mob/user as anything in searching_users)
		var/datum/component/storage/storage = searching_users[user]
		if(QDELETED(storage) || user.active_storage != storage)
			forget_searcher(user)
			continue
		if(!user.CanReach(storage.parent, view_only = TRUE))
			storage.close(user)
			forget_searcher(user)

/datum/strip_menu/proc/forget_searcher(mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_PARENT_QDELETING)
	LAZYREMOVE(searching_users, user)
	if(!length(searching_users))
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/// Kto nosi ten przedmiot w swoim schowku, jeśli to nie user: wtedy wyjęcie go jest kradzieżą z kieszeni
/obj/item/proc/strip_search_holder(mob/user)
	if(!(item_flags & IN_STORAGE))
		return null
	var/mob/living/holder = get(loc, /mob/living)
	if(!holder || holder == user)
		return null
	return holder

/obj/item/attack_hand(mob/user)
	var/mob/living/holder = strip_search_holder(user)
	if(!holder || !isliving(user))
		return ..()
	var/atom/storage_atom = loc
	holder.visible_message(
		"<span class='warning'>[user] próbuje coś wyjąć z [storage_atom.name] u [holder].</span>",
		"<span class='userdanger'>[user] próbuje coś wyjąć z twojego przedmiotu: [storage_atom.name].</span>",
		ignored_mobs = user,
	)
	to_chat(user, "<span class='notice'>Wyjmujesz [name] z [storage_atom.name] u [holder]...</span>")
	if(!do_after(user, strip_search_delay(src), target = holder))
		return TRUE
	// W trakcie ktoś przełożył przedmiot albo przeszukujący odszedł
	if(loc != storage_atom || !user.CanReach(src))
		return TRUE
	holder.log_message("[key_name(holder)] had [name] taken from [storage_atom.name] by [key_name(user)]", LOG_ATTACK, color="red")
	user.log_message("[key_name(holder)] had [name] taken from [storage_atom.name] by [key_name(user)]", LOG_ATTACK, color="red", log_globally=FALSE)
	return ..()

#undef STRIP_SEARCH_MIN_DELAY
