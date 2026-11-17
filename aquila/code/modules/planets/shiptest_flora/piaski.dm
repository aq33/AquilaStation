// AQUILA - teren i roślinność planet skalistych, białych piasków, pustynnych i mglistych z Shiptesta
// (shiptest-ss13/Shiptest, kod AGPLv3, ikony CC BY-SA 3.0): code/game/turfs/open/floor/plating/rockplanet.dm,
// whitesands.dm, desert.dm, shrouded.dm, code/game/turfs/closed/minerals.dm, code/game/turfs/open/water.dm
// i code/game/objects/structures/flora.dm.
// Podłogi jak przy planecie wulkanicznej: Shiptest wygładza je bitmaskiem (sprite'y 70x70), u nas to pojedyncze kafle
// 32x32 wycięte ze środka (tools/planets/floor_tiles.py) z losowymi wariantami /turf/open/floor/plating/asteroid.
// Ściany minerałów: stany bitmaski przerobione na nasz stary smoothing narożnikowy (tools/planets/wall_corners.py).
// Warianty "/lit" pominięte: obszary planet mają stałe światło.

// Planeta skalista

/// Żelazny piasek (Shiptest: /turf/open/floor/plating/asteroid/rockplanet)
/turf/open/floor/plating/asteroid/rockplanet
	name = "żelazny piasek"
	desc = "Rdzawy piasek pełen tlenków żelaza."
	icon = 'aquila/icons/planets/turf/rockplanet.dmi'
	icon_state = "rockplanet"
	environment_type = "rockplanet"
	floor_variance = 80
	baseturfs = /turf/open/floor/plating/asteroid/rockplanet
	turf_type = /turf/open/floor/plating/asteroid/rockplanet
	initial_gas_mix = PLANET_ROCK_ATMOS
	planetary_atmos = TRUE
	digResult = /obj/item/stack/ore/glass

/// Mokry żelazny piasek z brzegów rzadkich zbiorników wody
/turf/open/floor/plating/asteroid/rockplanet/wet
	name = "mokry żelazny piasek"
	icon_state = "rockplanet_wet"
	environment_type = "rockplanet_wet"

/// Spękana skała jaskiń
/turf/open/floor/plating/asteroid/rockplanet/cracked
	name = "spękany żelazny piasek"
	icon_state = "rockplanet_cracked"
	environment_type = "rockplanet_cracked"
	floor_variance = 0
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW

/// Czapy śniegu na planecie skalistej
/turf/open/floor/plating/asteroid/snow/rockplanet
	baseturfs = /turf/open/floor/plating/asteroid/rockplanet
	initial_gas_mix = PLANET_ROCK_ATMOS

/// Staw (Shiptest: /turf/open/water/rockplanet)
/turf/open/water/planet/rockplanet
	name = "staw"
	desc = "Mętna woda z rdzawym nalotem."
	color = "#719af1"
	initial_gas_mix = PLANET_ROCK_ATMOS
	baseturfs = /turf/open/water/planet/rockplanet

/turf/closed/mineral/random/rockplanet
	name = "rdzawa skała"
	icon = 'aquila/icons/planets/turf/walls/rockplanet.dmi'
	icon_state = "rock"
	smooth_icon = 'aquila/icons/planets/turf/walls/rockplanet.dmi'
	environment_type = "rockplanet"
	turf_type = /turf/open/floor/plating/asteroid/rockplanet/cracked
	baseturfs = /turf/open/floor/plating/asteroid/rockplanet/cracked
	initial_gas_mix = PLANET_ROCK_ATMOS
	defer_change = TRUE
	mineralChance = 10
	mineralSpawnChanceList = list(/obj/item/stack/ore/iron = 40, /obj/item/stack/ore/silver = 12, /obj/item/stack/ore/gold = 8,
		/obj/item/stack/ore/uranium = 5, /obj/item/stack/ore/titanium = 8, /obj/item/stack/ore/copper = 12, /obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/bluespace_crystal = 1)

// Białe piaski

/// Solony piasek (Shiptest: /turf/open/floor/plating/asteroid/whitesands)
/turf/open/floor/plating/asteroid/whitesands
	name = "solony piasek"
	desc = "Biały piasek przesycony solą. Szczypie w rany."
	icon = 'aquila/icons/planets/turf/whitesands.dmi'
	icon_state = "whitesands"
	environment_type = "whitesands"
	floor_variance = 83
	baseturfs = /turf/open/floor/plating/asteroid/whitesands
	turf_type = /turf/open/floor/plating/asteroid/whitesands
	initial_gas_mix = PLANET_SAND_ATMOS
	planetary_atmos = TRUE
	digResult = /obj/item/stack/ore/glass

/// Kamienisty solony piasek: zawsze z odłamkami
/turf/open/floor/plating/asteroid/whitesands/rocky
	floor_variance = 100

/// Wyschnięty piasek z koryt dawnych rzek
/turf/open/floor/plating/asteroid/whitesands/dried
	name = "wyschnięty piasek"
	desc = "Piasek spieczony w twardą skorupę."
	icon_state = "whitesands_dried"
	environment_type = "whitesands_dried"
	floor_variance = 0
	baseturfs = /turf/open/floor/plating/asteroid/whitesands/dried
	turf_type = /turf/open/floor/plating/asteroid/whitesands/dried
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW

/// Fioletowa trawa: jedna z niewielu roślin białych piasków
/turf/open/floor/plating/asteroid/whitesands/grass
	name = "fioletowa trawa"
	desc = "Nieliczna flora białych piasków ma fioletowy odcień."
	icon_state = "ws_grass"
	environment_type = "ws_grass"
	floor_variance = 0
	dug = TRUE
	baseturfs = /turf/open/floor/plating/asteroid/whitesands/grass/dead
	turf_type = /turf/open/floor/plating/asteroid/whitesands/grass
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS

/turf/open/floor/plating/asteroid/whitesands/grass/burn_tile()
	ScrapeAway()
	return TRUE

/turf/open/floor/plating/asteroid/whitesands/grass/dead
	name = "martwa trawa"
	desc = "Flora białych piasków nie żyje długo, a już na pewno nie po wojnie."
	color = "#ddffb3"
	baseturfs = /turf/open/floor/plating/asteroid/whitesands
	turf_type = /turf/open/floor/plating/asteroid/whitesands/grass/dead

/// Czapy śniegu na białych piaskach
/turf/open/floor/plating/asteroid/snow/whitesands
	baseturfs = /turf/open/floor/plating/asteroid/whitesands
	initial_gas_mix = PLANET_SAND_ATMOS

/// Kwaśne jeziorko (Shiptest: /turf/open/water/whitesands): płytki kwas siarkowy, parzy przy brodzeniu
/turf/open/water/planet/acid
	name = "jeziorko kwasu siarkowego"
	desc = "Płytki kwas siarkowy. Lepiej w niego nie wchodzić, choć przejść się da, jeśli nie zostanie się długo."
	color = "#57ffd5"
	initial_gas_mix = PLANET_SAND_ATMOS
	baseturfs = /turf/open/water/planet/acid
	reagent_to_extract = /datum/reagent/toxin/acid
	/// Oparzenia przy każdym wejściu na pole bez butów
	var/acid_burn = 4

/turf/open/water/planet/acid/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/wader = arrived
	if(wader.movement_type & (FLYING | FLOATING))
		return
	if(ishuman(wader))
		var/mob/living/carbon/human/human_wader = wader
		if(human_wader.shoes && (human_wader.shoes.resistance_flags & ACID_PROOF))
			return
		human_wader.apply_damage(acid_burn, BURN, pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	else
		wader.adjustFireLoss(acid_burn)
	if(prob(30))
		to_chat(wader, span_danger("Kwas parzy ci nogi!"))

/turf/closed/mineral/random/whitesands
	name = "solona skała"
	icon = 'aquila/icons/planets/turf/walls/whitesands.dmi'
	icon_state = "rock"
	smooth_icon = 'aquila/icons/planets/turf/walls/whitesands.dmi'
	environment_type = "whitesands_dried"
	turf_type = /turf/open/floor/plating/asteroid/whitesands/dried
	baseturfs = /turf/open/floor/plating/asteroid/whitesands/dried
	initial_gas_mix = PLANET_SAND_ATMOS
	defer_change = TRUE
	mineralChance = 10
	mineralSpawnChanceList = list(/obj/item/stack/ore/iron = 45, /obj/item/stack/ore/titanium = 20, /obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/silver = 8, /obj/item/stack/ore/gold = 4, /obj/item/stack/ore/uranium = 3, /obj/item/stack/ore/diamond = 1)

// Pustynia

/// Piasek pustyni (Shiptest: /turf/open/floor/plating/asteroid/desert)
/turf/open/floor/plating/asteroid/desert
	name = "piasek pustyni"
	desc = "Szorstki i włazi wszędzie."
	icon = 'aquila/icons/planets/turf/desert.dmi'
	icon_state = "desert"
	environment_type = "desert"
	floor_variance = 83
	baseturfs = /turf/open/floor/plating/asteroid/desert
	turf_type = /turf/open/floor/plating/asteroid/desert
	initial_gas_mix = PLANET_DESERT_ATMOS
	planetary_atmos = TRUE
	digResult = /obj/item/stack/ore/glass

/// Wyschnięte dno morskie
/turf/open/floor/plating/asteroid/desert/dry_seafloor
	name = "wyschnięte dno morskie"
	desc = "Trzeba było pić więcej wody."
	icon_state = "drydesert"
	environment_type = "drydesert"
	floor_variance = 0
	baseturfs = /turf/open/floor/plating/asteroid/desert/dry_seafloor
	turf_type = /turf/open/floor/plating/asteroid/desert/dry_seafloor
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW

/turf/closed/mineral/random/desert
	name = "piaskowiec"
	icon = 'aquila/icons/planets/turf/walls/desert.dmi'
	icon_state = "rock"
	smooth_icon = 'aquila/icons/planets/turf/walls/desert.dmi'
	environment_type = "desert"
	turf_type = /turf/open/floor/plating/asteroid/desert
	baseturfs = /turf/open/floor/plating/asteroid/desert
	initial_gas_mix = PLANET_DESERT_ATMOS
	defer_change = TRUE
	mineralChance = 10
	mineralSpawnChanceList = list(/obj/item/stack/ore/gold = 20, /obj/item/stack/ore/iron = 30, /obj/item/stack/ore/uranium = 8,
		/obj/item/stack/ore/plasma = 6, /obj/item/stack/ore/diamond = 3, /obj/item/stack/ore/titanium = 6, /obj/item/stack/ore/silver = 8)

// Planeta mglista

/// Ubity piasek (Shiptest: /turf/open/floor/plating/asteroid/shrouded)
/turf/open/floor/plating/asteroid/shrouded
	name = "ubity piasek"
	desc = "Piasek ubity na twardą ziemię."
	icon = 'aquila/icons/planets/turf/shrouded.dmi'
	icon_state = "shrouded"
	environment_type = "shrouded"
	floor_variance = 83
	baseturfs = /turf/open/floor/plating/asteroid/shrouded
	turf_type = /turf/open/floor/plating/asteroid/shrouded
	initial_gas_mix = PLANET_SHROUDED_ATMOS
	planetary_atmos = TRUE
	digResult = /obj/item/stack/ore/glass

/turf/closed/mineral/random/shrouded
	name = "skała spowita mgłą"
	icon = 'aquila/icons/planets/turf/walls/shrouded.dmi'
	icon_state = "rock"
	smooth_icon = 'aquila/icons/planets/turf/walls/shrouded.dmi'
	environment_type = "shrouded"
	turf_type = /turf/open/floor/plating/asteroid/shrouded
	baseturfs = /turf/open/floor/plating/asteroid/shrouded
	initial_gas_mix = PLANET_SHROUDED_ATMOS
	defer_change = TRUE
	mineralChance = 12
	mineralSpawnChanceList = list(/obj/item/stack/ore/uranium = 30, /obj/item/stack/ore/plasma = 25, /obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/bluespace_crystal = 4, /obj/item/stack/ore/titanium = 6, /obj/item/stack/ore/gold = 5, /obj/item/stack/ore/diamond = 1)

// Roślinność

/obj/structure/flora/rock/rockplanet
	name = "rdzawy kamień"
	desc = "Wypiętrzony guz czerwonej skały."
	icon = 'aquila/icons/planets/flora/piaski_rocks.dmi'
	icon_state = "redrock"

/obj/structure/flora/rock/pile/rockplanet
	name = "rdzawe kamienie"
	desc = "Sterta rdzawych kamieni."
	icon = 'aquila/icons/planets/flora/piaski_rocks.dmi'
	icon_state = "redrocks"
	gender = PLURAL

/// Ostaniec pustyni (Shiptest: rock/beach, „sea stack”)
/obj/structure/flora/rock/desert
	name = "ostaniec"
	desc = "Kolumna skały wyrzeźbiona przez dawne fale."
	icon = 'aquila/icons/planets/flora/piaski_rocks.dmi'
	icon_state = "basalt"

/// Kamyki (Shiptest: rock/asteroid)
/obj/structure/flora/rock/pile/desert
	name = "kamyki"
	desc = "Drobne kamyki odłupane od większej skały."
	icon = 'aquila/icons/planets/flora/piaski_rocks.dmi'
	icon_state = "asteroid"
	gender = PLURAL

/obj/structure/flora/grass/rockplanet
	name = "wełnianka"
	desc = "Odmiana prerii kochającej chłód. Dobrze znosi mroźną planetę skalistą, póki ma w pobliżu wodę."
	icon = 'aquila/icons/planets/flora/piaski_rocks.dmi'
	icon_state = "tall_grass_1"

/obj/structure/flora/grass/rockplanet/Initialize(mapload)
	. = ..()
	icon_state = "tall_grass_[rand(1, 2)]"

/obj/structure/flora/grass/rockplanet/dead
	name = "sucha wełnianka"
	desc = "Ta kępa najwyraźniej straciła dostęp do życiodajnej wody."
	icon_state = "dry_grass_1"

/obj/structure/flora/grass/rockplanet/dead/Initialize(mapload)
	. = ..()
	icon_state = "dry_grass_[rand(1, 2)]"

/obj/structure/flora/tree/cactus
	name = "kaktus maguaro"
	desc = "Wytrzymała odmiana saguaro z Układu Słonecznego. Sadzona na Marsie przeciw erozji gleby, dziś rośnie na mroźnych tundrach w całej znanej przestrzeni."
	icon = 'aquila/icons/planets/flora/piaski_cactus.dmi'
	icon_state = "cactus1"
	log_amount = 3

/obj/structure/flora/tree/cactus/Initialize(mapload)
	. = ..()
	icon_state = "cactus[rand(1, 4)]"

/// Wysoka sosna białych piasków (Shiptest: tree/tall/whitesands)
/obj/structure/flora/tree/whitesands
	name = "fioletowa sosna"
	desc = "Niezwykle wysokie drzewo o fioletowym igliwiu."
	icon = 'aquila/icons/planets/flora/piaski_tall_trees.dmi'
	icon_state = "pine_1"
	color = "#846996"

/obj/structure/flora/tree/whitesands/Initialize(mapload)
	. = ..()
	color = pick("#846996", "#7b4e99", "#924fab")
	icon_state = "pine_[rand(1, 2)]"

// Ruiny i biomy

/// Źródło promieniowania (Shiptest: /obj/effect/radiation): co kilka sekund impuls naszego radiation_pulse
/obj/effect/planet_radiation
	name = "promieniowanie"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	/// Siła impulsu i zasięg
	var/intensity = 3
	var/max_range = 3

/obj/effect/planet_radiation/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/planet_radiation/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/planet_radiation/process(delta_time)
	if(DT_PROB(25, delta_time))
		radiation_pulse(src, max_range = max_range, threshold = RAD_LIGHT_INSULATION, intensity = intensity)

/// Pustelnik (Shiptest: spawner/random/hermit): u nas piraci-zbieracze
/obj/effect/spawner/lootdrop/planet_hermit
	name = "losowy pustelnik"
	loot = list(
		/mob/living/basic/trooper/pirate/melee = 3,
		/mob/living/basic/trooper/pirate/ranged = 1,
	)

// Spawnery z szansą z greebli białych piasków (Shiptest: code/game/objects/effects/spawners/random/sand_planet.dm).
// Pusty klucz "" w liście to „nic”: lootdrop wtedy niczego nie stawia.

/obj/effect/spawner/lootdrop/planet_chance
	name = "losowa roślina planety"

/obj/effect/spawner/lootdrop/planet_chance/puce
	loot = list(/obj/structure/flora/ash/puce = 20, "" = 80)

/obj/effect/spawner/lootdrop/planet_chance/fern
	loot = list(/obj/structure/flora/ash/fern = 50, "" = 50)

/obj/effect/spawner/lootdrop/planet_chance/rock
	loot = list(/obj/structure/flora/rock = 70, "" = 30)

/obj/effect/spawner/lootdrop/planet_chance/whitesands_fauna
	name = "losowa fauna białych piasków"
	loot = list(
		/mob/living/basic/mining/goliath/whitesands/random = 15,
		/mob/living/basic/mining/basilisk/whitesands = 20,
		/obj/effect/spawner/lootdrop/planet_hermit = 5,
		"" = 60,
	)
