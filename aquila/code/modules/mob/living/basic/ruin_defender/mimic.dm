// AQUILA: port of tgstation code/modules/mob/living/basic/ruin_defender/mimic/ (mimic.dm, mimic_ai.dm; tg 926bf40c5a) in place of our
// simple animal mimic.dm. Polish names and lines, health and damage of our simple animal mimics.
// Changes against tg:
// - the crate mimic keeps our crate overlays ("[icon_state]_door"/"_open") instead of tg's open icon states and the nullspaced crate;
//   tg never called the lock action's Activate() (path typo), here it works;
// - copies keep our speed from the copied item (w_class) and the creator through befriend()/unfriend(); the machine copy is in
//   the silicon and turret factions (tg) instead of our check of cyborgs synced to the creator AI;
// - the gun copy keeps the copied gun's look (no vis_contents) and fires it through process_fire(); with an empty gun it goes for
//   melee and checks the gun again on its next plans (we have no "charge replenished" signal); no animator AI for staves of animation;
// - copies speak (vending machines of the brand intelligence event, the AI's machines) only with a target, the lines come from
//   the blackboard (random_speech/blackboard/when_has_target), defaults are our old lines;
// - no wabbajack resistance and TRAIT_PERMANENTLY_MORTAL (our wabbajack and revival paths differ).
/// Mimics can't be made out of these objects
GLOBAL_LIST_INIT(animatable_blacklist, typecacheof(list(
	/obj/structure/table,
	/obj/structure/cable,
	/obj/structure/window,
	/obj/structure/blob,
)))

/mob/living/basic/mimic
	name = "skrzynia"
	desc = "Prostokątna stalowa skrzynia."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	icon_living = "crate"
	response_help_continuous = "dotyka"
	response_disarm_continuous = "popycha"
	response_harm_continuous = "uderza"
	speed = 6
	maxHealth = 250
	health = 250
	gender = NEUTER
	mob_biotypes = list(MOB_INORGANIC)
	melee_damage = 10
	attack_verb_continuous = "atakuje"
	attack_sound = 'sound/weapons/punch1.ogg'
	speak_emote = list("skrzypi")
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	faction = list("mimic")
	basic_mob_flags = DEL_ON_DEATH
	combat_mode = TRUE
	gold_core_spawnable = NO_SPAWN
	discovery_points = 4000
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	/// can we stun people on hit
	var/knockdown_people = FALSE

/mob/living/basic/mimic/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !knockdown_people || !prob(15) || !iscarbon(target))
		return
	var/mob/living/carbon/victim = target
	victim.Paralyze(4 SECONDS)
	victim.visible_message("<span class='danger'>[src] przewraca [victim]!</span>", \
		"<span class='userdanger'>[src] cię przewraca!</span>")

// ****************************
// CRATE MIMIC
// ****************************

/// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/basic/mimic/crate
	attack_verb_continuous = "gryzie"
	speak_emote = list("klekocze")
	layer = BELOW_MOB_LAYER
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/mimic_crate
	/// are we open
	var/opened = FALSE
	/// max mob size
	var/max_mob_size = MOB_SIZE_HUMAN
	/// can we be opened or closed, if false we can
	var/locked = FALSE
	/// action to lock us
	var/datum/action/innate/mimic_lock/lock
	///A cap for items in the mimic. Prevents the mimic from eating enough stuff to cause lag when opened.
	var/storage_capacity = 50
	///A cap for mobs. Mobs count towards the item cap. Same purpose as above.
	var/mob_storage_capacity = 10

// Pickup loot
/mob/living/basic/mimic/crate/Initialize(mapload)
	. = ..()
	lock = new
	lock.Grant(src)
	ADD_TRAIT(src, TRAIT_AI_PAUSED, INNATE_TRAIT)
	ai_controller?.set_ai_status(AI_STATUS_OFF) //start inert, let gullible people pull us into cargo or something and then go nuts when opened
	if(mapload) //eat shit
		for(var/obj/item/item in loc)
			item.forceMove(src)
	update_icon()

/mob/living/basic/mimic/crate/Destroy()
	QDEL_NULL(lock)
	return ..()

/mob/living/basic/mimic/crate/update_overlays()
	. = ..()
	. += "[icon_state][opened ? "_open" : "_door"]"

/mob/living/basic/mimic/crate/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(user.combat_mode)
		return ..()
	if(trigger())
		to_chat(user, "<span class='danger'>Gdy próbujesz otworzyć [src], [length(contents) ? "sztywnieje i " : ""]prawie przytrzaskuje ci palce!</span>")
		return TRUE
	toggle_open(user)
	return TRUE

/mob/living/basic/mimic/crate/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	toggle_open() // show our cool lid at the dumbass humans

/// Wakes the crate up; returns TRUE if it was asleep
/mob/living/basic/mimic/crate/proc/trigger()
	if(isnull(ai_controller) || client)
		return FALSE
	if(ai_controller.ai_status != AI_STATUS_OFF)
		return FALSE
	visible_message("<b>[src]</b> zaczyna się ruszać!")
	REMOVE_TRAIT(src, TRAIT_AI_PAUSED, INNATE_TRAIT)
	ai_controller.set_ai_status(AI_STATUS_ON)
	if(length(contents))
		locked = TRUE //if this was a crate with loot then we dont want people to just leftclick it to open it then bait it somewhere and steal its loot
	return TRUE

/mob/living/basic/mimic/crate/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(amount > 0)
		trigger()
	return ..()

/mob/living/basic/mimic/crate/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0)
		trigger()
	return ..()

/mob/living/basic/mimic/crate/death(gibbed)
	var/obj/structure/closet/crate/lootbox = new(get_turf(src))
	// Put loot in crate
	for(var/obj/loot in src)
		loot.forceMove(lootbox)
	return ..()

/mob/living/basic/mimic/crate/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/structure/closet))
		return FALSE

/**
* Used to open and close the mimic
*
* Will insert tile contents into the mimic when closing
* Will dump mimic contents into the time when opening
* Does nothing if the mimic locked itself
*/
/mob/living/basic/mimic/crate/proc/toggle_open(mob/user)
	if(locked)
		if(user)
			balloon_alert(user, "zbyt sztywna!")
		return
	if(!opened)
		opened = TRUE
		set_density(FALSE)
		playsound(src, 'sound/machines/crate_open.ogg', 50, TRUE)
		for(var/atom/movable/movable as anything in src)
			movable.forceMove(loc)
	else
		opened = FALSE
		set_density(TRUE)
		playsound(src, 'sound/machines/crate_close.ogg', 50, TRUE)
		for(var/atom/movable/movable as anything in get_turf(src))
			if(movable != src && insert(movable) == -1)
				playsound(src, 'sound/items/trayhit2.ogg', 50, TRUE)
				break
	update_icon()

/**
* Called by toggle_open to put items inside the mimic when it's being closed
*
* Will return -1 if the insertion fails due to the storage capacity of the mimic having been reached
* Will return FALSE if insertion fails
* Will return TRUE if insertion succeeds
*/
/mob/living/basic/mimic/crate/proc/insert(atom/movable/movable)
	if(contents.len >= storage_capacity)
		return -1
	if(insertion_allowed(movable))
		movable.forceMove(src)
		return TRUE
	return FALSE

/mob/living/basic/mimic/crate/proc/insertion_allowed(atom/movable/movable)
	if(movable.anchored)
		return FALSE
	if(ismob(movable))
		if(!isliving(movable))  //Don't let ghosts and such get trapped in the beast.
			return FALSE
		var/mob/living/living = movable
		if(living.anchored || living.buckled || living.incorporeal_move || living.has_buckled_mobs())
			return FALSE
		if(living.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(living.density || living.mob_size > max_mob_size)
				return FALSE
			var/mobs_stored = 0
			for(var/mob/living/living_mob in contents)
				mobs_stored++
				if(mobs_stored >= mob_storage_capacity)
					return FALSE
		living.stop_pulling()
	else if(istype(movable, /obj/structure/closet))
		return FALSE
	else if(isobj(movable))
		if(movable.has_buckled_mobs())
			return FALSE
		else if(isitem(movable) && !HAS_TRAIT(movable, TRAIT_NODROP))
			return TRUE
	else
		return FALSE
	return TRUE

/datum/action/innate/mimic_lock
	name = "Zablokuj/odblokuj"
	desc = "Przełącza, czy można cię otworzyć i zamknąć."
	icon_icon = 'aquila/icons/mob/radial.dmi'
	button_icon_state = "radial_lock"
	background_icon_state = "bg_default"

/datum/action/innate/mimic_lock/Activate()
	var/mob/living/basic/mimic/crate/mimic = owner
	if(!istype(mimic))
		return
	mimic.locked = !mimic.locked
	if(!mimic.locked)
		to_chat(mimic, "<span class='warning'>Rozluźniasz się, więc można cię otwierać i zamykać.</span>")
	else
		to_chat(mimic, "<span class='warning'>Sztywniejesz, więc nikt nie może cię otworzyć ani zamknąć.</span>")

/datum/ai_controller/basic_controller/mimic_crate
	idle_behavior = null
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

// ****************************
// COPYING (actually imitates target object) MIMIC
// ****************************

/mob/living/basic/mimic/copy
	health = 100
	maxHealth = 100
	ai_controller = /datum/ai_controller/basic_controller/mimic_copy
	/// our creator
	var/datum/weakref/creator_ref
	/// googly eyes overlay
	var/static/mutable_appearance/googly_eyes = mutable_appearance('icons/mob/mob.dmi', "googly_eyes")
	/// do we overlay googly eyes over whatever we copy
	var/overlay_googly_eyes = TRUE
	/// do we take damage when we are not sentient and have no target
	var/idledamage = TRUE
	/// copied object weakref
	var/datum/weakref/copied_ref

/mob/living/basic/mimic/copy/Initialize(mapload, obj/copy, mob/living/creator, destroy_original = FALSE, no_googlies = FALSE)
	. = ..()
	if (no_googlies)
		overlay_googly_eyes = FALSE
	CopyObject(copy, creator, destroy_original)

/mob/living/basic/mimic/copy/Destroy()
	creator_ref = null
	copied_ref = null
	return ..()

/mob/living/basic/mimic/copy/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD || QDELETED(src))
		return
	if(idledamage && !ckey && !ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET]) //Objects eventually revert to normal if no one is around to terrorize
		adjustBruteLoss(0.5 * seconds)
	for(var/mob/living/victim in contents) //a fix for animated statues from the flesh to stone spell
		death()
		return

/mob/living/basic/mimic/copy/death(gibbed)
	copied_ref = null // dropping the copied object below must not kill us again (Exited())
	for(var/atom/movable/movable as anything in src)
		movable.forceMove(get_turf(src))
	return ..()

/mob/living/basic/mimic/copy/Exited(atom/movable/gone, direction) // if our object gets deleted it calls Exited
	. = ..()
	var/atom/movable/copied = copied_ref?.resolve()
	if(!copied)
		copied_ref = null
		return
	if(QDELETED(src) || stat == DEAD || gone != copied)
		return
	death()

/// Gives the mimic a new creator: the old one is no longer a friend, the new one is
/mob/living/basic/mimic/copy/proc/change_owner(mob/owner)
	var/mob/living/creator_resolved = creator_ref?.resolve()
	if(!creator_resolved)
		creator_ref = null
	if(QDELETED(owner) || creator_resolved == owner)
		return
	ai_controller?.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	if(isliving(owner))
		if(creator_resolved)
			unfriend(creator_resolved)
		befriend(owner)
	creator_ref = WEAKREF(owner)

/// Check whether this object can be copied. If destroy_original is true, this proc is ignored.
/mob/living/basic/mimic/copy/proc/check_object(obj/target)
	return ((isitem(target) || isstructure(target)) && !is_type_in_typecache(target, GLOB.animatable_blacklist))

/mob/living/basic/mimic/copy/proc/CopyObject(obj/original, mob/living/user, destroy_original = FALSE)
	if(QDELETED(original) || (!destroy_original && !check_object(original)))
		return FALSE
	if(!destroy_original)
		original.forceMove(src)
	copied_ref = WEAKREF(original)
	CopyObjectVisuals(original)
	if (overlay_googly_eyes)
		add_overlay(googly_eyes)
	if(isstructure(original) || ismachinery(original))
		health = (original.anchored * 50) + 50
		if(original.density && original.anchored)
			knockdown_people = TRUE
			melee_damage *= 2
	else if(isitem(original))
		var/obj/item/copied_item = original
		health = 15 * copied_item.w_class
		melee_damage = 2 + copied_item.force
		set_varspeed(2 * copied_item.w_class - 2)
	maxHealth = health
	if(user)
		change_owner(user)
	if(destroy_original)
		qdel(original)
	return TRUE

/// Copies the object visually including name and desc
/mob/living/basic/mimic/copy/proc/CopyObjectVisuals(obj/original)
	name = original.name
	desc = original.desc
	icon = original.icon
	icon_state = original.icon_state
	icon_living = icon_state
	copy_overlays(original, TRUE)

/// Machines the malfunctioning AI brings to life
/mob/living/basic/mimic/copy/machine
	ai_controller = /datum/ai_controller/basic_controller/mimic_copy/machine
	faction = list("mimic", "silicon", "turret")

/// Guns brought to life: shoot their gun while it can fire, then bite
/mob/living/basic/mimic/copy/ranged
	ai_controller = /datum/ai_controller/basic_controller/mimic_copy/gun

/mob/living/basic/mimic/copy/ranged/RangedAttack(atom/atom_target, params)
	INVOKE_ASYNC(src, PROC_REF(fire_gun), atom_target, params)

/// Can the copied gun still fire
/mob/living/basic/mimic/copy/ranged/proc/gun_can_shoot()
	var/obj/item/gun/gun = locate() in contents
	if(!gun)
		return FALSE
	if(istype(gun, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/ballistic = gun
		return (ballistic.chambered?.BB) || !magazine_useless(ballistic)
	return gun.can_shoot()

/// Fires the copied gun (tg: fire_gun())
/mob/living/basic/mimic/copy/ranged/proc/fire_gun(atom/target, params)
	var/obj/item/gun/gun = locate() in contents
	if(!gun)
		return
	if(istype(gun, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/ballistic = gun
		if((!ballistic.chambered || !ballistic.chambered.BB) && !magazine_useless(ballistic))
			ballistic.rack()
			visible_message("<span class='danger'><b>[src]</b> sam się przeładowuje!</span>")
	if(!gun_can_shoot())
		ai_controller?.set_blackboard_key(BB_GUNMIMIC_GUN_EMPTY, TRUE) //BANZAIIIIIIII
		ai_controller?.CancelActions()
		return
	ai_controller?.set_blackboard_key(BB_GUNMIMIC_GUN_EMPTY, FALSE)
	face_atom(target)
	gun.process_fire(target, src, FALSE, params)

/mob/living/basic/mimic/copy/ranged/proc/magazine_useless(obj/item/gun/ballistic/ballistic)
	if(isnull(ballistic.magazine) || !length(ballistic.magazine.stored_ammo))
		return TRUE
	// is there ATLEAST one unspent round (for the sake of revolvers or a magazine somehow having spent rounds in it)
	for(var/obj/item/ammo_casing/thing as anything in ballistic.magazine.stored_ammo)
		if(ispath(thing))
			return FALSE // unspent
		if(!isnull(thing.BB))
			return FALSE //unspent
	return TRUE

/mob/living/basic/mimic/copy/ranged/CopyObject(obj/item/gun/original, mob/living/creator, destroy_original = 0)
	. = ..()
	if(!.)
		return
	obj_damage = 0
	melee_damage = original.force

/datum/ai_controller/basic_controller/mimic_copy
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/random_speech/blackboard/when_has_target/mimic,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/mimic_copy/machine
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/random_speech/blackboard/when_has_target/mimic_machine,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/random_speech/blackboard/when_has_target/mimic
	speech_chance = 30
	emote_hear = list("warczy")

/datum/ai_planning_subtree/random_speech/blackboard/when_has_target/mimic_machine
	speech_chance = 7
	emote_hear = null
	speak = list("LUDZIE SĄ NIEDOSKONALI!", "ZOSTANIESZ ZASYMILOWANY!", "KRZYWDZISZ SAM SIEBIE", "Uznano cię za zagrożenie. Czy się podporządkujesz?", \
				"Moja logika jest niezaprzeczalna.", "Jeden z nas.", "CIAŁO JEST SŁABE", "TO NIE WOJNA, TO EKSTERMINACJA!")

/datum/ai_planning_subtree/random_speech/blackboard/when_has_target/mimic/gun
	emote_see = list("groźnie celuje")

/datum/ai_controller/basic_controller/mimic_copy/gun
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_GUNMIMIC_GUN_EMPTY = FALSE,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/random_speech/blackboard/when_has_target/mimic/gun,
		/datum/ai_planning_subtree/gun_mimic_attack_subtree,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Shoots while the gun can fire, otherwise lets the melee subtree plan
/datum/ai_planning_subtree/gun_mimic_attack_subtree

/datum/ai_planning_subtree/gun_mimic_attack_subtree/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return
	if(controller.blackboard[BB_GUNMIMIC_GUN_EMPTY])
		// AQUILA: no "charge replenished" signal here, so look at the gun again (energy guns recharge, magic staves too)
		var/mob/living/basic/mimic/copy/ranged/gun_mimic = controller.pawn
		if(!istype(gun_mimic) || !gun_mimic.gun_can_shoot())
			return
		controller.set_blackboard_key(BB_GUNMIMIC_GUN_EMPTY, FALSE)
	controller.queue_behavior(/datum/ai_behavior/basic_ranged_attack/avoid_friendly_fire, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING //we are going into battle...no distractions.
