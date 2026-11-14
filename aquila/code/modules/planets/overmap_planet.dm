// AQUILA - planeta na overmapie układu. Duży sprite z planets.dmi bez kolizji: statki przelatują nad nią, a prom
// w trybie dokowania, który znajdzie się nad planetą, zaczyna lądowanie (powierzchnia generuje się wtedy pierwszy raz).
// Niezniszczalna; pociski wycelowane w planetę spadają na jej powierzchnię (planet_bombardment.dm).

/// Co ile sprawdzać, czy nad planetą wisi prom w trybie dokowania
#define PLANET_LANDING_CHECK_DELAY (1 SECONDS)
/// Promień (w polach od środka sprite'a), w którym prom może zacząć lądowanie
#define PLANET_LANDING_RADIUS 4

GLOBAL_LIST_EMPTY(overmap_planets)

/obj/structure/overmap/planet
	name = "planeta"
	desc = "Planeta. Czujniki nie mają o niej żadnych danych, dopóki stanowisko rozpoznania jej nie przeskanuje."
	icon = 'nsv13/icons/overmap/stellarbodies/planets.dmi'
	icon_state = "planet_rocky"
	density = FALSE
	layer = OBJ_LAYER
	bound_width = 256
	bound_height = 256
	mass = MASS_IMMOBILE
	obj_integrity = 10000
	max_integrity = 10000
	armor = list("overmap_light" = 100, "overmap_medium" = 100, "overmap_heavy" = 100)
	overmap_deletion_traits = NONE
	weapon_addition_allowed = FALSE
	brakes = TRUE
	block_deletion = TRUE
	essential = TRUE
	faction = "planet"
	combat_dice_type = /datum/combat_dice/civilian
	damage_states = FALSE
	/// Typ planety (ścieżka przed Initialize, potem instancja)
	var/datum/planet_type/planet_type = /datum/planet_type/lava
	/// Powierzchnia (powstaje dopiero przy lądowaniu)
	var/datum/planet_surface/surface
	/// Czy stanowisko rozpoznania zeskanowało planetę (wcześniej widać tylko nazwę)
	var/planet_scanned = FALSE
	var/landing_check_timer

/obj/structure/overmap/planet/Initialize(mapload, planet_type_override)
	if(planet_type_override)
		planet_type = planet_type_override
	if(ispath(planet_type))
		planet_type = new planet_type
	icon_state = planet_type.overmap_icon_state
	. = ..()
	GLOB.overmap_planets += src
	surface = new(src)
	landing_check_timer = addtimer(CALLBACK(src, PROC_REF(check_landing_craft)), PLANET_LANDING_CHECK_DELAY, TIMER_LOOP | TIMER_STOPPABLE)

/obj/structure/overmap/planet/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE // Planety nie znikają od zwykłego qdel (jak block_deletion)
	block_deletion = FALSE
	GLOB.overmap_planets -= src
	if(landing_check_timer)
		deltimer(landing_check_timer)
		landing_check_timer = null
	QDEL_NULL(surface)
	planet_type = null
	return ..()

/// Planeta stoi w miejscu: fizyka tylko ustawia pozycję po powrocie układu na mapę i się wyłącza
/obj/structure/overmap/planet/process(delta_time)
	if(z)
		position._set(x * 32, y * 32)
	return PROCESS_KILL

/obj/structure/overmap/planet/apply_weapons()
	return

/obj/structure/overmap/planet/start_piloting(mob/living/carbon/user, position)
	. = ..()
	stop_piloting(user)

/obj/structure/overmap/planet/examine(mob/user)
	. = ..()
	if(!planet_scanned)
		. += span_notice("Nie zeskanowano jej jeszcze. Stanowisko rozpoznania poda typ, atmosferę i zagrożenia.")
		return
	. += span_notice(planet_type.desc)
	. += span_notice(planet_type.scan_text())
	if(!planet_type.can_land)
		. += span_warning("Na tej planecie nie da się wylądować.")
	else if(surface?.state == PLANET_SURFACE_READY)
		. += span_notice("Na powierzchni są wyznaczone lądowiska: [english_list(surface.landing_zones_names())].")

/// Środek sprite'a planety (w polach)
/obj/structure/overmap/planet/proc/center_turf()
	return locate(x + round(bound_width / world.icon_size / 2), y + round(bound_height / world.icon_size / 2), z)

/// Zapisuje wynik skanu (stanowisko rozpoznania, komora testowa)
/obj/structure/overmap/planet/proc/set_scanned()
	if(planet_scanned)
		return
	planet_scanned = TRUE
	name = "[name] ([planet_type.name])"

/// Czy powierzchnia jest gotowa; jeśli jeszcze jej nie ma, zaczyna ją budować
/obj/structure/overmap/planet/proc/ensure_surface()
	if(!planet_type.can_land)
		return FALSE
	if(surface.state == PLANET_SURFACE_READY)
		return TRUE
	if(surface.state == PLANET_SURFACE_NONE)
		INVOKE_ASYNC(surface, TYPE_PROC_REF(/datum/planet_surface, generate))
	return FALSE

/// Prom w trybie dokowania nad planetą zaczyna lądowanie
/obj/structure/overmap/planet/proc/check_landing_craft()
	if(!current_system || !z)
		return
	var/turf/center = center_turf()
	if(!center)
		return
	for(var/obj/structure/overmap/small_craft/transport/craft in current_system.system_contents)
		if(!craft.shuttle_port || craft.shuttle_docked_at || craft.z != z)
			continue
		if(get_dist(craft, center) > PLANET_LANDING_RADIUS)
			continue
		var/obj/item/fighter_component/docking_computer/DC = craft.loadout?.get_slot(HARDPOINT_SLOT_DOCKING)
		if(!DC?.docking_mode)
			continue
		craft.docking_act(src)

/datum/planet_surface/proc/landing_zones_names()
	. = list()
	for(var/turf/T as anything in landing_zones)
		. += landing_zones[T]

#undef PLANET_LANDING_CHECK_DELAY
#undef PLANET_LANDING_RADIUS
