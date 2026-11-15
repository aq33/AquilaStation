// AQUILA - planety w układach. add_planet() to wspólne wejście: stałe planety z danych układów, losowe w układach
// generowanych (każdy dostaje jedną) i później kafle mapy hex („nieznany sygnał”, tunel) wołają tę samą procedurę.
// Typ losowej planety zależy od rodzaju układu: każdy typ ma wagi dla znaczników układu (system_tags), a znaczniki
// układu to tag z system_type i parallax_property. Gazowe olbrzymy (scenery) dochodzą obok zwykłej planety.

/// Szansa, że układ z pasującym znacznikiem dostaje też ozdobę (gazowego olbrzyma)
#define PLANET_SCENERY_CHANCE 50

/// Dodaje planetę do układu (załadowanego albo w nullspace). Zwraca planetę.
/datum/star_system/proc/add_planet(planet_type = /datum/planet_type/lava, planet_x, planet_y, planet_name)
	RETURN_TYPE(/obj/structure/overmap/planet)
	// Sprite ma 8 × 8 pól: nie może wystawać za mapę
	planet_x = planet_x || rand(30, world.maxx - 40)
	planet_y = planet_y || rand(30, world.maxy - 40)
	var/obj/structure/overmap/planet/planet
	if(occupying_z)
		planet = new(locate(planet_x, planet_y, occupying_z), planet_type)
		system_contents |= planet
		planet.current_system = src
	else
		planet = new(null, planet_type)
		system_contents |= planet
		contents_positions[planet] = list("x" = planet_x, "y" = planet_y)
		planet.current_system = src
	planet.name = planet_name || default_planet_name()
	return planet

/// Nazwa jak w katalogach: nazwa układu i numer planety (nowa planeta jest już w system_contents)
/datum/star_system/proc/default_planet_name()
	var/static/list/numerals = list("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX")
	var/count = 0
	for(var/obj/structure/overmap/planet/other in system_contents)
		count++
	return "[name] [numerals[min(count, length(numerals))]]"

/// Planety układu
/datum/star_system/proc/get_planets()
	. = list()
	for(var/obj/structure/overmap/planet/planet in system_contents)
		. += planet

/// Znaczniki układu do wyboru typu planety: tag rodzaju układu i paralaksa. Układ bez żadnego to „safe”.
/datum/star_system/proc/planet_tags()
	. = list()
	if(islist(system_type) && system_type["tag"])
		. += system_type["tag"]
	if(parallax_property)
		. |= parallax_property
	if(!length(.))
		. += "safe"

/// Losuje typ planety pasujący do układu. scenery: ozdoba układu zamiast zwykłej planety. Bez pasującego typu zwraca
/// typ dla pustej przestrzeni (zwykła planeta) albo null (ozdoba).
/proc/pick_planet_type_for_system(datum/star_system/system, scenery = FALSE)
	return pick_planet_type_for_tags(system.planet_tags(), scenery)

/proc/pick_planet_type_for_tags(list/tags, scenery = FALSE)
	var/list/weights = planet_type_weights(tags, scenery)
	if(!length(weights) && !scenery)
		weights = planet_type_weights(list("safe"), FALSE)
	if(length(weights))
		return pickweight(weights)
	if(!scenery)
		return /datum/planet_type/lava

/// Typ -> suma wag dla znaczników
/proc/planet_type_weights(list/tags, scenery)
	. = list()
	for(var/planet_type in GLOB.planet_type_prototypes)
		var/datum/planet_type/prototype = GLOB.planet_type_prototypes[planet_type]
		if(prototype.scenery != scenery)
			continue
		var/weight = 0
		for(var/tag in tags)
			weight += LAZYACCESS(prototype.system_tags, tag)
		if(weight > 0)
			.[planet_type] = weight

// Każdy układ generowany (Badlands, Litelands) ma jedną planetę. Planeta dostaje nazwę układu dopiero po wylosowaniu
// nazwy przez generator, więc dochodzi chwilę po utworzeniu układu.
/datum/star_system/random/New()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(add_random_planet)), 1)

/datum/star_system/random/proc/add_random_planet()
	if(length(get_planets()))
		return
	add_planet(pick_planet_type_for_system(src))
	if(prob(PLANET_SCENERY_CHANCE))
		var/scenery_type = pick_planet_type_for_system(src, TRUE)
		if(scenery_type)
			add_planet(scenery_type)

/// Stałe planety układów z mapy gwiezdnej: nazwa układu -> typy planet (według opisu i paralaksy układu)
GLOBAL_LIST_INIT(fixed_planets_by_system, list(
	"Tortuga" = list(/datum/planet_type/lava),
	"Ethor" = list(/datum/planet_type/lava),
	"Bemike" = list(/datum/planet_type/lava),
	"Demon's Maw" = list(/datum/planet_type/lava),
))

/datum/controller/subsystem/star_system/Initialize(start_timeofday)
	. = ..()
	add_fixed_planets()

/datum/controller/subsystem/star_system/proc/add_fixed_planets()
	for(var/datum/star_system/system as anything in systems)
		var/list/planet_types = GLOB.fixed_planets_by_system[system.name]
		if(!length(planet_types) || length(system.get_planets()))
			continue
		for(var/planet_type in planet_types)
			system.add_planet(planet_type)

#undef PLANET_SCENERY_CHANCE
