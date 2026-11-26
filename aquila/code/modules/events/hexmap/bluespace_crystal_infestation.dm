// AQUILA - Gniazdo kryształów bluespace: w tunelach technicznych wyrasta gniazdo kryształów; ścięte dają odłamki jednorazowego teleportu, a nieruszone co jakiś czas przerzuca rzeczy i ludzi z okolicy w losowe bezpieczne miejsce okrętu (port z discordia-space/CEV-Eris code/game/gamemodes/events/hidden_events/bluespace_crystal_infestation.dm)
// Eris puts its bluespace crystal structure in a random (usually maintenance) area, feeds its bluespace entropy system
// and pulls nearby things to the nest; the event is hidden. We have no entropy, so ours is a nest on a free safe
// maintenance turf (our shared helper) that, while it still holds crystals, sends up to four loose items and living
// beings around it to random free safe turfs of the ship (never space, dangerous or closed rooms such as the brig)
// every 1.5-2.5 minutes, at most 15 times. It leaves alone the cuffed, anyone being pulled, hostile creatures and
// anyone carrying a bag of holding; the landing turfs are drawn once per pulse. Cutting it with wirecutters or a mining
// tool gives one-use bluespace shards: a separate item that, crushed or thrown, makes a plain bluespace jump of up to
// 8 turfs (like our crystal), but has no materials, research points or machine part use, so it is no source of real
// bluespace crystals. The crew gets a short announcement with the area.

/datum/round_event_control/aquila_hex_bluespace_crystal_infestation
	name = "Gniazdo kryształów bluespace"
	typepath = /datum/round_event/aquila_hex_bluespace_crystal_infestation
	weight = 8
	max_occurrences = 1
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_bluespace_crystal_infestation
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Pomieszczenie gniazda
	var/nest_area_name

/datum/round_event/aquila_hex_bluespace_crystal_infestation/start()
	var/turf/spot = aquila_hex_maint_turf()
	if(!spot)
		log_game("Bluespace Crystal Infestation: no free safe maintenance turf, cancelling the event.")
		return kill()
	var/obj/structure/aquila_bluespace_nest/nest = new(spot)
	nest_area_name = get_area_name(spot, TRUE)
	announce_to_ghosts(nest)
	message_admins("Gniazdo kryształów bluespace wyrasta w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Bluespace Crystal Infestation: a nest grew at [AREACOORD(spot)].")

/datum/round_event/aquila_hex_bluespace_crystal_infestation/announce(fake)
	if(!nest_area_name)
		return
	priority_announce("Czujniki wykryły skupisko energii bluespace w tunelach technicznych, w: [nest_area_name]. Najpewniej to gniazdo kryształów, które wyrosło po przelocie przez pole asteroid. Gniazdo może przerzucać pobliskie przedmioty i osoby w inne miejsca okrętu. Zalecamy ścięcie kryształów obcęgami albo kilofem.", "Ostrzeżenie przed anomalią")

/**
 * Gniazdo kryształów bluespace: póki ma kryształy, co jakiś czas przerzuca okoliczne rzeczy i istoty w losowe
 * bezpieczne miejsca okrętu. Ścinanie obcęgami albo narzędziem górniczym daje odłamki; ostatni kryształ niszczy gniazdo.
 */
/obj/structure/aquila_bluespace_nest
	name = "gniazdo kryształów bluespace"
	desc = "Skupisko świecących, błękitnych kryształów, które wrosły w podłogę. Powietrze wokół lekko drga."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "cerulean_crystal"
	color = "#7ab8ff"
	anchored = TRUE
	density = FALSE
	max_integrity = 100
	light_range = 2
	light_power = 0.8
	light_color = "#4f9dff"
	/// Ile kryształów zostało do ścięcia
	var/crystals = 4
	/// Ile razy jeszcze może przerzucić okolicę
	var/pulses_left = 15
	/// Zasięg przerzucania
	var/pulse_range = 2
	/// Najwięcej rzeczy przerzuconych naraz
	var/pulse_max_targets = 4
	/// Czas ścinania jednego kryształu
	var/harvest_time = 3 SECONDS
	COOLDOWN_DECLARE(next_pulse)

/obj/structure/aquila_bluespace_nest/Initialize(mapload)
	. = ..()
	crystals = rand(3, 5)
	COOLDOWN_START(src, next_pulse, rand(90, 150) SECONDS)
	START_PROCESSING(SSobj, src)

/obj/structure/aquila_bluespace_nest/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/aquila_bluespace_nest/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kryształów do ścięcia: [crystals]. Można je ściąć obcęgami albo narzędziem górniczym.</span>"

/obj/structure/aquila_bluespace_nest/process(delta_time)
	if(pulses_left <= 0 || crystals <= 0)
		return PROCESS_KILL
	if(!COOLDOWN_FINISHED(src, next_pulse))
		return
	COOLDOWN_START(src, next_pulse, rand(90, 150) SECONDS)
	pulse()

/// Czy puls może przerzucić tę rzecz: luźny przedmiot albo istota, ale nie skuty, ciągnięty, wrogi stwór ani nic z torbą przechowywania
/obj/structure/aquila_bluespace_nest/proc/can_throw(atom/movable/thing)
	if(thing == src || thing.anchored || !isturf(thing.loc))
		return FALSE
	if(!isliving(thing) && !isitem(thing))
		return FALSE
	if(thing.pulledby)
		return FALSE
	if(isliving(thing))
		var/mob/living/being = thing
		if(being.restrained())
			return FALSE
		// Wrogie stwory: każdy stwór bez gracza spoza frakcji neutralnej (karpie, pająki, roje), żeby gniazdo nie roznosiło ich po okręcie
		if(ishostile(being) || (!being.mind && (isanimal(being) || isbasicmob(being)) && !(FACTION_NEUTRAL in being.faction)))
			return FALSE
	var/static/list/bag_cache = typecacheof(/obj/item/storage/backpack/holding)
	if(bag_cache[thing.type] || length(typecache_filter_list(thing.GetAllContents(), bag_cache)))
		return FALSE
	return TRUE

/**
 * Przerzuca do pulse_max_targets luźnych przedmiotów i żywych istot z okolicy w bezpieczne miejsca okrętu; zwraca, ile przerzuciło.
 * destinations - pola lądowania (domyślnie losowane raz na puls przez aquila_hex_safe_teleport_turfs()), każde dla jednej rzeczy.
 */
/obj/structure/aquila_bluespace_nest/proc/pulse(list/destinations)
	. = 0
	pulses_left--
	var/turf/center = get_turf(src)
	if(!center)
		return
	var/list/targets = list()
	for(var/atom/movable/thing in range(pulse_range, center))
		if(can_throw(thing))
			targets += thing
	if(!length(targets))
		return
	destinations = destinations ? destinations.Copy() : aquila_hex_safe_teleport_turfs(min(length(targets), pulse_max_targets))
	if(!length(destinations))
		return
	playsound(center, 'sound/effects/phasein.ogg', 40, TRUE)
	for(var/atom/movable/thing as anything in shuffle(targets))
		if(. >= pulse_max_targets || !length(destinations))
			break
		var/turf/destination = popleft(destinations)
		if(do_teleport(thing, destination, 0, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE))
			.++
			if(isliving(thing))
				to_chat(thing, "<span class='warning'>Błękitny błysk szarpie tobą i nagle jesteś gdzie indziej!</span>")
	if(.)
		visible_message("<span class='warning'>[src] rozbłyska, a rzeczy wokół znikają!</span>")

/obj/structure/aquila_bluespace_nest/wirecutter_act(mob/living/user, obj/item/tool)
	harvest(user, tool)
	return TRUE

/obj/structure/aquila_bluespace_nest/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_MINING)
		harvest(user, I)
		return TRUE
	return ..()

/// Ścina jeden kryształ narzędziem
/obj/structure/aquila_bluespace_nest/proc/harvest(mob/living/user, obj/item/tool)
	if(crystals <= 0)
		return FALSE
	to_chat(user, "<span class='notice'>Zaczynasz ścinać kryształ z [src]...</span>")
	if(!tool.use_tool(src, user, harvest_time, volume = 50) || QDELETED(src) || crystals <= 0)
		return FALSE
	return cut_crystal(user)

/// Odcina kryształ jako odłamek; ostatni niszczy gniazdo
/obj/structure/aquila_bluespace_nest/proc/cut_crystal(mob/living/user)
	if(crystals <= 0)
		return null
	crystals--
	var/obj/item/aquila_bluespace_shard/shard = new(drop_location())
	user?.put_in_hands(shard)
	if(crystals <= 0)
		visible_message("<span class='notice'>Ostatni kryształ pęka, a [src] gaśnie i rozsypuje się w pył.</span>")
		qdel(src)
	return shard

/// Odłamek kryształu bluespace z gniazda: jednorazowy teleport po zgnieceniu albo rzuceniu, bez materiałów i punktów badań
/obj/item/aquila_bluespace_shard
	name = "odłamek kryształu bluespace"
	desc = "Świecący odłamek kryształu z gniazda bluespace. Zgnieciony przerzuca w losowe miejsce w pobliżu. Jest zbyt nietrwały, by nadawał się do czegokolwiek innego."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	w_class = WEIGHT_CLASS_TINY
	/// Zasięg teleportu
	var/blink_range = 8

/obj/item/aquila_bluespace_shard/attack_self(mob/user)
	user.visible_message("<span class='warning'>[user] miażdży [src]!</span>", "<span class='danger'>Miażdżysz [src]!</span>")
	shatter(user)

/obj/item/aquila_bluespace_shard/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) // nie złapany w locie
		visible_message("<span class='notice'>[src] syczy i znika przy uderzeniu!</span>")
		shatter(isliving(hit_atom) ? hit_atom : null)

/// Rozpada się i przerzuca target (jeśli jest) w losowe miejsce w pobliżu
/obj/item/aquila_bluespace_shard/proc/shatter(mob/living/target)
	var/turf/T = get_turf(src)
	if(T)
		new /obj/effect/particle_effect/sparks(T)
		playsound(T, "sparks", 50, TRUE)
	if(target)
		do_teleport(target, get_turf(target), blink_range, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	qdel(src)
