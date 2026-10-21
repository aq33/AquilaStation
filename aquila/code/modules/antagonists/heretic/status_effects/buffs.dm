// POTIONS

// CRUCIBLE SOUL
/datum/status_effect/crucible_soul
	id = "Blessing of Crucible Soul"
	status_type = STATUS_EFFECT_REFRESH
	duration = 40 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/crucible_soul
	show_duration = TRUE
	///Stores the location where the mob drank the potion, used to teleport the drinker back to the spot after expiration
	var/turf/location

/datum/status_effect/crucible_soul/on_apply()
	to_chat(owner,span_notice("Przenikasz przez rzeczywistość, nic nie jest poza twoim zasięgiem!"))
	owner.alpha = 180
	owner.pass_flags |= PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS | PASSVEHICLE
	location = get_turf(owner)
	var/datum/action/cancel_crucible_soul/cancel_button = new(owner)
	cancel_button.Grant(owner)
	return TRUE

/datum/status_effect/crucible_soul/on_remove()
	to_chat(owner,span_notice("Odzyskujesz cielesność i wracasz do pierwotnego miejsca..."))
	owner.alpha = initial(owner.alpha)
	owner.pass_flags &= ~(PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS | PASSVEHICLE)
	if(location)
		owner.forceMove(location)
	owner.apply_status_effect(/datum/status_effect/crucible_soul_cooldown)
	location = null
	for(var/datum/action/cancel_crucible_soul/cancel_button in owner.actions)
		qdel(cancel_button)

/datum/status_effect/crucible_soul/get_examine_text(mob/examiner)
	return span_notice("[owner.p_they(TRUE)] nie wydaje się do końca obecny.")

/datum/action/cancel_crucible_soul
	name = "Recall"
	desc = "Kończy błogosławieństwo przed czasem."
	icon_icon = 'aquila/icons/obj/antags/eldritch.dmi'
	button_icon_state = "crucible_soul"

/datum/action/cancel_crucible_soul/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/living_owner = owner
	if(!istype(living_owner))
		return
	var/datum/status_effect/active_effect = living_owner.has_status_effect(/datum/status_effect/crucible_soul)
	if(active_effect)
		qdel(active_effect)

/datum/status_effect/crucible_soul_cooldown
	id = "Crucible Soul Cooldown"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 2 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/crucible_soul/cooldown
	show_duration = TRUE
	remove_on_fullheal = TRUE

// DUSK AND DAWN
/datum/status_effect/duskndawn
	id = "Blessing of Dusk and Dawn"
	status_type = STATUS_EFFECT_REFRESH
	duration = 90 SECONDS
	show_duration = TRUE
	alert_type =/atom/movable/screen/alert/status_effect/duskndawn

/datum/status_effect/duskndawn/on_apply()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
	return TRUE

/datum/status_effect/duskndawn/on_remove()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()

// WOUNDED SOLDIER
/datum/status_effect/marshal
	id = "Blessing of Wounded Soldier"
	status_type = STATUS_EFFECT_REFRESH
	duration = 60 SECONDS
	tick_interval = 1 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/marshal

/datum/status_effect/marshal/on_apply()
	// AQUILA - tg: odporność na spowolnienie od obrażeń (movespeed immunity)
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_STATUS_EFFECT(id))
	owner.update_movespeed()
	return TRUE

/datum/status_effect/marshal/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_STATUS_EFFECT(id))
	owner.update_movespeed()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/drinker = owner
	// AQUILA - u nas zamiast ran jest krwawienie
	drinker.cauterise_wounds()
	if(length(drinker.get_missing_limbs()))
		drinker.regenerate_limbs()
		to_chat(drinker, span_hypnophrase("Mansus dał ci nowe kończyny."))
	playsound(drinker, 'sound/misc/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)

/datum/status_effect/marshal/tick(seconds_between_ticks)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbie = owner

	carbie.adjustBruteLoss(-0.5 * seconds_between_ticks, updating_health = FALSE)
	carbie.adjustFireLoss(-0.5 * seconds_between_ticks, updating_health = FALSE)
	// AQUILA - tg leczy rany zależnie od ich ciężkości; u nas im mocniej krwawisz, tym mocniej leczy
	var/bleed_rate = carbie.get_bleed_rate()
	if(bleed_rate)
		var/heal_amt = 1
		if(bleed_rate >= BLEED_CRITICAL)
			heal_amt = 6
		else if(bleed_rate >= BLEED_CUT)
			heal_amt = 3
		carbie.adjustBruteLoss(-heal_amt, updating_health = FALSE)
		carbie.adjust_blood_volume(heal_amt * 3, maximum = BLOOD_VOLUME_NORMAL)
		carbie.cauterise_wounds(0.2 * seconds_between_ticks)
	carbie.updatehealth()

/atom/movable/screen/alert/status_effect/crucible_soul
	name = "Blessing of Crucible Soul"
	desc = "Przenikasz przez rzeczywistość. Jesteś w połowie drogi do celu..."
	icon = 'aquila/icons/hud/screen_alert.dmi'
	icon_state = "crucible"

/atom/movable/screen/alert/status_effect/crucible_soul/cooldown
	desc = "Niedawno przenikałeś przez rzeczywistość. Musisz odczekać, zanim zrobisz to ponownie."
	icon_state = "crucible_cooldown"

/atom/movable/screen/alert/status_effect/duskndawn
	name = "Blessing of Dusk and Dawn"
	desc = "Wiele rzeczy kryje się za horyzontem. Z pomocą Sowy udało mi się prześlizgnąć obok straży Słońca i warty Księżyca."
	icon = 'aquila/icons/hud/screen_alert.dmi'
	icon_state = "duskndawn"

/atom/movable/screen/alert/status_effect/marshal
	name = "Blessing of Wounded Soldier"
	desc = "Niektórzy szukają mocy w odkupieniu. Mało kto wie, że bitwa jest odkupieniem ostatecznym, \
		a rany pozwalają pławić się w wiecznej chwale."
	icon = 'aquila/icons/hud/screen_alert.dmi'
	icon_state = "wounded_soldier"

// BLADES

/// Summons multiple foating knives around the owner.
/// Each knife will block an attack straight up.
/datum/status_effect/protective_blades
	id = "Silver Knives"
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = STATUS_EFFECT_NO_TICK
	/// The number of blades we summon up to.
	var/max_num_blades = 4
	/// The radius of the blade's orbit.
	var/blade_orbit_radius = 20
	/// The time between spawning blades.
	var/time_between_initial_blades = 0.25 SECONDS
	/// If TRUE, we self-delete our status effect after all the blades are deleted.
	var/delete_on_blades_gone = TRUE
	/// What blade type to create
	var/obj/effect/floating_blade/blade_type
	/// A list of blade effects orbiting / protecting our owner
	var/list/obj/effect/floating_blade/blades = list()

/datum/status_effect/protective_blades/on_creation(
	mob/living/new_owner,
	new_duration = STATUS_EFFECT_PERMANENT,
	max_num_blades = 4,
	blade_orbit_radius = 20,
	time_between_initial_blades = 0.25 SECONDS,
	blade_type = /obj/effect/floating_blade,
)

	src.duration = new_duration
	src.max_num_blades = max_num_blades
	src.blade_orbit_radius = blade_orbit_radius
	src.time_between_initial_blades = time_between_initial_blades
	src.blade_type = blade_type
	return ..()

/datum/status_effect/protective_blades/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_shield_reaction))
	for(var/blade_num in 1 to max_num_blades)
		var/time_until_created = (blade_num - 1) * time_between_initial_blades
		if(time_until_created <= 0)
			create_blade()
		else
			addtimer(CALLBACK(src, PROC_REF(create_blade)), time_until_created)

	return TRUE

/datum/status_effect/protective_blades/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK)
	QDEL_LIST(blades)

	return ..()

/// Creates a floating blade, adds it to our blade list, and makes it orbit our owner.
/datum/status_effect/protective_blades/proc/create_blade()
	if(QDELETED(src) || QDELETED(owner))
		return

	var/obj/effect/floating_blade/blade = new blade_type(get_turf(owner))
	blades += blade
	blade.orbit(owner, blade_orbit_radius)
	RegisterSignal(blade, COMSIG_PARENT_QDELETING, PROC_REF(remove_blade))
	playsound(get_turf(owner), 'sound/items/unsheath.ogg', 33, TRUE)

/// Signal proc for [COMSIG_LIVING_CHECK_BLOCK].
/// If we have a blade in our list, consume it and block the incoming attack (shield it)
/datum/status_effect/protective_blades/proc/on_shield_reaction(
	mob/living/carbon/human/source,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE,
)
	SIGNAL_HANDLER

	if(!length(blades))
		return

	if(HAS_TRAIT(source, TRAIT_BEING_BLADE_SHIELDED))
		return

	SEND_SIGNAL(src, COMSIG_BLADE_BARRIER_TRIGGERED)
	SEND_SIGNAL(source, COMSIG_MOB_BLADE_BARRIER_TRIGGERED, src)
	ADD_TRAIT(source, TRAIT_BEING_BLADE_SHIELDED, TRAIT_STATUS_EFFECT(id))
	addtimer(CALLBACK(src, PROC_REF(clear_shielded), source), 0.1 SECONDS)

	var/obj/effect/floating_blade/to_remove = blades[1]

	playsound(get_turf(source), 'sound/weapons/parry.ogg', 100, TRUE)
	source.visible_message(
		span_warning("[to_remove] krążący wokół [source] wskakuje przed [attack_text] i blokuje cios, po czym znika!"),
		span_warning("[to_remove] krążący wokół ciebie wskakuje przed [attack_text] i blokuje cios, po czym znika!"),
		span_hear("Słyszysz brzęk."),
	)

	qdel(to_remove)

	return SUCCESSFUL_BLOCK

/// Remove deleted blades from our blades list properly.
/datum/status_effect/protective_blades/proc/remove_blade(obj/effect/floating_blade/to_remove)
	SIGNAL_HANDLER

	if(!(to_remove in blades))
		CRASH("[type] called remove_blade() with a blade that was not in its blades list.")

	if(owner)
		to_remove.stop_orbit(owner.orbiters)
	blades -= to_remove

	if(!length(blades) && !QDELETED(src) && delete_on_blades_gone)
		qdel(src)

	return TRUE

/// A subtype that doesn't self-delete / disappear when all blades are gone
/// It instead regenerates over time back to the max after blades are consumed
/datum/status_effect/protective_blades/recharging
	delete_on_blades_gone = FALSE
	/// The amount of time it takes for a blade to recharge
	var/blade_recharge_time = 1 MINUTES

/datum/status_effect/protective_blades/recharging/on_creation(
	mob/living/new_owner,
	new_duration = STATUS_EFFECT_PERMANENT,
	max_num_blades = 4,
	blade_orbit_radius = 20,
	time_between_initial_blades = 0.25 SECONDS,
	blade_type = /obj/effect/floating_blade,
	blade_recharge_time = 1 MINUTES,
)

	src.blade_recharge_time = blade_recharge_time
	return ..()

/datum/status_effect/protective_blades/recharging/remove_blade(obj/effect/floating_blade/to_remove)
	. = ..()
	if(!.)
		return

	addtimer(CALLBACK(src, PROC_REF(create_blade)), blade_recharge_time)


/datum/status_effect/caretaker_refuge
	id = "Caretaker’s Last Refuge"
	status_type = STATUS_EFFECT_REFRESH
	duration = STATUS_EFFECT_PERMANENT
	alert_type = null
	var/static/list/caretaking_traits = list(TRAIT_GODMODE, TRAIT_HANDS_BLOCKED, TRAIT_IGNORESLOWDOWN, TRAIT_SECLUDED_LOCATION)

/datum/status_effect/caretaker_refuge/on_apply()
	animate(owner, alpha = 45, time = 0.5 SECONDS)
	owner.density = FALSE
	// AQUILA - tg: TRAIT_GODMODE; u nas nieśmiertelność to flaga GODMODE
	owner.status_flags |= GODMODE
	RegisterSignal(owner, COMSIG_MOB_BEFORE_SPELL_CAST, PROC_REF(prevent_spell_usage))
	RegisterSignal(owner, COMSIG_ATOM_HOLYATTACK, PROC_REF(nullrod_handler))
	RegisterSignal(owner, COMSIG_CARBON_CUFF_ATTEMPTED, PROC_REF(prevent_cuff))
	RegisterSignal(owner, COMSIG_BEING_STRIPPED, PROC_REF(no_strip))
	owner.add_traits(caretaking_traits, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/caretaker_refuge/on_remove()
	owner.remove_traits(caretaking_traits, TRAIT_STATUS_EFFECT(id))
	owner.status_flags &= ~GODMODE
	owner.alpha = initial(owner.alpha)
	owner.density = initial(owner.density)
	UnregisterSignal(owner, COMSIG_MOB_BEFORE_SPELL_CAST)
	UnregisterSignal(owner, COMSIG_ATOM_HOLYATTACK)
	UnregisterSignal(owner, COMSIG_CARBON_CUFF_ATTEMPTED)
	UnregisterSignal(owner, COMSIG_BEING_STRIPPED)
	owner.visible_message(
		span_warning("Mgła wokół [owner] znika i postać znów się materializuje!"),
		span_notice("Opuszczasz schronienie."),
	)

/datum/status_effect/caretaker_refuge/get_examine_text(mob/examiner)
	return span_warning("[owner.p_they(TRUE)] jest spowity bezbożną mgłą!")

/datum/status_effect/caretaker_refuge/proc/nullrod_handler(datum/source, obj/item/weapon)
	SIGNAL_HANDLER
	playsound(get_turf(owner), 'sound/effects/curse1.ogg', 80, TRUE)
	owner.visible_message(span_warning("[weapon] rozprasza mgłę wokół [owner]!"))
	owner.remove_status_effect(type)

/datum/status_effect/caretaker_refuge/proc/no_strip(atom/source, mob/user, obj/item/equipping)
	SIGNAL_HANDLER
	to_chat(user, span_warning("Nie możesz niczego zrobić z [source] - jest bezcielesny!"))
	return COMPONENT_CANT_STRIP

/datum/status_effect/caretaker_refuge/proc/prevent_spell_usage(datum/source, datum/spell)
	SIGNAL_HANDLER
	if(!istype(spell, /datum/action/cooldown/spell/caretaker))
		owner.balloon_alert(owner, "nie można rzucać zaklęć w schronieniu!")
		return SPELL_CANCEL_CAST

/datum/status_effect/caretaker_refuge/proc/prevent_cuff(datum/source, mob/attemptee)
	SIGNAL_HANDLER
	return COMSIG_CARBON_CUFF_PREVENT

// AQUILA - u nas sygnał próby skucia nie może jej przerwać, więc kajdanki same sprawdzają schronienie
/obj/item/restraints/handcuffs/attack(mob/living/carbon/C, mob/living/user)
	if(istype(C) && C.has_status_effect(/datum/status_effect/caretaker_refuge))
		to_chat(user, span_warning("Kajdanki przenikają przez bezcielesne dłonie [C]!"))
		return
	return ..()

// Path Of Moon status effect which hides the identity of the heretic
/datum/status_effect/moon_grasp_hide
	id = "Moon Grasp Hide Identity"
	status_type = STATUS_EFFECT_REFRESH
	duration = 15 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/moon_grasp_hide

/datum/status_effect/moon_grasp_hide/on_apply()
	owner.add_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/moon_grasp_hide/on_remove()
	owner.remove_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS), TRAIT_STATUS_EFFECT(id))

/atom/movable/screen/alert/status_effect/moon_grasp_hide
	name = "Blessing of The Moon"
	desc = "Księżyc mąci im wzrok, tak jak słońce zawsze mąciło twój."
	icon = 'aquila/icons/hud/screen_alert.dmi'
	icon_state = "moon_hide"

// Last Resort
/datum/status_effect/heretic_lastresort
	id = "heretic_lastresort"
	alert_type = /atom/movable/screen/alert/status_effect/heretic_lastresort
	duration = 12 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = STATUS_EFFECT_NO_TICK

/atom/movable/screen/alert/status_effect/heretic_lastresort
	name = "Last Resort"
	desc = "Kręci ci się w głowie, a serce bije tak szybko, jak tylko może!"
	icon = 'aquila/icons/hud/screen_alert.dmi'
	icon_state = "lastresort"

/datum/status_effect/heretic_lastresort/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))
	owner.update_movespeed()
	to_chat(owner, span_userdanger("Nie poddasz się tak łatwo!"))
	return TRUE

/datum/status_effect/heretic_lastresort/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))
	owner.update_movespeed()

/// AQUILA - tg: TRAIT_CALLBACK_REMOVE; zdejmuje blokadę wielokrotnego bloku
/datum/status_effect/protective_blades/proc/clear_shielded(mob/living/source)
	if(!QDELETED(source))
		REMOVE_TRAIT(source, TRAIT_BEING_BLADE_SHIELDED, TRAIT_STATUS_EFFECT(id))
