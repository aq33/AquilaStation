// AQUILA - Plaga larw: z wentylacji wypełzają larwy obcych; zwykłe po chwili wyrastają na pomioty, a pasożytnicze wgryzają się w człowieka i rosną w nim, dopóki ktoś ich nie wytnie albo nie otruje (port z vlggms/tegustation-bay12 code/modules/events/abominable_infestation.dm i code/modules/mob/living/simple_animal/hostile/infestation/larva.dm)
// Tegu spawns 2-4 (times severity) larvae, a third of them implanters; plain larvae turn after 1-1.5 min into one of five
// abominations, implanters burrow into a limb and burst out 2-4 minutes later as one of them. Ours keeps one abomination
// (the broodling) and its sprites, rewritten as basic mobs: a plain larva grows into a broodling after 1.5-2.5 minutes,
// a parasitic larva bites a human (a bio suit stops it) and becomes a body egg in the chest. The egg shows on the health
// analyzer from the start, is removed by organ manipulation of the chest (a removed larva is dead), and dies in 1-2 s
// when there are at least 2 units of pest killer in the host's blood; otherwise it bursts out after 3 minutes of the
// host's life (25 brute) as one broodling. Stasis and death of the host stop its growth. Unlike the xeno embryo it gives
// the host no immunity to facehuggers (the core body egg's TRAIT_XENO_IMMUNE is taken away, the medical HUD stays).
// Broodlings do not breed and a larva implants only once, so 3-5 larvae make at most 3-5 broodlings and nothing more.
// A parasitic larva that finds no host in 5 minutes grows into a broodling as well. Announced after the larvae are out.

/datum/round_event_control/aquila_hex_abominable_infestation
	name = "Plaga larw"
	typepath = /datum/round_event/aquila_hex_abominable_infestation
	weight = 8
	min_players = 15
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/aquila_hex_abominable_infestation
	fakeable = FALSE
	startWhen = 1
	announceWhen = 20

/datum/round_event/aquila_hex_abominable_infestation/start()
	var/list/spawned = spawn_larvae(aquila_hex_vent_turfs(), rand(3, 5))
	if(!length(spawned))
		log_game("Abominable Infestation: no open vents on the ship, cancelling the event.")
		return kill()
	var/mob/living/first = spawned[1]
	announce_to_ghosts(first)
	message_admins("Plaga larw: z wentylacji wychodzi [length(spawned)] larw, np. w [ADMIN_VERBOSEJMP(first)].")
	log_game("Abominable Infestation: [length(spawned)] alien larvae spawned from the vents.")

/datum/round_event/aquila_hex_abominable_infestation/announce(fake)
	priority_announce("Czujniki biologiczne wykryły na pokładzie nieznane formy życia przypominające larwy owadów. Część z nich wgryza się w ludzi: każdego pogryzionego zbada lekarz. Larwy w ciele usuwa operacja albo środek na szkodniki.", "Alarm biologiczny", ANNOUNCER_ALIENS)

/**
 * Stawia count larw przy wentylacjach (po jednej przy każdej), z czego co najmniej jedna i najwyżej dwie są
 * pasożytnicze; zwraca listę larw.
 */
/datum/round_event/aquila_hex_abominable_infestation/proc/spawn_larvae(list/turfs, count)
	var/implanters = min(count, rand(1, 2))
	. = aquila_hex_spawn_on_turfs(turfs, implanters, /mob/living/basic/aquila_hex_larva/implanter, 1, "%MOB wypełza z kratki wentylacyjnej!")
	var/list/left = turfs.Copy()
	for(var/mob/living/larva as anything in .)
		left -= get_turf(larva)
	. += aquila_hex_spawn_on_turfs(left, count - length(.), /mob/living/basic/aquila_hex_larva, 1, "%MOB wypełza z kratki wentylacyjnej!")

/**
 * Larwa obcych: wije się po tunelach i po 1,5-2,5 minuty wyrasta na pomiot.
 */
/mob/living/basic/aquila_hex_larva
	name = "larwa"
	desc = "Dziwne, owadopodobne stworzenie. Wije się, bulgocze i rośnie w oczach."
	icon = 'aquila/icons/mob/plagues/plagues.dmi'
	icon_state = "larva"
	icon_living = "larva"
	icon_dead = "larva_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	maxHealth = 10
	health = 10
	speed = 1
	melee_damage = 2
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	response_help_continuous = "szturcha"
	response_disarm_continuous = "odsuwa"
	response_harm_continuous = "rozdeptuje"
	speak_emote = list("bulgocze")
	death_message = "wije się w konwulsjach i zastyga."
	density = FALSE
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_TINY
	layer = LYING_MOB_LAYER
	faction = list("abomination")
	gold_core_spawnable = NO_SPAWN
	unsuitable_atmos_damage = 0
	ai_controller = /datum/ai_controller/basic_controller/aquila_hex_larva
	/// Kiedy larwa wyrasta na pomiot (world.time)
	var/grow_at

/mob/living/basic/aquila_hex_larva/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	grow_at = world.time + grow_delay()

/// Po jakim czasie od pojawienia się larwa wyrasta na pomiot
/mob/living/basic/aquila_hex_larva/proc/grow_delay()
	return rand(90, 150) SECONDS

/mob/living/basic/aquila_hex_larva/Life(seconds, times_fired)
	. = ..()
	if(stat != DEAD && !QDELETED(src) && isturf(loc) && world.time >= grow_at)
		mature()

/// Larwa zamienia się w pomiot; zwraca pomiot
/mob/living/basic/aquila_hex_larva/proc/mature()
	var/turf/spot = get_turf(src)
	if(!spot || stat == DEAD)
		return null
	var/mob/living/basic/aquila_hex_broodling/brood = new(spot)
	brood.visible_message("<span class='danger'>[src] pęka i wyłania się z niej [brood]!</span>")
	playsound(spot, 'sound/effects/splat.ogg', 50, TRUE)
	qdel(src)
	return brood

/**
 * Larwa pasożytnicza: goni ludzi i wgryza się w pierwszego, którego dopadnie; bez żywiciela po 5 minutach wyrasta na pomiot.
 */
/mob/living/basic/aquila_hex_larva/implanter
	name = "larwa pasożytnicza"
	desc = "Dziwne, owadopodobne stworzenie z ostrymi żuwaczkami. Węszy za ciepłym ciałem, w którym mogłoby się zagnieździć."
	icon_state = "larva_implanter"
	icon_living = "larva_implanter"
	ai_controller = /datum/ai_controller/basic_controller/aquila_hex_larva/implanter
	/// Larwa wgryzła się już w kogoś (mob czeka na usunięcie)
	var/burrowed = FALSE

/mob/living/basic/aquila_hex_larva/implanter/grow_delay()
	return 5 MINUTES

/mob/living/basic/aquila_hex_larva/implanter/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!client && ishuman(target) && implant(target))
		return TRUE
	return ..()

/// Wgryza się w człowieka i zamienia w larwę w jego ciele; zwraca TRUE, gdy się udało
/mob/living/basic/aquila_hex_larva/implanter/proc/implant(mob/living/carbon/human/host)
	if(burrowed || QDELETED(host) || host.stat == DEAD || stat == DEAD || !Adjacent(host))
		return FALSE
	if(host.getorganslot("parasite_egg") || host.getarmor(BODY_ZONE_CHEST, "bio") >= 60)
		return FALSE
	var/obj/item/bodypart/chest = host.get_bodypart(BODY_ZONE_CHEST)
	if(!chest || !IS_ORGANIC_LIMB(chest))
		return FALSE
	host.visible_message("<span class='danger'>[src] przegryza ubranie i skórę [host] i wije się do środka!</span>", \
		"<span class='userdanger'>[src] wgryza się w twoją klatkę piersiową i znika pod skórą!</span>")
	playsound(host, 'sound/effects/splat.ogg', 50, TRUE)
	host.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
	new /obj/item/organ/body_egg/aquila_hex_larva(host)
	log_combat(src, host, "implanted an alien larva into")
	// larwa jest już w ciele; mob znika dopiero po skończonym ataku, który właśnie trwa
	burrowed = TRUE
	moveToNullspace()
	QDEL_IN(src, 0)
	return TRUE

/datum/ai_controller/basic_controller/aquila_hex_larva
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/aquila_hex_larva/implanter
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/aquila_humans_only,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Cel tylko wśród ludzi
/datum/targeting_strategy/basic/aquila_humans_only

/datum/targeting_strategy/basic/aquila_humans_only/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	if(!ishuman(the_target))
		return FALSE
	return ..()

/**
 * Pomiot: wyrośnięta larwa, sama paszcza i pazury. Atakuje wszystko w pobliżu, ale się nie rozmnaża.
 */
/mob/living/basic/aquila_hex_broodling
	name = "pomiot"
	desc = "Wyrośnięta larwa obcych: sama paszcza i pazury. Na szczęście nie potrafi się rozmnażać."
	icon = 'aquila/icons/mob/plagues/plagues.dmi'
	icon_state = "broodling"
	icon_living = "broodling"
	icon_dead = "broodling_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	maxHealth = 35
	health = 35
	speed = 0.5
	melee_damage = 7
	melee_attack_cooldown = 1.5 SECONDS
	attack_verb_continuous = "szarpie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	response_help_continuous = "szturcha"
	response_disarm_continuous = "odpycha"
	response_harm_continuous = "uderza"
	speak_emote = list("syczy")
	death_message = "skrzeczy i pada."
	mob_size = MOB_SIZE_SMALL
	faction = list("abomination")
	combat_mode = TRUE
	gold_core_spawnable = NO_SPAWN
	unsuitable_atmos_damage = 0
	ai_controller = /datum/ai_controller/basic_controller/aquila_hex_broodling

/mob/living/basic/aquila_hex_broodling/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/datum/ai_controller/basic_controller/aquila_hex_broodling
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

/**
 * Larwa w ciele: rośnie przez 3 minuty życia żywiciela i wychodzi jako pomiot. Wycina ją operacja na organach klatki
 * piersiowej, zabija środek na szkodniki we krwi żywiciela; staza i śmierć żywiciela wstrzymują wzrost.
 */
/obj/item/organ/body_egg/aquila_hex_larva
	name = "larwa pasożyta"
	desc = "Wijąca się larwa obcych, która zagnieździła się w czyimś ciele."
	icon = 'aquila/icons/mob/plagues/plagues.dmi'
	icon_state = "larva_dead"
	/// Ile czasu larwa już rosła w żywicielu
	var/grown_time = 0
	/// Po ilu czasie wzrostu larwa wychodzi z ciała
	var/hatch_time = 3 MINUTES
	/// Najwięcej czasu doliczanego za jednym razem (Life() żywiciela co ok. 2 s; dłuższa przerwa to staza albo śmierć)
	var/max_growth_step = 4 SECONDS
	/// Kiedy (world.time) larwa ostatnio rosła
	var/last_growth
	/// Larwa zginęła (wycięta albo otruta) i już nie urośnie
	var/dead = FALSE

/obj/item/organ/body_egg/aquila_hex_larva/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	// rdzeniowe jajo daje odporność na przytulacze jak embrion obcego; larwa jej nie daje (HUD medyczny zostaje)
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_XENO_IMMUNE, "xeno immune")
	last_growth = world.time

/obj/item/organ/body_egg/aquila_hex_larva/Remove(mob/living/carbon/M, special = 0)
	if(!special)
		dead = TRUE
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/organ/body_egg/aquila_hex_larva/on_find(mob/living/finder)
	. = ..()
	to_chat(finder, "<span class='warning'>Larwa wije się między narządami. [grown_time >= hatch_time / 2 ? "Jest już duża i niespokojna." : "Jest jeszcze mała."]</span>")

/obj/item/organ/body_egg/aquila_hex_larva/aq_scan_line()
	if(dead)
		return null
	return "<b>Pasożyt w klatce piersiowej:</b> rosnąca larwa obcych ([round(grown_time / hatch_time * 100)]%). Operacja na organach klatki piersiowej albo co najmniej 2 j. środka na szkodniki we krwi."

/obj/item/organ/body_egg/aquila_hex_larva/egg_process()
	// czas od ostatniego wzrostu; przerwa w Life() żywiciela (staza) liczy się najwyżej jako jeden krok
	var/elapsed = clamp(world.time - last_growth, 0, max_growth_step)
	last_growth = world.time
	if(dead || !owner || owner.stat == DEAD || owner.IsInStasis())
		return
	if(owner.reagents?.has_reagent(/datum/reagent/toxin/pestkiller, 2))
		kill_larva()
		return
	grown_time += elapsed
	if(grown_time >= hatch_time)
		hatch()
		return
	if(grown_time > hatch_time * 0.5 && prob(4))
		to_chat(owner, "<span class='danger'>Coś wierci się w twojej klatce piersiowej!</span>")
		owner.adjustBruteLoss(1)
	else if(prob(3))
		to_chat(owner, "<span class='warning'>Czujesz dziwne łaskotanie pod mostkiem.</span>")

/// Środek na szkodniki zabija larwę w ciele; zwraca TRUE
/obj/item/organ/body_egg/aquila_hex_larva/proc/kill_larva()
	var/mob/living/carbon/host = owner
	to_chat(host, "<span class='notice'>Coś w twojej klatce piersiowej wierci się coraz słabiej i w końcu nieruchomieje.</span>")
	Remove(host)
	qdel(src)
	return TRUE

/// Larwa wychodzi z ciała jako pomiot; zwraca pomiot
/obj/item/organ/body_egg/aquila_hex_larva/proc/hatch()
	var/mob/living/carbon/host = owner
	var/turf/spot = get_turf(host)
	Remove(host)
	host.apply_damage(25, BRUTE, BODY_ZONE_CHEST)
	var/mob/living/basic/aquila_hex_broodling/brood = new(spot)
	host.visible_message("<span class='danger'>Z klatki piersiowej [host] wyrywa się [brood]!</span>", \
		"<span class='userdanger'>Coś rozrywa ci klatkę piersiową od środka!</span>")
	playsound(spot, 'sound/effects/splat.ogg', 60, TRUE)
	qdel(src)
	return brood
