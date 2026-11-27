// AQUILA - Zamach Syndykatu: Syndykat ogłasza na kanale okrętu, kogo zabije, a po kilkudziesięciu sekundach obok celu ląduje kapsuła z 2-4 oprychami (port z Bubberstation/Bubberstation modular_zubbers/code/modules/events/moderate/assassination_attempts/base_assassination_attempt.dm)
// Bubber picks a living human crew member who is not Syndicate, announces the hit as the Syndicate and 20-40 s later
// drops a Syndicate pod with five troopers (swords, SMGs, shotguns, stormtroopers) right on the victim's turf.
// Ours announces with our Polish lines, drops two to four thugs with knives or pistols (our basic Syndicate troopers,
// which do not smash obstacles) and never lands on the victim: the pod lands three to six tiles away on a free safe
// floor outside closed rooms, with no landing explosion, so the victim can run or call security. If the victim hides
// in a closed room, dies or leaves the ship before the pod comes, the pod lands where the victim was last seen. No
// "hammers" variant and no fake victims (our events are not faked by the fake announcement event).

/datum/round_event_control/aquila_hex_syndicate_assassination
	name = "Zamach Syndykatu"
	typepath = /datum/round_event/aquila_hex_syndicate_assassination
	weight = 5
	min_players = 15
	max_occurrences = 2
	earliest_start = 30 MINUTES

/datum/round_event_control/aquila_hex_syndicate_assassination/canSpawnEvent(players_amt, gamemode)
	. = ..()
	if(. && !aquila_hex_assassination_victim())
		return FALSE

/datum/round_event/aquila_hex_syndicate_assassination
	fakeable = FALSE
	announceWhen = 1
	/// Cel zamachu (weakref)
	var/datum/weakref/victim_ref
	/// Imię celu z ogłoszenia
	var/victim_name
	/// Pole lądowania wybrane, gdy cel był ostatnio widziany
	var/turf/fallback_landing
	/// Ilu oprychów leci w kapsule
	var/thug_count = 2

/datum/round_event/aquila_hex_syndicate_assassination/setup()
	startWhen = rand(10, 20) // 20-40 s jak w oryginale
	thug_count = rand(2, 4)
	var/mob/living/carbon/human/victim = aquila_hex_assassination_victim()
	fallback_landing = victim && aquila_hex_assassination_landing(victim)
	if(!victim || !fallback_landing) // kill() z setup() nie zatrzymuje eventu, więc announce() i start() sprawdzają cel
		log_game("Syndicate Assassination Attempt: no victim with a landing spot nearby, cancelling the event.")
		kill()
		return
	victim_ref = WEAKREF(victim)
	victim_name = victim.real_name

/datum/round_event/aquila_hex_syndicate_assassination/announce(fake)
	if(!victim_name)
		return
	var/list/lines = list(
		"[victim_name], policz dni, które ci zostały. Wystarczą palce jednej ręki.",
		"Witajcie, psy Nanotrasen. Przylatujemy po [victim_name]. Reszta może się rozejść.",
		"Puk, puk. Kto tam? Syndykat z nakazem dla: [victim_name]. Otwierać.",
		"[victim_name] wciąż żyje. Zaraz to naprawimy.",
		"Wysłaliśmy ekipę do [victim_name]. Dowóz w trzydzieści minut albo zamach gratis.",
	)
	priority_announce(pick(lines), "Wiadomość przechwycona na kanale okrętu", 'sound/misc/interference.ogg', sender_override = "Syndykat", color_override = "red")

/datum/round_event/aquila_hex_syndicate_assassination/start()
	if(!victim_name)
		return kill()
	var/mob/living/carbon/human/victim = victim_ref?.resolve()
	var/turf/landing
	if(aquila_hex_assassination_target_ok(victim))
		landing = aquila_hex_assassination_landing(victim)
	if(!landing && fallback_landing && aquila_hex_free_safe_turf(fallback_landing))
		landing = fallback_landing
	if(!landing)
		log_game("Syndicate Assassination Attempt: the landing spot near [victim_name] got blocked, no pod.")
		return kill()
	var/obj/effect/pod_landingzone/marker = launch(landing)
	announce_to_ghosts(marker)
	if(victim)
		notify_ghosts("Syndykat próbuje zabić: [victim_name]!", source = victim, action = NOTIFY_ORBIT, header = "Zamach w toku")
	message_admins("Zamach Syndykatu na [victim ? ADMIN_LOOKUPFLW(victim) : victim_name]: kapsuła z [thug_count] oprychami ląduje w [ADMIN_VERBOSEJMP(landing)].")
	log_game("Syndicate Assassination Attempt: a pod with [thug_count] thugs for [victim ? key_name(victim) : victim_name] is landing at [AREACOORD(landing)].")

/datum/round_event/aquila_hex_syndicate_assassination/kill()
	fallback_landing = null
	return ..()

/// Wysyła kapsułę z oprychami na pole; zwraca znacznik lądowania
/datum/round_event/aquila_hex_syndicate_assassination/proc/launch(turf/landing)
	return new /obj/effect/pod_landingzone(landing, make_pod())

/// Kapsuła Syndykatu bez wybuchu przy lądowaniu, z oprychami
/datum/round_event/aquila_hex_syndicate_assassination/proc/make_pod()
	var/static/list/thug_types = list(
		/mob/living/basic/trooper/syndicate/melee,
		/mob/living/basic/trooper/syndicate/ranged,
	)
	var/obj/structure/closet/supplypod/pod = new(null, STYLE_SYNDICATE)
	pod.explosionSize = list(0, 0, 0, 0)
	for(var/i in 1 to thug_count)
		var/thug_type = pick(thug_types)
		var/mob/living/basic/trooper/syndicate/thug = new thug_type(pod)
		thug.name = "oprych Syndykatu"
		thug.environment_smash = ENVIRONMENT_SMASH_NONE
	return pod

/// Czy człowiek może być celem zamachu: żywy gracz załogi na statku, bez antagonisty i nie z Syndykatu
/proc/aquila_hex_assassination_target_ok(mob/living/carbon/human/victim)
	if(!istype(victim) || QDELETED(victim) || victim.stat == DEAD || !victim.client || !victim.mind)
		return FALSE
	if(length(victim.mind.antag_datums) || (FACTION_SYNDICATE in victim.faction))
		return FALSE
	var/turf/victim_turf = get_turf(victim)
	return victim_turf && is_station_level(victim_turf.z)

/// Losowy cel zamachu, przy którym da się wylądować; null, gdy nikogo takiego nie ma
/proc/aquila_hex_assassination_victim()
	var/list/candidates = list()
	for(var/mob/living/carbon/human/crew in GLOB.player_list)
		if(aquila_hex_assassination_target_ok(crew))
			candidates += crew
	while(length(candidates))
		var/mob/living/carbon/human/victim = pick_n_take(candidates)
		if(aquila_hex_assassination_landing(victim))
			return victim

/// Wolne bezpieczne pole 3-6 pól od celu, poza zamkniętymi i niebezpiecznymi obszarami (nigdy na celu); null, gdy brak
/proc/aquila_hex_assassination_landing(mob/living/victim)
	var/turf/center = get_turf(victim)
	if(!center)
		return null
	var/list/spots = list()
	for(var/turf/T as anything in RANGE_TURFS(6, center))
		if(get_dist(T, center) < 3 || isspaceturf(T))
			continue
		var/area/turf_area = get_area(T)
		if(!turf_area || !(turf_area.type in GLOB.the_station_areas) || aquila_hex_closed_area_type(turf_area.type))
			continue
		if(aquila_hex_free_safe_turf(T))
			spots += T
	return length(spots) ? pick(spots) : null
