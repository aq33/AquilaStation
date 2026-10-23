// Magnes na asteroidy łapie też wraki: wrak ląduje na środku klatki (40x40), a cała klatka staje się strefą złomowania.

/// Bok klatki magnesu (tyle mają mapy asteroid)
#define MAGNET_CAGE_SIZE 40

/obj/machinery/computer/ship/mineral_magnet
	/// Wrak w klatce (zamiast asteroidy)
	var/datum/map_template/shipbreaker/current_wreck
	/// Pola wraku, które przy załadowaniu nie były kosmosem (do liczenia, ile zostało)
	var/list/wreck_turfs
	/// Obszary pól klatki sprzed załadowania wraku (pole => obszar), przywracane przy wypchnięciu
	var/list/cage_areas

/obj/machinery/computer/ship/mineral_magnet/Destroy()
	current_wreck = null
	wreck_turfs = null
	cage_areas = null
	return ..()

/// Wszystkie pola klatki magnesu
/obj/machinery/computer/ship/mineral_magnet/proc/get_cage_turfs()
	if(!target_location)
		return list()
	return block(target_location, locate(min(target_location.x + MAGNET_CAGE_SIZE - 1, world.maxx), min(target_location.y + MAGNET_CAGE_SIZE - 1, world.maxy), target_location.z))

/// Ile procent wraku jeszcze stoi (null bez wraku)
/obj/machinery/computer/ship/mineral_magnet/proc/get_wreck_health()
	if(!current_wreck || !length(wreck_turfs))
		return null
	var/standing = 0
	for(var/turf/T as anything in wreck_turfs)
		if(!isgroundlessturf(T))
			standing++
	return round(standing * 100 / length(wreck_turfs))

/obj/machinery/computer/ship/mineral_magnet/proc/pull_in_wreck(mob/user, obj/structure/overmap/asteroid/shipbreak_wreck/wreck)
	if(cooldown)
		say("BŁĄD: obwody magnetyzacji się ładują...")
		return FALSE
	if(!has_overmap() || !target_location)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		return FALSE
	linked.relay('nsv13/sound/effects/ship/tractor.ogg', "<span class='warning'>UWAGA: magnes namierzył wrak. Natychmiast opuścić klatkę na asteroidy.</span>")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 MINUTES)
	current_wreck = pick_shipbreaker_template(wreck.wreck_faction)
	log_game("[key_name(user)] przyciągnął magnesem [current_wreck.name] ([wreck.name])")
	addtimer(CALLBACK(src, PROC_REF(load_wreck)), 10 SECONDS)
	qdel(wreck)
	return TRUE

/obj/machinery/computer/ship/mineral_magnet/proc/load_wreck()
	if(!current_wreck || !target_location)
		return FALSE
	// Klatka może mieć pola z różnych obszarów (kosmos i okolica statku), każde wraca do swojego
	cage_areas = list()
	for(var/turf/T as anything in get_cage_turfs())
		cage_areas[T] = T.loc
	var/turf/origin = locate(target_location.x + round((MAGNET_CAGE_SIZE - current_wreck.width) / 2), target_location.y + round((MAGNET_CAGE_SIZE - current_wreck.height) / 2), target_location.z)
	var/list/bounds = current_wreck.load(origin)
	if(!bounds)
		message_admins("Magnes [ADMIN_VERBOSEJMP(src)] nie załadował wraku [current_wreck.mappath]")
		current_wreck = null
		cage_areas = null
		return FALSE
	wreck_turfs = list()
	for(var/turf/T as anything in current_wreck.get_affected_turfs(origin))
		if(!isgroundlessturf(T))
			wreck_turfs += T
	// Cała klatka to strefa złomowania, żeby spawarka Rayne działała też z zewnątrz wraku
	var/area/shipbreak_area = GLOB.areas_by_type[/area/space/shipbreak]
	for(var/turf/T as anything in get_cage_turfs())
		var/area/old_area = T.loc
		if(old_area == shipbreak_area)
			continue
		old_area.contents -= T
		shipbreak_area.contents += T
		T.change_area(old_area, shipbreak_area)
	damage_wreck()
	return TRUE

/// Wrak przylatuje już porozbijany (Monke: damage_ship), wybuchy są małe, żeby nie sięgnęły kadłuba za klatką
/obj/machinery/computer/ship/mineral_magnet/proc/damage_wreck()
	var/blast_chance = 100
	while(length(wreck_turfs) && prob(blast_chance))
		blast_chance -= 33
		explosion(pick(wreck_turfs), rand(0, 1), rand(1, 2), rand(2, 4), 0, FALSE, FALSE, 0, TRUE)

/obj/machinery/computer/ship/mineral_magnet/push_away_asteroid()
	if(!current_wreck)
		return ..()
	var/area/shipbreak_area = GLOB.areas_by_type[/area/space/shipbreak]
	for(var/turf/T as anything in get_cage_turfs())
		for(var/atom/A as anything in T.contents)
			if(!ismob(A) && !istype(A, /obj/effect/landmark/asteroid_spawn))
				qdel(A)
		T.ChangeTurf(turf_type)
		var/area/old_area = cage_areas?[T]
		if(old_area && T.loc == shipbreak_area)
			shipbreak_area.contents -= T
			old_area.contents += T
			T.change_area(shipbreak_area, old_area)
	current_wreck = null
	wreck_turfs = null
	cage_areas = null

#undef MAGNET_CAGE_SIZE
