// AQUILA - planety w układach. add_planet() to wspólne wejście: stałe planety z danych układów, losowe w układach
// generowanych (każdy dostaje jedną) i później kafle mapy hex („nieznany sygnał”, tunel) wołają tę samą procedurę.

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

/// Nazwa jak w katalogach: nazwa układu i numer planety
/datum/star_system/proc/default_planet_name()
	var/static/list/numerals = list("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX")
	var/count = 1
	for(var/obj/structure/overmap/planet/other in system_contents)
		count++
	return "[name] [numerals[min(count, length(numerals))]]"

/// Planety układu
/datum/star_system/proc/get_planets()
	. = list()
	for(var/obj/structure/overmap/planet/planet in system_contents)
		. += planet

// Każdy układ generowany (Badlands, Litelands) ma jedną planetę. Planeta dostaje nazwę układu dopiero po wylosowaniu
// nazwy przez generator, więc dochodzi chwilę po utworzeniu układu.
/datum/star_system/random/New()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(add_random_planet)), 1)

/datum/star_system/random/proc/add_random_planet()
	if(length(get_planets()))
		return
	add_planet(pick(subtypesof(/datum/planet_type)))
