
//These are shuttle areas; all subtypes are only used as teleportation markers, they have no actual function beyond that.
//Multi area shuttles are a thing now, use subtypes! ~ninjanomnom

/area/shuttle
	name = "Prom"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	has_gravity = STANDARD_GRAVITY
	always_unpowered = FALSE
	// Loading the same shuttle map at a different time will produce distinct area instances.
	area_flags = NONE
	lighting_colour_tube = "#fff0dd"
	lighting_colour_bulb = "#ffe1c1"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	//The mobile port attached to this area
	var/obj/docking_port/mobile/mobile_port

/area/shuttle/Initialize(mapload)
	if(!canSmoothWithAreas)
		canSmoothWithAreas = type
	. = ..()

/area/shuttle/Destroy()
	mobile_port = null
	. = ..()

//Returns how many shuttles are missing a skipovers on a given turf, this usually represents how many shuttles have hull breaches on this turf. This only works if this is the actual area of T when called.
//TODO: optimize this somehow
/area/shuttle/proc/get_missing_shuttles(turf/T)
	var/i = 0
	var/BT_index = length(T.baseturfs)
	var/area/shuttle/A
	var/obj/docking_port/mobile/S
	var/list/shuttle_stack = list(mobile_port) //Indexing through a list helps prevent looped directed graph errors.
	while(i++ < shuttle_stack.len)
		S = shuttle_stack[i]
		A = S.underlying_turf_area[T]
		if(istype(A) && A.mobile_port)
			shuttle_stack |= A.mobile_port
		.++
	for(BT_index in 1 to length(T.baseturfs))
		if(ispath(T.baseturfs[BT_index], /turf/baseturf_skipover/shuttle))
			.--

/area/shuttle/PlaceOnTopReact(turf/T, list/new_baseturfs, turf/fake_turf_type, flags)
	. = ..()
	if(!length(new_baseturfs) || !ispath(new_baseturfs[1], /turf/baseturf_skipover/shuttle) && (!ispath(new_baseturfs[1], /turf/open/floor/plating) || length(new_baseturfs) > 1 || fake_turf_type))
		return //Only add missing baseturfs if a shuttle is landing or player made plating is being added (player made is infered to be a new_baseturf list of 1 and no fake_turf_type)
	for(var/i in 1 to get_missing_shuttles(T))
		new_baseturfs.Insert(1,/turf/baseturf_skipover/shuttle)

/area/shuttle/proc/link_to_shuttle(obj/docking_port/mobile/M)
	mobile_port = M

/area/shuttle/get_virtual_z(turf/T)
	if(mobile_port && is_reserved_level(mobile_port.z))
		return mobile_port.current_z
	return ..(T)

////////////////////////////Multi-area shuttles////////////////////////////

////////////////////////////Syndicate infiltrator////////////////////////////

/area/shuttle/syndicate
	name = "Infiltrator Syndykatu"
	ambience_index = AMBIENCE_DANGER
	canSmoothWithAreas = /area/shuttle/syndicate

/area/shuttle/syndicate/bridge
	name = "Sterownia Infiltratora Syndykatu"

/area/shuttle/syndicate/medical
	name = "Ambulatorium Infiltratora Syndykatu"

/area/shuttle/syndicate/armory
	name = "Zbrojownia Infiltratora Syndykatu"

/area/shuttle/syndicate/eva
	name = "EVA Infiltratora Syndykatu"

/area/shuttle/syndicate/hallway

/area/shuttle/syndicate/airlock
	name = "Śluza Infiltratora Syndykatu"

////////////////////////////Pirate Shuttle////////////////////////////

/area/shuttle/pirate
	name = "Prom Piratów"
	requires_power = TRUE
	canSmoothWithAreas = /area/shuttle/pirate

////////////////////////////Bounty Hunter Shuttles////////////////////////////

/area/shuttle/hunter
	name = "Prom Łowców"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	canSmoothWithAreas = /area/shuttle/hunter

////////////////////////////White Ship////////////////////////////

/area/shuttle/abandoned
	name = "Opuszczony Statek"
	requires_power = TRUE
	canSmoothWithAreas = /area/shuttle/abandoned

/area/shuttle/abandoned/bridge
	name = "Mostek Opuszczonego Statku"

/area/shuttle/abandoned/engine
	name = "Maszynownia Opuszczonego Statku"

/area/shuttle/abandoned/bar
	name = "Bar Opuszczonego Statku"

/area/shuttle/abandoned/crew
	name = "Kwatery Załogi Opuszczonego Statku"

/area/shuttle/abandoned/cargo
	name = "Ładownia Opuszczonego Statku"

/area/shuttle/abandoned/medbay
	name = "Ambulatorium Opuszczonego Statku"

/area/shuttle/abandoned/pod
	name = "Kapsuła Opuszczonego Statku"

////////////////////////////Single-area shuttles////////////////////////////

/area/shuttle/transit
	name = "Nadprzestrzeń"
	desc = "Iiiiiiii"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/shuttle/custom
	name = "Własny Prom Gracza"

/area/shuttle/custom/powered
	name = "Własny Zasilany Prom Gracza"
	requires_power = FALSE

/area/shuttle/arrival
	name = "Prom Przylotów"
	area_flags = UNIQUE_AREA// SSjob refers to this area for latejoiners

/area/shuttle/pod_1
	name = "Kapsuła Ratunkowa Jeden"
	area_flags = BLOBS_ALLOWED

/area/shuttle/pod_2
	name = "Kapsuła Ratunkowa Dwa"
	area_flags = BLOBS_ALLOWED

/area/shuttle/pod_3
	name = "Kapsuła Ratunkowa Trzy"
	area_flags = BLOBS_ALLOWED

/area/shuttle/pod_4
	name = "Kapsuła Ratunkowa Cztery"
	area_flags = BLOBS_ALLOWED

/area/shuttle/mining
	name = "Prom Górniczy"

/area/shuttle/mining/large
	name = "Prom Górniczy"
	requires_power = TRUE

/area/shuttle/science
	name = "Prom Naukowy"
	requires_power = TRUE

/area/shuttle/exploration
	name = "Prom Eksploracyjny"
	requires_power = TRUE

/area/shuttle/labor
	name = "Prom Obozu Pracy"

/area/shuttle/supply
	name = "Prom Zaopatrzeniowy"

/area/shuttle/escape
	name = "Prom Ewakuacyjny"

/area/shuttle/escape/backup
	name = "Zapasowy Prom Ewakuacyjny"

/area/shuttle/escape/luxury
	name = "Luksusowy Prom Ewakuacyjny"
	teleport_restriction = TELEPORT_ALLOW_NONE

/area/shuttle/escape/arena
	name = "Arena"
	teleport_restriction = TELEPORT_ALLOW_NONE

/area/shuttle/escape/meteor
	name = "\proper meteor z przypiętymi silnikami"
	luminosity = NONE

/area/shuttle/transport
	name = "Prom Transportowy"

/area/shuttle/assault_pod
	name = "Stalowy Deszcz"

/area/shuttle/sbc_starfury
	name = "SBC Starfury"

/area/shuttle/sbc_fighter1
	name = "Myśliwiec SBC 1"

/area/shuttle/sbc_fighter2
	name = "Myśliwiec SBC 2"

/area/shuttle/sbc_corvette
	name = "Korweta SBC"

/area/shuttle/syndicate_scout
	name = "Zwiadowca Syndykatu"

/area/shuttle/caravan
	requires_power = TRUE

/area/shuttle/caravan/syndicate1
	name = "Myśliwiec Syndykatu"

/area/shuttle/caravan/syndicate2
	name = "Myśliwiec Syndykatu"

/area/shuttle/caravan/syndicate3
	name = "Statek Desantowy Syndykatu"

/area/shuttle/caravan/pirate
	name = "Kuter Piratów"

/area/shuttle/caravan/freighter1
	name = "Mały Frachtowiec"

/area/shuttle/caravan/freighter2
	name = "Malutki Frachtowiec"

/area/shuttle/caravan/freighter3
	name = "Malutki Frachtowiec"
