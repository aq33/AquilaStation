// AQUILA: port of tgstation code/modules/mob/living/basic/space_fauna/space_dragon/ (space_dragon.dm, dragon_breath.dm, dragon_gust.dm;
// tg 926bf40c5a) and the fire_breath mob ability (code/datums/actions/mobs/fire_breath.dm) in place of our simple animal
// hostile/space_dragon.dm. The antagonist (code/modules/antagonists/space_dragon/: objectives, rifts, wavespeak) stays ours.
// Polish names and lines, health and damage of our simple animal dragon.
// Changes against tg:
// - 350 health, our sounds, sprites and overlay states ("overlay_base", "overlay_gust", "overlay_gust_2", "overlay_dead");
// - our colour picker on the first login, no renaming (as before) and no shark form, fishing or achievements;
// - fire breath: our line of fire that stops at walls, windows and closed doors (tg stops at any dense turf), 30 burn damage,
//   50 to mechs; it invigorates carp (faction mates) for 8 s as before;
// - swallowing corpses heals half their max health (ours; tg a quarter); a swallowed mob coming back to life is spat out;
// - wing buffet: tg's escalating endlag; a failed rift makes it five times as tiring through our `tiredness_mult`
//   (tg TRAIT_RIFT_FAILURE); the rift summoning of our antagonist checks TRAIT_WING_BUFFET instead of `using_special`;
// - wall tearing through the wall_tearer element (4 s, reinforced walls 12 s as before); no door prying (door_pryer is not here
//   yet, our dragon never pried doors), no seethrough_mob;
// - players breathe fire by clicking something out of reach and use the wing buffet with the secondary click (right click,
//   the disarm intent in the old controls) or its button; an AI dragon (admin spawn) breathes fire at its target and bites;
// - the small sprite action of core (action.dm) still works on it.
/// The darkness threshold for space dragon when choosing a color
#define DARKNESS_THRESHOLD 50

/**
 * Advanced stage of the space carp life cycle, spawned as a midround antagonist
 * Can eat corpses to heal, blow people back with its wings, and obviously as a dragon it breathes fire. It can even tear through walls.
 * The midround event version also creates rifts which summon carp.
 */
/mob/living/basic/space_dragon
	name = "Kosmiczny smok"
	desc = "Ohydna, lewiatanowata istota, która lata w najbardziej nienaturalny sposób. Wygląda trochę jak kosmiczny karp."
	icon = 'icons/mob/spacedragon.dmi'
	icon_state = "spacedragon"
	icon_living = "spacedragon"
	icon_dead = "spacedragon_dead"
	bubble_icon = "spacedragon"
	faction = list("carp")
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	gender = NEUTER
	maxHealth = 350
	health = 350
	spacewalk = TRUE
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	pressure_resistance = 200
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0.5, OXY = 1)
	combat_mode = TRUE
	speed = 0
	attack_verb_continuous = "chrupie"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	obj_damage = 50
	melee_damage = 35
	melee_attack_cooldown = CLICK_CD_MELEE
	mob_size = MOB_SIZE_LARGE
	armour_penetration = 30
	pixel_x = -16
	base_pixel_x = -16
	mouse_opacity = MOUSE_OPACITY_ICON
	death_sound = 'sound/creatures/space_dragon_roar.ogg'
	death_message = "skrzeczy, gdy jego skrzydła obracają się w pył, i pada martwy na podłogę."
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	discovery_points = 0
	ai_controller = /datum/ai_controller/basic_controller/space_dragon
	/// The colour of the space dragon
	var/chosen_color
	/// Our fire breath action
	var/datum/action/cooldown/mob_cooldown/fire_breath/carp/fire_breath
	/// Our wing flap action
	var/datum/action/cooldown/mob_cooldown/wing_buffet/buffet
	/// The ability to make your sprite smaller
	var/datum/action/small_sprite/space_dragon/small_sprite
	/// Multiplier of the wing buffet tiredness, 5 after a failed rift (set by the antagonist datum)
	var/tiredness_mult = 1
	/// If the dragon failed its rifts and may not summon more (set by the antagonist datum, read by the summon rift action)
	var/can_summon_rifts = FALSE
	/// Is the dragon busy swallowing something
	var/is_swallowing = FALSE

/mob/living/basic/space_dragon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/content_barfer)
	AddElement(/datum/element/wall_tearer, tear_time = 4 SECONDS, reinforced_multiplier = 3)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	fire_breath = new(src)
	fire_breath.Grant(src)
	ai_controller?.set_blackboard_key(BB_TARGETED_ACTION, fire_breath)
	buffet = new(src)
	buffet.Grant(src)
	small_sprite = new
	small_sprite.Grant(src)
	update_icon()

/mob/living/basic/space_dragon/Destroy()
	fire_breath = null
	buffet = null
	small_sprite = null
	return ..()

/mob/living/basic/space_dragon/Login()
	. = ..()
	if(!chosen_color)
		INVOKE_ASYNC(src, PROC_REF(color_selection))

/**
 * Allows space dragon to choose a color for itself.
 *
 * Prompts the space dragon to choose a color, from which it will then apply to itself.
 * If an invalid color is given, will re-prompt the dragon until a proper color is chosen.
 */
/mob/living/basic/space_dragon/proc/color_selection()
	var/new_color = tgui_color_picker(src, "Jaki chcesz mieć kolor?", "Wybierz kolor", COLOR_WHITE)
	if(QDELETED(src) || chosen_color)
		return
	if(!new_color) //redo proc until we get a color
		to_chat(src, "<span class='warning'>Nieprawidłowy kolor, spróbuj ponownie.</span>")
		color_selection()
		return
	var/temp_hsv = RGBtoHSV(new_color)
	if(ReadHSV(temp_hsv)[3] < DARKNESS_THRESHOLD)
		to_chat(src, "<span class='danger'>Nieprawidłowy kolor. Twój kolor nie jest wystarczająco jasny.</span>")
		color_selection()
		return
	chosen_color = new_color
	add_atom_colour(chosen_color, FIXED_COLOUR_PRIORITY)
	update_icon()

/mob/living/basic/space_dragon/update_icon_state()
	. = ..()
	if(stat == DEAD)
		icon_state = icon_dead
		return
	if(!HAS_TRAIT(src, TRAIT_WING_BUFFET))
		icon_state = icon_living
		return
	if(HAS_TRAIT(src, TRAIT_WING_BUFFET_TIRED))
		icon_state = "[icon_living]_gust_2"
		return
	icon_state = "[icon_living]_gust"

/mob/living/basic/space_dragon/update_overlays()
	. = ..()
	if(small_sprite?.small)
		return
	var/overlay_state = "overlay_base"
	if(stat == DEAD)
		overlay_state = "overlay_dead"
	else if(HAS_TRAIT(src, TRAIT_WING_BUFFET_TIRED))
		overlay_state = "overlay_gust_2"
	else if(HAS_TRAIT(src, TRAIT_WING_BUFFET))
		overlay_state = "overlay_gust"
	var/mutable_appearance/overlay = mutable_appearance(icon, overlay_state)
	overlay.appearance_flags = RESET_COLOR
	. += overlay

/// Used by the small sprite action of core (action.dm) to bring the overlay back
/mob/living/basic/space_dragon/proc/update_dragon_overlay()
	update_icon()

/mob/living/basic/space_dragon/death(gibbed)
	. = ..()
	update_icon()

/mob/living/basic/space_dragon/revive(full_heal, admin_revive)
	. = ..()
	update_icon()

/mob/living/basic/space_dragon/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !istype(target, /obj/mecha))
		return
	var/obj/mecha/mech = target
	mech.take_damage(obj_damage, BRUTE, "melee", 1)

/// Before we attack something, check if we want to do something else instead
/mob/living/basic/space_dragon/proc/pre_attack(mob/living/source, atom/target)
	SIGNAL_HANDLER
	if(target == src)
		to_chat(src, "<span class='warning'>Prawie gryziesz samego siebie, ale w ostatniej chwili się rozmyślasz.</span>")
		return COMPONENT_HOSTILE_NO_ATTACK // Easy to misclick yourself, let's not
	if(HAS_TRAIT(src, TRAIT_WING_BUFFET))
		return COMPONENT_HOSTILE_NO_ATTACK
	if(!isliving(target))
		return NONE
	var/mob/living/living_target = target
	if(living_target.stat != DEAD)
		return NONE
	if(is_swallowing)
		balloon_alert(src, "zajęty!")
		return COMPONENT_HOSTILE_NO_ATTACK
	INVOKE_ASYNC(src, PROC_REF(try_eat), living_target)
	return COMPONENT_HOSTILE_NO_ATTACK

/// Try putting something inside us
/mob/living/basic/space_dragon/proc/try_eat(mob/living/food)
	to_chat(src, "<span class='warning'>Zaczynasz połykać [food] w całości...</span>")
	is_swallowing = TRUE
	var/finished = do_after(src, 3 SECONDS, target = food)
	is_swallowing = FALSE
	if(finished)
		eat(food)

/// Succeed in putting something inside us; heals half the eaten mob's max health
/mob/living/basic/space_dragon/proc/eat(mob/living/food)
	if(QDELETED(food) || food.loc == src)
		return FALSE
	playsound(src, 'sound/magic/demon_attack1.ogg', 100, TRUE)
	visible_message("<span class='warning'>[src] połyka [food] w całości!</span>")
	food.extinguish_mob() // It's wet in there, and our food is likely to be on fire. Let's be decent and not husk them.
	food.forceMove(src)
	adjustBruteLoss(-food.maxHealth * 0.5)
	return TRUE

/mob/living/basic/space_dragon/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		RegisterSignal(arrived, COMSIG_LIVING_REVIVE, PROC_REF(eaten_revived))

/mob/living/basic/space_dragon/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone))
		UnregisterSignal(gone, COMSIG_LIVING_REVIVE)

/// Release consumed mobs if they come back to life
/mob/living/basic/space_dragon/proc/eaten_revived(mob/living/eaten)
	SIGNAL_HANDLER
	if(eaten.loc != src)
		return
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	visible_message("<span class='danger'>[src] zwraca [eaten]!</span>")
	eaten.forceMove(loc)
	eaten.Paralyze(5 SECONDS)

/// Fire breath on anything out of reach (any control mode)
/mob/living/basic/space_dragon/RangedAttack(atom/target, params)
	. = ..()
	if(.)
		return
	fire_breath?.Trigger(target = target)

/// Wing buffet on the secondary click out of reach (right click, the disarm intent in the old controls)
/mob/living/basic/space_dragon/ranged_secondary_attack(atom/target, modifiers)
	buffet?.Trigger()

/// An AI dragon (admin spawn without a player) breathes fire at its target and bites
/datum/ai_controller/basic_controller/space_dragon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/continue_planning,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Breathe a line of flames towards the target (tg code/datums/actions/mobs/fire_breath.dm)
/datum/action/cooldown/mob_cooldown/fire_breath
	name = "Ogniste tchnienie"
	desc = "Zionie linią płomieni w stronę celu."
	icon_icon = 'icons/obj/wizard.dmi'
	button_icon_state = "fireball"
	cooldown_time = 3 SECONDS
	/// The range of the fire
	var/fire_range = 15
	/// The sound played when you use this ability
	var/fire_sound = 'sound/magic/fireball.ogg'
	/// Time to wait between spawning each fire turf
	var/fire_delay = 1
	/// How hot is our fire
	var/fire_temperature = 700
	/// 'How much' fire do we expose the turf to?
	var/fire_volume = 50
	/// How much damage do you take when engulfed?
	var/fire_damage = 20
	/// How much damage to mechs take when engulfed?
	var/mech_damage = 45

/datum/action/cooldown/mob_cooldown/fire_breath/Activate(atom/target_atom)
	attack_sequence(target_atom)
	StartCooldown()
	return TRUE

/// Apply our specific fire breathing shape, in proc form so we can override it in subtypes
/datum/action/cooldown/mob_cooldown/fire_breath/proc/attack_sequence(atom/target)
	playsound(get_turf(owner), fire_sound, 200, TRUE)
	fire_line(target)

/// Breathe fire in a line towards the target, optionally rotated at an offset from the target
/datum/action/cooldown/mob_cooldown/fire_breath/proc/fire_line(atom/target, offset)
	if(isnull(target))
		return
	var/turf/target_turf = get_ranged_target_turf_direct(owner, target, fire_range, offset)
	var/list/turfs = getline(owner, target_turf) - get_turf(owner)
	INVOKE_ASYNC(src, PROC_REF(progressive_fire_line), turfs)

/// Creates fire with a delay on the list of targeted turfs; stops at walls, windows and closed doors (our dragon fire)
/datum/action/cooldown/mob_cooldown/fire_breath/proc/progressive_fire_line(list/burn_turfs)
	if(QDELETED(owner) || owner.stat == DEAD)
		return
	// Guys we have already hit, no double dipping
	var/list/hit_list = list(owner) // also don't burn ourselves
	for(var/turf/target_turf in burn_turfs)
		if(isclosedturf(target_turf))
			return
		if(locate(/obj/structure/window) in target_turf)
			return
		for(var/obj/machinery/door/door in target_turf)
			if(door.density)
				return
		burn_turf(target_turf, hit_list, owner)
		sleep(fire_delay)
		if(QDELETED(owner))
			return

/// Finally spawn the actual fire
/datum/action/cooldown/mob_cooldown/fire_breath/proc/burn_turf(turf/fire_turf, list/hit_list, mob/living/source)
	new /obj/effect/hotspot(fire_turf)
	fire_turf.hotspot_expose(fire_temperature, fire_volume, TRUE)

	for(var/mob/living/barbecued in fire_turf.contents)
		if(barbecued in hit_list)
			continue
		hit_list |= barbecued
		on_burn_mob(barbecued, source)

	for(var/obj/mecha/robotron in fire_turf.contents)
		if(robotron in hit_list)
			continue
		hit_list |= robotron
		robotron.take_damage(mech_damage, BRUTE, "melee", 1)

/// Do something unpleasant to someone we set on fire
/datum/action/cooldown/mob_cooldown/fire_breath/proc/on_burn_mob(mob/living/barbecued, mob/living/source)
	to_chat(barbecued, "<span class='userdanger'>Trafia cię ogniste tchnienie [source]!</span>")
	barbecued.adjustFireLoss(fire_damage)

/// A space dragon's fire breath, toasts lunch AND buffs your friends
/datum/action/cooldown/mob_cooldown/fire_breath/carp
	desc = "Ogniste tchnienie kosmicznego smoka nie tylko zwęgla wrogów, ale też dodaje sił kosmicznym karpiom."
	fire_damage = 30
	mech_damage = 50
	fire_range = 20
	fire_temperature = 700
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/fire_breath/carp/on_burn_mob(mob/living/barbecued, mob/living/source)
	if(!source.faction_check_mob(barbecued))
		return ..()
	barbecued.apply_status_effect(/datum/status_effect/carp_invigoration)

/// Makes you run faster for the duration (the dragon's fire on carp)
/datum/status_effect/carp_invigoration
	id = "carp_invigorated"
	alert_type = null
	duration = 8 SECONDS

/datum/status_effect/carp_invigoration/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 2))
	owner.add_movespeed_modifier(MOVESPEED_ID_DRAGON_RAGE, multiplicative_slowdown = -0.5)

/datum/status_effect/carp_invigoration/on_remove()
	owner.remove_filter("anger_glow")
	owner.remove_movespeed_modifier(MOVESPEED_ID_DRAGON_RAGE)

/// Default additional time to spend stunned per usage of ability
#define DEFAULT_ACTIVATED_ENDLAG 3

/// Rise into the air and slam down, knocking people away. No real cooldown but has escalating endlag if used in quick succession.
/datum/action/cooldown/mob_cooldown/wing_buffet
	name = "Atak podmuchem"
	desc = "Podmuchami skrzydeł odrzucasz wrogów, odpychając ich i ogłuszając. Zbyt częste używanie zostawia cię bezbronnym na dłużej."
	icon_icon = 'icons/mob/actions/actions_space_dragon.dmi'
	button_icon_state = "gust_attack"
	cooldown_time = 1 SECONDS
	melee_cooldown_time = 0
	click_to_activate = FALSE
	shared_cooldown = NONE
	/// Timer we use to track our current action
	var/active_timer
	/// How far away can we reach people?
	var/gust_distance = 4
	/// How long to animate for before we start?
	var/windup_time = 1.2 SECONDS
	/// Minimum amount of stun time following use of wing buffet
	var/minimum_endlag = 4
	/// Amount of extra time to stay stunned after the end of the ability
	var/additional_endlag = 0
	/// Amount of time to add to endlag after each successful use of the ability
	var/endlag_per_activation = DEFAULT_ACTIVATED_ENDLAG
	/// How much accumulated stun time do we subtract every second? Takes a full minute to regen off a single use :(
	var/endlag_decay_per_second = DEFAULT_ACTIVATED_ENDLAG / 60
	/// List of traits we apply while the ability is ongoing, stops us from moving around and such
	var/static/list/applied_traits = list(
		TRAIT_IMMOBILIZED,
		TRAIT_NO_FLOATING_ANIM,
		TRAIT_WING_BUFFET,
	)

/datum/action/cooldown/mob_cooldown/wing_buffet/Grant(mob/granted_to)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/action/cooldown/mob_cooldown/wing_buffet/Remove(mob/removed_from)
	deltimer(active_timer)
	UnregisterSignal(removed_from, COMSIG_LIVING_LIFE)
	removed_from.remove_traits(applied_traits + TRAIT_WING_BUFFET_TIRED, REF(src))
	return ..()

/datum/action/cooldown/mob_cooldown/wing_buffet/IsAvailable(feedback = FALSE)
	. = ..()
	if(!. || HAS_TRAIT(owner, TRAIT_WING_BUFFET))
		return FALSE

/// Decay our accumulated additional tiredness
/datum/action/cooldown/mob_cooldown/wing_buffet/proc/on_life(mob/living/liver, seconds_per_tick)
	SIGNAL_HANDLER
	if(liver.stat == DEAD)
		return // not so life now buddy
	additional_endlag = max(0, additional_endlag - (endlag_decay_per_second * (seconds_per_tick || SSMOBS_DT)))

/datum/action/cooldown/mob_cooldown/wing_buffet/Activate(atom/target)
	begin_sequence()
	StartCooldown()
	return TRUE

/// Rise up into the air
/datum/action/cooldown/mob_cooldown/wing_buffet/proc/begin_sequence()
	owner.add_traits(applied_traits, REF(src)) // No moving till we're done
	owner.update_icon()
	animate(owner, pixel_y = 20, time = windup_time)
	active_timer = addtimer(CALLBACK(src, PROC_REF(ground_pound)), windup_time, TIMER_STOPPABLE)

/// Slam into the ground
/datum/action/cooldown/mob_cooldown/wing_buffet/proc/ground_pound()
	if(QDELETED(owner))
		return
	owner.pixel_y = owner.base_pixel_y
	playsound(owner, 'sound/effects/gravhit.ogg', 100, TRUE)
	for(var/mob/living/candidate in view(gust_distance, owner))
		if(candidate == owner || candidate.faction_check_mob(owner))
			continue
		owner.visible_message("<span class='boldwarning'>Podmuch odrzuca [candidate]!</span>")
		to_chat(candidate, "<span class='userdanger'>Podmuch cię odrzuca!</span>")
		var/dir_to_target = get_dir(get_turf(owner), get_turf(candidate))
		var/throwtarget = get_edge_target_turf(candidate, dir_to_target)
		candidate.safe_throw_at(throwtarget, 10, 1, owner)
		candidate.Paralyze(5 SECONDS)

	var/endlag_multiplier = 1
	var/mob/living/basic/space_dragon/dragon = owner
	if(istype(dragon))
		endlag_multiplier = dragon.tiredness_mult
	var/stun_time = minimum_endlag + (additional_endlag * endlag_multiplier)
	additional_endlag += endlag_per_activation * endlag_multiplier // double dips, rough
	ADD_TRAIT(owner, TRAIT_WING_BUFFET_TIRED, REF(src))
	owner.update_icon()
	active_timer = addtimer(CALLBACK(src, PROC_REF(complete_ability)), stun_time, TIMER_STOPPABLE)

/datum/action/cooldown/mob_cooldown/wing_buffet/proc/complete_ability()
	active_timer = null
	if(QDELETED(owner))
		return
	owner.remove_traits(applied_traits + TRAIT_WING_BUFFET_TIRED, REF(src))
	owner.update_icon()

#undef DEFAULT_ACTIVATED_ENDLAG

/// Carp wave speech of the space dragon antagonist and its carp
/mob/living/proc/carp_talk(message, shown_name = real_name)
	message = trim(message)
	if(!message)
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, "<span class='warning'>Twoja wiadomość zawiera zakazane słowa.</span>")
		return
	message = treat_message_min(message)
	log_talk(message, LOG_SAY)
	var/message_a = say_quote(message)
	var/rendered = "<span class='carpspeak'>Karpiowa Mowa Fal <span class='name'>[shown_name]</span> <span class='message'>[message_a]</span></span>" // port BeeStation #9908
	if(istype(src, /mob/living/basic/space_dragon))
		rendered = "<span class='big'>[rendered]</span>"
	for(var/mob/S in GLOB.player_list)
		if(!S.stat && ("carp" in S.faction))
			to_chat(S, rendered)
		if(S in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(S, src)
			to_chat(S, "[link] [rendered]")

// The content_barfer element lives in aquila/code/datums/elements/content_barfer.dm (shared with the mining mobs)

#undef DARKNESS_THRESHOLD
