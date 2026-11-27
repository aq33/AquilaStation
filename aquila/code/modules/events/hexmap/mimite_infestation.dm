// AQUILA - Plaga mimitów: z wentylacji wychodzą 3-4 mimity, które udają leżące obok przedmioty, rzucają się na tych, którzy je podniosą albo podejdą, i co kilka minut się powielają, ale nigdy ponad twardy limit (port z BeeStation/BeeStation-Hornet code/modules/events/mimite_infestation.dm i code/modules/mob/living/simple_animal/hostile/mimite.dm)
// Bee's simple animal mimites copy any nearby object, ambush whoever touches them with knockdown and morph venom,
// crawl through vents and replicate 3-5 times each (also into ranged and crate mimites) until the event ends after an
// hour. Ours is a basic mob with Bee's sprite: it copies only loose items (and drops the disguise when the copied item
// is gone; its own look is saved before the disguise and restored whole), ambushes with knockdown and 5 u of morph
// venom, and replicates every ~3 minutes while its own count lasts (2 for the first ones, one less for each generation).
// On top of that no more than 12 mimites can ever exist in a round (GLOB.aquila_hex_mimites_made), so the plague has
// a hard ceiling. No vent crawling (it walks), no ranged or crate mimites, no mimite HUD. The crew is warned after
// 3.5-4 minutes, only if a mimite is still alive.

/// Najwięcej mimitów, które mogą powstać w jednej rundzie (z eventu i z powielania razem)
#define AQUILA_HEX_MIMITE_CAP 12

/// Ile mimitów powstało w tej rundzie
GLOBAL_VAR_INIT(aquila_hex_mimites_made, 0)

/datum/round_event_control/aquila_hex_mimite_infestation
	name = "Plaga mimitów"
	typepath = /datum/round_event/aquila_hex_mimite_infestation
	weight = 8
	min_players = 20
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/aquila_hex_mimite_infestation
	fakeable = FALSE
	startWhen = 1
	announceWhen = 100
	/// Słabe referencje do pierwszych mimitów
	var/list/mimites = list()

/datum/round_event/aquila_hex_mimite_infestation/setup()
	announceWhen = rand(100, 125)

/datum/round_event/aquila_hex_mimite_infestation/start()
	var/list/spawned = spawn_mimites(aquila_hex_vent_turfs(), prob(50) ? 4 : 3)
	if(!length(spawned))
		log_game("Mimite Infestation: no open vents on the ship or the mimite cap is reached, cancelling the event.")
		return kill()
	var/mob/living/first = spawned[1]
	announce_to_ghosts(first)
	message_admins("Plaga mimitów: z wentylacji wychodzi [length(spawned)] mimitów, np. w [ADMIN_VERBOSEJMP(first)].")
	log_game("Mimite Infestation: [length(spawned)] mimites spawned from the vents.")

/datum/round_event/aquila_hex_mimite_infestation/announce(fake)
	var/alive = FALSE
	for(var/mob/living/basic/aquila_mimite/mimite as anything in GLOB.aquila_hex_mimites)
		if(mimite.stat != DEAD)
			alive = TRUE
			break
	if(alive)
		priority_announce("Na pokład dostały się niezidentyfikowane formy życia, które potrafią udawać przedmioty. Uważajcie na rzeczy leżące tam, gdzie ich wcześniej nie było, i zabezpieczcie kratki wentylacyjne.", "Alarm biologiczny", ANNOUNCER_ALIENS)

/datum/round_event/aquila_hex_mimite_infestation/kill()
	mimites = null
	return ..()

/// Stawia do count mimitów przy wentylacjach (po jednym przy każdej, w granicach limitu), zwraca listę mimitów
/datum/round_event/aquila_hex_mimite_infestation/proc/spawn_mimites(list/turfs, count)
	count = min(count, AQUILA_HEX_MIMITE_CAP - GLOB.aquila_hex_mimites_made)
	if(count <= 0)
		return list()
	. = aquila_hex_spawn_on_turfs(turfs, count, /mob/living/basic/aquila_mimite, 1, "%MOB wypełza z kratki wentylacyjnej!")
	for(var/mob/living/basic/aquila_mimite/mimite as anything in .)
		LAZYADD(mimites, WEAKREF(mimite))

/// Żywe mimity
GLOBAL_LIST_EMPTY(aquila_hex_mimites)

/**
 * Mimita: czarna, zmiennokształtna masa, która udaje leżące obok przedmioty i rzuca się na ofiary.
 */
/mob/living/basic/aquila_mimite
	name = "mimita"
	desc = "Stworzenie nieznanego pochodzenia. Lubi udawać coś zwyczajnego i czekać na ofiarę."
	icon = 'aquila/icons/mob/plagues/plagues.dmi'
	icon_state = "mimite"
	icon_living = "mimite"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC)
	maxHealth = 50
	health = 50
	speed = 1
	melee_damage = 10
	armour_penetration = 10
	attack_verb_continuous = "chlasta"
	attack_sound = 'sound/effects/splat.ogg'
	response_help_continuous = "szturcha"
	response_disarm_continuous = "odpycha"
	response_harm_continuous = "uderza"
	speak_emote = list("szczebiocze")
	death_message = "rozpryskuje się w kałużę czarnej mazi!"
	basic_mob_flags = DEL_ON_DEATH
	pass_flags = PASSTABLE
	combat_mode = TRUE
	see_in_dark = 8
	faction = list("mimic")
	gold_core_spawnable = NO_SPAWN
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	ai_controller = /datum/ai_controller/basic_controller/aquila_mimite
	/// Przedmiot, który mimita teraz udaje
	var/datum/weakref/form_ref
	/// Własny wygląd mimity zapisany przed przebraniem
	var/mutable_appearance/own_appearance
	/// Ile razy ta mimita może się jeszcze powielić
	var/remaining_replications = 2
	/// Postęp do następnego powielenia (powiela się przy 350)
	var/growth = 0
	COOLDOWN_DECLARE(disguise_cooldown)

/mob/living/basic/aquila_mimite/Initialize(mapload)
	. = ..()
	GLOB.aquila_hex_mimites += src
	GLOB.aquila_hex_mimites_made++
	AddElement(/datum/element/ai_retaliate)
	COOLDOWN_START(src, disguise_cooldown, 6 SECONDS)

/mob/living/basic/aquila_mimite/Destroy()
	GLOB.aquila_hex_mimites -= src
	var/obj/item/form = form_ref?.resolve()
	if(form)
		UnregisterSignal(form, COMSIG_PARENT_QDELETING)
	form_ref = null
	own_appearance = null
	return ..()

/mob/living/basic/aquila_mimite/death(gibbed)
	var/turf/spot = get_turf(src)
	if(spot)
		new /obj/effect/decal/cleanable/oil(spot)
	return ..()

/mob/living/basic/aquila_mimite/examine(mob/user)
	var/obj/item/form = form_ref?.resolve()
	if(QDELETED(form))
		return ..()
	. = form.examine(user)
	if(get_dist(user, src) <= 2)
		. += "<span class='warning'>Coś tu nie gra...</span>"

/mob/living/basic/aquila_mimite/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD || QDELETED(src))
		return
	var/has_target = !isnull(ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
	if(form_ref && has_target)
		restore()
	else if(!form_ref && !has_target && !client && COOLDOWN_FINISHED(src, disguise_cooldown))
		disguise()
	if(isturf(loc))
		growth += rand(1, 6)
		if(growth >= 350)
			growth = 0
			replicate()

/// Przedmioty, które mimita może udawać
/mob/living/basic/aquila_mimite/proc/can_copy(obj/item/target)
	return istype(target) && isturf(target.loc) && !target.anchored && !(target.item_flags & ABSTRACT) && target.invisibility < INVISIBILITY_OBSERVER

/// Udaje losowy przedmiot leżący w pobliżu; zwraca TRUE, gdy udaje
/mob/living/basic/aquila_mimite/proc/disguise(obj/item/target)
	if(!target)
		var/list/options = list()
		for(var/obj/item/candidate in view(3, src))
			if(can_copy(candidate))
				options += candidate
		if(!length(options))
			return FALSE
		target = pick(options)
	if(!can_copy(target))
		return FALSE
	form_ref = WEAKREF(target)
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_form_deleted))
	visible_message("<span class='warning'>[src] nagle wykręca się i zmienia kształt, stając się kopią [target]!</span>")
	own_appearance = new(src)
	appearance = target.appearance
	transform = initial(transform)
	pixel_x = base_pixel_x
	pixel_y = base_pixel_y
	alpha = max(alpha, 150)
	density = FALSE
	ai_controller?.set_blackboard_key(BB_AGGRO_RANGE, 1)
	COOLDOWN_START(src, disguise_cooldown, 6 SECONDS)
	return TRUE

/// Wraca do swojej postaci; zwraca TRUE, gdy coś udawała
/mob/living/basic/aquila_mimite/proc/restore()
	if(!form_ref)
		return FALSE
	var/obj/item/form = form_ref.resolve()
	if(form)
		UnregisterSignal(form, COMSIG_PARENT_QDELETING)
	form_ref = null
	if(own_appearance)
		appearance = own_appearance
		own_appearance = null
	density = initial(density)
	visible_message("<span class='warning'>[src] nagle zapada się w sobie i staje się falującą czarną masą!</span>")
	ai_controller?.set_blackboard_key(BB_AGGRO_RANGE, 4)
	COOLDOWN_START(src, disguise_cooldown, 10 SECONDS)
	return TRUE

/// Udawany przedmiot zniknął: mimita zrzuca przebranie
/mob/living/basic/aquila_mimite/proc/on_form_deleted(datum/source)
	SIGNAL_HANDLER
	restore()

/// Zasadzka: kto dotknie przebranej mimity, zostaje przewrócony i ukąszony
/mob/living/basic/aquila_mimite/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!form_ref || !istype(user))
		return ..()
	ambush(user)
	return TRUE

/// Rzuca się z przebrania na ofiarę; zwraca TRUE
/mob/living/basic/aquila_mimite/proc/ambush(mob/living/carbon/victim)
	restore()
	victim.Knockdown(4 SECONDS)
	victim.reagents?.add_reagent(/datum/reagent/toxin/morphvenom, 5)
	victim.visible_message("<span class='danger'>[src] gwałtownie gryzie [victim]!</span>", "<span class='userdanger'>[src] cię gryzie!</span>")
	playsound(src, 'sound/weapons/bite.ogg', 50, TRUE)
	ai_controller?.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	return TRUE

/mob/living/basic/aquila_mimite/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	restore()
	return ..()

/// Powiela się w granicach własnego licznika i limitu rundy; zwraca nową mimitę albo null
/mob/living/basic/aquila_mimite/proc/replicate()
	if(remaining_replications <= 0 || GLOB.aquila_hex_mimites_made >= AQUILA_HEX_MIMITE_CAP || stat == DEAD || !isturf(loc))
		return null
	remaining_replications--
	var/mob/living/basic/aquila_mimite/child = new type(loc)
	child.remaining_replications = remaining_replications
	child.visible_message("<span class='warning'>Od [src] odrywa się kawałek czarnej mazi i formuje nową mimitę!</span>")
	playsound(child, 'sound/effects/splat.ogg', 50, TRUE)
	return child

/datum/ai_controller/basic_controller/aquila_mimite
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 4,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/aquila_mimite
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Przebrana mimita stoi w miejscu jak zwykły przedmiot
/datum/idle_behavior/idle_random_walk/aquila_mimite

/datum/idle_behavior/idle_random_walk/aquila_mimite/perform_idle_behavior(delta_time, datum/ai_controller/controller)
	var/mob/living/basic/aquila_mimite/mimite = controller.pawn
	if(istype(mimite) && mimite.form_ref)
		return
	return ..()

#undef AQUILA_HEX_MIMITE_CAP
