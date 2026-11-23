// AQUILA - turfy, ściany i rośliny planety dżunglowej z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, ikony CC BY-SA 3.0):
// code/game/turfs/open/floor/plating/jungle.dm, code/game/turfs/closed/minerals.dm (random/jungle),
// code/modules/events/spacevine.dm (dense, weak), code/datums/mapgen/planetary/battlefield_generator.dm (dead),
// code/modules/mining/lavaland/ash_flora.dm (garden).
// Zmiany względem Shiptesta:
// - trawy dżungli (zwykła, ciemna, żółta) i piasek rzeczny to kafle 32x32 wycięte ze sprite'ów 70x70
//   (tools/planets/floor_tiles.py), bez postrzępionych brzegów; błoto i spękana ziemia na naszych ikonach tg;
// - nowe typy pod /turf/open/floor/plating/asteroid zamiast przerabiania naszych /turf/open/floor/plating/dirt/jungle
//   (te mają pod spodem przepaść dżungli, a planeta nie może mieć dziur po wybuchu);
// - statyczne pnącza to nasze /obj/structure/spacevine bez kontrolera (nie rosną), gęste zasłaniają widok;
// - ogródki dają roślinę naszej botaniki z losowym nasieniem jadalnej rośliny zamiast losowego jedzenia ze spawnera;
// - atmosfera stała: ciepło i wilgotno, oddychalna (Shiptest: 303–313 K, 101–136 kPa, czasem ślad CO).

/// Atmosfera planety dżunglowej (oddychalna, ciepła)
#define PLANET_JUNGLE_ATMOS "o2=22;n2=89;co2=2;TEMP=308"

// Podłogi

/// Błoto (Shiptest: asteroid/dirt/jungle)
/turf/open/floor/plating/asteroid/dirt/jungle
	name = "błoto"
	desc = "Z bliska to wciąż ziemia, tylko bardziej mokra niż zwykle."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	baseturfs = /turf/open/floor/plating/asteroid/dirt/jungle
	turf_type = /turf/open/floor/plating/asteroid/dirt/jungle
	initial_gas_mix = PLANET_JUNGLE_ATMOS
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND

/turf/open/floor/plating/asteroid/dirt/jungle/dark
	icon_state = "greenerdirt"
	baseturfs = /turf/open/floor/plating/asteroid/dirt/jungle/dark
	turf_type = /turf/open/floor/plating/asteroid/dirt/jungle/dark

/// Spękana ziemia (Shiptest: asteroid/dirt/wasteland)
/turf/open/floor/plating/asteroid/dirt/jungle/wasteland
	name = "spękana ziemia"
	desc = "Wygląda na trochę suchą."
	icon_state = "wasteland"
	environment_type = "wasteland"
	floor_variance = 15
	baseturfs = /turf/open/floor/plating/asteroid/dirt/jungle/wasteland
	turf_type = /turf/open/floor/plating/asteroid/dirt/jungle/wasteland

/// Trawa dżungli (Shiptest: asteroid/dirt/grass/jungle)
/turf/open/floor/plating/asteroid/dirt/grass/jungle
	name = "trawa dżungli"
	desc = "Gęsta, soczysta trawa."
	icon = 'aquila/icons/planets/turf/jungle_floors.dmi'
	icon_state = "junglegrass"
	environment_type = "junglegrass"
	baseturfs = /turf/open/floor/plating/asteroid/dirt/jungle
	turf_type = /turf/open/floor/plating/asteroid/dirt/grass/jungle
	initial_gas_mix = PLANET_JUNGLE_ATMOS

/turf/open/floor/plating/asteroid/dirt/grass/jungle/dark
	name = "ciemna trawa dżungli"
	icon_state = "darkjunglegrass"
	environment_type = "darkjunglegrass"
	turf_type = /turf/open/floor/plating/asteroid/dirt/grass/jungle/dark

/turf/open/floor/plating/asteroid/dirt/grass/jungle/yellow
	name = "żółta trawa"
	desc = "Wyschnięta, sucha trawa."
	icon_state = "yellowgrass"
	environment_type = "yellowgrass"
	turf_type = /turf/open/floor/plating/asteroid/dirt/grass/jungle/yellow

/// Piasek rzeczny (Shiptest: asteroid/sand/jungle)
/turf/open/floor/plating/asteroid/river_sand
	name = "piasek rzeczny"
	desc = "Gęsty, mokry piasek z brzegów rzek i jezior planet dżunglowych."
	icon = 'aquila/icons/planets/turf/jungle_floors.dmi'
	icon_state = "riversand"
	icon_plating = "riversand"
	environment_type = "riversand"
	floor_variance = 50
	digResult = /obj/item/stack/ore/glass
	baseturfs = /turf/open/floor/plating/asteroid/river_sand
	turf_type = /turf/open/floor/plating/asteroid/river_sand
	initial_gas_mix = PLANET_JUNGLE_ATMOS
	planetary_atmos = TRUE

/// Mech dżungli (Shiptest: moss/jungle)
/turf/open/floor/plating/moss/jungle
	name = "mech dżungli"
	desc = "Mech chętnie zakorzenia się w wilgoci, zwykle razem ze swoimi kolegami grzybami."
	baseturfs = /turf/open/floor/plating/asteroid/dirt/jungle
	initial_gas_mix = PLANET_JUNGLE_ATMOS

/turf/open/water/planet/jungle/blood
	name = "krew"
	desc = "Posoka dawno zmarłych, ujarzmiona przez coś, co unosi się nad nią."
	color = "#800000"
	fishing_preset = null
	reagent_to_extract = /datum/reagent/blood
	baseturfs = /turf/open/water/planet/jungle/blood

// Ściany

/// Boksyt z rudami (Shiptest: mineral/random/jungle)
/turf/closed/mineral/random/planet_jungle
	name = "boksyt"
	desc = "Muł i błoto zmumifikowały się w twardy kształt w porannym słońcu."
	icon = 'aquila/icons/planets/turf/walls/jungle_wall.dmi'
	icon_state = "bauxite"
	smooth_icon = 'aquila/icons/planets/turf/walls/jungle_wall.dmi'
	environment_type = "dirt"
	turf_type = /turf/open/floor/plating/asteroid/dirt/jungle
	baseturfs = /turf/open/floor/plating/asteroid/dirt/jungle
	initial_gas_mix = PLANET_JUNGLE_ATMOS
	defer_change = TRUE
	mineralSpawnChanceList = list(/obj/item/stack/ore/uranium = 5, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/silver = 12, /obj/item/stack/ore/plasma = 20, /obj/item/stack/ore/iron = 40, /obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/bluespace_crystal = 1)

/// Skażona skała bez rud (Shiptest: mineral/random/jungle/polluted)
/turf/closed/mineral/random/planet_jungle/polluted
	name = "skażona skała"
	desc = "Cokolwiek tu kiedyś rządziło, została po tym tylko trucizna."
	icon = 'aquila/icons/planets/turf/walls/polluted_wall.dmi'
	icon_state = "polluted"
	smooth_icon = 'aquila/icons/planets/turf/walls/polluted_wall.dmi'
	environment_type = "wasteland"
	turf_type = /turf/open/floor/plating/asteroid/dirt/jungle/wasteland
	baseturfs = /turf/open/floor/plating/asteroid/dirt/jungle/wasteland
	mineralChance = 0

// Pnącza: bez kontrolera nie rosną

/// Gęste pnącza: nie da się przez nie patrzeć (Shiptest: spacevine/dense)
/obj/structure/spacevine/dense
	name = "gęste pnącza"
	desc = "Splątana ściana pnączy. Przez nią nic nie widać."
	opacity = TRUE
	icon_state = "Hvy1"

/obj/structure/spacevine/dense/Initialize(mapload)
	. = ..()
	icon_state = "Hvy[rand(1, 3)]"

/// Kruche pnącza
/obj/structure/spacevine/weak
	name = "kruche pnącza"
	desc = "Niezwykle ekspansywny gatunek pnącza. Ten wygląda na delikatniejszy niż większość."
	max_integrity = 25

/obj/structure/spacevine/weak/Initialize(mapload)
	. = ..()
	icon_state = "Light[rand(1, 3)]"

/// Martwe pnącza pól bitwy (Shiptest: battlefield_generator.dm)
/obj/structure/spacevine/dead
	name = "martwe pnącza"
	desc = "Uschnięte, brązowe pnącza."
	color = "#66400f"

/obj/structure/spacevine/dead/Initialize(mapload)
	. = ..()
	add_atom_colour("#66400f", FIXED_COLOUR_PRIORITY)

// Ogródki

/// Bujny ogródek: dzika roślina naszej botaniki z jadalnymi owocami (Shiptest: ash/garden)
/obj/structure/flora/ash/garden
	name = "bujny ogródek"
	desc = "W glebie i cieniu coś cicho rośnie."
	icon = 'aquila/icons/planets/flora/ice_jungle_flora.dmi'
	icon_state = "garden"
	base_icon_state = "garden"
	/// Nasiona do losowania (typ -> waga)
	var/list/garden_seeds = list(
		/obj/item/plant_seeds/preset/potato = 3,
		/obj/item/plant_seeds/preset/carrot = 3,
		/obj/item/plant_seeds/preset/berry = 3,
		/obj/item/plant_seeds/preset/cabbage = 2,
		/obj/item/plant_seeds/preset/tomato = 2,
		/obj/item/plant_seeds/preset/corn = 1,
		/obj/item/plant_seeds/preset/pineapple = 1,
		/obj/item/plant_seeds/preset/watermelon = 1,
	)

/obj/structure/flora/ash/garden/Initialize(mapload)
	seed_type = pickweight(garden_seeds)
	. = ..()
	icon_state = initial(icon_state)

/// Zmrożony ogródek planet lodowych
/obj/structure/flora/ash/garden/frigid
	name = "zmrożony ogródek"
	desc = "Delikatna warstwa szronu okrywa wytrzymałe krzaczki."
	icon_state = "gardencold"
	base_icon_state = "gardencold"
	garden_seeds = list(
		/obj/item/plant_seeds/preset/potato = 3,
		/obj/item/plant_seeds/preset/cabbage = 3,
		/obj/item/plant_seeds/preset/carrot = 2,
		/obj/item/plant_seeds/preset/chili/ice = 2,
		/obj/item/plant_seeds/preset/wheat = 1,
	)
