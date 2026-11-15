// AQUILA - planeta-śmietnisko: turfy, rośliny, źródła promieniowania i spawnery śmieci z Shiptesta
// (shiptest-ss13/Shiptest, kod AGPLv3, ikony CC BY-SA 3.0): code/game/turfs/open/floor/plating/wasteplanet.dm,
// code/game/objects/effects/radiation.dm, code/modules/ruins/objects_and_mobs/generic_hazards/ (beczki z odpadami),
// code/game/objects/effects/spawners/random/waste_planet.dm i ash_flora.dm (kolonia świecących grzybów).
// Zmiany względem Shiptesta:
// - atmosfera stała (PLANET_WASTE_ATMOS) zamiast losowej /datum/atmosphere: dużo tlenu i trochę CO2 zamiast tlenku węgla
//   i dwutlenku siarki, których nie mamy;
// - warianty "/lit" pominięte (obszar planety ma stałe światło), ściany betonowe to nasze zwykłe i wzmocnione;
// - promieniowanie przez nasze radiation_pulse (AQ#600) zamiast starego rad_act; beczki to zwykłe struktury bez systemu
//   zagrożeń Shiptesta (/obj/structure/hazard): promieniują co kilka sekund, gdy w pobliżu jest gracz;
// - złom (salvageable) jak przy planecie wulkanicznej: puste ramy maszyn i komputerów; wraki mechów Clip -> zwykłe;
// - smoła to płytka woda z wolnym chodem i bez łowiska; ogródki (losowe jedzenie) -> grzyby botaniki.

#define PLANET_WASTE_ATMOS "o2=38;n2=56;co2=8;TEMP=288.15"

// Teren

/turf/open/floor/plating/asteroid/wasteplanet
	name = "suchy kamień"
	desc = "Spękana, wyjałowiona skała. Pachnie rdzą i chemikaliami."
	icon = 'aquila/icons/planets/turf/wasteplanet.dmi'
	icon_state = "wasteplanet0"
	environment_type = "wasteplanet"
	turf_type = /turf/open/floor/plating/asteroid/wasteplanet
	floor_variance = 45
	digResult = /obj/item/stack/ore/glass
	baseturfs = /turf/open/floor/plating/asteroid/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	planetary_atmos = TRUE

/// Poszycie wysypiska
/turf/open/floor/plating/wasteplanet
	baseturfs = /turf/open/floor/plating/asteroid/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/wasteplanet/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/floor/plating/wasteplanet/rust
	name = "zardzewiałe poszycie"
	desc = "Przeżarta rdzą stal."

/turf/open/floor/plating/wasteplanet/rust/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rust)

/// Wnętrza ruin z atmosferą planety
/turf/open/floor/plasteel/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS

/turf/open/floor/plasteel/dark/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS

/turf/open/floor/plasteel/stairs/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/pod/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/engine/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/mineral/plastitanium/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS

/turf/open/floor/mineral/plastitanium/red/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS

/// Beton na otwartej przestrzeni wysypiska (losowe płyty jak w Shiptest)
/turf/open/floor/concrete/wasteplanet
	baseturfs = /turf/open/floor/plating/asteroid/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/concrete/wasteplanet/Initialize(mapload)
	. = ..()
	if(!broken && !burnt && prob(40))
		icon_state = pick("conc_slab_1", "conc_slab_4")

/turf/open/floor/concrete/wasteplanet/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/floor/concrete/slab_4/wasteplanet
	baseturfs = /turf/open/floor/plating/asteroid/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/concrete/pavement/wasteplanet
	baseturfs = /turf/open/floor/plating/asteroid/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	planetary_atmos = TRUE

/// Smoła: płytka, bardzo spowalnia, ryb w niej nie ma
/turf/open/water/planet/tar
	name = "dół ze smołą"
	desc = "Płytka smoła. Mocno spowalnia."
	color = "#574747"
	slowdown = 2
	immerse_overlay_alpha = 240
	reagent_to_extract = /datum/reagent/oil
	baseturfs = /turf/open/floor/plating/asteroid/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	planetary_atmos = TRUE

// Ściany

/turf/closed/mineral/random/wasteplanet
	name = "skażona skała"
	desc = "Cokolwiek tu kiedyś żyło, została tylko trucizna."
	icon = 'aquila/icons/planets/turf/wasteplanet_wall.dmi'
	icon_state = "wasteplanet"
	smooth_icon = 'aquila/icons/planets/turf/wasteplanet_wall.dmi'
	environment_type = "wasteplanet"
	turf_type = /turf/open/floor/plating/asteroid/wasteplanet
	baseturfs = /turf/open/floor/plating/asteroid/wasteplanet
	initial_gas_mix = PLANET_WASTE_ATMOS
	defer_change = TRUE
	mineralChance = 20
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 30, /obj/item/stack/ore/diamond = 0.5, /obj/item/stack/ore/gold = 4, /obj/item/stack/ore/silver = 5,
		/obj/item/stack/ore/iron = 40, /obj/item/stack/ore/plasma = 35,
	)

/// Ściany zrujnowanych budowli wysypiska: część jest już nadgryziona
/turf/closed/wall/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet
	girder_type = /obj/structure/girder/wasteworld

/turf/closed/wall/rust/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet/rust
	girder_type = /obj/structure/girder/wasteworld

/turf/closed/wall/r_wall/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet

/turf/closed/wall/r_wall/rust/wasteplanet
	baseturfs = /turf/open/floor/plating/wasteplanet/rust

/// Przerdzewiały dźwigar wysypiska: łatwo go rozwalić
/obj/structure/girder/wasteworld
	name = "przerdzewiały dźwigar"
	max_integrity = 40

// Rośliny

/// Kolonia świecących grzybów: żywi się promieniowaniem i świeci na zielono
/obj/structure/flora/ash/glowshroom
	name = "kolonia świecących grzybów"
	desc = "Mała, wytrzymała kępa świecących grzybów, które żywią się promieniowaniem i oczyszczają z niego glebę."
	icon = 'aquila/icons/planets/flora/waste_flora.dmi'
	icon_state = "glowshroom"
	base_icon_state = "glowshroom"
	seed_type = /obj/item/plant_seeds/preset/glowshroom
	light_range = 2
	light_power = 0.6
	light_color = "#66ff66"

/obj/structure/flora/ash/glowshroom/Initialize(mapload)
	. = ..()
	icon_state = "glowshroom"

// Promieniowanie

/// Promieniowanie tła: niewidoczne, co kilka sekund napromieniowuje losowe pola w zasięgu, gdy jest tu gracz
/obj/effect/radiation
	name = "promieniowanie tła"
	desc = "Co jakiś czas wysyła impuls promieniowania. Widzą go tylko obserwatorzy."
	icon = 'aquila/icons/planets/waste/radioactive.dmi'
	icon_state = "radiation"
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	/// Siła impulsu (natężenie promieniowania)
	var/rad_intensity = 2
	/// Zasięg impulsu od pola trafienia
	var/rad_range = 2
	/// Zasięg, w którym szuka gracza i losuje pola
	var/rad_spread = 3
	/// Szansa na impuls na każde otwarte pole w zasięgu
	var/rad_prob = 20
	var/rad_delay = 4 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/effect/radiation/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/radiation/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/radiation/process(delta_time)
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	var/player_in_range = FALSE
	for(var/mob/living/living in range(rad_spread, loc))
		if(living.client)
			player_in_range = TRUE
			break
	if(!player_in_range)
		return
	COOLDOWN_START(src, pulse_cooldown, rad_delay)
	for(var/turf/open/open_turf in view(rad_spread, src))
		if(prob(rad_prob))
			radiation_pulse(open_turf, max_range = rad_range, threshold = RAD_LIGHT_INSULATION, intensity = rad_intensity)

/obj/effect/radiation/waste

/obj/effect/radiation/waste/intense
	rad_intensity = 6
	rad_delay = 8 SECONDS
	rad_prob = 10

/// Beczka z odpadami promieniotwórczymi: promieniuje, kiedy ktoś jest blisko, i mocniej przy uderzeniu
/obj/structure/radioactive_barrel
	name = "beczka z odpadami jądrowymi"
	desc = "Stary pojemnik na promieniotwórcze produkty uboczne."
	icon = 'aquila/icons/planets/waste/radioactive.dmi'
	icon_state = "barrel"
	density = TRUE
	anchored = FALSE
	max_integrity = 600
	/// Natężenie i zasięg impulsu
	var/rad_intensity = 3
	var/rad_range = 3
	/// Co ile promieniuje i z jakiej odległości „wyczuwa” gracza
	var/rad_delay = 2 SECONDS
	var/client_range = 5
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/structure/radioactive_barrel/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/radioactive_barrel/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/radioactive_barrel/process(delta_time)
	for(var/mob/living/living in range(client_range, loc))
		if(living.client)
			pulse()
			return

/obj/structure/radioactive_barrel/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	pulse()

/obj/structure/radioactive_barrel/proc/pulse()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, rad_delay)
	radiation_pulse(src, max_range = rad_range, threshold = RAD_LIGHT_INSULATION, intensity = rad_intensity)

/obj/structure/radioactive_barrel/rusty
	icon_state = "barrel_rust"

/obj/structure/radioactive_barrel/waste
	name = "cieknąca beczka z odpadami"
	desc = "Dawne statki często po prostu wyrzucały odpady przez śluzę. Na dłuższą metę okazało się to fatalnym pomysłem."
	icon_state = "barrel_tipped"
	anchored = TRUE
	rad_intensity = 4
	rad_delay = 1.5 SECONDS

/obj/structure/radioactive_barrel/stack
	name = "sterta odpadów jądrowych"
	desc = "Wyrzucone odpady jądrowe. Gdy wokół planety zbierze się ich dość, promieniotwórcze toksyny potrafią zatruć całą atmosferę."
	icon_state = "barrel_3"
	anchored = TRUE
	rad_intensity = 6
	client_range = 6
	rad_delay = 1 SECONDS

// Spawnery śmieci wysypiska (listy jak w Shiptest)

/obj/effect/spawner/lootdrop/waste
	name = "losowe śmieci wysypiska"

/obj/effect/spawner/lootdrop/waste/grille_or_trash
	loot = list(
		/obj/structure/grille/broken = 5,
		/obj/structure/grille = 5,
		/obj/item/cigbutt = 1,
		/obj/item/trash/candy = 1,
		/obj/item/trash/chips = 1,
		/obj/item/food/deadmouse = 1,
		/obj/item/trash/pistachios = 1,
		/obj/item/trash/popcorn = 1,
		/obj/item/trash/raisins = 1,
		/obj/item/trash/sosjerky = 1,
		/obj/item/trash/syndi_cakes = 1,
	)

/obj/effect/spawner/lootdrop/waste/mechwreck
	name = "wrak egzoszkieletu z wysypiska"
	loot = list(
		/obj/structure/mecha_wreckage/ripley = 24,
		/obj/structure/mecha_wreckage/ripley/firefighter = 9,
		/obj/structure/mecha_wreckage/ripley/mkii = 9,
	)

/obj/effect/spawner/lootdrop/waste/mechwreck/rare
	loot = list(
		/obj/structure/mecha_wreckage/durand = 25,
		/obj/structure/mecha_wreckage/odysseus = 25,
		/obj/structure/mecha_wreckage/gygax = 25,
	)

/obj/effect/spawner/lootdrop/waste/radiation
	loot = list(
		/obj/structure/radioactive_barrel = 6,
		/obj/structure/radioactive_barrel/stack = 6,
		/obj/structure/radioactive_barrel/waste = 6,
	)

/obj/effect/spawner/lootdrop/waste/radiation/more_rads
	loot = list(
		/obj/structure/radioactive_barrel = 3,
		/obj/structure/radioactive_barrel/stack = 12,
		/obj/structure/radioactive_barrel/waste = 12,
	)

/obj/effect/spawner/lootdrop/waste/atmos_can
	loot = list(
		/obj/machinery/portable_atmospherics/canister/toxins = 3,
		/obj/machinery/portable_atmospherics/canister/carbon_dioxide = 3,
		/obj/machinery/portable_atmospherics/canister/nitrogen = 3,
		/obj/machinery/portable_atmospherics/canister/oxygen = 3,
		/obj/machinery/portable_atmospherics/canister/nitrous_oxide = 1,
		/obj/machinery/portable_atmospherics/canister/water_vapor = 1,
	)

/obj/effect/spawner/lootdrop/waste/atmos_can/rare
	loot = list(
		/obj/machinery/portable_atmospherics/canister/tritium = 3,
		/obj/machinery/portable_atmospherics/canister/bz = 3,
	)

/// Złom: puste ramy maszyn i komputerów (system złomowania Shiptesta pominięty, jak przy planecie wulkanicznej)
/obj/effect/spawner/lootdrop/waste/salvageable
	loot = list(
		/obj/structure/frame/machine = 60,
		/obj/structure/frame/computer = 10,
		/obj/item/stack/ore/iron = 10,
		/obj/item/stack/sheet/iron = 5,
	)

/obj/effect/spawner/lootdrop/waste/girder
	loot = list(
		/obj/structure/girder/wasteworld = 3,
		/obj/structure/girder = 1,
		/obj/structure/girder/displaced = 1,
		/obj/structure/girder/reinforced = 1,
	)

/// Miny wysypiska (zamiast min naciskowych Shiptesta)
/obj/effect/spawner/lootdrop/waste/mine
	loot = list(
		/obj/effect/mine/explosive = 1,
		/obj/effect/mine/shrapnel = 3,
		/obj/effect/mine/stun = 1,
	)

/// Śmieci na ziemi
/obj/effect/spawner/lootdrop/waste/trash_decal
	loot = list(
		/obj/effect/decal/cleanable/dirt = 6,
		/obj/effect/decal/cleanable/oil = 2,
		/obj/effect/decal/cleanable/robot_debris = 1,
		/obj/effect/decal/cleanable/glass = 1,
		/obj/effect/decal/cleanable/generic = 2,
	)

/obj/effect/spawner/lootdrop/waste/trash_decal/Initialize(mapload)
	// Część rzutów bez niczego: w Shiptest spawner brudu miał wagę 1800, więc pustka jest częścią wyglądu
	if(prob(50))
		loot = null
	return ..()

/// Łupy z hivebotów i ich rdzeni
/obj/effect/spawner/lootdrop/waste/hivebot
	lootcount = 2
	loot = list(
		/obj/item/stack/ore/iron = 3,
		/obj/item/stack/ore/gold = 1,
		/obj/item/stack/ore/plasma = 1,
		/obj/item/stack/ore/silver = 1,
		/obj/item/stack/ore/titanium = 1,
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/uranium = 1,
	)

#undef PLANET_WASTE_ATMOS
