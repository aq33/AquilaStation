// AQUILA - Burza Ianów: ogłoszenie burzy jonowej, po chwili sprostowanie, że to burza IANÓW, i przy członkach załogi pojawiają się corgi o imionach Ian Alfa, Ian Beta itd. (port z VOREStation code/modules/events/ian_storm_vr.dm)
// VORE spawns its Ian subtype next to every living human on the station levels, outside shielded areas, with steam.
// We use the plain basic corgi named "Ian <Greek letter>", not our Ian subtype, which keeps his age in persistence.
// At most one corgi per crew member and 15 in total, only next to living humans on the ship; the correction comes
// 7 seconds after the first announcement from a timer, not from spawn(), like VORE.

/datum/round_event_control/aquila_hex_ian_storm
	name = "Burza Ianów"
	typepath = /datum/round_event/aquila_hex_ian_storm
	weight = 8
	min_players = 3
	max_occurrences = 1
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_ian_storm
	fakeable = FALSE
	announceWhen = 1
	startWhen = 5 // after the correction
	/// Most corgis the storm brings
	var/max_ians = 15
	/// Corgis brought so far
	var/ians = 0

/datum/round_event/aquila_hex_ian_storm/announce(fake)
	priority_announce("Okręt przeleciał przez burzę jonową. Prosimy sprawdzić wszystkie urządzenia elektroniczne pod kątem usterek.", "Alarm: Anomalia", ANNOUNCER_IONSTORM)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Chwileczkę. Nie, to pomyłka. Okręt przeleciał przez burzę IANÓW!", "Alarm: Ian"), 7 SECONDS)

/datum/round_event/aquila_hex_ian_storm/start()
	var/list/crew = list()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.client || H.stat == DEAD)
			continue
		var/turf/T = get_turf(H)
		if(T && is_station_level(T.z))
			crew += H
	shuffle_inplace(crew)
	for(var/mob/living/carbon/human/H as anything in crew)
		if(ians >= max_ians)
			break
		place_ian(get_turf(H))
	log_game("Ian Storm: [ians] corgi(s) brought.")

/// Places one corgi on a free floor next to the turf, returns it
/datum/round_event/aquila_hex_ian_storm/proc/place_ian(turf/center)
	if(!center)
		return null
	for(var/attempt in 1 to 3)
		var/turf/open/target = get_step(center, pick(GLOB.alldirs))
		if(!istype(target) || isspaceturf(target) || is_blocked_turf(target, TRUE))
			continue
		var/mob/living/basic/pet/dog/corgi/doge = new(target)
		doge.real_name = "Ian [pick("Alfa", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Jota", "Kappa", "Lambda", "Omikron", "Ro", "Sigma", "Tau", "Ypsilon", "Fi", "Chi", "Psi", "Omega")]"
		doge.name = doge.real_name
		var/datum/effect_system/steam_spread/steam = new
		steam.set_up(3, FALSE, target)
		steam.start()
		ians++
		return doge
	return null
