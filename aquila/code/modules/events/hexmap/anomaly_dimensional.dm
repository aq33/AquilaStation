// AQUILA - Anomalia wymiarowa: kafel po kaflu przerabia podłogi, ściany, krzesła i stoły w promieniu 3 na jeden materiał i barwi okna na jego kolor, potem raz może przeskoczyć gdzie indziej (port z tgstation code/modules/events/anomaly/anomaly_dimensional.dm + code/game/objects/effects/anomalies/anomalies_dimensional*.dm)
// Simplified on the user's decision: themes are only harmless materials we have (gold, silver, glass, wood, titanium)
// instead of tg's themed turf sets (meat, pizza, natural, winter, lavaland...), no airlocks, toilets or random spawns.
// Only plain chairs and tables are replaced (with the material ones), windows are only recoloured.
// Walls: reinforced walls and NSV hull walls, shuttle walls, walls next to space and walls with anything inside the wall
// turf (signs, posters) are skipped; shuttle floors too. Wall mounted machines (APCs, lights, intercoms, alarms) sit on
// the floor next to the wall in our code and ChangeTurf on the wall does not touch them, so they stay where they are.
// Plating, engine, glass, circuit and holodeck floors are left alone. tg's theme icon overlay is replaced with the
// material colour on a rift sprite. The material is only a look, like metalgen (TRAIT_MATERIALS_TRANSMUTED): a
// dismantled wall, a pried tile or a broken chair gives back no gold or silver. The material walls and floors are saved
// by the ship structure persistence like any material turf built by the crew, together with that trait.
// When it jumps elsewhere, it avoids the anomaly blacklist areas (AI core, engine, solars, holodeck, shuttles).

#define AQUILA_HEX_DIMENSIONAL_TILE_MATERIAL 500
#define AQUILA_HEX_DIMENSIONAL_WALL_MATERIAL (MINERAL_MATERIAL_AMOUNT * 2)
#define AQUILA_HEX_DIMENSIONAL_FURNITURE_MATERIAL 2000

/datum/round_event_control/aquila_hex_anomaly_dimensional
	name = "Anomalia wymiarowa"
	typepath = /datum/round_event/aquila_hex_anomaly/dimensional
	weight = 10
	min_players = 10
	max_occurrences = 3

/datum/round_event/aquila_hex_anomaly/dimensional
	anomaly_path = /obj/effect/anomaly/aquila_hex_dimensional
	announce_kind = "dimensional"

/obj/effect/anomaly/aquila_hex_dimensional
	name = "anomalia wymiarowa"
	desc = "Szczelina, przez którą przecieka kawałek innego wymiaru. Wszystko wokół niej zaczyna wyglądać inaczej."
	icon_state = "rift"
	lifespan = 3 MINUTES
	/// Zasięg przemiany
	var/range = 3
	/// Materiał tej anomalii (typ /datum/material)
	var/theme_material
	/// Kafle do przerobienia w tym miejscu
	var/list/turf/target_turfs = list()
	/// Ile razy jeszcze przeskoczy w inne miejsce
	var/teleports_left = 1

/obj/effect/anomaly/aquila_hex_dimensional/Initialize(mapload, new_lifespan)
	. = ..()
	teleports_left = rand(0, 1)
	animate(src, transform = matrix() * 0.85, time = 3, loop = -1)
	animate(transform = matrix(), time = 3, loop = -1)

/obj/effect/anomaly/aquila_hex_dimensional/Destroy()
	target_turfs = null
	return ..()

// Bez ..(): anomalia stoi w miejscu
/obj/effect/anomaly/aquila_hex_dimensional/anomalyEffect(delta_time)
	transmute_next()

/// Przerabia kolejny kafel; gdy w okolicy nie ma już czego, przeskakuje albo znika
/obj/effect/anomaly/aquila_hex_dimensional/proc/transmute_next()
	if(!theme_material)
		prepare_area()
	while(length(target_turfs))
		var/turf/affected = target_turfs[1]
		target_turfs.Cut(1, 2)
		if(!QDELETED(affected) && aquila_hex_dimensional_transmute(affected, theme_material))
			playsound(affected, 'sound/magic/blind.ogg', 50, TRUE)
			new /obj/effect/temp_visual/aquila_hex_transmute_flash(affected)
			return affected
	if(teleports_left <= 0 || !relocate())
		qdel(src)

/// Losuje materiał i zbiera kafle w zasięgu
/obj/effect/anomaly/aquila_hex_dimensional/proc/prepare_area(new_material)
	theme_material = new_material || pick(aquila_hex_dimensional_materials())
	var/datum/material/material = SSmaterials.GetMaterialRef(theme_material)
	add_atom_colour(material.greyscale_colors, FIXED_COLOUR_PRIORITY)
	target_turfs = list()
	for(var/turf/T as anything in spiral_range_turfs(range, src))
		if(aquila_hex_dimensional_can_transmute(T, theme_material))
			target_turfs += T

/// Przeskakuje do innego obszaru okrętu i zapowiada to. Zwraca TRUE po przeskoku.
/obj/effect/anomaly/aquila_hex_dimensional/proc/relocate()
	var/static/list/excluded_areas
	if(!excluded_areas)
		excluded_areas = typecacheof(ANOMALY_AREA_BLACKLIST) - typecacheof(ANOMALY_AREA_SUBTYPE_WHITELIST)
	var/turf/new_turf = aquila_hex_random_ship_turf(excluded_areas)
	if(!new_turf)
		return FALSE
	teleports_left--
	var/area/new_area = get_area(new_turf)
	priority_announce("Niestabilność wymiarowa przemieściła się. Spodziewany punkt uderzenia: [new_area.name].", "Alarm: Anomalia", ANNOUNCER_SPANOMALIES)
	forceMove(new_turf)
	remove_atom_colour(FIXED_COLOUR_PRIORITY)
	prepare_area()
	return TRUE

/obj/effect/temp_visual/aquila_hex_transmute_flash
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	duration = 3

/// Materiały anomalii wymiarowej
/proc/aquila_hex_dimensional_materials()
	var/static/list/materials = list(
		/datum/material/gold,
		/datum/material/silver,
		/datum/material/glass,
		/datum/material/wood,
		/datum/material/titanium,
	)
	return materials

/// Podłoga, którą anomalia przerobi na podłogę z materiału
/proc/aquila_hex_dimensional_floor_ok(turf/T, material_type)
	var/static/list/skipped_floors = typecacheof(list(
		/turf/open/floor/plating,
		/turf/open/floor/engine,
		/turf/open/floor/glass,
		/turf/open/floor/circuit,
		/turf/open/floor/holofloor,
	))
	if(!isfloorturf(T) || is_type_in_typecache(T, skipped_floors) || T.holodeck_compatible || istype(get_area(T), /area/shuttle))
		return FALSE
	return !(istype(T, /turf/open/floor/material) && aquila_hex_dimensional_has_material(T, material_type))

/// Ściana, którą anomalia przerobi na ścianę z materiału (bez kadłuba, ścian przy kosmosie, promów i ścian z czymś w środku)
/proc/aquila_hex_dimensional_wall_ok(turf/T, material_type)
	if(!iswallturf(T) || istype(T, /turf/closed/wall/r_wall) || istype(T, /turf/closed/wall/ship) || istype(get_area(T), /area/shuttle))
		return FALSE
	if(locate(/obj) in T) // znaki, plakaty i inne rzeczy w samej ścianie
		return FALSE
	for(var/direction in GLOB.alldirs) // ściana przy kosmosie to burta okrętu
		if(isspaceturf(get_step(T, direction)))
			return FALSE
	return !(istype(T, /turf/closed/wall/material) && aquila_hex_dimensional_has_material(T, material_type))

/// Czy rzecz jest już z tego materiału
/proc/aquila_hex_dimensional_has_material(atom/thing, material_type)
	return !!thing.custom_materials?[SSmaterials.GetMaterialRef(material_type)]

/// Lista materiałów dla set_custom_materials (sam klucz w list() byłby tekstem)
/proc/aquila_hex_dimensional_material_list(material_type, amount)
	. = list()
	.[material_type] = amount

/// Nadaje rzeczy materiał tylko z wyglądu: jak po metalgenie, rozebrana nic z niego nie oddaje
/proc/aquila_hex_dimensional_apply_material(atom/target, material_type, amount)
	ADD_TRAIT(target, TRAIT_MATERIALS_TRANSMUTED, METALGEN_TRAIT)
	target.set_custom_materials(aquila_hex_dimensional_material_list(material_type, amount))

/// Okno, które anomalia zabarwi na kolor materiału
/proc/aquila_hex_dimensional_window_ok(obj/structure/window/window, datum/material/material)
	return istype(window) && window.fulltile && window.color != material.greyscale_colors

/// Czy na kaflu jest coś do przerobienia
/proc/aquila_hex_dimensional_can_transmute(turf/T, material_type)
	if(isspaceturf(T) || isindestructiblefloor(T) || isindestructiblewall(T))
		return FALSE
	if(aquila_hex_dimensional_floor_ok(T, material_type) || aquila_hex_dimensional_wall_ok(T, material_type))
		return TRUE
	var/datum/material/material = SSmaterials.GetMaterialRef(material_type)
	for(var/obj/thing in T)
		if(aquila_hex_dimensional_furniture_type(thing) || aquila_hex_dimensional_window_ok(thing, material))
			return TRUE
	return FALSE

/// Materiałowy odpowiednik krzesła albo stołu (tylko zwykłe, bez podtypów)
/proc/aquila_hex_dimensional_furniture_type(obj/thing)
	if(thing.type == /obj/structure/chair)
		var/obj/structure/chair/chair = thing
		return chair.has_buckled_mobs() ? null : /obj/structure/chair/greyscale
	if(thing.type == /obj/structure/table)
		return /obj/structure/table/greyscale
	return null

/**
 * Przerabia kafel: podłogę albo ścianę na materiał, zwykłe krzesła i stoły na meble z materiału, okna barwi na kolor
 * materiału. Zwraca TRUE, jeśli coś się zmieniło.
 */
/proc/aquila_hex_dimensional_transmute(turf/T, material_type)
	var/datum/material/material = SSmaterials.GetMaterialRef(material_type)
	if(!material || !aquila_hex_dimensional_can_transmute(T, material_type))
		return FALSE
	if(aquila_hex_dimensional_floor_ok(T, material_type))
		T = T.ChangeTurf(/turf/open/floor/material, flags = CHANGETURF_INHERIT_AIR)
		aquila_hex_dimensional_apply_material(T, material_type, AQUILA_HEX_DIMENSIONAL_TILE_MATERIAL)
	else if(aquila_hex_dimensional_wall_ok(T, material_type))
		T = T.ChangeTurf(/turf/closed/wall/material)
		aquila_hex_dimensional_apply_material(T, material_type, AQUILA_HEX_DIMENSIONAL_WALL_MATERIAL)
	for(var/obj/thing in T)
		if(istype(thing, /obj/structure/window))
			if(aquila_hex_dimensional_window_ok(thing, material))
				thing.add_atom_colour(material.greyscale_colors, FIXED_COLOUR_PRIORITY)
			continue
		var/furniture_type = aquila_hex_dimensional_furniture_type(thing)
		if(!furniture_type)
			continue
		var/obj/new_furniture = new furniture_type(T)
		new_furniture.setDir(thing.dir)
		aquila_hex_dimensional_apply_material(new_furniture, material_type, AQUILA_HEX_DIMENSIONAL_FURNITURE_MATERIAL)
		qdel(thing)
	return TRUE

#undef AQUILA_HEX_DIMENSIONAL_TILE_MATERIAL
#undef AQUILA_HEX_DIMENSIONAL_WALL_MATERIAL
#undef AQUILA_HEX_DIMENSIONAL_FURNITURE_MATERIAL
