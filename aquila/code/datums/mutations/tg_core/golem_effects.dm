// AQUILA - port z tgstation (code/game/objects/items/stacks/golem_food/golem_status_effects.dm + golem_hand_actions.dm)
// Nakładki na kończyny golemów tg pominięte (inne sprite'y golemów) - zawsze używamy poświaty filtra.

/// Abstract holder for golem status effects, you should never have more than one of these active
/datum/status_effect/golem
	id = "golem_status"
	duration = 5 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/golem_status
	/// Name of the mineral we ate to get this
	var/mineral_name = ""
	/// Text to display on buff application
	var/applied_fluff = ""
	/// Icon used to represent the alert
	var/alert_icon = 'icons/obj/stack_objects.dmi'
	/// Icon state to display to represent the alert
	var/alert_icon_state = "sheet-monkey"
	/// Tooltip to display when hovering over the alert
	var/alert_desc = "Something went wrong and this tooltip is not displaying correctly."
	/// What color does the filter glow?
	var/filter_color = LIGHT_COLOR_DEFAULT
	/// If TRUE, then this status effect is exclusive to other golem status effects and cannot be stacked with them.
	var/exclusive = TRUE
	/// Used to calculate the overall duration based on how many stone bodyparts the mob has.
	var/duration_mult_per_bodypart = 0.15 // 0.1 + (0.15 * 6 bodyparts) = 1
	/// The minimum duration if the mob has no stone bodypart
	var/minimum_duration_mult = 0.1

/atom/movable/screen/alert/status_effect/golem_status
	name = "Metamorphic %SOMETHING%"
	desc = "You've enjoyed a tasty meal and are now experiencing a bug."
	icon_state = "template"
	/// Overlay we show on top of the template icon
	var/mutable_appearance/mineral_overlay
	/// When we reach this much remaining time we will start animating as a warning
	var/early_expiry_warning = 30 SECONDS
	/// When we reach this much remaining time we will start animating more urgently as a warning
	var/imminent_expiry_warning = 5 SECONDS

/// Set up how the alert ACTUALLY looks, based on the effect applied
/atom/movable/screen/alert/status_effect/golem_status/proc/update_details(buff_time)
	var/datum/status_effect/golem/golem_effect = attached_effect
	if(!istype(golem_effect))
		CRASH("Golem status alert attached to invalid status effect.")
	name = replacetext(name, "%SOMETHING%", golem_effect.mineral_name)
	desc = golem_effect.alert_desc
	mineral_overlay = mutable_appearance(golem_effect.alert_icon, golem_effect.alert_icon_state)
	update_appearance(UPDATE_ICON)
	if(buff_time > early_expiry_warning)
		addtimer(CALLBACK(src, PROC_REF(early_warning)), buff_time - early_expiry_warning, TIMER_DELETE_ME)
	if(buff_time > imminent_expiry_warning)
		addtimer(CALLBACK(src, PROC_REF(imminent_warning)), buff_time - imminent_expiry_warning, TIMER_DELETE_ME)

/// Animate to indicate effect is expiring soon
/atom/movable/screen/alert/status_effect/golem_status/proc/early_warning()
	animate(src, alpha = 75, time = 1 SECONDS, loop = -1)
	animate(alpha = 255, time = 1 SECONDS, loop = -1)

/// Animate to indicate effect is expiring very soon
/atom/movable/screen/alert/status_effect/golem_status/proc/imminent_warning()
	animate(src, alpha = 25, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 200, time = 0.5 SECONDS, loop = -1)

/atom/movable/screen/alert/status_effect/golem_status/update_overlays()
	. = ..()
	if(mineral_overlay)
		. += mineral_overlay

/atom/movable/screen/alert/status_effect/golem_status/Destroy()
	QDEL_NULL(mineral_overlay)
	return ..()

/datum/status_effect/golem/on_apply()
	. = ..()
	if(!.)
		return FALSE
	if(applied_fluff)
		to_chat(owner, "<span class='notice'>[applied_fluff]</span>")
	if(filter_color)
		owner.add_filter("[id]_filter", 2, outline_filter(size = 1.25, color = filter_color))
		var/the_filter = owner.get_filter("[id]_filter")
		animate(the_filter, alpha = 0) // start at 0 alpha
		animate(the_filter, alpha = 150, time = 7.5 SECONDS, loop = -1, easing = SINE_EASING) // fade in and out
		animate(alpha = 50, time = 7.5 SECONDS, loop = -1, easing = SINE_EASING)
	return TRUE

/datum/status_effect/golem/on_creation(mob/living/new_owner, multiplier = 1)
	// Golemy (u nas cały gatunek golem) liczą się jak 6 kamiennych kończyn
	var/exponent = 0.5
	var/duration_mult = minimum_duration_mult
	if(isgolem(new_owner))
		duration_mult = 0.1 + duration_mult_per_bodypart * 6
		exponent = 0.2
	if(multiplier > 1)
		duration *= (duration_mult * multiplier) ** exponent
	else
		duration *= duration_mult * multiplier
	var/buff_duration = duration
	. = ..()
	if(!. || QDELETED(src))
		return FALSE
	var/atom/movable/screen/alert/status_effect/golem_status/status_alert = linked_alert
	if(istype(status_alert))
		status_alert.update_details(buff_time = buff_duration)
	RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_ROCK_METAMORPHIC), PROC_REF(on_metamorphic_lost))

/datum/status_effect/golem/proc/on_metamorphic_lost()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/golem/on_remove()
	if(mineral_name)
		to_chat(owner, "<span class='warning'>Działanie minerału ([mineral_name]) słabnie.</span>")
	owner.remove_filter("[id]_filter")
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ROCK_METAMORPHIC))
	return ..()

/datum/status_effect/golem/get_examine_text()
	if(mineral_name)
		return "<span class='notice'>[owner.p_their(TRUE)] ciało przecinają żyły minerału ([mineral_name]).</span>"

/// Freezes hunger for the duration
/datum/status_effect/golem/uranium
	mineral_name = "uran"
	applied_fluff = "Z ciała wyrastają ci świecące kryształy. Czujesz przypływ energii!"
	alert_icon_state = "sheet-uranium"
	alert_desc = "Wewnętrzne promieniowanie zaspokaja wszystkie twoje potrzeby żywieniowe."
	filter_color = LIGHT_COLOR_GREEN

/datum/status_effect/golem/uranium/on_apply()
	. = ..()
	if(!.)
		return FALSE
	ADD_TRAIT(owner, TRAIT_NOHUNGER, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/golem/uranium/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOHUNGER, TRAIT_STATUS_EFFECT(id))
	return ..()

/// Magic immunity
/datum/status_effect/golem/silver
	mineral_name = "srebro"
	applied_fluff = "Twoje barki pokrywają lśniące płyty. Czujesz się uświęcony!"
	alert_icon_state = "sheet-silver"
	alert_desc = "Twoje ciało odpycha nadprzyrodzone wpływy."
	filter_color = LIGHT_COLOR_FAINT_BLUE

/datum/status_effect/golem/silver/on_apply()
	. = ..()
	if(!.)
		return FALSE
	owner.add_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/golem/silver/on_remove()
	owner.remove_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), TRAIT_STATUS_EFFECT(id))
	return ..()

/// Ile ładunku ogniwa daje punkt obrażeń od ognia (tg 0.005 * STANDARD_CELL_CHARGE, u nas ogniwo ma 1000)
#define GOLEM_PLASMA_ENERGY_PER_DAMAGE 5
/// Multiplier to apply to burn damage, not 0 so that we can reverse it more easily
#define GOLEM_PLASMA_BURN_MULTIPLIER 0.05

/// Heat immunity, turns heat damage into local power
/datum/status_effect/golem/plasma
	mineral_name = "plazma"
	applied_fluff = "Z ciała wyrastają ci pręty chłodzące z plazmy. Wytrzymasz każdy żar!"
	alert_icon_state = "sheet-plasma"
	alert_desc = "Chroni cię przed wysokim ciśnieniem, a obrażenia od gorąca zamieniasz w energię."
	filter_color = LIGHT_COLOR_PINK

/datum/status_effect/golem/plasma/on_apply()
	. = ..()
	if(!.)
		return FALSE
	owner.add_traits(list(TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTHEAT), TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMGE, PROC_REF(on_burned))
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.burn_mod *= GOLEM_PLASMA_BURN_MULTIPLIER
	return TRUE

/datum/status_effect/golem/plasma/on_remove()
	owner.remove_traits(list(TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTHEAT), TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMGE)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.burn_mod /= GOLEM_PLASMA_BURN_MULTIPLIER
	return ..()

/// When we take fire damage, zap a nearby APC
/datum/status_effect/golem/plasma/proc/on_burned(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(damagetype != BURN || damage <= 0)
		return
	var/area/our_area = get_area(owner)
	var/obj/machinery/power/apc/our_apc = our_area?.get_apc()
	if(!our_apc)
		return
	zap_effect(our_apc)
	our_apc.cell?.give(damage * GOLEM_PLASMA_ENERGY_PER_DAMAGE)

#undef GOLEM_PLASMA_ENERGY_PER_DAMAGE
#undef GOLEM_PLASMA_BURN_MULTIPLIER

/// Shoot a beam at the target atom
/datum/status_effect/golem/plasma/proc/zap_effect(atom/target)
	owner.Beam(target, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
	playsound(owner, 'sound/magic/lightningshock.ogg', 50, TRUE)

/// Makes you spaceproof
/datum/status_effect/golem/plasteel
	mineral_name = "plastal"
	applied_fluff = "Płyty z plastali szczelnie cię okrywają. Czujesz się zaizolowany!"
	alert_icon_state = "sheet-plasteel"
	alert_desc = "Jesteś odporny na zimno i niskie ciśnienie."
	filter_color = LIGHT_COLOR_DEFAULT

/datum/status_effect/golem/plasteel/on_apply()
	. = ..()
	if(!.)
		return FALSE
	owner.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/golem/plasteel/on_remove()
	owner.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), TRAIT_STATUS_EFFECT(id))
	return ..()

/// Makes you reflect energy projectiles
/datum/status_effect/golem/gold
	mineral_name = "złoto"
	applied_fluff = "Na całym ciele tworzą ci się lśniące płyty. Czujesz się lustrzany!"
	alert_icon_state = "sheet-gold_2"
	alert_desc = "Twoje lśniące ciało odbija broń energetyczną."
	filter_color = LIGHT_COLOR_DIM_YELLOW
	/// Czy to my dodaliśmy flagę (żeby nie zdjąć cudzej)
	var/added_shiny = FALSE

/datum/status_effect/golem/gold/on_apply()
	. = ..()
	if(!.)
		return FALSE
	if(!(owner.flags_ricochet & RICOCHET_SHINY))
		owner.flags_ricochet |= RICOCHET_SHINY
		added_shiny = TRUE
	return TRUE

/datum/status_effect/golem/gold/on_remove()
	if(added_shiny)
		owner.flags_ricochet &= ~RICOCHET_SHINY
	return ..()

/// Makes you hard to see
/datum/status_effect/golem/diamond
	mineral_name = "diamenty"
	applied_fluff = "Iskrzące klejnoty zaginają wokół ciebie światło. Czujesz się niewidoczny!"
	tick_interval = 0.25 SECONDS
	alert_icon_state = "sheet-diamond"
	alert_desc = "Światło zagina się wokół ciebie: stojąc, jesteś trudny do zauważenia, a w ruchu - szybszy."
	filter_color = LIGHT_COLOR_ELECTRIC_CYAN
	/// Alpha to remove per tick while stood still
	var/alpha_per_tick = 20
	/// Alpha to apply while moving
	var/moving_alpha = 200
	/// Gatunek, któremu podmieniliśmy ciosy, i jego oryginalne wartości
	var/datum/species/modified_species
	var/initial_attack_verb
	var/initial_attack_sound
	var/initial_miss_sound

/datum/status_effect/golem/diamond/on_apply()
	. = ..()
	if(!.)
		return FALSE
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_THROW, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK), PROC_REF(on_reveal))
	owner.alpha = moving_alpha
	owner.add_movespeed_modifier("[type]", multiplicative_slowdown = -0.2)
	// tg zmienia ciosy rąk na cięcia - u nas ciosy siedzą w gatunku
	var/mob/living/carbon/human/human_owner = owner
	if(istype(human_owner) && human_owner.dna?.species)
		modified_species = human_owner.dna.species
		initial_attack_verb = modified_species.attack_verb
		initial_attack_sound = modified_species.attack_sound
		initial_miss_sound = modified_species.miss_sound
		modified_species.attack_verb = "slash"
		modified_species.attack_sound = 'sound/weapons/slash.ogg'
		modified_species.miss_sound = 'sound/weapons/slashmiss.ogg'
	return TRUE

/datum/status_effect/golem/diamond/tick()
	owner.alpha = max(owner.alpha - alpha_per_tick, 0)

/// Reset alpha to starting value
/datum/status_effect/golem/diamond/proc/on_reveal()
	SIGNAL_HANDLER
	owner.alpha = moving_alpha

/datum/status_effect/golem/diamond/on_remove()
	owner.alpha = initial(owner.alpha)
	owner.remove_movespeed_modifier("[type]")
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_THROW, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK))
	var/mob/living/carbon/human/human_owner = owner
	if(modified_species && istype(human_owner) && human_owner.dna?.species == modified_species)
		modified_species.attack_verb = initial_attack_verb
		modified_species.attack_sound = initial_attack_sound
		modified_species.miss_sound = initial_miss_sound
	modified_species = null
	return ..()

/// Makes you tougher
/datum/status_effect/golem/titanium
	mineral_name = "tytan"
	applied_fluff = "Z twoich ramion wyrastają tytanowe pierścienie. Jesteś gotów stawić czoła światu!"
	alert_icon_state = "sheet-titanium"
	alert_desc = "Jesteś odporniejszy na ciosy i sam uderzasz mocniej."
	filter_color = LIGHT_COLOR_HALOGEN
	/// Amount to reduce brute damage by
	var/brute_modifier = 0.8
	/// How much extra damage do we do with our fists?
	var/damage_increase = 3
	/// Deal this much extra damage to mining mobs, most of which take 0 unarmed damage usually
	var/mining_bonus = 30

/datum/status_effect/golem/titanium/on_apply()
	. = ..()
	if(!.)
		return FALSE
	RegisterSignal(owner, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_punched))
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.brute_mod *= brute_modifier
		human_owner.unarmed_damage_bonus += damage_increase
	return TRUE

/// Give mining mobs an extra slap
/datum/status_effect/golem/titanium/proc/on_punched(mob/living/puncher, atom/punchee, proximity)
	SIGNAL_HANDLER
	if(!proximity || !isliving(punchee) || !puncher.combat_mode)
		return
	var/mob/living/victim = punchee
	if(victim.stat == DEAD || !(victim.mobility_flags & MOBILITY_STAND) || !victim.has_faction(list("mining", "boss")))
		return
	victim.apply_damage(mining_bonus, BRUTE)

/datum/status_effect/golem/titanium/on_remove()
	UnregisterSignal(owner, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.brute_mod /= brute_modifier
		human_owner.unarmed_damage_bonus -= damage_increase
	return ..()

/// Makes you slippery
/datum/status_effect/golem/bananium
	mineral_name = "bananium"
	applied_fluff = "Z twoich szczelin sączą się żyły bananium. Czujesz się trochę zabawnie!"
	alert_icon_state = "sheet-bananium"
	alert_desc = "Czujesz się jakoś zabawnie."
	filter_color = LIGHT_COLOR_BRIGHT_YELLOW
	/// The slipperiness component which we have applied
	var/datum/component/slippery/slipperiness
	/// Czy to my dodaliśmy kaczy chód
	var/added_waddle = FALSE

/datum/status_effect/golem/bananium/on_apply()
	. = ..()
	if(!.)
		return FALSE
	if(!owner.GetComponent(/datum/component/waddling))
		owner.AddComponent(/datum/component/waddling)
		added_waddle = TRUE
	ADD_TRAIT(owner, TRAIT_NOSLIPWATER, TRAIT_STATUS_EFFECT(id))
	slipperiness = owner.AddComponent(/datum/component/slippery/golem_bananium, 12 SECONDS, NO_SLIP_WHEN_WALKING)
	return TRUE

/datum/status_effect/golem/bananium/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOSLIPWATER, TRAIT_STATUS_EFFECT(id))
	if(added_waddle)
		qdel(owner.GetComponent(/datum/component/waddling))
	QDEL_NULL(slipperiness)
	return ..()

/// tg can_slip_callback: śliski tylko wtedy, gdy właściciel leży
/datum/component/slippery/golem_bananium

/datum/component/slippery/golem_bananium/Slip(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	var/mob/living/slipper = parent
	if(!istype(slipper) || (slipper.mobility_flags & MOBILITY_STAND) || arrived == slipper)
		return
	return ..()

#define LIGHTBULB_FILTER "filter_lightbulb_glow"

/datum/status_effect/golem/lightbulb
	id = "golem_lightbulb"
	status_type = STATUS_EFFECT_REFRESH
	duration = 2 MINUTES
	alert_type = null
	filter_color = null
	exclusive = FALSE
	duration_mult_per_bodypart = 0.11 // 0.34 + (0.11 * 6 bodyparts) = 1
	minimum_duration_mult = 0.34
	var/glow_range = 3
	var/glow_power = 1
	var/glow_color = LIGHT_COLOR_DEFAULT
	var/obj/effect/dummy/lighting_obj/moblight/lightbulb

/datum/status_effect/golem/lightbulb/on_apply()
	. = ..()
	if(!.)
		return FALSE
	to_chat(owner, "<span class='notice'>Zaczynasz zdrowo świecić.</span>")
	lightbulb = owner.mob_light(glow_range, glow_power, glow_color)
	owner.add_filter(LIGHTBULB_FILTER, 2, list("type" = "outline", "color" = glow_color, "alpha" = 60, "size" = 1))
	return TRUE

/datum/status_effect/golem/lightbulb/on_remove()
	QDEL_NULL(lightbulb)
	owner.remove_filter(LIGHTBULB_FILTER)
	to_chat(owner, "<span class='warning'>Twoja poświata gaśnie.</span>")
	return ..()

#undef LIGHTBULB_FILTER

// --- Ręce z minerałów (tg golem_hand_actions.dm) ---

/// How long can you hold onto gibtonite before you need to let it go?
#define GIBTONITE_GOLEM_HOLD_TIME 2 MINUTES
/// ID for a filter we apply so we can remove it again
#define BLUESPACE_GLOW_FILTER "bluespace_glow_filter"

/// Lets you hold a gibtonite ore in one hand and shoot it like a gun
/obj/item/gibtonite_hand
	name = "stabilised gibtonite fist"
	desc = "Lepiej czymś tym rzuć, zanim wyjdzie drugą stroną twojego ciała."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	lefthand_file = 'aquila/icons/mutations/tg_core/golem_lefthand.dmi'
	righthand_file = 'aquila/icons/mutations/tg_core/golem_righthand.dmi'
	item_state = "gibtonite_hand"
	item_flags = ABSTRACT | NOBLUDGEON
	w_class = WEIGHT_CLASS_HUGE
	/// The bomb we're going to throw
	var/obj/item/gibtonite/held_gibtonite

/obj/item/gibtonite_hand/Initialize(mapload, obj/item/gibtonite/held_gibtonite)
	. = ..()
	if(!held_gibtonite)
		return INITIALIZE_HINT_QDEL
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	src.held_gibtonite = held_gibtonite
	icon = held_gibtonite.icon
	icon_state = held_gibtonite.icon_state
	held_gibtonite.forceMove(src)
	addtimer(CALLBACK(src, PROC_REF(release_gibtonite)), GIBTONITE_GOLEM_HOLD_TIME, TIMER_DELETE_ME)

/obj/item/gibtonite_hand/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!held_gibtonite)
		to_chat(user, "<span class='warning'>[src] syczy - to był niewypał!</span>")
		qdel(src)
		return
	playsound(src, 'sound/weapons/sonic_jackhammer.ogg', 50, TRUE)
	var/obj/item/gibtonite/bomb = held_gibtonite
	held_gibtonite = null
	bomb.forceMove(get_turf(user))
	bomb.det_time = 2 SECONDS
	bomb.GibtoniteReaction(user, "A [src] has targeted [target] with a thrown and primed")
	bomb.throw_at(target, 10, 3, user)
	qdel(src)

/// Called when you can't hold it in any longer and just drop it on the ground
/obj/item/gibtonite_hand/proc/release_gibtonite()
	if(!held_gibtonite)
		qdel(src)
		return
	var/obj/item/gibtonite/bomb = held_gibtonite
	held_gibtonite = null
	bomb.forceMove(get_turf(src))
	bomb.GibtoniteReaction(isliving(loc) ? loc : null, "A [src] has dropped and primed a")
	qdel(src)

/obj/item/gibtonite_hand/Destroy()
	QDEL_NULL(held_gibtonite)
	return ..()

/// Point at a target and teleport somewhere vaguely close to it
/obj/item/bluespace_finger
	name = "bluespace knot"
	desc = "Chwyć mocno rzeczywistość i przyciągnij się w pobliskie miejsce."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	lefthand_file = 'aquila/icons/mutations/tg_core/golem_lefthand.dmi'
	righthand_file = 'aquila/icons/mutations/tg_core/golem_righthand.dmi'
	item_state = "bluespace_hand"
	item_flags = ABSTRACT | DROPDEL | NOBLUDGEON
	/// How far away can you point?
	var/teleport_range = 7
	/// How long does it take to teleport?
	var/teleport_time = 2 SECONDS
	/// How accurate are you?
	var/teleport_vary = 2
	/// Czy właśnie trwa teleport
	var/teleporting = FALSE

/obj/item/bluespace_finger/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(teleporting)
		return
	var/turf/target_turf = get_turf(target)
	if(!target_turf || get_dist(target_turf, get_turf(src)) > teleport_range)
		balloon_alert(user, "za daleko!")
		return
	if(is_blocked_turf(target_turf, TRUE))
		balloon_alert(user, "brak miejsca!")
		return
	INVOKE_ASYNC(src, PROC_REF(do_golem_teleport), target_turf, user)

/obj/item/bluespace_finger/proc/do_golem_teleport(turf/target_turf, mob/living/user)
	teleporting = TRUE
	var/obj/effect/temp_visual/teleport_golem/landing_indicator = new(target_turf)
	user.add_filter(BLUESPACE_GLOW_FILTER, 2, list("type" = "outline", "color" = COLOR_BRIGHT_BLUE, "alpha" = 0, "size" = 1))
	var/filter = user.get_filter(BLUESPACE_GLOW_FILTER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)

	var/did_teleport = do_after(user, teleport_time, target = user)
	qdel(landing_indicator)
	user.remove_filter(BLUESPACE_GLOW_FILTER)
	teleporting = FALSE
	if(!did_teleport || QDELETED(src))
		return

	var/list/valid_landing_tiles = list(target_turf)
	for(var/turf/potential_landing in oview(teleport_vary, target_turf))
		if(is_blocked_turf(potential_landing, TRUE))
			continue
		valid_landing_tiles += potential_landing
	var/turf/final_destination = pick(valid_landing_tiles)
	for(var/mob/living/telefrag in final_destination)
		telefrag.Knockdown(2 SECONDS)
	do_teleport(user, final_destination, asoundin = 'sound/effects/phasein.ogg', no_effects = TRUE)
	qdel(src)

/obj/effect/temp_visual/teleport_golem
	name = "bluespace silhouette"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "teleport"
	duration = 6 SECONDS

#undef GIBTONITE_GOLEM_HOLD_TIME
#undef BLUESPACE_GLOW_FILTER
