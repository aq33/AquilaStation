// AQUILA - zgodność wspólnych elementów heretyka (szaty, ostrza, naszyjniki, statusy) z naszym kodem.
// Elementy z tg zachowują ścieżki typów i API z tg, żeby pliki ścieżek mogły z nich korzystać.

/// Spowolnienie od zimna pustki (tg: /datum/movespeed_modifier/void_chill)
#define MOVESPEED_ID_VOID_CHILL "void_chill"

// is_touching_rust() jest w _compat/rustvoid.dm, check_behind() w _compat/bladecosmic.dm.

// ---------------------------------------------------------------------------
// Nakładki na alertach (tg: overlay_state / overlay_icon)

/atom/movable/screen/alert
	/// tg: stan nakładki rysowanej na alercie
	var/overlay_state
	/// tg: plik nakładki
	var/overlay_icon = 'aquila/icons/hud/screen_alert.dmi'

/atom/movable/screen/alert/Initialize(mapload)
	. = ..()
	if(overlay_state)
		update_appearance()

/atom/movable/screen/alert/update_overlays()
	. = ..()
	if(overlay_state)
		. += mutable_appearance(overlay_icon, overlay_state)

// ---------------------------------------------------------------------------
// Sygnały z tg, których nasz rdzeń nie wysyła

/// tg: COMSIG_LIVING_CHECK_BLOCK - blokowanie ataków przez statusy/przedmioty (np. ostrza ochronne)
/mob/living/carbon/human/check_shields(atom/AM, damage, attack_text = "atak", attack_type = MELEE_ATTACK, armour_penetration = 0)
	var/damage_type = BRUTE
	if(isitem(AM))
		var/obj/item/hitting_item = AM
		damage_type = hitting_item.damtype
	else if(isprojectile(AM))
		var/obj/item/projectile/hitting_projectile = AM
		damage_type = hitting_projectile.damage_type
	if(SEND_SIGNAL(src, COMSIG_LIVING_CHECK_BLOCK, AM, damage, attack_text, attack_type, armour_penetration, damage_type) & SUCCESSFUL_BLOCK)
		return TRUE
	return ..()

/// tg: COMSIG_MOB_TRIED_ACCESS - np. znak zamka odbiera dostęp
/obj/allowed(mob/M)
	if(ismob(M) && (SEND_SIGNAL(M, COMSIG_MOB_TRIED_ACCESS, src) & ACCESS_DISALLOWED))
		return FALSE
	return ..()

/// tg: COMSIG_ATOM_HOLYATTACK - trafienie świętą bronią
/obj/item/nullrod/attack(mob/living/M, mob/living/user, params)
	if(isliving(M))
		SEND_SIGNAL(M, COMSIG_ATOM_HOLYATTACK, src, user)
	return ..()

/// tg: COMSIG_BEING_STRIPPED - blokada rozbierania
/datum/strippable_item/try_equip(atom/source, obj/item/equipping, mob/user)
	if(equipping && (SEND_SIGNAL(source, COMSIG_BEING_STRIPPED, user, equipping) & COMPONENT_CANT_STRIP))
		return FALSE
	return ..()

/datum/strippable_item/try_unequip(atom/source, mob/user)
	. = ..()
	if(!.)
		return
	if(SEND_SIGNAL(source, COMSIG_BEING_STRIPPED, user, get_item(source)) & COMPONENT_CANT_STRIP)
		return FALSE

/// tg: COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT / _CARBON - podmiana komunikatu o trafieniu
/mob/living/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	if(I && (SEND_SIGNAL(I, COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT, src, user) & SIGNAL_MESSAGE_MODIFIED))
		return TRUE
	if(SEND_SIGNAL(src, COMSIG_SEND_ITEM_ATTACK_MESSAGE_CARBON, I, user) & SIGNAL_MESSAGE_MODIFIED)
		return TRUE
	return ..()

// tg: COMSIG_LIVING_ADJUST_*_DAMAGE - pozwala zignorować zmianę obrażeń (szaty księżyca)
/mob/living/carbon/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, BRUTE, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return 0
	return ..()

/mob/living/carbon/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_status)
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_BURN_DAMAGE, BURN, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return 0
	return ..()

/mob/living/carbon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_TOX_DAMAGE, TOX, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return 0
	return ..()

/mob/living/carbon/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	if(SEND_SIGNAL(src, COMSIG_LIVING_ADJUST_OXY_DAMAGE, OXY, amount, forced) & COMPONENT_IGNORE_CHANGE)
		return 0
	return ..()

// COMSIG_LIVING_ADJUST_STAMINA_DAMAGE wysyła teraz sama pula staminy (/datum/stamina_container/adjust)

// ---------------------------------------------------------------------------
// Cechy z tg bez odpowiednika w rdzeniu

/// tg: TRAIT_UNKNOWN_APPEARANCE - wygląda jak "Unknown"
/mob/living/carbon/human/get_visible_name()
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		return "Unknown"
	return ..()

/mob/living/carbon/human/get_face_name(if_no_face = "Unknown")
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		return if_no_face
	return ..()

/// tg: TRAIT_UNKNOWN_VOICE - mówi jako "Unknown"
/mob/living/carbon/human/GetVoice()
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_VOICE))
		return "Unknown"
	return ..()

/// tg: TRAIT_NO_WORN_ICON - przedmiot nie rysuje się na mobie
/obj/item/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, special_override_flags = NONE)
	if(!isinhands && HAS_TRAIT(src, TRAIT_NO_WORN_ICON))
		return mutable_appearance(null, null, -(alternate_worn_layer || default_layer))
	return ..()

// ---------------------------------------------------------------------------
// Halucynacje w API tg (u nas /datum/hallucination przyjmuje carbona)

/// tg: wywołuje halucynację danego typu. Dla urojeń (delusion) obsługuje czas i to, kogo dotyczą.
/mob/living/proc/cause_hallucination(hallucination_type, source = "an external source", duration, affects_us, affects_others, skip_nearby, play_wabbajack)
	if(!ispath(hallucination_type, /datum/hallucination))
		CRASH("cause_hallucination called with invalid type: [hallucination_type] ([source])")
	if(!iscarbon(src))
		return null
	var/mob/living/carbon/carbon_src = src
	if(ispath(hallucination_type, /datum/hallucination/delusion/preset))
		var/datum/hallucination/delusion/preset/preset = hallucination_type
		var/final_duration = isnull(duration) ? initial(preset.preset_duration) : duration
		var/hit_others = isnull(affects_others) ? initial(preset.preset_affects_others) : affects_others
		var/hit_us = isnull(affects_us) ? initial(preset.preset_affects_us) : affects_us
		var/skip = isnull(skip_nearby) ? FALSE : skip_nearby
		. = null
		if(hit_others)
			. = new hallucination_type(carbon_src, TRUE, "custom", final_duration, skip, initial(preset.delusion_icon_state), initial(preset.delusion_icon_file), initial(preset.delusion_name))
		if(hit_us)
			var/datum/hallucination/self_delusion/self = new /datum/hallucination/self_delusion(carbon_src, TRUE, "custom", final_duration, initial(preset.delusion_icon_state), initial(preset.delusion_icon_file), !!play_wabbajack)
			if(!.)
				. = self
		return .
	if(ispath(hallucination_type, /datum/hallucination/delusion))
		return new hallucination_type(carbon_src, TRUE, null, isnull(duration) ? 30 SECONDS : duration, isnull(skip_nearby) ? TRUE : skip_nearby)
	return new hallucination_type(carbon_src, TRUE)

/// tg: gotowe urojenia (u nas "custom" z ustalonym obrazkiem)
/datum/hallucination/delusion/preset
	/// Plik ikony urojenia
	var/delusion_icon_file = 'icons/effects/effects.dmi'
	/// Stan ikony urojenia
	var/delusion_icon_state = "nothing"
	/// Nazwa wyświetlana zamiast imion
	var/delusion_name = "..."
	/// Domyślny czas trwania
	var/preset_duration = 30 SECONDS
	/// Czy inni wyglądają inaczej dla ofiary
	var/preset_affects_others = TRUE
	/// Czy ofiara widzi siebie inaczej
	var/preset_affects_us = FALSE

/datum/hallucination/delusion/preset/moon
	delusion_icon_file = 'aquila/icons/mob/nonhuman-player/eldritch_mobs.dmi'
	delusion_icon_state = "moon_mass"
	delusion_name = "moon"
	preset_duration = 15 SECONDS

// Halucynacja obrazów heretyka. tg buduje wygląd człowieka w szatach; u nas najbliższy gotowy obrazek.
/datum/hallucination/delusion/preset/heretic
	delusion_icon_file = 'aquila/icons/mob/nonhuman-player/eldritch_mobs.dmi'
	delusion_icon_state = "stalker"
	delusion_name = "Heretic"
	preset_duration = 11 SECONDS

/datum/hallucination/delusion/preset/heretic/gate
	delusion_name = "Mind Gate"
	preset_duration = 60 SECONDS
	preset_affects_us = TRUE

// ---------------------------------------------------------------------------
// Kosmiczny prześladowca (szaty kosmosu zakładane przez nie-heretyka)

/datum/brain_trauma/magic/stalker/cosmic
	random_gain = FALSE

/datum/brain_trauma/magic/stalker/cosmic/create_stalker()
	var/turf/stalker_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z)
	stalker = new /obj/effect/hallucination/simple/stalker_phantom/cosmic(stalker_source, owner)

/obj/effect/hallucination/simple/stalker_phantom/cosmic
	image_icon = 'aquila/icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	image_state = "star_gazer"
	px = -32

// ---------------------------------------------------------------------------
// /datum/component/aura_healing z tg

#define HEAL_EFFECT_COOLDOWN (1 SECONDS)

/// Applies healing to those in the area.
/// Will provide them with an alert while they're in range, as well as
/// give them a healing particle.
/// Can be applied to those only with a trait conditionally.
/datum/component/aura_healing
	/// The range of which to heal
	var/range = 5
	/// Whether or not you must be a visible object of the parent
	var/requires_visibility = TRUE
	/// Brute damage to heal over a second
	var/brute_heal = 0
	/// Burn damage to heal over a second
	var/burn_heal = 0
	/// Toxin damage to heal over a second
	var/toxin_heal = 0
	/// Suffocation damage to heal over a second
	var/suffocation_heal = 0
	/// Stamina damage to heal over a second
	var/stamina_heal = 0
	/// Amount of blood to heal over a second
	var/blood_heal = 0
	/// Amount of bleeding to stop per second (tg: wound clotting)
	var/wound_clotting = 0
	/// Map of organ (such as ORGAN_SLOT_BRAIN) to damage heal over a second
	var/list/organ_healing = null
	/// Amount of damage to heal on simple mobs over a second
	var/simple_heal = 0
	/// Trait to limit healing to, if set
	var/limit_to_trait = null
	/// The color to give the healing visual
	var/healing_color = COLOR_GREEN
	/// If the aura also heals the owner of the component
	var/self_heal = TRUE
	/// A list of being healed to active alerts
	var/list/mob/living/current_alerts = list()
	/// Cooldown between showing the heal effect
	COOLDOWN_DECLARE(last_heal_effect_time)
	/// Kiedy ostatnio leczyliśmy (u nas SSprocessing nie podaje delty)
	var/last_process_time = 0

/datum/component/aura_healing/Initialize(
	range = 5,
	requires_visibility = TRUE,
	brute_heal = 0,
	burn_heal = 0,
	toxin_heal = 0,
	suffocation_heal = 0,
	stamina_heal = 0,
	blood_heal = 0,
	wound_clotting = 0,
	organ_healing = null,
	simple_heal = 0,
	limit_to_trait = null,
	healing_color = COLOR_GREEN,
	self_heal = TRUE,
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	START_PROCESSING(SSprocessing, src)
	last_process_time = world.time

	src.range = range
	src.requires_visibility = requires_visibility
	src.brute_heal = brute_heal
	src.burn_heal = burn_heal
	src.toxin_heal = toxin_heal
	src.suffocation_heal = suffocation_heal
	src.stamina_heal = stamina_heal
	src.blood_heal = blood_heal
	src.wound_clotting = wound_clotting
	src.organ_healing = organ_healing
	src.simple_heal = simple_heal
	src.limit_to_trait = limit_to_trait
	src.healing_color = healing_color
	src.self_heal = self_heal

/datum/component/aura_healing/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	var/alert_category = "aura_healing_[REF(src)]"
	for(var/mob/living/alert_holder as anything in current_alerts)
		alert_holder.clear_alert(alert_category)
	current_alerts.Cut()
	return ..()

/datum/component/aura_healing/process()
	var/seconds_per_tick = clamp((world.time - last_process_time) / 10, 0, 5)
	last_process_time = world.time
	var/should_show_effect = COOLDOWN_FINISHED(src, last_heal_effect_time)
	if(should_show_effect)
		COOLDOWN_START(src, last_heal_effect_time, HEAL_EFFECT_COOLDOWN)

	var/list/to_heal = list()
	var/alert_category = "aura_healing_[REF(src)]"

	var/list/candidates = requires_visibility ? view(range, parent) : range(range, parent)
	for(var/mob/living/candidate in candidates)
		if(!isnull(limit_to_trait) && !HAS_TRAIT(candidate, limit_to_trait))
			continue
		if(!self_heal && candidate == parent)
			continue
		to_heal[candidate] = TRUE

	for(var/mob/living/candidate as anything in to_heal)
		if(!current_alerts[candidate])
			var/atom/movable/screen/alert/aura_healing/alert = candidate.throw_alert(alert_category, /atom/movable/screen/alert/aura_healing, new_master = parent)
			if(alert)
				alert.desc = "Leczy cię [parent]."
			current_alerts[candidate] = TRUE

		if(should_show_effect && candidate.health < candidate.maxHealth)
			new /obj/effect/temp_visual/heal(get_turf(candidate), healing_color)

		if(iscarbon(candidate) || issilicon(candidate))
			candidate.adjustBruteLoss(-brute_heal * seconds_per_tick, updating_health = FALSE)
			candidate.adjustFireLoss(-burn_heal * seconds_per_tick, updating_health = FALSE)

		if(iscarbon(candidate))
			var/mob/living/carbon/carbidate = candidate
			// Toxin healing is forced for slime people
			carbidate.adjustToxLoss(-toxin_heal * seconds_per_tick, updating_health = FALSE, forced = TRUE)
			carbidate.adjustOxyLoss(-suffocation_heal * seconds_per_tick, updating_health = FALSE)
			carbidate.adjustStaminaLoss(-stamina_heal * seconds_per_tick, updating_health = FALSE)
			for(var/organ in organ_healing)
				carbidate.adjustOrganLoss(organ, -organ_healing[organ] * seconds_per_tick)
			if(wound_clotting)
				carbidate.cauterise_wounds(wound_clotting * seconds_per_tick)
		else if(isanimal(candidate))
			candidate.adjustBruteLoss(-simple_heal * seconds_per_tick, updating_health = FALSE)

		if(blood_heal && candidate.blood_volume < BLOOD_VOLUME_NORMAL)
			candidate.blood_volume = min(candidate.blood_volume + blood_heal * seconds_per_tick, BLOOD_VOLUME_NORMAL)

		candidate.updatehealth()

	for(var/mob/living/remove_alert_from as anything in current_alerts - to_heal)
		remove_alert_from.clear_alert(alert_category)
		current_alerts -= remove_alert_from

/atom/movable/screen/alert/aura_healing
	name = "Aura Healing"
	desc = "Coś cię leczy."
	icon_state = "template"

#undef HEAL_EFFECT_COOLDOWN

// ---------------------------------------------------------------------------
// /datum/component/blood_walk z tg

///Blood walk, a component that causes you to make blood wherever you walk.
/datum/component/blood_walk
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///How many blood pools can we create?
	///If we reach 0, we will stop leaving blood and self delete
	var/blood_remaining = 0
	///Typepath of what blood decal we create on walk
	var/blood_type
	///The sound that plays when we spread blood.
	var/sound_played
	///How loud will the sound be, if there is one.
	var/sound_volume
	///The chance of spawning blood whenever walking
	var/blood_spawn_chance
	///Should the decal face the direction of the parent
	var/target_dir_change
	///Should we transfer the parent's blood DNA to created blood decal
	var/transfer_blood_dna
	///List of additional blood DNA we're adding to the decal
	var/list/blood_dna_info

/datum/component/blood_walk/Initialize(
	blood_type = /obj/effect/decal/cleanable/blood,
	sound_played,
	sound_volume = 80,
	blood_spawn_chance = 100,
	target_dir_change = FALSE,
	transfer_blood_dna = FALSE,
	max_blood = INFINITY,
	list/blood_dna_info = list("meaty DNA" = "MT-"),
)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.blood_type = blood_type
	src.sound_played = sound_played
	src.sound_volume = sound_volume
	src.blood_spawn_chance = blood_spawn_chance
	src.target_dir_change = target_dir_change
	src.transfer_blood_dna = transfer_blood_dna
	src.blood_dna_info = blood_dna_info?.Copy()
	blood_remaining = max_blood

/datum/component/blood_walk/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(spread_blood), override = TRUE)

/datum/component/blood_walk/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/blood_walk/InheritComponent(
	datum/component/new_comp,
	i_am_original,
	blood_type = /obj/effect/decal/cleanable/blood,
	sound_played,
	sound_volume = 80,
	blood_spawn_chance = 100,
	target_dir_change = FALSE,
	transfer_blood_dna = FALSE,
	max_blood = INFINITY,
)
	if(!i_am_original)
		return
	if(max_blood >= INFINITY || blood_remaining >= INFINITY)
		return
	// Applying a new version of the blood walk component will add the new version's step count to our's.
	blood_remaining += max_blood

///Spawns blood (if possible) under the source, and plays a sound effect (if any)
/datum/component/blood_walk/proc/spread_blood(atom/movable/source)
	SIGNAL_HANDLER

	var/turf/current_turf = source.loc
	if(!isturf(current_turf) || isclosedturf(current_turf) || isspaceturf(current_turf) || istype(current_turf, /turf/open/openspace))
		return
	if(!prob(blood_spawn_chance))
		return

	var/obj/effect/decal/cleanable/blood/blood = new blood_type(current_turf)
	if(QDELETED(blood)) // Our blood was placed on somewhere it shouldn't be and qdeleted in init.
		return
	var/list/blood_DNA = blood_dna_info ? blood_dna_info.Copy() : list()
	if(transfer_blood_dna)
		var/list/source_dna = source.return_blood_DNA()
		if(length(source_dna))
			blood_DNA |= source_dna
	if(length(blood_DNA))
		blood.add_blood_DNA(blood_DNA)

	if(target_dir_change)
		blood.setDir(source.dir)
	if(!isnull(sound_played))
		playsound(source, sound_played, sound_volume, TRUE, 2, TRUE)

	blood_remaining = max(blood_remaining - 1, 0)
	if(blood_remaining <= 0)
		qdel(src)

// ---------------------------------------------------------------------------
// /datum/component/leash z tg (bez wyszukiwania ścieżki - u nas krok po kroku, a w ostateczności teleport)

/// Keeps the parent within the distance of its owner as naturally as possible,
/// but teleporting if necessary.
/datum/component/leash
	/// The owner of the leash. If this is qdeleted, the leash is as well.
	var/atom/owner
	/// The maximum distance you can move from your owner
	var/distance
	/// The object type to create on the old turf when forcibly teleporting out
	var/force_teleport_out_effect
	/// The object type to create on the new turf when forcibly teleporting out
	var/force_teleport_in_effect
	/// Avoid sending out "too far" bubbles
	var/silent = FALSE
	/// Should we snap instead of teleporting back?
	var/snap_on_teleport = FALSE
	/// Czy właśnie sami przesuwamy rodzica
	var/performing_path_move = FALSE

/datum/component/leash/Initialize(
	atom/owner,
	distance = 3,
	force_teleport_out_effect,
	force_teleport_in_effect,
	silent = FALSE,
	snap_on_teleport = FALSE,
)
	. = ..()
	if(!ismovable(parent))
		stack_trace("Parent must be a movable")
		return COMPONENT_INCOMPATIBLE
	if(!isatom(owner))
		stack_trace("[owner] (owner) is not an atom")
		return COMPONENT_INCOMPATIBLE
	if(!isnum(distance))
		stack_trace("[distance] (distance) must be a number")
		return COMPONENT_INCOMPATIBLE

	src.owner = owner
	src.distance = distance
	src.force_teleport_out_effect = force_teleport_out_effect
	src.force_teleport_in_effect = force_teleport_in_effect
	src.silent = silent
	src.snap_on_teleport = snap_on_teleport

	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(on_owner_qdel))
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_parent_pre_move))
	if(ismovable(owner))
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	check_distance()

/datum/component/leash/Destroy()
	owner = null
	return ..()

/datum/component/leash/proc/set_distance(distance)
	ASSERT(isnum(distance))
	src.distance = distance
	check_distance()

/datum/component/leash/proc/on_owner_qdel()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/leash/proc/on_owner_moved(atom/movable/source)
	SIGNAL_HANDLER
	check_distance()

/datum/component/leash/proc/on_parent_pre_move(atom/movable/source, atom/new_location)
	SIGNAL_HANDLER
	if(performing_path_move)
		return NONE
	var/turf/new_location_turf = get_turf(new_location)
	if(get_dist(new_location_turf, owner) <= distance)
		return NONE
	if(ismob(source) && !silent)
		source.balloon_alert(source, "za daleko!")
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/leash/proc/check_distance()
	if(QDELETED(owner) || get_dist(parent, owner) <= distance)
		return
	var/atom/movable/atom_parent = parent
	if(isnull(owner.loc))
		atom_parent.moveToNullspace()
		return
	if(isnull(atom_parent.loc) || atom_parent.z != owner.z)
		force_teleport_back("in nullspace")
		return

	performing_path_move = TRUE
	var/steps = 0
	while(get_dist(atom_parent, owner) > distance && steps < 5)
		steps++
		var/turf/next_step = get_step_towards(atom_parent, owner)
		if(!next_step || !atom_parent.Move(next_step, get_dir(atom_parent, next_step)))
			break
	performing_path_move = FALSE

	if(get_dist(atom_parent, owner) > distance)
		force_teleport_back("incomplete path")

/datum/component/leash/proc/force_teleport_back(reason)
	if(snap_on_teleport)
		qdel(src)
		return
	var/atom/movable/movable_parent = parent
	if(force_teleport_out_effect)
		new force_teleport_out_effect(movable_parent.loc)
	performing_path_move = TRUE
	movable_parent.forceMove(get_turf(owner))
	performing_path_move = FALSE
	if(force_teleport_in_effect)
		new force_teleport_in_effect(movable_parent.loc)
	if(ismob(movable_parent) && !silent)
		movable_parent.balloon_alert(movable_parent, "za daleko!")
