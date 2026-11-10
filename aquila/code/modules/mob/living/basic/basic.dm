// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/basic.dm (bee/master 0adf0fe9ae)
// Adapted to our conventions:
// - one interaction verb per action (`response_*_continuous`, third person, Polish), like `response_help` of our simple
//   animals. Bee's second-person `*_simple` verbs are not used: everyone, the user included, sees the third-person line.
// - `friendly` and `attacktext` mirror `friendly_verb_continuous` and `attack_verb_continuous`, because core attack code
//   (attack_animal() of mobs and objects, mechs, supermatter) reads them from any attacking animal.
// - `death_message`/`death_sound` as in Bee; `deathsound` (mob var) follows `death_sound` for the deathgasp emote.
// - movement speed through our ID-based movespeed modifiers, no fire handler, no abstract_type/living_flags.

///Simple animals 2.0, This time, let's really try to keep it simple. This basetype should purely be used as a base-level for implementing simplified behaviours for things such as damage and attacks. Everything else should be in components or AI behaviours.
/mob/living/basic
	name = "zwierzę"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	gender = PLURAL
	status_flags = CANPUSH

	var/basic_mob_flags = NONE

	///Defines how fast the basic mob can move. This is a multiplier
	var/speed = 1
	///How much stamina the mob recovers per second
	var/stamina_recovery = 5

	///how much damage this basic mob does to objects, if any.
	var/obj_damage = 0
	///How much armour they ignore, as a flat reduction from the targets armour value.
	var/armour_penetration = 0
	///Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	///How much bare wounding power it has
	var/bare_wound_bonus = 0
	///If the attacks from this are sharp
	var/sharpness = NONE

	/// Sound played when the critter attacks.
	var/attack_sound
	/// Override for the visual attack effect shown on 'do_attack_animation()'.
	var/attack_vis_effect
	///Played when someone punches the creature.
	var/attacked_sound = "punch" //This should be an element
	/// How often can you melee attack?
	var/melee_attack_cooldown = 2 SECONDS

	///What kind of objects this mob can smash.
	var/environment_smash = ENVIRONMENT_SMASH_NONE

	/// 1 for full damage, 0 for none, -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	///Minimum force required to deal any damage.
	var/force_threshold = 0

	///Verbs used for speaking e.g. "Says" or "Chitters". This can be elementized
	var/list/speak_emote = list()

	///When someone interacts with the basic mob (third person, like response_help of our simple animals)
	///Help-intent verb.
	var/response_help_continuous = "szturcha"
	///Disarm-intent verb.
	var/response_disarm_continuous = "popycha"
	///Harm-intent verb.
	var/response_harm_continuous = "uderza"

	///Basic mob's own attack verb.
	var/attack_verb_continuous = "atakuje"
	///Attacking, but without damage.
	var/friendly_verb_continuous = "łasi się do"
	/// Mirror of attack_verb_continuous for core code that reads the simple animal var
	var/attacktext
	/// Mirror of friendly_verb_continuous for core code that reads the simple animal var
	var/friendly

	/// Message shown when the mob dies, instead of the generic deathgasp line
	var/death_message = ""
	/// Sound played when the mob dies
	var/death_sound

	////////THIS SECTION COULD BE ITS OWN ELEMENT
	///Icon to use
	var/icon_living = ""
	///Icon when the animal is dead. Don't use animated icons for this.
	var/icon_dead = ""
	///We only try to show a gibbing animation if this exists.
	var/icon_gib = null

	///If the mob can be spawned with a gold slime core. HOSTILE_SPAWN are spawned with plasma, FRIENDLY_SPAWN are spawned with blood.
	var/gold_core_spawnable = NO_SPAWN
	///Sentience type, for slime potions. SHOULD BE AN ELEMENT BUT I DONT CARE ABOUT IT FOR NOW
	var/sentience_type = SENTIENCE_ORGANIC
	/// Innate access, as the simple animal one (sentience potions, pathfinding through doors)
	var/obj/item/card/id/access_card = null
	/// Can medical stacks heal it (read by the same code as for simple animals)
	var/healable = TRUE

	///Leaving something at 0 means it's off - has no maximum.
	var/list/habitable_atmos = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	///This damage is taken when atmos doesn't fit all the requirements above. Set to 0 to avoid adding the atmos_requirements element.
	var/unsuitable_atmos_damage = 1

	///Minimal body temperature without receiving damage
	var/minimum_survivable_temperature = 250
	///Maximal body temperature without receiving damage
	var/maximum_survivable_temperature = 350
	///This damage is taken when the body temp is too cold. Set both this and unsuitable_heat_damage to 0 to avoid adding the basic_body_temp_sensitive element.
	var/unsuitable_cold_damage = 1
	///This damage is taken when the body temp is too hot. Set both this and unsuitable_cold_damage to 0 to avoid adding the basic_body_temp_sensitive element.
	var/unsuitable_heat_damage = 1

/mob/living/basic/Initialize(mapload)
	. = ..()

	if(gender == PLURAL)
		gender = pick(MALE,FEMALE)

	if(!real_name)
		real_name = name

	if(!loc)
		stack_trace("Basic mob being instantiated in nullspace")

	attacktext = attack_verb_continuous
	friendly = friendly_verb_continuous
	if(death_sound)
		deathsound = death_sound

	update_basic_mob_varspeed()

	if(speak_emote)
		speak_emote = string_list(speak_emote)

	if(unsuitable_atmos_damage != 0)
		//String assoc list returns a cached list, so this is like a static list to pass into the element below.
		habitable_atmos = string_assoc_list(habitable_atmos)
		AddElement(/datum/element/atmos_requirements, habitable_atmos, unsuitable_atmos_damage)

	if(unsuitable_cold_damage != 0 && unsuitable_heat_damage != 0)
		AddElement(/datum/element/basic_body_temp_sensitive, minimum_survivable_temperature, maximum_survivable_temperature, unsuitable_cold_damage, unsuitable_heat_damage)

/mob/living/basic/Destroy()
	QDEL_NULL(access_card)
	return ..()

/mob/living/basic/Life(seconds, times_fired)
	. = ..()
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery * SSMOBS_DT, forced = TRUE)

/// Body temperature follows the environment like for simple animals (Bee: base /mob/living/handle_environment()), damage is done by elements
/mob/living/basic/handle_environment(datum/gas_mixture/environment)
	. = ..()
	if(!isturf(loc))
		return
	var/areatemp = get_temperature(environment)
	if(abs(areatemp - bodytemperature) > 5)
		adjust_bodytemperature((areatemp - bodytemperature) / 5)

/// Bee sends COMSIG_LIVING_HANDLE_BREATHING from /mob/living/Life(), we send it from the breathing step of basic mobs
/mob/living/basic/handle_breathing(times_fired)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_BREATHING, SSMOBS_DT, times_fired)

/mob/living/basic/say_mod(input, list/message_mods = list())
	if(length(speak_emote))
		verb_say = pick(speak_emote)
	return ..()

/mob/living/basic/death(gibbed)
	if(!gibbed && (death_sound || death_message || !(basic_mob_flags & DEL_ON_DEATH)))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "deathgasp")
	. = ..()
	if(basic_mob_flags & DEL_ON_DEATH)
		qdel(src)
	else
		health = 0
		look_dead()

/**
 * Apply the appearance and properties this mob has when it dies
 * This is called by the mob pretending to be dead too so don't put loot drops in here or something
 */
/mob/living/basic/proc/look_dead()
	icon_state = icon_dead
	if(basic_mob_flags & FLIP_ON_DEATH)
		transform = transform.Turn(180)
	if(!(basic_mob_flags & REMAIN_DENSE_WHILE_DEAD))
		set_density(FALSE)
	SEND_SIGNAL(src, COMSIG_BASICMOB_LOOK_DEAD)

/mob/living/basic/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(!.)
		return
	look_alive()

/// Apply the appearance and properties this mob has when it is alive
/mob/living/basic/proc/look_alive()
	icon_state = icon_living
	if(basic_mob_flags & FLIP_ON_DEATH)
		transform = transform.Turn(180)
	if(!(basic_mob_flags & REMAIN_DENSE_WHILE_DEAD))
		set_density(initial(density))
	mobility_flags = MOBILITY_FLAGS_DEFAULT
	update_mobility()
	SEND_SIGNAL(src, COMSIG_BASICMOB_LOOK_ALIVE)

/mob/living/basic/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		return
	// Same line as our simple animals
	. += span_deadsay(HAS_MIND_TRAIT(user, TRAIT_NAIVE) ? "Po bliższym przyjrzeniu się wygląda, jakby spał." : "Po bliższym przyjrzeniu się wygląda na martwego.")

/mob/living/basic/proc/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	face_atom(target)
	if (!ignore_cooldown)
		changeNext_move(melee_attack_cooldown)
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE //but more importantly return before attack_animal called
	var/result = target.attack_basic_mob(src, modifiers)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	return result

/mob/living/basic/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	melee_attack(attack_target, modifiers)

/mob/living/basic/vv_edit_var(vname, vval)
	. = ..()
	switch(vname)
		if(NAMEOF(src, speed))
			datum_flags |= DF_VAR_EDITED
			set_varspeed(vval)
		if(NAMEOF(src, attack_verb_continuous))
			attacktext = vval
		if(NAMEOF(src, friendly_verb_continuous))
			friendly = vval

/mob/living/basic/proc/set_varspeed(var_value)
	speed = var_value
	update_basic_mob_varspeed()

/mob/living/basic/proc/update_basic_mob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(MOVESPEED_ID_SIMPLEMOB_VARSPEED, TRUE)
	add_movespeed_modifier(MOVESPEED_ID_SIMPLEMOB_VARSPEED, TRUE, 100, multiplicative_slowdown = speed, override = TRUE)
	SEND_SIGNAL(src, POST_BASIC_MOB_UPDATE_VARSPEED)

/// Riding (our old riding component, like simple animals)
/mob/living/basic/relaymove(mob/user, direction)
	var/datum/component/riding/riding_datum = GetComponent(/datum/component/riding)
	if(riding_datum)
		riding_datum.handle_ride(user, direction)

/mob/living/basic/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Zdrowie"] = GENERATE_STAT_TEXT("[round((health / maxHealth) * 100)]%")
	return tab_data

/mob/living/basic/proc/compare_sentience_type(compare_type)
	return sentience_type == compare_type

/// Called when a ghost or a sentience potion takes the mob over (simple animal: turns its AI off for good)
/mob/living/basic/proc/sentience_act()
	ai_controller?.set_ai_status(AI_STATUS_OFF)

/mob/living/basic/get_idcard(hand_first)
	return access_card

/// Updates movement speed based on stamina loss
/mob/living/basic/update_stamina()
	set_varspeed(initial(speed) + (staminaloss * 0.06))

/mob/living/basic/gib_animation()
	if(icon_gib)
		new /obj/effect/temp_visual/gib_animation/animal(loc, icon_gib)

/// Same question as /mob/living/simple_animal/proc/environment_air_is_safe() (mouse migration spawns, minor_mapping.dm),
/// answered from habitable_atmos (the atmos_requirements element does the damage)
/mob/living/basic/proc/environment_air_is_safe()
	if(!unsuitable_atmos_damage || !isopenturf(loc))
		return TRUE
	var/turf/open/open_turf = loc
	var/datum/gas_mixture/air = open_turf.air
	if(isnull(air))
		return !(habitable_atmos["min_oxy"] || habitable_atmos["min_plas"] || habitable_atmos["min_n2"] || habitable_atmos["min_co2"])
	var/list/gases = list(
		"oxy" = air.get_moles(GAS_O2),
		"plas" = air.get_moles(GAS_PLASMA) + air.get_moles(GAS_CONSTRICTED_PLASMA),
		"n2" = air.get_moles(GAS_N2),
		"co2" = air.get_moles(GAS_CO2),
	)
	for(var/gas in gases)
		if(!ISINRANGE(gases[gas], habitable_atmos["min_[gas]"], (habitable_atmos["max_[gas]"] || INFINITY)))
			return FALSE
	return TRUE
