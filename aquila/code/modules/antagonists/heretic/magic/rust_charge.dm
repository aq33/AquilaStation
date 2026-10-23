// Rust charge, a charge action that can only be started on rust (destroys the walls around the charger, like in tg)
// AQUILA - w tg to /datum/action/cooldown/mob_cooldown/charge/rust. U nas nie ma akcji mob_cooldown ani move_managera,
// więc szarża jest zaklęciem z celowaniem, a ruch to pętla kroków (jak w tg: rdza, burzenie otoczenia, obrażenia).
/datum/action/cooldown/spell/pointed/rust_charge
	name = "Rust Charge"
	desc = "Szarża, którą trzeba zacząć na zardzewiałym polu. Niszczy wszystko, w co uderzysz, \
		zadaje duże obrażenia innym i rozsiewa wokół ciebie rdzę."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	aim_assist = FALSE
	// Zasięg celowania nie ogranicza szarży, długość biegu ogranicza charge_distance
	cast_range = 50

	/// Delay before the charge actually occurs
	var/charge_delay = 0.3 SECONDS
	/// The amount of turfs we move past the target
	var/charge_past = 0
	/// The maximum distance we can charge
	var/charge_distance = 10
	/// The sleep time before moving in deciseconds while charging
	var/charge_speed = 0.5
	/// The damage the charger does when bumping into something
	var/charge_damage = 25
	/// If we destroy objects while charging
	var/destroy_objects = TRUE
	/// Czy właśnie trwa szarża
	var/charging = FALSE
	/// Ile odporności na obrażenia dodaliśmy szarżującemu człowiekowi
	var/added_resistance = 0

/datum/action/cooldown/spell/pointed/rust_charge/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return
	if(charging)
		return FALSE

/datum/action/cooldown/spell/pointed/rust_charge/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	var/turf/open/start_turf = get_turf(owner)
	if(!istype(start_turf) || !HAS_TRAIT(start_turf, TRAIT_RUSTY))
		owner.balloon_alert(owner, "musisz stać na rdzy!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/rust_charge/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(do_charge), owner, cast_on)

/// Właściwa szarża (śpi między krokami)
/datum/action/cooldown/spell/pointed/rust_charge/proc/do_charge(mob/living/charger, atom/target_atom)
	var/turf/chargeturf = get_turf(target_atom)
	if(!istype(charger) || !chargeturf)
		return
	var/dir = get_dir(charger, chargeturf)
	var/turf/target = get_ranged_target_turf(chargeturf, dir, charge_past)
	if(!target)
		return

	charging = TRUE
	if(ishuman(charger))
		var/mob/living/carbon/human/human_charger = charger
		added_resistance = 100
		human_charger.physiology.damage_resistance += added_resistance
	RegisterSignal(charger, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	charger.setDir(dir)
	do_charge_indicator(charger, target)

	sleep(charge_delay)

	var/steps = min(get_dist(charger, target), charge_distance)
	for(var/i in 1 to steps)
		if(QDELETED(charger) || charger.stat == DEAD || !isturf(charger.loc))
			break
		var/turf/next_turf = get_step_towards(charger, target)
		if(!next_turf || next_turf == get_turf(charger))
			break
		charger.Move(next_turf, get_dir(charger, next_turf))
		sleep(charge_speed)

	if(!QDELETED(charger))
		charger.setDir(dir)
		charge_end(charger)
	charging = FALSE

/datum/action/cooldown/spell/pointed/rust_charge/proc/charge_end(mob/living/charger)
	UnregisterSignal(charger, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_MOVED))
	affect_aoe(charger)

/datum/action/cooldown/spell/pointed/rust_charge/proc/do_charge_indicator(atom/charger, atom/charge_target)
	var/turf/target_turf = get_turf(charge_target)
	if(!target_turf)
		return
	new /obj/effect/temp_visual/dragon_swoop/bubblegum(target_turf)
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(charger.loc, charger)
	animate(D, alpha = 0, color = COLOR_RED, transform = matrix()*2, time = 3)

/datum/action/cooldown/spell/pointed/rust_charge/proc/on_moved(mob/living/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/decoy/fading(old_loc, source)
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	var/turf/victim = get_turf(source)
	source.do_rust_heretic_act(victim)
	for(var/dir in GLOB.alldirs)
		var/turf/nearby_turf = get_step(victim, dir)
		if(istype(nearby_turf))
			source.do_rust_heretic_act(nearby_turf)

/datum/action/cooldown/spell/pointed/rust_charge/proc/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return
	for(var/dir in GLOB.alldirs)
		var/turf/source = get_turf(charger)
		var/turf/closed/next_turf = get_step(charger, dir)
		if(!istype(source) || !istype(next_turf))
			continue
		SSexplosions.medturf += next_turf

/datum/action/cooldown/spell/pointed/rust_charge/proc/on_bump(atom/movable/source, atom/target)
	SIGNAL_HANDLER
	if(owner == target)
		return
	if(destroy_objects)
		if(isturf(target))
			INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
		if(isobj(target) && target.density)
			SSexplosions.med_mov_atom += target

	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	if(isliving(target))
		hit_target(source, target, charge_damage)

/// Actually hit someone
/datum/action/cooldown/spell/pointed/rust_charge/proc/hit_target(atom/movable/source, mob/living/target, damage_dealt)
	target.visible_message(span_danger("[source] wbija się w [target]!"), span_userdanger("[source] wdeptuje cię w ziemię!"))
	target.apply_damage(damage_dealt, BRUTE)
	playsound(get_turf(target), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(target, 4, 3)
	shake_camera(source, 2, 3)

/datum/action/cooldown/spell/pointed/rust_charge/proc/affect_aoe(mob/living/charger)
	for(var/mob/living/nearby_mob in view(1, charger))
		if(nearby_mob == charger)
			continue
		nearby_mob.apply_damage(charge_damage, BRUTE)
		nearby_mob.Knockdown(5 SECONDS)
	if(added_resistance && ishuman(charger))
		var/mob/living/carbon/human/human_charger = charger
		human_charger.physiology.damage_resistance -= added_resistance
	added_resistance = 0
