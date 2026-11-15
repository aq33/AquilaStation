// AQUILA - turfy i roślinność planet morskich (plaża, planeta wodna) z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3,
// ikony CC BY-SA 3.0): code/game/turfs/open/floor/plating/beach.dm, waterplanet.dm, closed/minerals.dm
// (random/beach, random/waterplanet), objects/structures/flora.dm (driftwood, driftlog, rock/beach, rock/asteroid,
// tree/dead_pine) i items/toys.dm (seashell). Podłogi 70x70 pocięte na kafle 32x32 (tools/planets/floor_tiles.py,
// jak przy planecie wulkanicznej), warianty "/lit" pominięte: obszary planet mają stałe światło. Woda jest
// w aquila/code/modules/planets/water/.

/// Atmosfera plaży: ciepła i oddychalna (Shiptest: BEACHPLANET_ATMOS, 283-303 K)
#define PLANET_BEACH_ATMOS "o2=22;n2=82;TEMP=293.15"
/// Atmosfera planety wodnej: oddychalna, ale lodowata (jak wzburzone morze)
#define PLANET_WATER_ATMOS "o2=22;n2=82;TEMP=255.37"

/// Piasek plaży (Shiptest: /turf/open/floor/plating/asteroid/sand)
/turf/open/floor/plating/asteroid/sand
	name = "piasek"
	desc = "Ciepły, drobny piasek plaży."
	icon = 'aquila/icons/planets/turf/beach_floors.dmi'
	icon_state = "beachsand"
	environment_type = "beachsand"
	floor_variance = 83
	baseturfs = /turf/open/floor/plating/asteroid/sand
	turf_type = /turf/open/floor/plating/asteroid/sand
	initial_gas_mix = PLANET_BEACH_ATMOS
	planetary_atmos = TRUE
	digResult = /obj/item/stack/ore/glass
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND

/// Mokry, ubity piasek przy wodzie i w jaskiniach
/turf/open/floor/plating/asteroid/sand/dense
	name = "mokry piasek"
	desc = "Ubity, wilgotny piasek. Odciski stóp zostają w nim na długo."
	icon_state = "beachsand_wet"
	environment_type = "beachsand_wet"
	baseturfs = /turf/open/floor/plating/asteroid/sand/dense
	turf_type = /turf/open/floor/plating/asteroid/sand/dense

/// Ziemia plaży (Shiptest: /turf/open/floor/plating/asteroid/dirt/beach)
/turf/open/floor/plating/asteroid/dirt/beach
	baseturfs = /turf/open/floor/plating/asteroid/dirt/beach
	initial_gas_mix = PLANET_BEACH_ATMOS
	planetary_atmos = TRUE

/// Trawa plaży
/turf/open/floor/plating/asteroid/dirt/grass/beach
	baseturfs = /turf/open/floor/plating/asteroid/sand
	initial_gas_mix = PLANET_BEACH_ATMOS
	planetary_atmos = TRUE

/// Ciemna trawa (Shiptest: dirt/grass/dark, darkgrass.dmi)
/turf/open/floor/plating/asteroid/dirt/grass/dark
	name = "ciemna trawa"
	desc = "Gęsta, ciemnozielona trawa."
	icon = 'aquila/icons/planets/turf/beach_floors.dmi'
	icon_state = "darkgrass"
	environment_type = "darkgrass"

/// Ciemna trawa plaży: łaty rozlewa greeble dark_beach
/turf/open/floor/plating/asteroid/dirt/grass/dark/beach
	baseturfs = /turf/open/floor/plating/asteroid/sand
	initial_gas_mix = PLANET_BEACH_ATMOS
	planetary_atmos = TRUE

/// Czarodziejska trawa w jaskiniach plaży (Shiptest: dirt/grass/fairy): nasza świecąca trawa z atmosferą planety
/turf/open/floor/grass/fairy/planet
	baseturfs = /turf/open/floor/plating/asteroid/sand/dense
	initial_gas_mix = PLANET_BEACH_ATMOS
	planetary_atmos = TRUE

/// Mokra skała planety wodnej (Shiptest: /turf/open/floor/plating/asteroid/waterplanet)
/turf/open/floor/plating/asteroid/waterplanet
	name = "mokre skaliste podłoże"
	desc = "Przez grunt przesącza się woda."
	icon = 'aquila/icons/planets/turf/beach_floors.dmi'
	icon_state = "wateryrock"
	environment_type = "wateryrock"
	floor_variance = 0
	baseturfs = /turf/open/floor/plating/asteroid/waterplanet
	turf_type = /turf/open/floor/plating/asteroid/waterplanet
	initial_gas_mix = PLANET_WATER_ATMOS
	planetary_atmos = TRUE
	digResult = /obj/item/stack/ore/glass/basalt
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/// Nadbrzeżny margiel: skała jaskiń plaży, zwykłe rudy (Shiptest: random/beach, bez własnej ikony)
/turf/closed/mineral/random/beach
	name = "nadbrzeżny margiel"
	desc = "Woda wyżera linię brzegową i zostawia w miękknącym kamieniu pofalowane blizny."
	turf_type = /turf/open/floor/plating/asteroid/sand/dense
	baseturfs = /turf/open/floor/plating/asteroid/sand/dense
	initial_gas_mix = PLANET_BEACH_ATMOS
	defer_change = TRUE

/// Skała jaskiń planety wodnej. Rudy z Shiptesta, ruda lodu zamieniona na żelazo i plazmę (nie mamy jej).
/turf/closed/mineral/random/waterplanet
	name = "mokra skała"
	desc = "Skała nasiąknięta wodą, śliska od glonów."
	turf_type = /turf/open/floor/plating/asteroid/waterplanet
	baseturfs = /turf/open/floor/plating/asteroid/waterplanet
	initial_gas_mix = PLANET_WATER_ATMOS
	defer_change = TRUE
	mineralChance = 10
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/diamond = 5,
		/obj/item/stack/ore/silver = 11,
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/iron = 35,
		/obj/item/stack/ore/gold = 2,
	)

// Rośliny i drobiazgi plaży

/// Ostaniec morski (Shiptest: rock/beach)
/obj/structure/flora/rock/beach
	name = "ostaniec"
	desc = "Słup skalny wyrzeźbiony przez fale."

/// Kamyki (Shiptest: rock/asteroid)
/obj/structure/flora/rock/asteroid
	name = "kamyki"
	desc = "Kilka drobnych kamyków odłupanych od większej skały."
	icon = 'aquila/icons/planets/flora/beach_flora.dmi'
	icon_state = "asteroid"
	density = FALSE
	gender = PLURAL

/obj/structure/flora/rock/asteroid/Initialize(mapload)
	. = ..()
	icon_state = "asteroid[rand(0, 9)]"

/// Drewno wyrzucone przez morze (Shiptest: driftwood)
/obj/structure/flora/driftwood
	name = "wyrzucone drewno"
	desc = "Wszystko, co morze zabrało, a potem zwróciło, wygładzone przez fale."
	icon = 'aquila/icons/planets/flora/beach_flora.dmi'
	icon_state = "stick2"
	density = FALSE

/obj/structure/flora/driftwood/Initialize(mapload)
	. = ..()
	icon_state = "stick[rand(1, 4)]"

/// Pień wyrzucony przez morze (Shiptest: driftlog)
/obj/structure/flora/driftlog
	name = "wyrzucony pień"
	desc = "Spory kawał drewna wyrzucony przez morze na brzeg."
	icon = 'aquila/icons/planets/flora/beach_flora.dmi'
	icon_state = "dry_log"
	density = FALSE

/// Martwa sosna w jaskiniach nad zatoką (Shiptest: tree/dead_pine)
/obj/structure/flora/tree/dead_pine
	name = "martwa sosna"
	desc = "Martwa sosna, z której opadły wszystkie igły."
	icon = 'aquila/icons/planets/flora/beach_trees.dmi'
	icon_state = "med_pine_dead"
	pixel_x = -16

/// Muszla z plaży (Shiptest: toy/seashell)
/obj/item/toy/seashell
	name = "muszla"
	desc = "Obyś zawsze miał muszlę w kieszeni i piasek w butach. Cokolwiek to znaczy."
	icon = 'aquila/icons/planets/flora/beach_flora.dmi'
	icon_state = "shell1"
	w_class = WEIGHT_CLASS_TINY
	var/static/list/possible_colors = list("" = 2, "#9e9aa5" = 1, "#808000" = 1, "#8fa0b3" = 1, "#b38686" = 1)

/obj/item/toy/seashell/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	icon_state = "shell[rand(1, 3)]"
	color = pickweight(possible_colors)
	setDir(pick(GLOB.cardinals))

/// Łata ciemnej trawy na plaży (Shiptest: grass_patch_spawner/dark_beach)
/obj/effect/greeble_spawner/grass_patch/dark_beach
	name = "spawner łaty ciemnej trawy"
	turf_to_spread = /turf/open/floor/plating/asteroid/dirt/grass/dark/beach
	big_brush = TRUE
	only_spread_on_spawning_turf = TRUE
	max_turfs_to_spread = 8
	min_turfs_to_spread = 3
	patch_direction_locked = TRUE
	chance_to_terminate = 0
	terminate_chance_add = 5
