// „Po sprzęt” z konsoli drużyn XO: każdy członek drużyny dostaje własny znacznik przy najbliższym działającym
// automacie drużyny na swoim okręcie (najpierw ten sam pokład, potem najbliższy pokład, potem odległość).
// Znacznik widzi tylko on, w świecie i jako wskaźnik na krawędzi ekranu (squad_pointers.dm). Wygasa jak inne
// znaczniki albo wcześniej, gdy członek otworzy ten automat.

/// Automat na pokładzie poza zasięgiem aq_deck_offset() (ten sam okręt) liczymy jako tak odległy
#define SQUAD_GEAR_FAR_DECKS 100

/// Automaty drużyn na mapie
GLOBAL_LIST_EMPTY(aq_squad_vendors)

/obj/machinery/squad_vendor/Initialize(mapload)
	. = ..()
	GLOB.aq_squad_vendors += src

/obj/machinery/squad_vendor/Destroy()
	GLOB.aq_squad_vendors -= src
	return ..()

/obj/machinery/squad_vendor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	aq_clear_gear_marker(user)

/// Członek otworzył automat, do którego go wysłano: znacznik „Po sprzęt” nie jest już potrzebny
/obj/machinery/squad_vendor/proc/aq_clear_gear_marker(mob/user)
	var/mob/living/carbon/human/member = user
	if(!istype(member) || !member.squad)
		return FALSE
	var/datum/aq_squad_marker/gear/marker = member.squad.aq_gear_markers?[member]
	if(!marker || marker.vendor != src)
		return FALSE
	qdel(marker)
	return TRUE

/// Najbliższy działający automat drużyny na okręcie członka albo null
/proc/aq_nearest_squad_vendor(mob/living/member, list/candidates = GLOB.aq_squad_vendors)
	var/turf/member_turf = get_turf(member)
	if(!member_turf)
		return null
	var/ship = member_turf.get_overmap()
	var/obj/machinery/squad_vendor/best
	var/best_decks
	var/best_distance
	for(var/obj/machinery/squad_vendor/vendor as anything in candidates)
		if(QDELETED(vendor) || !vendor.is_operational)
			continue
		var/turf/vendor_turf = get_turf(vendor)
		if(!vendor_turf || vendor_turf.get_overmap() != ship)
			continue
		var/deck_offset = aq_deck_offset(member_turf.z, vendor_turf.z)
		if(isnull(deck_offset) && !ship)
			continue // poza okrętem: tylko ten sam poziom
		var/decks = isnull(deck_offset) ? SQUAD_GEAR_FAR_DECKS : abs(deck_offset)
		var/distance = sqrt((vendor_turf.x - member_turf.x) ** 2 + (vendor_turf.y - member_turf.y) ** 2)
		if(best && (decks > best_decks || (decks == best_decks && distance >= best_distance)))
			continue
		best = vendor
		best_decks = decks
		best_distance = distance
	return best

/// Gdzie stoi automat, z perspektywy członka: „Zbrojownia (C2, wyżej)”
/proc/aq_gear_location_text(mob/living/member, obj/machinery/squad_vendor/vendor)
	var/turf/vendor_turf = get_turf(vendor)
	var/area/vendor_area = get_area(vendor_turf)
	var/text = vendor_area ? format_text(vendor_area.name) : "nieznany obszar"
	var/list/details = list()
	var/sector = aq_squad_sector(vendor_turf)
	if(sector)
		details += sector
	var/turf/member_turf = get_turf(member)
	var/deck_offset = member_turf ? aq_deck_offset(member_turf.z, vendor_turf.z) : null
	if(deck_offset)
		details += deck_offset > 0 ? "wyżej" : "niżej"
	if(length(details))
		text += " ([jointext(details, ", ")])"
	return text

/// Osobisty znacznik „Po sprzęt”: widzi go tylko owner
/datum/aq_squad_marker/gear
	var/mob/living/carbon/human/owner
	var/obj/machinery/squad_vendor/vendor

/datum/aq_squad_marker/gear/New(datum/squad/squad, mob/living/carbon/human/owner, obj/machinery/squad_vendor/vendor, placer_name)
	src.owner = owner
	src.vendor = vendor
	..(squad, SQUAD_MARKER_GEAR, get_turf(vendor), placer_name)
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))
	RegisterSignal(vendor, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))

/datum/aq_squad_marker/gear/Destroy()
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
		if(squad?.aq_gear_markers?[owner] == src)
			LAZYREMOVE(squad.aq_gear_markers, owner)
	if(vendor)
		UnregisterSignal(vendor, COMSIG_PARENT_QDELETING)
	owner = null
	vendor = null
	return ..()

/datum/aq_squad_marker/gear/proc/on_target_deleted()
	SIGNAL_HANDLER
	qdel(src)

/datum/squad
	/// Osobiste znaczniki „Po sprzęt”: członek -> /datum/aq_squad_marker/gear
	var/list/aq_gear_markers

/// Stawia członkowi jego znacznik „Po sprzęt” (zastępuje poprzedni)
/datum/squad/proc/aq_set_gear_marker(mob/living/carbon/human/member, obj/machinery/squad_vendor/vendor, placer_name)
	var/datum/aq_squad_marker/gear/old_marker = aq_gear_markers?[member]
	if(old_marker)
		qdel(old_marker)
	var/datum/aq_squad_marker/gear/marker = new(src, member, vendor, placer_name)
	LAZYSET(aq_gear_markers, member, marker)
	marker.show_to(member)
	marker.update_pointer(member)
	return marker

/// Komunikat na ekranie jednego członka (aq_squad_screen_alert wysyła do całej drużyny)
/datum/squad/proc/aq_member_screen_alert(mob/living/carbon/human/member, message, title, mob/living/sender, hold_time)
	if(!member.client)
		return
	member.playsound_local(get_turf(member), 'nsv13/sound/effects/notice2.ogg', 40, FALSE)
	member.client.aq_queue_squad_alert(new /datum/aq_squad_alert(title, message, colour, sender, hold_time))

/// XO wskazuje każdemu żywemu członkowi najbliższy automat drużyny. Zwraca, ilu dostało znacznik, albo null przy odstępie.
/datum/squad/proc/aq_ping_gear(mob/sender, list/candidates = GLOB.aq_squad_vendors)
	if(!sender)
		return null
	// Konsolę może obsłużyć też admin-duch, który nie ma odstępu znaczników
	var/mob/living/living_sender = sender
	if(istype(living_sender))
		if(world.time < living_sender.aq_next_squad_marker)
			to_chat(sender, "<span class='warning'>Za szybko. Odczekaj chwilę przed kolejnym znacznikiem.</span>")
			return null
		living_sender.aq_next_squad_marker = world.time + SQUAD_MARKER_COOLDOWN
	var/title = "[squad_marker_pl(SQUAD_MARKER_GEAR)] - [sender.real_name]"
	var/span_style = squad_channel?.text_span_style || "sciradio"
	var/list/recipients = aq_alert_recipients()
	var/pinged = 0
	var/alive = 0
	for(var/mob/living/carbon/human/member as anything in members)
		if(QDELETED(member) || member.stat == DEAD)
			continue
		alive++
		var/obj/machinery/squad_vendor/vendor = aq_nearest_squad_vendor(member, candidates)
		var/text
		if(vendor)
			aq_set_gear_marker(member, vendor, sender.real_name)
			text = "Po sprzęt: [aq_gear_location_text(member, vendor)]."
			pinged++
		else
			// Stary znacznik wskazywałby automat, który już nie działa
			var/datum/aq_squad_marker/gear/stale_marker = aq_gear_markers?[member]
			if(stale_marker)
				qdel(stale_marker)
			text = "Na okręcie nie ma działającego automatu drużyny."
		to_chat(member, "<span class='[span_style]'><b>\[[name]\] [title]:</b> [text]</span>")
		if(member in recipients)
			aq_member_screen_alert(member, text, title, sender, 4 SECONDS)
	log_game("[key_name(sender)] sent squad [name] to the nearest squad vendors ([pinged]/[alive] members)")
	aq_log_message(sender.real_name, "Po sprzęt: każdy dostał znacznik najbliższego automatu drużyny.", "marker")
	to_chat(sender, "<span class='notice'>Znacznik „Po sprzęt” w drużynie [name] dostali: [pinged] z [alive].</span>")
	return pinged

/datum/squad/aq_update_pointers(mob/living/carbon/human/member)
	. = ..()
	var/datum/aq_squad_marker/gear/gear_marker = aq_gear_markers?[member]
	gear_marker?.update_pointer(member)

// Login() czyści client.images: znacznik wraca razem ze znacznikami drużyny
/datum/squad/aq_add_marker_images(mob/living/carbon/human/member)
	. = ..()
	var/datum/aq_squad_marker/gear/gear_marker = aq_gear_markers?[member]
	gear_marker?.show_to(member)

// Wyjście z drużyny zdejmuje osobisty znacznik
/datum/squad/aq_remove_marker_images(mob/living/carbon/human/member)
	. = ..()
	var/datum/aq_squad_marker/gear/gear_marker = aq_gear_markers?[member]
	if(gear_marker)
		qdel(gear_marker)

#undef SQUAD_GEAR_FAR_DECKS
