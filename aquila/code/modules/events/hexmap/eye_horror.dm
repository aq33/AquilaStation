// AQUILA - Oczny horror: obok kogoś z załogi materializuje się ogromne oko z innego wymiaru, które co kilkanaście sekund oślepia błyskiem każdego, kto na nie patrzy, i sieje halucynacje, dopóki ktoś go nie zabije (port z LLA-Gaming/SS13 code/modules/events/eye_horror.dm i code/modules/mob/living/simple_animal/hostile/eye_horror.dm)
// LLA's "It That Sees" lands in a room near people after a 5 minute warning, flashes everyone in the room on arrival and
// makes everyone who hears it hallucinate more and more; the event passes when it dies. Ours appears at once 2-4 tiles
// from a random crew member outside maintenance, dangerous and closed areas (announced right after it is there) and is a basic
// mob drawn with our eyeball sprite (bigger and bloodshot): it flies, bites, and every 12 seconds flashes everyone who
// sees it within 5 tiles with a clear line (no walls, windows or closed doors in between). The flash goes through our flash_act(), so sunglasses, welding goggles, a welding mask or
// helmet protect; whoever got flashed also hallucinates for up to a minute. It does not break walls or doors, comes
// from no gold slime core and no ghost can take it over. No medals.

/datum/round_event_control/aquila_hex_eye_horror
	name = "Oczny horror"
	typepath = /datum/round_event/aquila_hex_eye_horror
	weight = 10
	min_players = 10
	max_occurrences = 2
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_eye_horror
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Stwór z eventu
	var/datum/weakref/horror_ref

/datum/round_event/aquila_hex_eye_horror/start()
	var/mob/living/basic/aquila_eye_horror/horror = spawn_horror(aquila_hex_spot_near_crew())
	if(!horror)
		log_game("Eye Horror: no free turf near the crew found, cancelling the event.")
		return kill()
	horror_ref = WEAKREF(horror)
	announce_to_ghosts(horror)

/datum/round_event/aquila_hex_eye_horror/announce(fake)
	var/mob/living/basic/aquila_eye_horror/horror = horror_ref?.resolve()
	if(QDELETED(horror) || horror.stat == DEAD)
		return
	var/area/horror_area = get_area(horror)
	priority_announce("W pomieszczeniu [horror_area.name] wykryto paranormalne częstotliwości i nieziemskie oznaki życia. Opuśćcie je natychmiast i nie patrzcie w oko bez okularów przeciwsłonecznych albo spawalniczych.", "Alarm paranormalny", ANNOUNCER_SPANOMALIES)

/datum/round_event/aquila_hex_eye_horror/proc/spawn_horror(turf/spot)
	if(!isturf(spot))
		return null
	var/mob/living/basic/aquila_eye_horror/horror = new(spot)
	horror.visible_message("<span class='danger'>Powietrze pęka i wyłania się z niego ogromne, przekrwione oko!</span>")
	horror.gaze()
	message_admins("Oczny horror pojawia się w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Eye Horror: an eye horror spawned at [AREACOORD(spot)].")
	return horror

/**
 * Wolne i bezpieczne pole 2-4 pola od losowej osoby z załogi, która jest poza tunelami technicznymi i niebezpiecznymi
 * obszarami statku; null, gdy nikogo takiego nie ma.
 */
/proc/aquila_hex_spot_near_crew()
	var/list/crew = list()
	for(var/mob/living/carbon/human/person in GLOB.player_list)
		if(person.stat == DEAD || !person.client)
			continue
		var/turf/person_turf = get_turf(person)
		if(!person_turf || !is_station_level(person_turf.z))
			continue
		var/area/person_area = get_area(person_turf)
		if(!person_area || !(person_area.type in GLOB.the_station_areas) || istype(person_area, /area/maintenance) || aquila_hex_closed_area_type(person_area.type))
			continue
		crew += person
	while(length(crew))
		var/mob/living/carbon/human/person = pick_n_take(crew)
		var/turf/center = get_turf(person)
		var/list/spots = list()
		for(var/turf/T as anything in aquila_hex_free_turfs_near(center, 25, 4))
			var/area/spot_area = get_area(T)
			if(get_dist(T, center) >= 2 && aquila_hex_free_safe_turf(T) && !aquila_hex_closed_area_type(spot_area?.type))
				spots += T
		if(length(spots))
			return pick(spots)

/**
 * Ten, Który Widzi: ogromne oko, które oślepia błyskiem i sieje halucynacje.
 */
/mob/living/basic/aquila_eye_horror
	name = "Ten, Który Widzi"
	desc = "Ohydztwo z innego wymiaru: jedno ogromne, przekrwione oko, które nie mruga. Patrzenie na nie boli."
	icon = 'icons/mob/carp.dmi'
	icon_state = "eyeball"
	icon_living = "eyeball"
	color = "#ff8080"
	resize = 1.5
	gender = NEUTER
	mob_biotypes = list(MOB_ORGANIC)
	maxHealth = 180
	health = 180
	speed = 1
	melee_damage = 12
	attack_verb_continuous = "kąsa"
	attack_sound = 'sound/weapons/pierce.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	response_help_continuous = "dotyka"
	response_disarm_continuous = "odpycha"
	response_harm_continuous = "uderza"
	speak_emote = list("woła telepatycznie")
	death_message = "wydaje bezgłośny wrzask i rozpływa się w powietrzu."
	basic_mob_flags = DEL_ON_DEATH
	combat_mode = TRUE
	faction = list("spooky")
	gold_core_spawnable = NO_SPAWN
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	pressure_resistance = 200
	light_range = 2
	light_power = 0.8
	light_color = LIGHT_COLOR_RED
	ai_controller = /datum/ai_controller/basic_controller/aquila_eye_horror
	/// Co ile oko oślepia błyskiem
	var/gaze_delay = 12 SECONDS
	/// Zasięg błysku
	var/gaze_range = 5
	COOLDOWN_DECLARE(gaze_cooldown)

/mob/living/basic/aquila_eye_horror/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/aquila_eye_horror/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD && !QDELETED(src) && COOLDOWN_FINISHED(src, gaze_cooldown))
		gaze()

/// Błysk w każdego, kto widzi oko z gaze_range pól bez szyby ani ściany po drodze (ochrona oczu działa jak przy błysku lampy); zwraca listę oślepionych
/mob/living/basic/aquila_eye_horror/proc/gaze()
	. = list()
	if(stat == DEAD || !isturf(loc))
		return
	COOLDOWN_START(src, gaze_cooldown, gaze_delay)
	for(var/mob/living/carbon/victim in viewers(gaze_range, src))
		if(victim.stat != CONSCIOUS || victim.is_blind())
			continue
		if(!aquila_hex_clear_line(get_turf(src), get_turf(victim), gaze_range))
			continue
		if(!victim.flash_act(1))
			continue
		victim.adjust_hallucinations_up_to(20 SECONDS, 60 SECONDS)
		to_chat(victim, "<span class='userdanger'>Oko patrzy prosto na ciebie i świat zaczyna się rozpadać!</span>")
		. += victim
	if(length(.))
		visible_message("<span class='danger'>[src] rozbłyska oślepiającym światłem!</span>")
		playsound(src, 'sound/weapons/flash.ogg', 50, TRUE)

/datum/ai_controller/basic_controller/aquila_eye_horror
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
