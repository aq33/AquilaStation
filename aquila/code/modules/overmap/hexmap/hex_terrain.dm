// AQUILA - teren kafli mapy hex (raport/ftl_mapa_06_plan_pr.md, PR B). Rodzaje i rozmieszczenie jak w makiecie v4:
// teren wokół układów według ich typu, miny przy fortecach Syndykatu, tunele w parach. Ten teren trafia do zapisu kampanii.
// Burze jonowe, ławice karpi i komety losują się co rundę i dryfują; nieznane sygnały i pola anomalii pojawiają się
// losowo w trakcie rundy i znikają, gdy okręt je zbada (odleci z kafla).

GLOBAL_LIST_EMPTY(hex_terrains)

/// Rodzaj terenu po identyfikatorze (HEX_TERRAIN_*)
/proc/hex_terrain(id)
	RETURN_TYPE(/datum/hex_terrain)
	if(!length(GLOB.hex_terrains))
		for(var/path in subtypesof(/datum/hex_terrain))
			var/datum/hex_terrain/T = new path
			GLOB.hex_terrains[T.id] = T
	return GLOB.hex_terrains[id || HEX_TERRAIN_EMPTY]

/datum/hex_terrain
	var/id
	var/name
	var/desc
	/// Zatrzymuje skok: okręt i floty nie przelatują przez ten kafel
	var/stops = TRUE
	/// Nikt nie może tu wlecieć
	var/blocks = FALSE
	/// Losowany co rundę albo w trakcie rundy, nie trafia do zapisu kampanii
	var/moving = FALSE
	/// Tło (parallax_property) układu kafla
	var/parallax
	/// Eventy środowiska z puli kafla (typy /datum/round_event_control)
	var/list/events = list()
	/// Antagoniści z puli kafla (losują się razem z eventami, z minimum graczy eventu)
	var/list/antags = list()

/datum/hex_terrain/empty
	id = HEX_TERRAIN_EMPTY
	name = "Pusta przestrzeń"
	desc = "Bez efektów środowiska."
	stops = FALSE
	events = list(
		/datum/round_event_control/aquila_stray_cargo,
		/datum/round_event_control/dolphin_migration,
		/datum/round_event_control/aquila_hex_rescue_pod,
		/datum/round_event_control/aquila_hex_economic_news,
	)

/datum/hex_terrain/asteroids
	id = HEX_TERRAIN_ASTEROIDS
	name = "Pole asteroid"
	desc = "Pył i meteory uderzają w kadłub."
	parallax = "rocks"
	events = list(
		/datum/round_event_control/space_dust,
		/datum/round_event_control/meteor_wave/major_dust,
		/datum/round_event_control/asteroid_impact,
		/datum/round_event_control/meteor_wave,
		/datum/round_event_control/meteor_wave/threatening,
		/datum/round_event_control/meteor_wave/catastrophic,
		/datum/round_event_control/immovable_rod,
		/datum/round_event_control/aquila_hex_comet_expulsion,
		/datum/round_event_control/aquila_hex_lone_hunter,
	)
	antags = list(
		/datum/round_event_control/spider_infestation,
		/datum/round_event_control/crystal_invasion,
		/datum/round_event_control/blob,
	)

/datum/hex_terrain/junk
	id = HEX_TERRAIN_JUNK
	name = "Złomowisko"
	desc = "Gruz i wraki po bitwach, przy pirackich bazach."
	parallax = "graveyard"
	events = list(
		/datum/round_event_control/aquila_stray_cargo/syndicate,
		/datum/round_event_control/meteor_wave/meaty,
		/datum/round_event_control/immovable_rod,
		/datum/round_event_control/aquila_hex_rogue_drone_swarm,
		/datum/round_event_control/aquila_hex_wreck_graveyard,
		/datum/round_event_control/aquila_hex_loot_pod,
	)
	antags = list(
		/datum/round_event_control/spawn_swarmer,
		/datum/round_event_control/aquila_rogue_drone,
		/datum/round_event_control/morph,
		/datum/round_event_control/horror,
		/datum/round_event_control/blood_worm,
		/datum/round_event_control/alien_infestation,
		/datum/round_event_control/salvagers,
	)

/datum/hex_terrain/nebula
	id = HEX_TERRAIN_NEBULA
	name = "Mgławica"
	desc = "Gęsty gaz. Przelot bez zatrzymania."
	stops = FALSE
	parallax = "nebula-thick"
	events = list(
		/datum/round_event_control/anomaly/anomaly_hallucination,
		/datum/round_event_control/aurora_caelus,
		/datum/round_event_control/aquila_hex_nebula_flicker,
		/datum/round_event_control/aquila_hex_lone_hunter,
	)
	antags = list(
		/datum/round_event_control/pirates,
		/datum/round_event_control/revenant,
		/datum/round_event_control/shadow_demon,
		/datum/round_event_control/obsessed,
		/datum/round_event_control/ninja,
	)

/datum/hex_terrain/electrical
	id = HEX_TERRAIN_ELECTRICAL
	name = "Burza elektryczna"
	desc = "Wyładowania w instalacji okrętu."
	parallax = "quasar"
	events = list(
		/datum/round_event_control/electrical_storm,
		/datum/round_event_control/processor_overload,
		/datum/round_event_control/aquila_hex_storm_discharge,
		/datum/round_event_control/aquila_hex_apc_damage,
		/datum/round_event_control/aquila_hex_sensor_jamming,
	)
	antags = list(
		/datum/round_event_control/pulse_demon,
		/datum/round_event_control/aquila_rogue_drone,
	)

/datum/hex_terrain/ion
	id = HEX_TERRAIN_ION
	name = "Burza jonowa"
	desc = "Rodzi się przy kwazarach i dryfuje. Prawa jonowe SI, zanik łączności."
	moving = TRUE
	parallax = "quasar"
	events = list(
		/datum/round_event_control/ion_storm,
		/datum/round_event_control/communications_blackout,
		/datum/round_event_control/anomaly,
		/datum/round_event_control/aquila_hex_emp_storm,
		/datum/round_event_control/aquila_hex_computer_damage,
	)
	antags = list(
		HEX_POOL_MALF,
		/datum/round_event_control/pulse_demon,
	)

/datum/hex_terrain/radiation
	id = HEX_TERRAIN_RADIATION
	name = "Promieniowanie"
	desc = "Burze radiacyjne i radioaktywny szlam."
	parallax = "radiation_cloud"
	events = list(
		/datum/round_event_control/radiation_storm,
		/datum/round_event_control/radiation_storm/deadly,
		/datum/round_event_control/radioactive_sludge,
	)
	antags = list(
		/datum/round_event_control/aquila_teratoma,
		/datum/round_event_control/sentient_disease,
		/datum/round_event_control/monkey_uprising,
		/datum/round_event_control/morph,
	)

/datum/hex_terrain/flare
	id = HEX_TERRAIN_FLARE
	name = "Aktywność gwiazdy"
	desc = "Rozbłyski przy gwiazdach i supernowych."
	parallax = "supernova_planet"
	events = list(
		/datum/round_event_control/aquila_hex_solar_flare,
		/datum/round_event_control/aquila_hex_solar_storm,
		/datum/round_event_control/aquila_hex_emp_storm,
	)
	antags = list(
		/datum/round_event_control/pulse_demon,
		/datum/round_event_control/shadow_demon,
		/datum/round_event_control/slaughter,
		/datum/round_event_control/sinfuldemon,
		/datum/round_event_control/devil,
	)

/datum/hex_terrain/anomalies
	id = HEX_TERRAIN_ANOMALIES
	name = "Pole anomalii"
	desc = "Anomalie na pokładzie do zneutralizowania. Znika po zbadaniu."
	moving = TRUE
	parallax = "pitchblack"
	events = list(
		/datum/round_event_control/anomaly,
		/datum/round_event_control/anomaly/anomaly_bluespace,
		/datum/round_event_control/anomaly/anomaly_delimber,
		/datum/round_event_control/anomaly/anomaly_flux,
		/datum/round_event_control/anomaly/anomaly_grav,
		/datum/round_event_control/anomaly/anomaly_hallucination,
		/datum/round_event_control/anomaly/anomaly_pyro,
		/datum/round_event_control/anomaly/anomaly_vortex,
		/datum/round_event_control/anomaly/anomaly_fluid,
		/datum/round_event_control/aquila_magnetic_field,
		/datum/round_event_control/aquila_hex_drive_instability,
		/datum/round_event_control/aquila_hex_bluespace_interphase,
		/datum/round_event_control/aquila_hex_bluespace_rifts,
	)
	antags = list(
		/datum/round_event_control/aquila_chrono_legionnaire,
		/datum/round_event_control/paradox_clone,
		/datum/round_event_control/portal_storm_kurwinox,
		/datum/round_event_control/portal_storm_syndicate,
		/datum/round_event_control/obsessed,
	)

/datum/hex_terrain/gravity
	id = HEX_TERRAIN_GRAVITY
	name = "Anomalia grawitacyjna"
	desc = "Wahania grawitacji wokół czarnych dziur i dysków akrecyjnych."
	parallax = "accretiondisk_planet"
	events = list(
		/datum/round_event_control/aquila_hex_gravity_failure,
		/datum/round_event_control/aquila_hex_dark_matter_influx,
		/datum/round_event_control/aquila_hex_harmonic_surge,
		/datum/round_event_control/aquila_hex_damper_recalibration,
	)
	antags = list(
		/datum/round_event_control/bingle,
		/datum/round_event_control/voidwalker,
	)

/datum/hex_terrain/carp
	id = HEX_TERRAIN_CARP
	name = "Ławica karpi"
	desc = "Dryfuje po mapie, karpie atakują kadłub."
	moving = TRUE
	events = list(
		/datum/round_event_control/carp_migration,
	)
	antags = list(
		/datum/round_event_control/space_dragon,
	)

/datum/hex_terrain/wormhole
	id = HEX_TERRAIN_WORMHOLE
	name = "Tunel czasoprzestrzenny"
	desc = "Wejście przenosi na drugi koniec tunelu w tym samym sektorze."
	parallax = "pitchblack"
	events = list(
		/datum/round_event_control/wormholes,
		/datum/round_event_control/anomaly/anomaly_bluespace,
		/datum/round_event_control/aquila_hex_bluespace_interphase,
	)
	antags = list(
		/datum/round_event_control/aquila_chrono_legionnaire,
		/datum/round_event_control/paradox_clone,
		/datum/round_event_control/abductor,
	)

/datum/hex_terrain/black_hole
	id = HEX_TERRAIN_BLACK_HOLE
	name = "Czarna dziura"
	desc = "Nieprzelotna dla wszystkich."
	blocks = TRUE

/datum/hex_terrain/comet
	id = HEX_TERRAIN_COMET
	name = "Kometa"
	desc = "Leci po mapie, w ogonie lodowe meteory."
	moving = TRUE
	parallax = "icefield"
	events = list(
		/datum/round_event_control/space_dust,
		/datum/round_event_control/meteor_wave/major_dust,
		/datum/round_event_control/aquila_hex_comet_expulsion,
		/datum/round_event_control/aquila_hex_comet_tail,
		/datum/round_event_control/aquila_hex_rich_comet,
	)
	antags = list(
		/datum/round_event_control/blob,
		/datum/round_event_control/alien_infestation,
	)

/datum/hex_terrain/mines
	id = HEX_TERRAIN_MINES
	name = "Pole minowe"
	desc = "Miny Syndykatu przy bazach i bramie."
	antags = list(
		/datum/round_event_control/operative,
		/datum/round_event_control/infiltrators,
		/datum/round_event_control/portal_storm_syndicate,
	)

/datum/hex_terrain/signal
	id = HEX_TERRAIN_SIGNAL
	name = "Nieznany sygnał"
	desc = "Wrak, kapsuła albo zasadzka. Przelot bez zatrzymania, znika po zbadaniu."
	stops = FALSE
	moving = TRUE
	events = list(
		/datum/round_event_control/aquila_stray_cargo,
		/datum/round_event_control/aquila_stray_cargo/syndicate,
		/datum/round_event_control/aquila_hex_rescue_pod,
		/datum/round_event_control/aquila_hex_freighter_attack,
		/datum/round_event_control/aquila_hex_wreck_graveyard,
		/datum/round_event_control/aquila_hex_loot_pod,
	)
	antags = list(
		/datum/round_event_control/fugitives,
		/datum/round_event_control/aquila_prisoner_transfer,
		/datum/round_event_control/aquila_stray_cargo/lost_crew,
		/datum/round_event_control/horror,
		/datum/round_event_control/morph,
		/datum/round_event_control/paradox_clone,
		/datum/round_event_control/ninja,
	)

/datum/hex
	/// Drugi koniec tunelu czasoprzestrzennego
	var/datum/hex/wormhole_pair

/datum/hex/proc/terrain_datum()
	RETURN_TYPE(/datum/hex_terrain)
	return hex_terrain(terrain)

/// Pula eventów prawdziwego układu: według jego typu ze starmap.json
/datum/hex/proc/pool_terrain()
	RETURN_TYPE(/datum/hex_terrain)
	if(!system || istype(system, /datum/star_system/random/hex_empty))
		return terrain_datum()
	var/static/list/by_tag = list(
		"debris" = HEX_TERRAIN_ASTEROIDS,
		"radioactive" = HEX_TERRAIN_RADIATION,
		"nebula" = HEX_TERRAIN_NEBULA,
		"gas" = HEX_TERRAIN_NEBULA,
		"quasar" = HEX_TERRAIN_ION,
		"accretiondisk" = HEX_TERRAIN_GRAVITY,
		"blackhole" = HEX_TERRAIN_GRAVITY,
		"graveyard" = HEX_TERRAIN_JUNK,
		"pirate" = HEX_TERRAIN_JUNK,
		"supernova" = HEX_TERRAIN_FLARE,
		"demonstar" = HEX_TERRAIN_FLARE,
		"wormhole" = HEX_TERRAIN_WORMHOLE,
		"icefield" = HEX_TERRAIN_COMET,
		"ice_planet" = HEX_TERRAIN_COMET,
		"hazardous" = HEX_TERRAIN_CARP,
	)
	return hex_terrain(by_tag[system.system_type?["tag"]])

/// Zmienia teren kafla i tło jego pustego układu
/datum/hex/proc/set_terrain(new_terrain)
	terrain = new_terrain || HEX_TERRAIN_EMPTY
	if(terrain != HEX_TERRAIN_WORMHOLE && wormhole_pair)
		// Tunel ma dwa końce: drugi koniec bez pary prowadziłby donikąd, więc znika razem z tym
		var/datum/hex/other_end = wormhole_pair
		wormhole_pair = null
		if(other_end.wormhole_pair == src)
			other_end.wormhole_pair = null
			if(other_end.terrain == HEX_TERRAIN_WORMHOLE)
				other_end.set_terrain(HEX_TERRAIN_EMPTY)
	if(istype(system, /datum/star_system/random/hex_empty))
		system.parallax_property = terrain_datum().parallax

/datum/hexmap
	/// Ruchome zjawiska: list("terrain", "hex", "dir", "tail")
	var/list/drifters = list()

/// Hex na brzegu sektora (tam nie kładziemy losowego terenu)
/datum/hexmap/proc/is_edge(datum/hex/H)
	var/list/dims = sectors["[H.sector]"]
	return H.col < 2 || H.row < 2 || H.col > dims["cols"] - 3 || H.row > dims["rows"] - 3

/// Wolne hexy: bez układu i bez terenu
/datum/hexmap/proc/free_hexes(sector, no_edge = TRUE)
	. = list()
	for(var/id in hexes)
		var/datum/hex/H = hexes[id]
		if(H.system || H.terrain != HEX_TERRAIN_EMPTY || (sector && H.sector != sector))
			continue
		if(no_edge && is_edge(H))
			continue
		. += H

/// Skupisko terenu wokół hexa (jak blob() w makiecie)
/datum/hexmap/proc/lay_blob(datum/hex/start, terrain, amount)
	if(!start)
		return
	var/list/queue = list(start)
	var/list/seen = list()
	seen[start] = TRUE
	var/laid = 0
	while(length(queue) && laid < amount)
		var/datum/hex/H = pick_n_take(queue)
		if(!H.system && H.terrain == HEX_TERRAIN_EMPTY)
			H.set_terrain(terrain)
			laid++
		for(var/datum/hex/N as anything in neighbours(H))
			if(!seen[N] && prob(80))
				seen[N] = TRUE
				queue += N

/datum/hexmap/proc/free_neighbours(datum/hex/H)
	. = list()
	for(var/datum/hex/N as anything in neighbours(H))
		if(!N.system && N.terrain == HEX_TERRAIN_EMPTY)
			. += N

/// Odległość do najbliższego układu w sektorze
/datum/hexmap/proc/far_from_systems(datum/hex/H, min_distance)
	for(var/name in system_hexes)
		var/datum/hex/S = system_hexes[name]
		if(S.sector == H.sector && distance(S, H) < min_distance)
			return FALSE
	return TRUE

/**
 * Teren na początku rundy: stały z zapisu kampanii albo nowy (pierwsza runda, reset), potem ruchome zjawiska
 * oraz pierwsze sygnały i pola anomalii.
 */
/datum/hexmap/proc/generate_terrain(list/saved)
	if(!(length(saved) && load_terrain(saved)))
		lay_static_terrain()
	lay_drifters()
	for(var/i in 1 to 5)
		spawn_random_terrain(HEX_TERRAIN_SIGNAL)
		spawn_random_terrain(HEX_TERRAIN_ANOMALIES)

/datum/hexmap/proc/lay_static_terrain()
	for(var/name in system_hexes)
		var/datum/hex/H = system_hexes[name]
		var/datum/star_system/S = H.system
		switch(S?.system_type?["tag"])
			if("nebula")
				lay_blob(H, HEX_TERRAIN_NEBULA, rand(5, 7))
			if("debris")
				lay_blob(H, HEX_TERRAIN_ASTEROIDS, rand(4, 6))
			if("graveyard", "pirate")
				lay_blob(H, HEX_TERRAIN_JUNK, rand(3, 5))
			if("radioactive")
				lay_blob(H, HEX_TERRAIN_RADIATION, rand(3, 5))
			if("blackhole")
				var/list/free = free_neighbours(H)
				if(length(free))
					var/datum/hex/hole = free[1]
					hole.set_terrain(HEX_TERRAIN_BLACK_HOLE)
					for(var/datum/hex/N as anything in free_neighbours(hole))
						if(prob(60))
							N.set_terrain(HEX_TERRAIN_GRAVITY)
			if("accretiondisk")
				for(var/datum/hex/N as anything in free_neighbours(H))
					if(prob(40))
						N.set_terrain(HEX_TERRAIN_GRAVITY)
			if("supernova", "demonstar")
				var/list/free = free_neighbours(H)
				for(var/i in 1 to min(2, length(free)))
					var/datum/hex/N = free[i]
					N.set_terrain(HEX_TERRAIN_FLARE)
	for(var/name in list("Tortuga", "Abious I", "Feaf"))
		var/datum/hex/H = system_hexes[name]
		if(H)
			lay_blob(H, HEX_TERRAIN_JUNK, 2)
	// pola minowe Syndykatu przy fortecach i przy bramie Romulus
	for(var/name in list("Rubicon", "Economus", "Abassi", "Romulus"))
		var/datum/hex/H = system_hexes[name]
		if(!H)
			continue
		for(var/datum/hex/N as anything in free_neighbours(H))
			if(prob(50))
				N.set_terrain(HEX_TERRAIN_MINES)
	for(var/i in 1 to 5)
		lay_random_blob(HEX_TERRAIN_ASTEROIDS, rand(3, 5))
	for(var/i in 1 to 3)
		lay_random_blob(HEX_TERRAIN_NEBULA, 5)
	for(var/i in 1 to 3)
		lay_random_blob(HEX_TERRAIN_ELECTRICAL, rand(2, 3))
	for(var/i in 1 to 2)
		lay_random_blob(HEX_TERRAIN_JUNK, rand(2, 3))
	for(var/i in 1 to 2)
		var/list/free = free_hexes()
		if(length(free))
			var/datum/hex/H = pick(free)
			H.set_terrain(HEX_TERRAIN_GRAVITY)
	// tunele: pary w tym samym sektorze, co najmniej 8 kafli od siebie
	for(var/i in 1 to 3)
		var/list/free = free_hexes()
		if(!length(free))
			break
		var/datum/hex/A = pick(free)
		var/list/far = list()
		for(var/datum/hex/B as anything in free)
			if(B.sector == A.sector && distance(A, B) >= 8)
				far += B
		if(!length(far))
			continue
		var/datum/hex/B = pick(far)
		link_wormhole(A, B)

/datum/hexmap/proc/lay_random_blob(terrain, amount)
	var/list/free = free_hexes()
	if(length(free))
		lay_blob(pick(free), terrain, amount)

/datum/hexmap/proc/link_wormhole(datum/hex/A, datum/hex/B)
	A.set_terrain(HEX_TERRAIN_WORMHOLE)
	B.set_terrain(HEX_TERRAIN_WORMHOLE)
	A.wormhole_pair = B
	B.wormhole_pair = A

/// Teren z zapisu kampanii. Zwraca FALSE, jeśli zapis nie pasuje do tej mapy (wtedy teren powstaje od nowa).
/datum/hexmap/proc/load_terrain(list/saved)
	var/list/tiles = saved["tiles"]
	if(!islist(tiles))
		return FALSE
	var/loaded = 0
	for(var/id in tiles)
		var/datum/hex/H = hexes[id]
		var/datum/hex_terrain/T = hex_terrain(tiles[id])
		if(!H || H.system || !T || T.moving || T.id == HEX_TERRAIN_WORMHOLE)
			continue
		H.set_terrain(T.id)
		loaded++
	var/list/pairs = saved["wormholes"]
	if(islist(pairs))
		for(var/list/pair in pairs)
			var/datum/hex/A = hexes[pair[1]]
			var/datum/hex/B = hexes[pair[2]]
			if(A && B && !A.system && !B.system && A.terrain == HEX_TERRAIN_EMPTY && B.terrain == HEX_TERRAIN_EMPTY)
				link_wormhole(A, B)
				loaded++
	return loaded > 0

/// Stały teren do zapisu kampanii
/datum/hexmap/proc/save_terrain()
	var/list/tiles = list()
	var/list/pairs = list()
	for(var/id in hexes)
		var/datum/hex/H = hexes[id]
		var/datum/hex_terrain/T = H.terrain_datum()
		if(T.id == HEX_TERRAIN_EMPTY || T.moving)
			continue
		if(T.id == HEX_TERRAIN_WORMHOLE)
			if(H.wormhole_pair && H.id < H.wormhole_pair.id)
				pairs += list(list(H.id, H.wormhole_pair.id))
			continue
		tiles[id] = T.id
	return list("tiles" = tiles, "wormholes" = pairs)

/// Burze jonowe z kwazarów, karpie w sektorze neutralnym, komety przy lodowych planetach
/datum/hexmap/proc/lay_drifters()
	drifters = list()
	var/list/quasars = list()
	var/list/ice = list()
	for(var/name in system_hexes)
		var/datum/hex/H = system_hexes[name]
		switch(H.system?.system_type?["tag"])
			if("quasar")
				quasars += H
			if("ice_planet", "icefield")
				ice += H
	for(var/i in 1 to 3)
		add_drifter(HEX_TERRAIN_ION, length(quasars) ? pick(quasars) : null)
	for(var/i in 1 to 3)
		add_drifter(HEX_TERRAIN_CARP, null, SECTOR_NEUTRAL)
	for(var/i in 1 to 2)
		add_drifter(HEX_TERRAIN_COMET, length(ice) ? pick(ice) : null)
	lay_moving()

/datum/hexmap/proc/add_drifter(terrain, datum/hex/near, sector)
	var/list/start = near ? free_neighbours(near) : list()
	if(!length(start))
		start = free_hexes(sector)
	if(!length(start))
		return
	drifters += list(list("terrain" = terrain, "hex" = pick(start), "dir" = rand(1, 6), "tail" = list()))

/// Kładzie ruchome zjawiska na mapie od nowa (kafel z okrętem gracza zostaje, jaki był)
/datum/hexmap/proc/lay_moving()
	var/datum/hex/player_hex = SSstar_system.find_main_overmap()?.current_hex()
	for(var/id in hexes)
		var/datum/hex/H = hexes[id]
		if(H == player_hex)
			continue
		if(H.terrain in list(HEX_TERRAIN_ION, HEX_TERRAIN_CARP, HEX_TERRAIN_COMET))
			H.set_terrain(HEX_TERRAIN_EMPTY)
	for(var/list/D as anything in drifters)
		var/datum/hex/H = D["hex"]
		put_moving(H, D["terrain"], player_hex)
		if(D["terrain"] == HEX_TERRAIN_ION)
			for(var/datum/hex/N as anything in neighbours(H))
				if(prob(35))
					put_moving(N, HEX_TERRAIN_ION, player_hex)
		for(var/datum/hex/T as anything in D["tail"])
			put_moving(T, D["terrain"], player_hex)

/datum/hexmap/proc/put_moving(datum/hex/H, terrain, datum/hex/player_hex)
	if(H && H != player_hex && !H.system && H.terrain == HEX_TERRAIN_EMPTY)
		H.set_terrain(terrain)

/// Dryf: burze i komety lecą swoim kierunkiem, karpie krążą
/datum/hexmap/proc/drift()
	var/datum/hex/player_hex = SSstar_system.find_main_overmap()?.current_hex()
	for(var/list/D as anything in drifters)
		var/datum/hex/H = D["hex"]
		var/datum/hex/next
		if(D["terrain"] == HEX_TERRAIN_CARP)
			var/list/options = list()
			for(var/datum/hex/N as anything in neighbours(H))
				if(!N.system && N != player_hex)
					options += N
			if(length(options))
				next = pick(options)
		else
			var/list/dir = GLOB.hex_axial_dirs[D["dir"]]
			next = hex_axial(H.sector, H.q + dir[1], H.r + dir[2])
			if(!next || next.system || next == player_hex || is_edge(next) || prob(25))
				D["dir"] = rand(1, 6)
				next = null
		if(!next)
			continue
		if(D["terrain"] == HEX_TERRAIN_COMET)
			var/list/tail = list(H) + D["tail"]
			D["tail"] = tail.Copy(1, min(length(tail), 2) + 1)
		D["hex"] = next
	lay_moving()

/// Nowy nieznany sygnał albo pole anomalii w losowym wolnym miejscu (do limitu)
/datum/hexmap/proc/spawn_random_terrain(terrain)
	var/count = 0
	for(var/id in hexes)
		var/datum/hex/H = hexes[id]
		if(H.terrain == terrain)
			count++
	if(count >= (terrain == HEX_TERRAIN_SIGNAL ? HEX_MAX_SIGNALS : HEX_MAX_ANOMALY_FIELDS))
		return
	var/list/free = free_hexes()
	var/list/far = list()
	for(var/datum/hex/H as anything in free)
		if(far_from_systems(H, 2))
			far += H
	var/list/options = length(far) ? far : free
	if(!length(options))
		return
	var/datum/hex/H = pick(options)
	H.set_terrain(terrain)
	if(terrain == HEX_TERRAIN_ANOMALIES)
		H.hex_spawn_anomaly_cluster() // skupisko do skanowania od razu (misja skanowania, war_missions.dm)
	return H

/// Zmiany terenu w trakcie rundy: nowe sygnały i anomalie, dryf burz, karpi i komet
/datum/hexmap/proc/start_terrain_timers()
	addtimer(CALLBACK(src, PROC_REF(random_terrain_tick)), rand(HEX_RANDOM_TERRAIN_MIN, HEX_RANDOM_TERRAIN_MAX))
	addtimer(CALLBACK(src, PROC_REF(drift_tick)), rand(HEX_DRIFT_MIN, HEX_DRIFT_MAX))

/datum/hexmap/proc/random_terrain_tick()
	spawn_random_terrain(pick(HEX_TERRAIN_SIGNAL, HEX_TERRAIN_ANOMALIES))
	addtimer(CALLBACK(src, PROC_REF(random_terrain_tick)), rand(HEX_RANDOM_TERRAIN_MIN, HEX_RANDOM_TERRAIN_MAX))

/datum/hexmap/proc/drift_tick()
	drift()
	addtimer(CALLBACK(src, PROC_REF(drift_tick)), rand(HEX_DRIFT_MIN, HEX_DRIFT_MAX))

/// Okręt gracza odlatuje z kafla: zbadany sygnał albo pole anomalii znika
/datum/hex/proc/on_player_left()
	if(terrain in list(HEX_TERRAIN_SIGNAL, HEX_TERRAIN_ANOMALIES))
		set_terrain(HEX_TERRAIN_EMPTY)

/datum/star_system/remove_ship(obj/structure/overmap/OM, turf/new_location, is_ftl_jump = TRUE)
	var/datum/hex/H = hex
	. = ..()
	if(OM?.role == MAIN_OVERMAP && H)
		H.on_player_left()

/// Tunel czasoprzestrzenny: okręt gracza wylatuje na drugim końcu (bez ładunku napędu i bez chłodzenia)
/obj/structure/overmap/proc/hex_wormhole_transit(datum/hex/from_hex)
	var/datum/hex/here = current_hex()
	if(here != from_hex || !here.wormhole_pair || SSstar_system.ships[src]?["target_system"] || ftl_drive?.ftl_state == FTL_STATE_JUMPING)
		return FALSE
	var/datum/star_system/target = GLOB.hexmap.system_for(here.wormhole_pair)
	var/datum/star_system/curr = SSstar_system.ships[src]["current_system"]
	relay('nsv13/sound/effects/ship/FTL.ogg', "<span class='warning'>Tunel czasoprzestrzenny wciąga okręt!</span>", channel = CHANNEL_SHIP_ALERT)
	SEND_SIGNAL(src, COMSIG_SHIP_DEPARTED)
	curr.remove_ship(src)
	jump_end(target)
	return TRUE
