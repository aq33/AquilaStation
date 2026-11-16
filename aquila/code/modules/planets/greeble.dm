// AQUILA - greeble: małe szablony mapy (zakręt rzeki, obozowisko, krater) ładowane na powierzchni planety po wygenerowaniu
// terenu. Port code/datums/mapgen/greeble.dm z Shiptesta (shiptest-ss13/Shiptest, AGPLv3).
// Zmiany względem Shiptesta:
// - zamiast osobnego podtypu spawnera i szablonu dla każdej mapy (60 par na planetę lodową) jest jeden spawner na
//   planetę z ważoną listą plików map (greeble_maps), a szablony są wspólne dla tej samej ścieżki;
// - spawnery biomów rejestrują się w GLOB.planet_greeble_spawners, a powierzchnia ładuje swoje po ruinach i populacji
//   (Shiptest przeszukiwał każde pole po generacji);
// - szablon nie staje na polach ruin ani lądowisk (NO_RUINS_1), poza powierzchnią planety ani na żyłach klasy 4.

GLOBAL_LIST_EMPTY(planet_greeble_spawners)
/// Ścieżka mapy -> szablon greebla
GLOBAL_LIST_EMPTY(planet_greeble_templates)

/obj/effect/greeble_spawner
	name = "spawner greebla planety"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	/// Ścieżka mapy szablonu (podtypy z losowaniem wybierają ją z greeble_maps)
	var/greeble_map
	/// Ścieżka mapy -> waga
	var/list/greeble_maps
	/// Czy szablon czyści obiekty i moby pod sobą (domyślnie tak, jak w Shiptest)
	var/clear_everything = TRUE
	/// Czy zakotwiczone gęste obiekty blokują szablon
	var/blocked_by_anchored = FALSE

/obj/effect/greeble_spawner/Initialize(mapload)
	. = ..()
	if(!greeble_map && length(greeble_maps))
		greeble_map = pickweight(greeble_maps)
	if(!greeble_map)
		return INITIALIZE_HINT_QDEL
	GLOB.planet_greeble_spawners += src

/obj/effect/greeble_spawner/Destroy(force)
	GLOB.planet_greeble_spawners -= src
	return ..()

/// Wspólny szablon dla ścieżki mapy
/obj/effect/greeble_spawner/proc/get_template()
	var/datum/map_template/template = GLOB.planet_greeble_templates[greeble_map]
	if(!template)
		template = new /datum/map_template(greeble_map, "greeble [greeble_map]", TRUE)
		GLOB.planet_greeble_templates[greeble_map] = template
	return template

/// Ładuje szablon na powierzchni, jeśli się mieści. Spawner zawsze znika.
/obj/effect/greeble_spawner/proc/start_load(datum/planet_surface/surface)
	var/turf/deploy_location = get_turf(src)
	var/datum/map_template/template = get_template()
	if(template && can_deploy(template, deploy_location, surface))
		if(clear_everything)
			for(var/turf/T as anything in template.get_affected_turfs(deploy_location, TRUE))
				for(var/atom/movable/AM as anything in T)
					if(AM == src || (!isobj(AM) && !isliving(AM)))
						continue
					if(isliving(AM))
						var/mob/living/creature = AM
						if(creature.client)
							continue
					qdel(AM)
		template.load(deploy_location, centered = TRUE)
	qdel(src)

/obj/effect/greeble_spawner/proc/can_deploy(datum/map_template/template, turf/deploy_location, datum/planet_surface/surface)
	var/static/list/banned_objects = typecacheof(list(
		/obj/effect/anomaly,
		/obj/docking_port,
		/obj/machinery/drill,
	))
	if(!deploy_location)
		return FALSE
	for(var/turf/T as anything in template.get_affected_turfs(deploy_location, TRUE))
		if(!surface.contains(T) || (T.flags_1 & NO_RUINS_1))
			return FALSE
		if(T.loc != surface.surface_area && T.loc != surface.cave_area)
			return FALSE
		if(isclosedturf(T) && !ismineralturf(T))
			return FALSE
		for(var/obj/O in T)
			if(is_type_in_typecache(O, banned_objects))
				return FALSE
			if(istype(O, /obj/structure/vein))
				var/obj/structure/vein/vein = O
				if(vein.deep_vein)
					return FALSE
			if(blocked_by_anchored && O.density && O.anchored)
				return FALSE
	return TRUE

/// Łata trawy: rozlewa wybrany turf po kilku polach (proceduralnie, bez mapy)
/obj/effect/greeble_spawner/grass_patch
	name = "spawner łaty trawy"
	greeble_map = "patch"
	/// Turf, który się rozlewa
	var/turf/open/turf_to_spread
	/// Rozlewa się tylko po polach takiego typu jak pole startowe (gładsze przejścia biomów)
	var/only_spread_on_spawning_turf = FALSE
	/// Pędzel 3 × 3 w kształcie plusa
	var/big_brush = FALSE
	var/max_turfs_to_spread = 8
	var/min_turfs_to_spread = 3
	/// Nie wraca w kierunku, z którego przyszła
	var/patch_direction_locked = TRUE
	/// Szansa na koniec po każdym kroku i o ile rośnie z każdym polem
	var/chance_to_terminate = 20
	var/terminate_chance_add = 6

/obj/effect/greeble_spawner/grass_patch/start_load(datum/planet_surface/surface)
	var/turf/open/current_turf = get_turf(src)
	if(!istype(current_turf) || !turf_to_spread)
		qdel(src)
		return
	var/initial_turf_type = current_turf.type
	var/list/previous_turfs = list()
	var/forbidden_spread_dir
	var/terminate_chance = chance_to_terminate
	for(var/spawned in 0 to max_turfs_to_spread - 1)
		if(spawned >= min_turfs_to_spread && prob(terminate_chance))
			break
		spread_to(current_turf, surface)
		if(big_brush)
			for(var/direction in GLOB.cardinals)
				spread_to(get_step(current_turf, direction), surface)
		var/list/possible_dirs = GLOB.cardinals.Copy()
		if(forbidden_spread_dir)
			possible_dirs -= forbidden_spread_dir
		for(var/checked_dir in possible_dirs.Copy())
			var/turf/checked_turf = get_step(current_turf, checked_dir)
			if(!isopenturf(checked_turf) || !surface.contains(checked_turf) || (checked_turf.flags_1 & NO_RUINS_1))
				possible_dirs -= checked_dir
			else if(!big_brush && istype(checked_turf, turf_to_spread))
				possible_dirs -= checked_dir
			else if(big_brush && (checked_turf in previous_turfs))
				possible_dirs -= checked_dir
			else if(only_spread_on_spawning_turf && !big_brush && !istype(checked_turf, initial_turf_type))
				possible_dirs -= checked_dir
		if(!length(possible_dirs))
			break
		var/next_dir = pick(possible_dirs)
		if(patch_direction_locked)
			forbidden_spread_dir = REVERSE_DIR(next_dir)
		previous_turfs += current_turf
		current_turf = get_step(current_turf, next_dir)
		terminate_chance += terminate_chance_add
	qdel(src)

/obj/effect/greeble_spawner/grass_patch/proc/spread_to(turf/T, datum/planet_surface/surface)
	if(!isopenturf(T) || !surface.contains(T) || (T.flags_1 & NO_RUINS_1) || is_planet_hazard_turf(T))
		return
	T.ChangeTurf(turf_to_spread, initial(turf_to_spread.baseturfs), CHANGETURF_IGNORE_AIR)

/// Ładuje greeble postawione przez biomy na tej powierzchni (po ruinach i populacji)
/datum/planet_surface/proc/load_greebles()
	for(var/obj/effect/greeble_spawner/spawner as anything in GLOB.planet_greeble_spawners.Copy())
		if(QDELETED(spawner) || !contains(get_turf(spawner)))
			continue
		spawner.start_load(src)
		PLANET_CHECK_TICK
