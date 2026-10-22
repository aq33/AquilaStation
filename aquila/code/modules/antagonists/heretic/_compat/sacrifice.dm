// AQUILA - zgodność dla systemu ofiar heretyka (sacrifice_knowledge/*, items/corrupted_organs.dm).
// Elementy z tg dodane pod tymi samymi ścieżkami i z tym samym API, przepięte na nasze sygnały.

#ifndef COMSIG_ORGAN_IMPLANTED
/// Called on the organ when it is implanted into someone (mob/living/carbon/receiver)
#define COMSIG_ORGAN_IMPLANTED "organ_implanted"
#endif
#ifndef COMSIG_ORGAN_SURGICALLY_REMOVED
/// Called when an organ gets surgically removed (mob/living/user, mob/living/carbon/old_owner, target_zone, obj/item/tool)
#define COMSIG_ORGAN_SURGICALLY_REMOVED "organ_surgically_removed"
#endif
#ifndef TRAIT_RELAYING_ATTACKER
/// Mob has the relay_attackers element applied
#define TRAIT_RELAYING_ATTACKER "relaying_attacker"
#endif
#ifndef ATTACKER_STAMINA_ATTACK
#define ATTACKER_STAMINA_ATTACK (1<<0)
#endif
#ifndef ATTACKER_SHOVING
#define ATTACKER_SHOVING (1<<1)
#endif
#ifndef ATTACKER_DAMAGING_ATTACK
#define ATTACKER_DAMAGING_ATTACK (1<<2)
#endif
#ifndef ATTACK_RANGED
#define ATTACK_RANGED (1<<3)
#endif

/// Indeks języka w argumentach /mob/living/say() (u nas SPEECH_LANGUAGE jest zakomentowany)
#define SACRIFICE_SAY_LANGUAGE_ARG 5

// ---------------------------------------------------------------------------
// Cele ofiarne
// ---------------------------------------------------------------------------

/// tg: umysły załogi z manifestu (u nas GLOB.data_core.locked)
/proc/get_crewmember_minds()
	var/list/minds = list()
	for(var/datum/data/record/record as anything in GLOB.data_core.locked)
		var/datum/mind/mind = record.fields["mindref"]
		if(mind)
			minds += mind
	return minds

/// Listy działów (GLOB.*_positions), do których należy dana praca - zamiast departments_bitflags z tg
/proc/heretic_job_departments(job_title)
	. = list()
	if(!job_title)
		return
	var/list/departments = list(
		"command" = GLOB.command_positions,
		"security" = GLOB.security_positions,
		"engineering" = GLOB.engineering_positions,
		"medical" = GLOB.medical_positions,
		"science" = GLOB.science_positions,
		"supply" = GLOB.supply_positions,
		"civilian" = GLOB.civilian_positions,
		"munitions" = GLOB.munitions_positions,
	)
	for(var/department in departments)
		if(job_title in departments[department])
			. += department

// ---------------------------------------------------------------------------
// relay_attackers (tg) - jeden sygnał „ktoś mnie zaatakował”
// ---------------------------------------------------------------------------

/**
 * This element registers to a shitload of signals which can signify "someone attacked me".
 * If anyone does it sends a single "someone attacked me" signal containing details about who done it.
 * This prevents other components and elements from having to register to the same list of a million signals, should be more maintainable in one place.
 */
/datum/element/relay_attackers

/datum/element/relay_attackers/Attach(datum/target)
	. = ..()
	if (!HAS_TRAIT(target, TRAIT_RELAYING_ATTACKER)) // Little bit gross but we want to just apply this shit from a bunch of places
		// AQUILA - nasze odpowiedniki sygnałów tg
		RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(after_attackby))
		RegisterSignals(target, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_MOB_ATTACK_ALIEN), PROC_REF(on_attack_generic))
		RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_attack_secondary))
		RegisterSignal(target, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(on_attack_npc))
		RegisterSignal(target, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
		RegisterSignal(target, COMSIG_ATOM_HITBY, PROC_REF(on_hitby))
		RegisterSignal(target, COMSIG_ATOM_HULK_ATTACK, PROC_REF(on_attack_hulk))
	ADD_TRAIT(target, TRAIT_RELAYING_ATTACKER, REF(src))

/datum/element/relay_attackers/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_MOB_ATTACK_ALIEN,
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_HITBY,
		COMSIG_ATOM_HULK_ATTACK,
	))
	REMOVE_TRAIT(source, TRAIT_RELAYING_ATTACKER, REF(src))

/datum/element/relay_attackers/proc/after_attackby(atom/target, obj/item/weapon, mob/attacker, params)
	SIGNAL_HANDLER
	if(!istype(weapon) || !ismob(attacker))
		return
	if(weapon.force)
		relay_attacker(target, attacker, weapon.damtype == STAMINA ? ATTACKER_STAMINA_ATTACK : ATTACKER_DAMAGING_ATTACK, get_dir(target, attacker))

/datum/element/relay_attackers/proc/on_attack_generic(atom/target, mob/living/attacker, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(attacker))
		return

	// Check for a shove.
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		relay_attacker(target, attacker, ATTACKER_SHOVING, get_dir(target, attacker))
		return

	// Else check for combat mode.
	if(attacker.combat_mode)
		relay_attacker(target, attacker, ATTACKER_DAMAGING_ATTACK, get_dir(target, attacker))
		return

/// AQUILA - u nas popchnięcie (prawy przycisk) ma osobny sygnał
/datum/element/relay_attackers/proc/on_attack_secondary(atom/target, mob/living/attacker, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(attacker))
		return
	relay_attacker(target, attacker, ATTACKER_SHOVING, get_dir(target, attacker))

/datum/element/relay_attackers/proc/on_attack_npc(atom/target, mob/living/simple_animal/attacker)
	SIGNAL_HANDLER
	if(!istype(attacker))
		return
	if(attacker.melee_damage > 0)
		relay_attacker(target, attacker, ATTACKER_DAMAGING_ATTACK, get_dir(target, attacker))

/// Even if another component blocked this hit, someone still shot at us
/datum/element/relay_attackers/proc/on_bullet_act(atom/target, obj/item/projectile/hit_projectile, def_zone)
	SIGNAL_HANDLER
	if(!istype(hit_projectile) || hit_projectile.nodamage)
		return
	if(!ismob(hit_projectile.firer))
		return
	relay_attacker(target, hit_projectile.firer, ATTACK_RANGED | (hit_projectile.damage_type == STAMINA ? ATTACKER_STAMINA_ATTACK : ATTACKER_DAMAGING_ATTACK), get_dir(target, hit_projectile))

/// Even if another component blocked this hit, someone still threw something
/datum/element/relay_attackers/proc/on_hitby(atom/target, atom/movable/hit_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!isitem(hit_atom))
		return
	var/obj/item/hit_item = hit_atom
	if(!hit_item.throwforce)
		return
	var/atom/thrown_by = throwingdatum?.thrower
	if(!istype(thrown_by))
		return
	relay_attacker(target, thrown_by, ATTACK_RANGED | (hit_item.damtype == STAMINA ? ATTACKER_STAMINA_ATTACK : ATTACKER_DAMAGING_ATTACK), get_dir(target, hit_atom))

/datum/element/relay_attackers/proc/on_attack_hulk(atom/target, mob/attacker)
	SIGNAL_HANDLER
	relay_attacker(target, attacker, ATTACKER_DAMAGING_ATTACK, get_dir(target, attacker))

/// Send out a signal identifying whoever just attacked us (usually a mob but sometimes a mech or turret)
/datum/element/relay_attackers/proc/relay_attacker(atom/victim, atom/attacker, attack_flags, direction)
	SEND_SIGNAL(victim, COMSIG_ATOM_WAS_ATTACKED, attacker, attack_flags, direction)

// Sygnały COMSIG_ORGAN_IMPLANTED/REMOVED wysyła aquila/code/game/machinery/dna_infuser/_compat.dm

/// tg: COMSIG_ORGAN_SURGICALLY_REMOVED wysyłany po wycięciu organu operacją
/datum/surgery_step/manipulate_organs/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/extracting = (current_type == "extract" && I?.owner == target) ? I : null
	. = ..()
	if(extracting && !QDELETED(extracting) && extracting.owner != target)
		SEND_SIGNAL(extracting, COMSIG_ORGAN_SURGICALLY_REMOVED, user, target, target_zone, tool)

// noticable_organ (tg) jest w aquila/code/game/machinery/dna_infuser/_compat.dm

// ---------------------------------------------------------------------------
// corrupted_organ (tg) - wspólne zachowanie organów od ofiary heretyka
// ---------------------------------------------------------------------------

/// Component applying shared behaviour by cursed organs granted when sacrificed by a heretic
/// Mostly just does something spooky when it is removed
/datum/element/corrupted_organ

/datum/element/corrupted_organ/Attach(obj/item/organ/target, add_color = TRUE)
	. = ..()
	if (!istype(target) || (target.organ_flags & ORGAN_EXTERNAL))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ORGAN_SURGICALLY_REMOVED, PROC_REF(on_removed))

	var/atom/atom_parent = target
	if(add_color)
		atom_parent.add_atom_colour(COLOR_VOID_PURPLE, FIXED_COLOUR_PRIORITY)

	atom_parent.add_filter("ray", 1, list(
		type = "rays",
		size = 12,
		color = COLOR_VOID_PURPLE,
		density = 12
	))
	var/ray_filter = atom_parent.get_filter("ray")
	animate(ray_filter, offset = 100, time = 2 MINUTES, loop = -1, flags = ANIMATION_PARALLEL) // Absurdly long animate so nobody notices it hitching when it loops
	animate(offset = 0, time = 2 MINUTES) // I sure hope duration of animate doesnt have any performance effect

/datum/element/corrupted_organ/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_ORGAN_SURGICALLY_REMOVED))
	return ..()

/// When we're taken out of someone, do something spooky
/datum/element/corrupted_organ/proc/on_removed(atom/organ, mob/living/remover, mob/living/carbon/loser)
	SIGNAL_HANDLER
	if (loser?.reagents?.has_reagent(/datum/reagent/water/holywater) || loser?.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY) || prob(20))
		return
	if (prob(75))
		organ.AddComponent(\
			/datum/component/haunted_item,\
			haunt_color = "#00000000", \
			aggro_radius = 4, \
			spawn_message = span_revenwarning("[organ] unosi się złowieszczo w powietrze, pulsując nienaturalną siłą!"), \
			despawn_message = span_revenwarning("[organ] opada bez ruchu na ziemię."), \
		)
		return
	var/turf/origin_turf = get_turf(organ)
	playsound(organ, 'sound/magic/forcewall.ogg', vol = 100)
	new /obj/effect/temp_visual/curse_blast(origin_turf)
	organ.visible_message(span_revenwarning("[organ] wybucha falą mrocznej energii!"))
	for(var/mob/living/target in range(1, origin_turf))
		var/armor = target.run_armor_check(attack_flag = "bomb")
		target.apply_damage(30, BURN, blocked = armor)
	qdel(organ)

/obj/effect/temp_visual/curse_blast
	icon = 'icons/effects/64x64.dmi'
	pixel_x = -16
	pixel_y = -16
	icon_state = "curse"
	duration = 0.3 SECONDS

/obj/effect/temp_visual/curse_blast/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix() * 0.2, time = 0, flags = ANIMATION_PARALLEL)
	animate(transform = matrix() * 2, time = duration, easing = QUAD_EASING|EASE_IN)

	animate(src, alpha = 255, time = 0, flags = ANIMATION_PARALLEL)
	animate(alpha = 255, time = 0.2 SECONDS)
	animate(alpha = 0, time = 0.1 SECONDS)

// ---------------------------------------------------------------------------
// shadowspeak (tg) - czasem mówisz w języku cieni
// ---------------------------------------------------------------------------

/datum/status_effect/shadowspeak
	id = "forced_shadowspeak"
	alert_type = null
	remove_on_fullheal = FALSE //Ideally, the fullheal will remove whatever's causing the status effect in the first place.
	var/shadowspeak_chance

/datum/status_effect/shadowspeak/on_creation(mob/living/new_owner, shadowspeak_chance)
	src.shadowspeak_chance = shadowspeak_chance
	return ..()

/datum/status_effect/shadowspeak/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(on_spoken))

/datum/status_effect/shadowspeak/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/// When the mob speaks, sometimes put it in a different language
/datum/status_effect/shadowspeak/proc/on_spoken(mob/living/new_owner, list/speech_args)
	SIGNAL_HANDLER
	if (new_owner.reagents?.has_reagent(/datum/reagent/water/holywater) || prob(shadowspeak_chance))
		return
	speech_args[SACRIFICE_SAY_LANGUAGE_ARG] = /datum/language/shadowtongue

// ---------------------------------------------------------------------------
// Wymiociny z robakami (zepsuty wyrostek)
// ---------------------------------------------------------------------------

/// Nebula vomit with extra guests
/obj/effect/decal/cleanable/vomit/nebula/worms

/obj/effect/decal/cleanable/vomit/nebula/worms/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	for (var/i in 1 to rand(2, 3))
		new /mob/living/simple_animal/hostile/asteroid/hivelordbrood(loc)

// ---------------------------------------------------------------------------
// Latarka i stetoskop (tg: penlight_examine / hear_beat_noise / hear_breath_noise)
// ---------------------------------------------------------------------------

/obj/item/flashlight/attack(mob/living/carbon/M, mob/living/carbon/human/user)
	var/obj/item/organ/eyes/corrupt/corrupt_eyes
	if(iscarbon(M) && M != user && on && light_power >= 1 && user.zone_selected == BODY_ZONE_PRECISE_EYES)
		corrupt_eyes = M.getorganslot(ORGAN_SLOT_EYES)
		if(!istype(corrupt_eyes) || (M.head && M.head.flags_cover & HEADCOVERSEYES) || (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSEYES) || (M.glasses && M.glasses.flags_cover & GLASSESCOVERSEYES))
			corrupt_eyes = null
	. = ..()
	if(corrupt_eyes && corrupt_eyes.owner == M && !QDELETED(user))
		to_chat(user, corrupt_eyes.penlight_examine(user, src))

/obj/item/clothing/neck/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	var/listening = ishuman(M) && isliving(user) && !user.combat_mode && M.stat != DEAD
	var/zone = user?.zone_selected
	. = ..()
	if(!listening || QDELETED(M) || QDELETED(user))
		return
	var/obj/item/organ/heart/corrupt/corrupt_heart = M.getorganslot(ORGAN_SLOT_HEART)
	if(istype(corrupt_heart) && corrupt_heart.beating)
		to_chat(user, corrupt_heart.hear_beat_noise(user))
	if(zone != BODY_ZONE_CHEST)
		return
	var/obj/item/organ/lungs/corrupt/corrupt_lungs = M.getorganslot(ORGAN_SLOT_LUNGS)
	if(istype(corrupt_lungs))
		to_chat(user, corrupt_lungs.hear_breath_noise(user))

#undef SACRIFICE_SAY_LANGUAGE_ARG
