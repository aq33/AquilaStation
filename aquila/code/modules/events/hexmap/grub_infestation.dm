// AQUILA - Plaga słonecznych larw: z wentylacji wypełza kilka larw, które wysysają prąd z APC pomieszczenia, przegryzają odsłonięte kable i najedzone rosną do dużych robaków (port z VOREStation/VOREStation code/modules/events/grubinfestation_vr.dm i code/modules/mob/living/simple_mob/subtypes/vore/solargrub_larva.dm, solargrub.dm)
// VORE larvae crawl inside powered machines, drain them through a hidden machine and, after 7 MW, balloon into vore
// solargrubs that sit on cables, drain the powernet and APCs and may evolve into a solar moth. Ours is one basic mob
// written from scratch with three growth stages on our grub sprites (tinted yellow): it drains the APC cell of the room it
// is in (the APC recharges from the grid as usual), now and then bites through an exposed cable under it (at most two per
// grub, shock immune) and grows twice after draining enough. Stage three is the end: no moths, no vore, no breeding, so
// the event lets out 3-6 larvae and never more. Big grubs bite back with a weak shock. The crew is warned 1.5-2 minutes
// after the larvae come out of the vents, and about 10 minutes later the sensors name the rooms where some still live.

/datum/round_event_control/aquila_hex_grub_infestation
	name = "Plaga słonecznych larw"
	typepath = /datum/round_event/aquila_hex_grub_infestation
	weight = 10
	min_players = 10
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_grub_infestation
	fakeable = FALSE
	startWhen = 1
	announceWhen = 45
	endWhen = 300
	/// Słabe referencje do wypuszczonych larw
	var/list/grubs = list()

/datum/round_event/aquila_hex_grub_infestation/setup()
	announceWhen = rand(45, 60)

/datum/round_event/aquila_hex_grub_infestation/start()
	var/list/spawned = spawn_grubs(aquila_hex_vent_turfs(), rand(3, 6))
	if(!length(spawned))
		log_game("Grub Infestation: no open vents on the ship, cancelling the event.")
		return kill()
	var/mob/living/first = spawned[1]
	announce_to_ghosts(first)
	message_admins("Plaga słonecznych larw: z wentylacji wychodzi [length(spawned)] larw, np. w [ADMIN_VERBOSEJMP(first)].")
	log_game("Grub Infestation: [length(spawned)] solar grubs spawned from the vents.")

/datum/round_event/aquila_hex_grub_infestation/announce(fake)
	if(!length(aquila_hex_living_areas(grubs)))
		return
	priority_announce("Czujniki biologiczne wykryły na pokładzie słoneczne larwy. Te robaki wysysają prąd z urządzeń i przegryzają odsłonięte kable, a najedzone rosną. Prosimy usunąć je, zanim zaczną wpływać na pracę działów.", "Alarm biologiczny", ANNOUNCER_ALIENS)

/datum/round_event/aquila_hex_grub_infestation/end()
	var/list/areas = aquila_hex_living_areas(grubs)
	if(length(areas))
		priority_announce("Czujniki zawęziły miejsca pobytu pozostałych słonecznych larw do: [english_list(areas)].", "Alarm biologiczny")

/datum/round_event/aquila_hex_grub_infestation/kill()
	grubs = null
	return ..()

/// Stawia count larw przy wentylacjach (po jednej przy każdej), zwraca listę larw
/datum/round_event/aquila_hex_grub_infestation/proc/spawn_grubs(list/turfs, count)
	. = aquila_hex_spawn_on_turfs(turfs, count, /mob/living/basic/aquila_solargrub, 1, "%MOB wypełza z kratki wentylacyjnej!")
	for(var/mob/living/basic/aquila_solargrub/grub as anything in .)
		LAZYADD(grubs, WEAKREF(grub))

/**
 * Słoneczna larwa: wysysa prąd z APC pomieszczenia i rośnie w trzech stadiach (larwa, robak, duży robak).
 */
/mob/living/basic/aquila_solargrub
	name = "słoneczna larwa"
	desc = "Mały, żółto świecący robak. Wysysa prąd z każdego urządzenia w pobliżu, a im więcej zje, tym bardziej rośnie."
	icon = 'icons/mob/animal.dmi'
	icon_state = "grub_1"
	icon_living = "grub_1"
	icon_dead = "grub_1_dead"
	color = "#ffe45c"
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	maxHealth = 10
	health = 10
	speed = 2
	melee_damage = 1
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	response_help_continuous = "szturcha"
	response_disarm_continuous = "odsuwa"
	response_harm_continuous = "rozgniata"
	death_message = "zwija się w kłębek i gaśnie."
	density = FALSE
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_TINY
	faction = list("solargrub")
	gold_core_spawnable = NO_SPAWN
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 400
	light_range = 1.5
	light_power = 0.8
	light_color = LIGHT_COLOR_YELLOW
	ai_controller = /datum/ai_controller/basic_controller/aquila_solargrub
	/// Stadium wzrostu (1-3)
	var/stage = 1
	/// Ile energii larwa już wyssała
	var/power_drained = 0
	/// Ile energii trzeba wyssać, żeby wejść w stadium 2 i 3
	var/list/stage_thresholds = list(1500, 4000)
	/// Ile energii larwa wysysa co Life() w każdym stadium
	var/list/drain_per_life = list(10, 20, 40)
	/// Ile kabli przegryzła
	var/cables_chewed = 0
	/// Najwięcej kabli, które jedna larwa przegryzie
	var/max_cables_chewed = 2

/mob/living/basic/aquila_solargrub/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/aquila_solargrub/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD || QDELETED(src) || !isturf(loc))
		return
	feed(aquila_hex_drain_area_power(src, drain_per_life[stage]))

/mob/living/basic/aquila_solargrub/death(gibbed)
	. = ..()
	set_light(0)

/// Dolicza wyssaną energię i sprawdza wzrost; zwraca TRUE, gdy larwa urosła
/mob/living/basic/aquila_solargrub/proc/feed(amount)
	if(amount <= 0)
		return FALSE
	power_drained += amount
	if(prob(5))
		do_sparks(1, TRUE, src)
	if(stage > length(stage_thresholds) || power_drained < stage_thresholds[stage])
		return FALSE
	return grow()

/// Następne stadium wzrostu (najwyżej trzecie)
/mob/living/basic/aquila_solargrub/proc/grow()
	if(stage >= 3 || stat == DEAD)
		return FALSE
	stage++
	icon_state = "grub_[stage]"
	icon_living = icon_state
	icon_dead = "grub_[stage]_dead"
	maxHealth = stage == 2 ? 30 : 60
	health = maxHealth
	melee_damage = stage == 2 ? 3 : 6
	speed = stage == 2 ? 2 : 3
	update_basic_mob_varspeed()
	name = stage == 2 ? "słoneczny robak" : "duży słoneczny robak"
	desc = "Opasły, iskrzący robak, który wyrósł na prądzie z okrętu. [stage == 3 ? "Gryzie z ładunkiem elektrycznym." : "Wciąż rośnie."]"
	set_light(stage + 0.5, 1, LIGHT_COLOR_YELLOW)
	visible_message("<span class='warning'>[src] nagle pęcznieje i rośnie!</span>")
	do_sparks(3, TRUE, src)
	return TRUE

/// Duży robak razi prądem przy ugryzieniu
/mob/living/basic/aquila_solargrub/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(!. || stage < 3 || !iscarbon(target) || !prob(25))
		return
	var/mob/living/carbon/victim = target
	victim.electrocute_act(8, src, 1, safety = TRUE, stun = FALSE)

/// SI larwy przegryza kable, które znalazła pod sobą (gracz w ciele larwy gryzie normalnie)
/mob/living/basic/aquila_solargrub/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(!client && proximity_flag && istype(attack_target, /obj/structure/cable))
		chew_cable(attack_target)
		return TRUE
	return ..()

/// Przegryza kabel (najwyżej max_cables_chewed); zwraca TRUE, gdy przegryzła
/mob/living/basic/aquila_solargrub/proc/chew_cable(obj/structure/cable/cable)
	if(QDELETED(cable) || cables_chewed >= max_cables_chewed || stat == DEAD)
		return FALSE
	cables_chewed++
	visible_message("<span class='warning'>[src] przegryza [cable] i wysysa z niego iskry!</span>")
	do_sparks(2, TRUE, src)
	cable.deconstruct()
	feed(500)
	return TRUE

/datum/ai_controller/basic_controller/aquila_solargrub
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables/aquila_solargrub,
	)

/// Larwa częściej niż mysz szuka odsłoniętych kabli pod sobą (sama kończy, gdy przegryzła swoje dwa)
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables/aquila_solargrub
	hunt_chance = 1

/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables/aquila_solargrub/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/basic/aquila_solargrub/grub = controller.pawn
	if(istype(grub) && grub.cables_chewed >= grub.max_cables_chewed)
		return
	return ..()
