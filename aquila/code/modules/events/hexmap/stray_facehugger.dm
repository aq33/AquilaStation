// AQUILA - Zbłąkany facehugger: w tunelach technicznych pojawia się jeden żywy facehugger, a po 1-3 minutach, jeśli nadal żyje, czujniki biologiczne ostrzegają załogę (port z ChaoticOnyx/OnyxBay code/datums/events/stray_facehugger.dm)
// OnyxBay spawns its simple animal facehugger on a free maintenance turf and only tells the admins. Our facehugger is
// the mask item, which jumps only at someone who steps on it or picks it up, so the stray one is a small variant that
// also leaps at a huggable victim up to 3 tiles away in view (a proximity monitor, 3 s between leaps). The rest is our
// facehugger: a covered mouth kills it, a successful hug plants the alien embryo. Unlike OnyxBay the crew gets a warning
// 1-3 minutes later if the facehugger is still alive, so one hug does not quietly start a xenomorph round.

/datum/round_event_control/aquila_hex_stray_facehugger
	name = "Zbłąkany facehugger"
	typepath = /datum/round_event/aquila_hex_stray_facehugger
	weight = 10
	min_players = 10
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/aquila_hex_stray_facehugger
	fakeable = FALSE
	startWhen = 1

/datum/round_event/aquila_hex_stray_facehugger/start()
	var/obj/item/clothing/mask/facehugger/aquila_stray/hugger = spawn_facehugger(aquila_hex_maint_turf())
	if(!hugger)
		log_game("Stray Facehugger: no free maintenance turf found, cancelling the event.")
		return kill()
	announce_to_ghosts(hugger)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquila_hex_stray_facehugger_warning), WEAKREF(hugger)), rand(1, 3) MINUTES)

/// Ostrzeżenie załogi, jeśli facehugger nadal żyje; zwraca TRUE, gdy ogłosiło
/proc/aquila_hex_stray_facehugger_warning(datum/weakref/hugger_ref)
	var/obj/item/clothing/mask/facehugger/hugger = hugger_ref?.resolve()
	if(QDELETED(hugger) || hugger.stat == DEAD)
		return FALSE
	priority_announce("Czujniki biologiczne wykryły obcy organizm w tunelach technicznych. Załoga proszona jest o unikanie tuneli i zgłaszanie ochronie wszelkich małych, szybkich stworzeń.", "Alarm biologiczny", ANNOUNCER_ALIENS)
	return TRUE

/datum/round_event/aquila_hex_stray_facehugger/proc/spawn_facehugger(turf/spot)
	if(!isturf(spot))
		return null
	var/obj/item/clothing/mask/facehugger/aquila_stray/hugger = new(spot)
	message_admins("Zbłąkany facehugger pojawia się w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Stray Facehugger: a facehugger spawned at [AREACOORD(spot)].")
	return hugger

/// Facehugger, który sam skacze na ofiarę w pobliżu
/obj/item/clothing/mask/facehugger/aquila_stray
	/// Zasięg skoku
	var/leap_range = 3
	var/datum/proximity_monitor/proximity_monitor
	COOLDOWN_DECLARE(leap_cooldown)

/obj/item/clothing/mask/facehugger/aquila_stray/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, leap_range)

/obj/item/clothing/mask/facehugger/aquila_stray/Destroy()
	QDEL_NULL(proximity_monitor)
	return ..()

/obj/item/clothing/mask/facehugger/aquila_stray/HasProximity(atom/movable/AM)
	if(stat != CONSCIOUS || attached || !isturf(loc) || !CanHug(AM))
		return ..()
	if(Adjacent(AM))
		return Leap(AM)
	return leap_at(AM)

/// Skacze w stronę ofiary w zasięgu; zwraca TRUE, gdy skoczył
/obj/item/clothing/mask/facehugger/aquila_stray/proc/leap_at(mob/living/victim)
	if(!COOLDOWN_FINISHED(src, leap_cooldown) || get_dist(src, victim) > leap_range || !(victim in view(leap_range, get_turf(src))))
		return FALSE
	COOLDOWN_START(src, leap_cooldown, 3 SECONDS)
	visible_message("<span class='danger'>[src] skacze na [victim]!</span>")
	throw_at(victim, leap_range, 1)
	return TRUE
