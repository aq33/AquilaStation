// AQUILA - projektor nakazu (Baystation12 code/game/objects/items/devices/holowarrant.dm, sprite stamtąd w granacie Żandarmerii).
// Nakaz bierze się z kartoteki: osoba ze statusem „do aresztowania” albo „do przeszukania”. Kapitan, Starszy Oficer
// albo Komendant autoryzuje go kartą. Autoryzowany nakaz przeszukania otwiera drzwi jednego wybranego obszaru temu,
// kto ma projektor przy sobie. Zmiana statusu w kartotece unieważnia nakaz.

/obj/item/holowarrant
	name = "projektor nakazu"
	desc = "Wyświetla nakaz z kartoteki Żandarmerii. Nakaz trzeba autoryzować kartą Kapitana, Starszego Oficera albo Komendanta."
	icon = 'aquila/icons/obj/security/holowarrant.dmi'
	icon_state = "holowarrant"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	/// Rekord ochrony z nakazem (weakref, bo rekord może zniknąć)
	var/datum/weakref/record_ref
	/// Imię celu, „Arrest” albo „Search” i powód w chwili załadowania
	var/target_name
	var/warrant_type
	var/reason
	/// Kto autoryzował (null = nieautoryzowany)
	var/authorized_by
	/// Obszar przeszukania (tylko nakaz przeszukania)
	var/area/search_area
	/// Mob, któremu projektor daje dostęp do drzwi
	var/mob/living/holder

/obj/item/holowarrant/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_AQ_CRIMINAL_STATUS_CHANGED, PROC_REF(on_status_changed))

/obj/item/holowarrant/Destroy()
	set_holder(null)
	search_area = null
	return ..()

/obj/item/holowarrant/update_icon_state()
	icon_state = target_name ? "holowarrant_filled" : "holowarrant"
	return ..()

/obj/item/holowarrant/proc/warrant_title()
	return warrant_type == "Search" ? "nakaz przeszukania" : "nakaz aresztowania"

/obj/item/holowarrant/proc/warrant_text()
	if(!target_name)
		return "Projektor jest pusty."
	. = "<b>[capitalize(warrant_title())]</b>: [target_name]. Powód: [reason || "brak"]."
	if(warrant_type == "Search")
		. += " Obszar: [search_area ? search_area.name : "nie wskazano"]."
	. += authorized_by ? " Autoryzował: [authorized_by]." : " <i>Nieautoryzowany.</i>"

/obj/item/holowarrant/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[warrant_text()]</span>"

/// Wybór osoby z nakazem z kartoteki (i obszaru przy przeszukaniu)
/obj/item/holowarrant/attack_self(mob/user)
	var/list/choices = list()
	for(var/datum/data/record/record in GLOB.data_core.security)
		if(record.fields["criminal"] in list("Arrest", "Search"))
			choices["[record.fields["name"]] ([aq_criminal_status_name(record.fields["criminal"])])"] = record
	if(!length(choices))
		to_chat(user, "<span class='warning'>W kartotece nikt nie ma statusu „do aresztowania” ani „do przeszukania”.</span>")
		return
	var/picked = tgui_input_list(user, "Czyj nakaz wyświetlić?", name, choices)
	if(!picked || !user.is_holding(src))
		return
	var/datum/data/record/record = choices[picked]
	var/area/where
	if(record.fields["criminal"] == "Search")
		var/list/areas = list()
		var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
		for(var/area/A as anything in GLOB.sortedAreas)
			if(A.z in station_levels)
				areas[A.name] = A
		var/area_name = tgui_input_list(user, "Który obszar obejmuje przeszukanie?", name, areas)
		if(!area_name || !user.is_holding(src))
			return
		where = areas[area_name]
	load_warrant(record, where)
	to_chat(user, "<span class='notice'>Załadowano [warrant_title()]: [target_name]. Teraz potrzebna autoryzacja kartą.</span>")

/obj/item/holowarrant/proc/load_warrant(datum/data/record/record, area/where)
	record_ref = WEAKREF(record)
	target_name = record.fields["name"]
	warrant_type = record.fields["criminal"]
	reason = aq_last_status_reason(record)
	search_area = where
	authorized_by = null
	update_appearance()

/obj/item/holowarrant/proc/clear_warrant()
	record_ref = null
	target_name = null
	warrant_type = null
	reason = null
	search_area = null
	authorized_by = null
	update_appearance()

/// Kapitan, Starszy Oficer albo Komendant
/obj/item/holowarrant/proc/can_authorize(obj/item/card/id/id)
	var/list/access = id?.GetAccess() || list()
	return (ACCESS_CAPTAIN in access) || (ACCESS_HOP in access) || (ACCESS_HOS in access)

/obj/item/holowarrant/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/id = W.GetID()
	if(!id)
		return ..()
	if(!target_name)
		to_chat(user, "<span class='warning'>Projektor jest pusty.</span>")
		return TRUE
	if(!can_authorize(id))
		to_chat(user, "<span class='warning'>Nakaz autoryzuje tylko Kapitan, Starszy Oficer albo Komendant.</span>")
		return TRUE
	authorize(id.assignment ? "[id.registered_name], [id.assignment]" : id.registered_name)
	return TRUE

/obj/item/holowarrant/proc/authorize(author)
	authorized_by = author
	aq_security_announce("Nakaz: [warrant_title()] dla: [target_name] autoryzował [author][warrant_type == "Search" && search_area ? " (obszar: [search_area.name])" : ""].")
	aq_security_hud_message("Autoryzowano [warrant_title()]: [target_name].")
	update_appearance()

/// Pokazanie nakazu komuś (klik na osobę)
/obj/item/holowarrant/attack(mob/living/target, mob/living/user, params)
	if(!target_name)
		return ..()
	user.visible_message("<span class='notice'>[user] pokazuje [target] hologram nakazu.</span>", "<span class='notice'>Pokazujesz [target] hologram nakazu.</span>")
	to_chat(target, "<span class='notice'>[warrant_text()]</span>")
	to_chat(user, "<span class='notice'>[warrant_text()]</span>")
	return TRUE

/// Status w kartotece zmienił się z „do aresztowania” albo „do przeszukania”: nakaz wygasa
/obj/item/holowarrant/proc/on_status_changed(datum/source, datum/data/record/record, old_status, new_status)
	SIGNAL_HANDLER
	if(!record_ref || record_ref.resolve() != record || new_status == warrant_type)
		return
	var/mob/viewer = holder || (ismob(loc) ? loc : null)
	if(viewer)
		to_chat(viewer, "<span class='warning'>[capitalize(warrant_title())] dla: [target_name] wygasł (zmiana statusu w kartotece).</span>")
	clear_warrant()

// --- Dostęp do drzwi obszaru przeszukania ---

/obj/item/holowarrant/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	set_holder(user)

/obj/item/holowarrant/dropped(mob/user, silent = FALSE)
	. = ..()
	set_holder(null)

/obj/item/holowarrant/proc/set_holder(mob/living/new_holder)
	if(holder == new_holder)
		return
	if(holder)
		UnregisterSignal(holder, COMSIG_MOB_ALLOWED)
	holder = isliving(new_holder) ? new_holder : null
	if(holder)
		RegisterSignal(holder, COMSIG_MOB_ALLOWED, PROC_REF(grant_search_access))

/obj/item/holowarrant/proc/grant_search_access(mob/source, obj/target)
	SIGNAL_HANDLER
	if(warrant_type != "Search" || !authorized_by || !search_area || !istype(target, /obj/machinery/door))
		return FALSE
	return get_area(target) == search_area

/// Powód ostatniej zmiany statusu z historii rekordu (wpis „… Powód: X”)
/proc/aq_last_status_reason(datum/data/record/record)
	var/counter = 1
	var/last
	while(record.fields["com_[counter]"])
		last = record.fields["com_[counter]"]
		counter++
	if(!last)
		return null
	var/pos = findtext(last, "Powód: ")
	return pos ? copytext(last, pos + length("Powód: ")) : null
