// AQUILA - turfy księżyca i pola asteroid z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, ikony CC BY-SA 3.0):
// code/game/turfs/open/floor/plating/moon.dm, code/game/turfs/closed/minerals.dm (/turf/closed/mineral/random/moon),
// ikony icons/turf/floors/moonsand.dmi, icons/turf/planetary/moon.dmi, icons/turf/walls/moon.dmi.
// Regolit (70x70 z bitmaską) pocięty na kafle 32x32 (tools/planets/floor_tiles.py), ściany z bitmaski na nasz smoothing
// narożnikowy (tools/planets/wall_corners.py). Warianty "/lit" pominięte: światło daje obszar planety.
// Kratery: Shiptest odpala na części pól getDug(), który u nas wyrzuca piasek, więc tu pole tylko wygląda na rozkopane.

/// Regolit księżyca
/turf/open/floor/plating/asteroid/moon
	name = "regolit"
	desc = "Pył i okruchy skał księżycowych. Podobno szkodliwe dla płuc."
	icon = 'aquila/icons/planets/turf/moon.dmi'
	icon_state = "moonsand"
	icon_plating = "moonsand"
	environment_type = "moonsand"
	floor_variance = 83
	baseturfs = /turf/open/floor/plating/asteroid/moon_coarse/dark
	turf_type = /turf/open/floor/plating/asteroid/moon
	digResult = /obj/item/stack/ore/glass
	initial_gas_mix = AIRLESS_ATMOS
	planetary_atmos = TRUE

/// Regolit z kraterami po meteorytach (część pól wygląda na rozkopane)
/turf/open/floor/plating/asteroid/moon/craters
	/// Szansa na krater na polu (Shiptest: 1 na 12)
	var/crater_chance = 8.3

/turf/open/floor/plating/asteroid/moon/craters/Initialize(mapload)
	. = ..()
	if(prob(crater_chance))
		make_crater()

/// Pole wygląda na wykopane, ale bez wyrzucania piasku (generator stawia tysiące takich pól)
/turf/open/floor/plating/asteroid/proc/make_crater()
	dug = TRUE
	icon_plating = "[environment_type]_dug"
	icon_state = "[environment_type]_dug"

/// Twardy regolit
/turf/open/floor/plating/asteroid/moon_coarse
	name = "twardy regolit"
	desc = "Twardsza, mniej pylista skała księżycowa."
	icon = 'aquila/icons/planets/turf/moon.dmi'
	icon_state = "moonsand_coarse"
	icon_plating = "moonsand_coarse"
	environment_type = "moonsand_coarse"
	floor_variance = 0
	baseturfs = /turf/open/floor/plating/asteroid/moon_coarse/dark
	turf_type = /turf/open/floor/plating/asteroid/moon_coarse
	digResult = /obj/item/stack/ore/glass
	initial_gas_mix = AIRLESS_ATMOS
	planetary_atmos = TRUE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW

/turf/open/floor/plating/asteroid/moon_coarse/craters
	/// Szansa na krater (Shiptest: 10%)
	var/crater_chance = 10

/turf/open/floor/plating/asteroid/moon_coarse/craters/Initialize(mapload)
	. = ..()
	if(prob(crater_chance))
		make_crater()

/// Ciemny twardy regolit: grunt pod ścianami i podłoże księżyca
/turf/open/floor/plating/asteroid/moon_coarse/dark
	icon_state = "moonsand_coarse_dark"
	icon_plating = "moonsand_coarse_dark"
	environment_type = "moonsand_coarse_dark"
	turf_type = /turf/open/floor/plating/asteroid/moon_coarse/dark

/// Skała księżycowa z rudami
/turf/closed/mineral/random/moon
	name = "skała księżycowa"
	desc = "Podobno świetnie przewodzi portale."
	icon = 'aquila/icons/planets/turf/moon_wall.dmi'
	icon_state = "moonrock"
	smooth_icon = 'aquila/icons/planets/turf/moon_wall.dmi'
	environment_type = "moonsand_coarse_dark"
	turf_type = /turf/open/floor/plating/asteroid/moon_coarse/dark
	baseturfs = /turf/open/floor/plating/asteroid/moon_coarse/dark
	initial_gas_mix = AIRLESS_ATMOS
	defer_change = TRUE
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 2, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/plasma = 1, /obj/item/stack/ore/iron = 40, /obj/item/stack/ore/titanium = 20,
		/obj/item/stack/ore/bluespace_crystal = 5)

/// Lód bez powietrza (jaskinie lodowe pola asteroid)
/turf/open/floor/plating/ice/airless
	initial_gas_mix = AIRLESS_ATMOS
	baseturfs = /turf/open/floor/plating/asteroid/airless

/// Krawędź pola asteroid i słabego sygnału: dalej nie da się przelecieć
/turf/closed/indestructible/rock/planet_edge/asteroid
	name = "gęsty pas asteroid"
	desc = "Skały tak gęsto upakowane, że nie da się między nimi przecisnąć. Dalej nic nie widać."
	baseturfs = /turf/closed/indestructible/rock/planet_edge/asteroid

// Próżnia na powierzchni planety (pole asteroid, słaby sygnał): nie da się na niej stanąć, więc lądowiska ją zasypują
// gruntem, a kapsuły desantowe jej nie celują
/turf/open/space
	planet_landing_hazard = TRUE
