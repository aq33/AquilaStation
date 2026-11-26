// AQUILA - Inwazja hivebotów: w obszarze, w którym przebywa załoga, materializuje się teleporter hivebotów, czujniki zgłaszają syntetyczne formy życia, a po chwili teleporter wypluwa 4-6 hivebotów i znika (port z LLA-Gaming/SS13 code/modules/events/hive_bots.dm)
// LLA picks an area near people and a free turf there, alerts "Synthetic lifesigns detected" and places a hivebot
// teleporter, which warps its hivebots in later; the event passes when the crew destroys them all. Ours uses our basic
// hivebots (melee, ranged and rapid) and a teleporter of our own (the core /obj/structure/hivebot_beacon sleeps in a
// timer, so it is not reused): it appears with a smoke puff 20-30 s before it spits the bots out, then disappears.
// No medals and stories (we have none). Inside the ship, unlike our rogue drone swarm, which shoots the hull from space.

/datum/round_event_control/aquila_hex_hivebots
	name = "Inwazja hivebotów"
	typepath = /datum/round_event/aquila_hex_hivebots
	weight = 5
	min_players = 10
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/aquila_hex_hivebots
	fakeable = FALSE
	startWhen = 1
	announceWhen = 3
	/// Pole, na którym stanie teleporter (wybrane w setup())
	var/turf/impact_turf
	var/area/impact_area

/datum/round_event/aquila_hex_hivebots/setup()
	impact_turf = find_impact_turf()
	impact_area = get_area(impact_turf)
	if(!impact_turf)
		log_game("Hivebot Invasion: no free floor near the crew found, cancelling the event.")
		kill()

/datum/round_event/aquila_hex_hivebots/announce(fake)
	if(!impact_area)
		return
	priority_announce("Wykryto syntetyczne sygnatury życia w obszarze: [impact_area.name]. Sygnatury zgadzają się z wzorcem hivebotów. Ochrona proszona o natychmiastową reakcję, a pozostała załoga o niepodchodzenie do dziwnych nadajników.", "Alarm bezpieczeństwa")

/datum/round_event/aquila_hex_hivebots/start()
	if(!impact_turf)
		return kill()
	var/obj/structure/aquila_hex_hivebot_teleporter/tele = new(impact_turf)
	tele.schedule_warp(rand(20, 30) SECONDS)
	announce_to_ghosts(tele)
	message_admins("Inwazja hivebotów: teleporter w [ADMIN_VERBOSEJMP(impact_turf)].")
	log_game("Hivebot Invasion: hivebot teleporter placed at [AREACOORD(impact_turf)].")

/datum/round_event/aquila_hex_hivebots/kill()
	impact_turf = null
	impact_area = null
	return ..()

/// Wolne pole w obszarze, w którym jest ktoś z załogi; bez załogi na statku losowe wolne pole statku
/datum/round_event/aquila_hex_hivebots/proc/find_impact_turf()
	var/list/crew = shuffle(aquila_hex_ship_crew())
	for(var/mob/living/someone as anything in crew)
		var/area/crew_area = get_area(someone)
		if(!(crew_area?.type in GLOB.the_station_areas))
			continue
		var/list/turfs = list()
		for(var/turf/T in crew_area)
			if(aquila_hex_free_safe_turf(T) && get_dist(T, someone) >= 3)
				turfs += T
		if(length(turfs))
			return pick(turfs)
	for(var/attempt in 1 to 10)
		var/turf/T = aquila_hex_random_ship_turf()
		if(aquila_hex_free_safe_turf(T))
			return T

/// Teleporter hivebotów: po czasie wypluwa hiveboty i znika
/obj/structure/aquila_hex_hivebot_teleporter
	name = "dziwny nadajnik"
	desc = "Pulsujący nadajnik nieznanej konstrukcji. Coś po drugiej stronie właśnie się do niego dostraja."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "def_radar-off"
	anchored = TRUE
	density = TRUE
	max_integrity = 150
	/// Ile hivebotów wyjdzie
	var/bot_amount = 5
	/// Już wypluł hiveboty
	var/warped = FALSE

/obj/structure/aquila_hex_hivebot_teleporter/Initialize(mapload)
	. = ..()
	bot_amount = rand(4, 6)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, loc)
	smoke.start()
	playsound(src, 'sound/effects/empulse.ogg', 25, TRUE)
	visible_message("<span class='boldannounce'>[src] materializuje się w kłębach dymu!</span>")

/obj/structure/aquila_hex_hivebot_teleporter/proc/schedule_warp(delay)
	addtimer(CALLBACK(src, PROC_REF(warp_bots)), delay)

/// Wypluwa hiveboty i znika; zwraca listę hivebotów
/obj/structure/aquila_hex_hivebot_teleporter/proc/warp_bots()
	. = list()
	if(warped || QDELETED(src))
		return
	warped = TRUE
	icon_state = "def_radar"
	visible_message("<span class='danger'>[src] włącza się, a z jego wnętrza wysypują się hiveboty!</span>")
	playsound(src, 'sound/effects/empulse.ogg', 25, TRUE)
	var/turf/spot = get_turf(src)
	var/list/turfs = aquila_hex_free_turfs_near(spot, bot_amount, 2)
	for(var/i in 1 to bot_amount)
		var/bot_type = pick(/mob/living/basic/hivebot, /mob/living/basic/hivebot/range, /mob/living/basic/hivebot/rapid)
		. += new bot_type(length(turfs) ? pick(turfs) : spot)
	log_game("Hivebot Invasion: [length(.)] hivebots warped in at [AREACOORD(spot)].")
	QDEL_IN(src, 5 SECONDS)
