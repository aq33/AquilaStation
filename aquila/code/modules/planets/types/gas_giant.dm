// AQUILA - gazowe i plazmowe olbrzymy (Shiptest: code/datums/mapgen/single_biome/Gas_Giant.dm, /turf/open/chasm/gas_giant,
// /datum/atmosphere/gas_giant, AGPLv3). Ozdoba układu (scenery): dochodzi obok zwykłej planety.
// W Shiptest olbrzym to sama przepaść gazu, na której statek dokuje i zbiera gaz własnymi pompami. U nas (decyzja:
// platforma do lądowania) lądowiska to platformy wydobywcze zawieszone w atmosferze: barierki, znaczniki, syfon gazu
// i puste kanistry. Zejście z platformy to upadek w głąb olbrzyma (przepaść bez dna). Wysokie ciśnienie i mróz,
// gazowy olbrzym z podtlenkiem azotu, plazmowy z plazmą, metanowy z metanem (plan maszynowni E8).

/// Atmosfera olbrzymów: ok. 800 kPa przy 80 K (Shiptest: 500-1550 kPa, 30-120 K)
#define GAS_GIANT_ATMOS_MIX "n2=1800;n2o=1200;TEMP=80"
#define PLASMA_GIANT_ATMOS_MIX "plasma=2600;co2=400;TEMP=80"
#define METHANE_GIANT_ATMOS_MIX "methane=2200;n2=800;TEMP=90"

/datum/planet_type/gas_giant
	sky_state = "gas_giant"
	sky_atmosphere_color = "#f0b070"
	sky_scale = 3.5
	name = "gazowy olbrzym"
	desc = "Ogromna kula gęstego gazu bez stałej powierzchni. Na orbicie wiszą platformy wydobywcze, z których da się czerpać gaz."
	overmap_icon_state = "planet_gas"
	overmap_color = "#e0a060"
	generator_type = /datum/planet_generator/single/gas_giant
	surface_area_type = /area/planet/surface/gas_giant
	cave_area_type = /area/planet/surface/cave/gas_giant
	edge_turf_type = /turf/open/chasm/gas_giant
	atmosphere_desc = "gęsta, azot i podtlenek azotu pod wysokim ciśnieniem"
	temperature_desc = "głęboki mróz (ok. 80 K)"
	hazard_desc = "brak stałego gruntu poza platformami, ciśnienie miażdżące bez skafandra, gaz usypiający"
	surface_size = PLANET_SURFACE_SIZE_DWARF
	ground_turf_type = /turf/open/floor/plating/planet_platform
	scenery = TRUE
	mission_target = FALSE
	system_tags = list("gas" = 4, "nebula" = 3, "nebula-thick" = 3, "safe" = 1)
	fixed_systems = list("Helios Sigma", "Lesziru", "Zeta Reticuli")
	/// Kanistry ustawiane na platformie obok syfonu
	var/platform_canisters = 2

/datum/planet_type/gas_giant/plasma
	sky_state = "gas_plasma"
	sky_atmosphere_color = "#c070f0"
	name = "plazmowy olbrzym"
	desc = "Olbrzym z gazu przesyconego plazmą. Platformy wydobywcze na jego orbicie to cenne źródło paliwa."
	overmap_color = "#b060d0"
	generator_type = /datum/planet_generator/single/gas_giant/plasma
	surface_area_type = /area/planet/surface/gas_giant/plasma
	edge_turf_type = /turf/open/chasm/gas_giant/plasma
	atmosphere_desc = "gęsta plazma z domieszką dwutlenku węgla pod wysokim ciśnieniem"
	hazard_desc = "brak stałego gruntu poza platformami, ciśnienie miażdżące bez skafandra, toksyczna i palna plazma"
	ground_turf_type = /turf/open/floor/plating/planet_platform/plasma
	system_tags = list("gas" = 2, "nebula" = 1, "nebula-thick" = 1, "demonstar" = 1)
	fixed_systems = list("Zurs")

/datum/planet_type/gas_giant/methane
	sky_state = "gas_giant"
	sky_atmosphere_color = "#80c0d0"
	name = "metanowy olbrzym"
	desc = "Olbrzym z zimnego metanu z domieszką azotu. Platformy wydobywcze na jego orbicie dają paliwo do dysz i generatorów."
	overmap_color = "#70a8c0"
	generator_type = /datum/planet_generator/single/gas_giant/methane
	surface_area_type = /area/planet/surface/gas_giant/methane
	edge_turf_type = /turf/open/chasm/gas_giant/methane
	atmosphere_desc = "gęsty metan z domieszką azotu pod wysokim ciśnieniem"
	hazard_desc = "brak stałego gruntu poza platformami, ciśnienie miażdżące bez skafandra, palny metan"
	ground_turf_type = /turf/open/floor/plating/planet_platform/methane
	system_tags = list("gas" = 3, "nebula" = 2, "nebula-thick" = 2, "safe" = 1)
	fixed_systems = null

/// Platforma: barierki dookoła, znaczniki w rogach i na bokach, syfon gazu i puste kanistry w lewym dolnym rogu
/datum/planet_type/gas_giant/decorate_landing_zone(datum/planet_surface/surface, turf/zone_center, radius)
	var/min_x = zone_center.x - radius
	var/max_x = zone_center.x + radius
	var/min_y = zone_center.y - radius
	var/max_y = zone_center.y + radius
	var/z_level = zone_center.z
	for(var/turf/T as anything in RANGE_TURFS(radius, zone_center))
		if(!surface.contains(T) || !istype(T, /turf/open/floor/plating/planet_platform))
			continue
		var/list/edges = list()
		if(T.y == max_y)
			edges += NORTH
		if(T.y == min_y)
			edges += SOUTH
		if(T.x == max_x)
			edges += EAST
		if(T.x == min_x)
			edges += WEST
		for(var/edge_dir in edges)
			var/obj/structure/railing/railing = new(T)
			railing.setDir(edge_dir)
	var/list/beacon_spots = list(
		locate(min_x + 1, min_y + 1, z_level), locate(max_x - 1, min_y + 1, z_level),
		locate(min_x + 1, max_y - 1, z_level), locate(max_x - 1, max_y - 1, z_level),
		locate(zone_center.x, min_y + 1, z_level), locate(zone_center.x, max_y - 1, z_level),
		locate(min_x + 1, zone_center.y, z_level), locate(max_x - 1, zone_center.y, z_level),
	)
	for(var/turf/T as anything in beacon_spots)
		if(T && surface.contains(T) && !is_planet_hazard_turf(T))
			new /obj/structure/marker_beacon(T, "Yellow")
	var/turf/siphon_turf = locate(min_x + 3, min_y + 3, z_level)
	if(!siphon_turf || is_planet_hazard_turf(siphon_turf))
		return
	new /obj/machinery/planet_gas_siphon(siphon_turf)
	var/list/canister_spots = list(get_step(siphon_turf, EAST), get_step(siphon_turf, NORTH))
	for(var/i in 1 to min(platform_canisters, length(canister_spots)))
		var/turf/T = canister_spots[i]
		if(T && !is_planet_hazard_turf(T))
			new /obj/machinery/portable_atmospherics/canister(T)
	new /obj/structure/sign/warning/vacuum(get_step(siphon_turf, SOUTHWEST))

/// Generator jednego biomu bez jaskiń (Shiptest: /datum/map_generator/single_biome)
/datum/planet_generator/single
	mountain_height = 1
	/// Biom całej powierzchni
	var/single_biome_type = /datum/planet_biome/gas_giant

/datum/planet_generator/single/get_biome(turf/T)
	var/datum/planet_biome/biome = get_planet_biome(single_biome_type)
	turf_biome_cache[T] = biome
	return biome

/datum/planet_generator/single/gas_giant

/datum/planet_generator/single/gas_giant/plasma
	single_biome_type = /datum/planet_biome/gas_giant/plasma

/datum/planet_generator/single/gas_giant/methane
	single_biome_type = /datum/planet_biome/gas_giant/methane

/// Sam gaz: bez roślin, obiektów i zwierząt (Shiptest stawiał obserwatory, które tu od razu spadałyby w głąb)
/datum/planet_biome/gas_giant
	open_turf_types = list(/turf/open/chasm/gas_giant = 1)
	flora_spawn_chance = 0
	feature_spawn_chance = 0
	mob_spawn_chance = 0

/datum/planet_biome/gas_giant/plasma
	open_turf_types = list(/turf/open/chasm/gas_giant/plasma = 1)

/datum/planet_biome/gas_giant/methane
	open_turf_types = list(/turf/open/chasm/gas_giant/methane = 1)

/// Gaz olbrzyma: przepaść bez dna
/turf/open/chasm/gas_giant
	name = "otchłań gazu"
	desc = "Gaz, z którego składa się olbrzym. Dalej nic nie widać, ale jedno jest pewne: kto tu wpadnie, już nie wróci."
	icon = 'icons/turf/floors.dmi'
	icon_state = "reebegame"
	color = "#b5651d"
	smooth = NONE
	canSmoothWith = null
	baseturfs = /turf/open/chasm/gas_giant
	initial_gas_mix = GAS_GIANT_ATMOS_MIX
	planetary_atmos = TRUE

/turf/open/chasm/gas_giant/plasma
	color = "#8a2be2"
	baseturfs = /turf/open/chasm/gas_giant/plasma
	initial_gas_mix = PLASMA_GIANT_ATMOS_MIX

/turf/open/chasm/gas_giant/methane
	color = "#5f9ea0"
	baseturfs = /turf/open/chasm/gas_giant/methane
	initial_gas_mix = METHANE_GIANT_ATMOS_MIX

/// Podłoga platformy wydobywczej (pod nią otchłań)
/turf/open/floor/plating/planet_platform
	name = "platforma wydobywcza"
	desc = "Ażurowa płyta platformy zawieszonej nad otchłanią gazu."
	baseturfs = /turf/open/chasm/gas_giant
	initial_gas_mix = GAS_GIANT_ATMOS_MIX
	planetary_atmos = TRUE

/turf/open/floor/plating/planet_platform/plasma
	baseturfs = /turf/open/chasm/gas_giant/plasma
	initial_gas_mix = PLASMA_GIANT_ATMOS_MIX

/turf/open/floor/plating/planet_platform/methane
	baseturfs = /turf/open/chasm/gas_giant/methane
	initial_gas_mix = METHANE_GIANT_ATMOS_MIX

/area/planet/surface/gas_giant
	name = "Atmosfera Gazowego Olbrzyma"
	lighting_overlay_colour = "#e8a868"
	ambience_index = AMBIENCE_SPACE
	sound_environment = SOUND_AREA_SPACE

/area/planet/surface/gas_giant/plasma
	name = "Atmosfera Plazmowego Olbrzyma"
	lighting_overlay_colour = "#c890e8"

/area/planet/surface/gas_giant/methane
	name = "Atmosfera Metanowego Olbrzyma"
	lighting_overlay_colour = "#98c8d8"

/area/planet/surface/cave/gas_giant
	name = "Wnętrze Olbrzyma"

/// Syfon gazu: zasysa gaz atmosfery planety spod siebie i wtłacza go do kanistrów stojących obok (na sąsiednich polach)
/obj/machinery/planet_gas_siphon
	name = "syfon gazu atmosferycznego"
	desc = "Pompa zasysająca gaz z atmosfery planety do kanistrów ustawionych tuż obok niej. Włącza się ją ręką. Na plazmowym olbrzymie to darmowe paliwo."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "siphon:0"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	processing_flags = NONE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 300
	/// Czy pompuje
	var/on = FALSE
	/// Do jakiego ciśnienia napełnia kanistry (kPa)
	var/target_pressure = 4500
	/// Ile moli gazu na sekundę trafia do jednego kanistra
	var/moles_per_second = 40

/obj/machinery/planet_gas_siphon/Destroy()
	STOP_PROCESSING(SSmachines, src)
	return ..()

/obj/machinery/planet_gas_siphon/examine(mob/user)
	. = ..()
	. += span_notice("Jest [on ? "włączony" : "wyłączony"]. Napełnia kanistry na sąsiednich polach do [target_pressure] kPa.")

/obj/machinery/planet_gas_siphon/update_icon_state()
	icon_state = "siphon:[on]"
	return ..()

/obj/machinery/planet_gas_siphon/interact(mob/user)
	. = ..()
	set_on(!on)
	to_chat(user, span_notice("[on ? "Włączasz" : "Wyłączasz"] [src]."))

/obj/machinery/planet_gas_siphon/proc/set_on(new_on)
	on = new_on
	if(on)
		START_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSmachines, src)
	update_icon()

/obj/machinery/planet_gas_siphon/process(delta_time)
	if(!on)
		return PROCESS_KILL
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/source = T?.return_air()
	if(!source || source.total_moles() <= 0)
		return
	for(var/obj/machinery/portable_atmospherics/canister/canister in pump_targets())
		if(canister.air_contents.return_pressure() >= target_pressure)
			continue
		var/datum/gas_mixture/taken = source.remove(moles_per_second * delta_time)
		if(!taken)
			return
		canister.air_contents.merge(taken)
		canister.update_icon()
	T.air_update_turf()

/// Kanistry na sąsiednich polach
/obj/machinery/planet_gas_siphon/proc/pump_targets()
	. = list()
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		if(!T)
			continue
		for(var/obj/machinery/portable_atmospherics/canister/canister in T)
			. += canister

#undef GAS_GIANT_ATMOS_MIX
#undef PLASMA_GIANT_ATMOS_MIX
#undef METHANE_GIANT_ATMOS_MIX
