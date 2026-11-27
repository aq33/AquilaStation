// AQUILA - Szalejący kosmiczny dzik: w tunelach technicznych pojawia się wysmarowany dzik, który szarżuje na ludzi, przewraca każdego, na kogo wpadnie, i zostawia za sobą mokry ślad (port z vgstation-coders/vgstation13 code/modules/events/spacehog.dm i code/modules/mob/living/simple_animal/hostile/hog.dm, rampagingspacehog)
// vg's rampaging overgreased hog (300 HP, the captain's spare ID inside so it passes any door) never attacks: when hurt
// it squeals and dashes three tiles a tick to one of its "homes" in maintenance, knocking down whoever it bumps and leaving
// 5 s of lube behind. Ours is a basic mob with vg's sprite that charges at people it sees within 5 tiles: its gore does
// 8 brute and knocks down for 2 s (once per 4 s), and any human it runs into falls over as well. It opens no doors (no
// spare ID), and the trail is a short wet floor (water, 5 s, a quarter of its steps) instead of lube. As in vg it rolls only
// when the ship has a cook or more than four midshipmen. The crew is warned right after it appears.

/datum/round_event_control/aquila_hex_hog
	name = "Szalejący kosmiczny dzik"
	typepath = /datum/round_event/aquila_hex_hog
	weight = 10
	min_players = 5
	max_occurrences = 1
	earliest_start = 10 MINUTES

/datum/round_event_control/aquila_hex_hog/canSpawnEvent(players_amt, gamemode)
	. = ..()
	if(. && !aquila_hex_hog_audience())
		return FALSE

/// Czy na statku jest kucharz albo więcej niż czterech majtków (warunek z vg)
/proc/aquila_hex_hog_audience()
	var/assistants = 0
	for(var/mob/living/carbon/human/person in GLOB.player_list)
		if(person.stat == DEAD || !person.mind)
			continue
		if(person.mind.assigned_role == JOB_NAME_COOK)
			return TRUE
		if(person.mind.assigned_role == JOB_NAME_ASSISTANT)
			assistants++
	return assistants > 4

/datum/round_event/aquila_hex_hog
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Dzik z eventu
	var/datum/weakref/hog_ref

/datum/round_event/aquila_hex_hog/start()
	var/mob/living/basic/aquila_space_hog/hog = spawn_hog(aquila_hex_maint_turf())
	if(!hog)
		log_game("Space Hog: no free maintenance turf found, cancelling the event.")
		return kill()
	hog_ref = WEAKREF(hog)
	announce_to_ghosts(hog)

/datum/round_event/aquila_hex_hog/announce(fake)
	var/mob/living/basic/aquila_space_hog/hog = hog_ref?.resolve()
	if(QDELETED(hog) || hog.stat == DEAD)
		return
	var/area/hog_area = get_area(hog)
	priority_announce("Na pokład wdarł się rozjuszony kosmiczny dzik, cały w smarze. Ostatnio widziany w: [hog_area.name]. Prosimy nie stawać mu na drodze i zgłosić się do kuchni z każdym pomysłem na pieczeń.", "Alarm biologiczny", ANNOUNCER_ALIENS)

/datum/round_event/aquila_hex_hog/proc/spawn_hog(turf/spot)
	if(!isturf(spot))
		return null
	var/mob/living/basic/aquila_space_hog/hog = new(spot)
	hog.visible_message("<span class='danger'>[hog] wypada z ciemności i kwiczy przeraźliwie!</span>")
	message_admins("Szalejący kosmiczny dzik pojawia się w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Space Hog: a rampaging hog spawned at [AREACOORD(spot)].")
	return hog

/**
 * Szalejący kosmiczny dzik: szarżuje na ludzi i przewraca każdego, na kogo wpadnie.
 */
/mob/living/basic/aquila_space_hog
	name = "szalejący kosmiczny dzik"
	desc = "Ogromny, wysmarowany smarem dzik z kosmosu. Zostawia za sobą śliski ślad i taranuje każdego, kto stanie mu na drodze."
	icon = 'aquila/icons/mob/plagues/plagues.dmi'
	icon_state = "hog_overgreased"
	icon_living = "hog_overgreased"
	icon_dead = "hog_overgreased_dead"
	gender = MALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	maxHealth = 300
	health = 300
	speed = 0
	melee_damage = 8
	attack_verb_continuous = "bodzie"
	attack_sound = 'sound/weapons/punch1.ogg'
	response_help_continuous = "klepie"
	response_disarm_continuous = "popycha"
	response_harm_continuous = "uderza"
	speak_emote = list("kwiczy")
	death_message = "kwiczy po raz ostatni i pada."
	mob_size = MOB_SIZE_LARGE
	combat_mode = TRUE
	faction = list("hog")
	gold_core_spawnable = NO_SPAWN
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 500
	butcher_results = list(/obj/item/food/meat/slab = 8)
	ai_controller = /datum/ai_controller/basic_controller/aquila_space_hog
	/// Jak długo leży przewrócony
	var/knockdown_time = 2 SECONDS
	/// Szansa (%), że krok zostawi mokrą podłogę
	var/trail_chance = 25
	COOLDOWN_DECLARE(knockdown_cooldown)

/mob/living/basic/aquila_space_hog/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/aquila_space_hog/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(stat == DEAD || !prob(trail_chance))
		return
	var/turf/open/trail = OldLoc
	if(istype(trail) && !isspaceturf(trail))
		trail.MakeSlippery(TURF_WET_WATER, min_wet_time = 5 SECONDS, max_wet_time = 5 SECONDS)

/mob/living/basic/aquila_space_hog/Bump(atom/bumped)
	. = ..()
	if(stat == DEAD || !ishuman(bumped))
		return
	ram(bumped)

/mob/living/basic/aquila_space_hog/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(. && ishuman(target))
		ram(target)

/// Przewraca człowieka (najwyżej raz na 4 s); zwraca TRUE, gdy przewrócił
/mob/living/basic/aquila_space_hog/proc/ram(mob/living/carbon/human/victim)
	if(!COOLDOWN_FINISHED(src, knockdown_cooldown) || victim.stat == DEAD)
		return FALSE
	COOLDOWN_START(src, knockdown_cooldown, 4 SECONDS)
	victim.Knockdown(knockdown_time)
	victim.visible_message("<span class='danger'>[src] taranuje [victim] i przewraca na ziemię!</span>", "<span class='userdanger'>[src] cię taranuje!</span>")
	playsound(src, 'sound/effects/bang.ogg', 40, TRUE)
	return TRUE

/datum/ai_controller/basic_controller/aquila_space_hog
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 5,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
