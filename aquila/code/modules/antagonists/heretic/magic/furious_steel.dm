/datum/action/cooldown/spell/pointed/projectile/furious_steel
	name = "Furious Steel"
	desc = "Przywołuje trzy srebrne ostrza, które krążą wokół ciebie. \
		Krążące ostrza chronią cię przed atakami, ale znikają po użyciu. \
		Możesz też kliknięciem miotać ostrzami w cel, zadając obrażenia i wywołując krwawienie."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "furious_steel"
	sound = 'aquila/sound/items/weapons/guillotine.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS
	invocation = "F'LSH'NG S'LV'R!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = NONE

	active_msg = "Przywołujesz trzy ostrza wściekłego srebra."
	deactive_msg = "Chowasz ostrza wściekłego srebra."
	cast_range = 20
	projectile_type = /obj/item/projectile/floating_blade
	projectile_amount = 3

	///Effect of the projectile that surrounds us while the spell is active
	var/projectile_effect = /obj/effect/floating_blade
	/// A ref to the status effect surrounding our heretic on activation.
	var/datum/status_effect/protective_blades/blade_effect

/datum/action/cooldown/spell/pointed/projectile/furious_steel/InterceptClickOn(mob/living/clicker, params, atom/target)
	// Let the caster prioritize using items like guns over blade casts
	if(clicker.get_active_held_item())
		return FALSE
	// Let the caster prioritize melee attacks like punches and shoves over blade casts
	if(get_dist(clicker, target) <= 1)
		return FALSE

	return ..()

/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return

	if(!isliving(on_who))
		return
	// Delete existing
	if(blade_effect)
		stack_trace("[type] had an existing blade effect in on_activation. This might be an exploit, and should be investigated.")
		UnregisterSignal(blade_effect, COMSIG_PARENT_QDELETING)
		UnregisterSignal(blade_effect, COMSIG_BLADE_BARRIER_TRIGGERED)
		QDEL_NULL(blade_effect)

	var/mob/living/living_user = on_who
	blade_effect = living_user.apply_status_effect(/datum/status_effect/protective_blades, STATUS_EFFECT_PERMANENT, projectile_amount, 25, 0.66 SECONDS, projectile_effect)
	if(!blade_effect)
		return
	RegisterSignal(blade_effect, COMSIG_PARENT_QDELETING, PROC_REF(on_status_effect_deleted))
	RegisterSignal(blade_effect, COMSIG_BLADE_BARRIER_TRIGGERED, PROC_REF(on_status_effect_triggered))

/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(blade_effect)
		UnregisterSignal(blade_effect, COMSIG_PARENT_QDELETING)
		UnregisterSignal(blade_effect, COMSIG_BLADE_BARRIER_TRIGGERED)
		QDEL_NULL(blade_effect)

/datum/action/cooldown/spell/pointed/projectile/furious_steel/before_cast(atom/cast_on)
	if(isnull(blade_effect) || !current_amount)
		unset_click_ability(owner, refund_cooldown = FALSE)
		return SPELL_CANCEL_CAST

	return ..() | SPELL_NO_IMMEDIATE_COOLDOWN // all CD handling will be done by the status effect being deleted

/datum/action/cooldown/spell/pointed/projectile/furious_steel/fire_projectile(atom/target)
	. = ..()
	if(length(blade_effect?.blades))
		qdel(blade_effect.blades[1])

/datum/action/cooldown/spell/pointed/projectile/furious_steel/ready_projectile(obj/item/projectile/to_launch, atom/target, mob/user, iteration)
	. = ..()
	to_launch.def_zone = check_zone(user.zone_selected)

/// If our blade status effect is deleted, clear our refs and deactivate
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_status_effect_deleted(datum/status_effect/protective_blades/source)
	SIGNAL_HANDLER

	blade_effect = null
	var/blades_remaining = current_amount
	// Which scales the cooldown according to projectiles remaining
	unset_click_ability(owner, refund_cooldown = FALSE)
	// Snowflake because it does not handle cooldown if we used every projectile
	if(blades_remaining <= 0)
		StartCooldown()

/// Reduce our projectile amount when our blade status effect is triggered
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_status_effect_triggered(datum/status_effect/protective_blades/source, atom/target)
	SIGNAL_HANDLER

	if(blade_effect == source)
		current_amount -= 1

/obj/item/projectile/floating_blade
	name = "blade"
	icon = 'aquila/icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	speed = 2 // tg: 0.5 pola na tyknięcie, u nas czas na pole
	damage = 25
	armour_penetration = 100
	sharpness = SHARP_EDGED
	bleed_force = BLEED_CUT // tg: wound_bonus = 15
	pass_flags = PASSTABLE | PASSFLAPS
	/// Color applied as an outline filter on init
	var/outline_color = "#f8f8ff"

/obj/item/projectile/floating_blade/Initialize(mapload)
	. = ..()
	add_filter("dio_knife", 2, list("type" = "outline", "color" = outline_color, "size" = 1))

/obj/item/projectile/floating_blade/prehit_pierce(atom/hit)
	if(isliving(hit) && isliving(firer))
		var/mob/living/caster = firer
		var/mob/living/victim = hit
		if(caster == victim)
			return PROJECTILE_PIERCE_PHASE

		if(caster.mind)
			var/datum/antagonist/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
			if(monster?.master == caster.mind)
				return PROJECTILE_PIERCE_PHASE

		if(victim.can_block_magic(MAGIC_RESISTANCE))
			visible_message(span_warning("[src] spada na ziemię i rozpływa się w zetknięciu z [victim]!"))
			return PROJECTILE_DELETE_WITHOUT_HITTING

	return ..()

/obj/item/projectile/floating_blade/haunted
	name = "ritual blade"
	icon = 'aquila/icons/obj/weapons/khopesh.dmi'
	icon_state = "render"
	damage = 35
	bleed_force = BLEED_DEEP_WOUND // tg: wound_bonus = 25
	outline_color = "#D7CBCA"

/datum/action/cooldown/spell/pointed/projectile/furious_steel/solo
	name = "Lesser Furious Steel"
	cooldown_time = 20 SECONDS
	projectile_amount = 1
	active_msg = "Przywołujesz ostrze wściekłego srebra."
	deactive_msg = "Chowasz ostrze wściekłego srebra."

/datum/action/cooldown/spell/pointed/projectile/furious_steel/haunted
	name = "Cursed Steel"
	desc = "Przywołuje dwa przeklęte ostrza, które krążą wokół ciebie. \
		Krążące ostrza chronią cię przed atakami, ale znikają po użyciu. \
		Możesz też kliknięciem miotać ostrzami w cel, zadając obrażenia i wywołując krwawienie."
	background_icon_state = "bg_ecult" // kept intentionally
	overlay_icon_state = "bg_cult_border"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cursed_steel"
	sound = 'aquila/sound/items/weapons/guillotine.ogg'

	cooldown_time = 40 SECONDS
	invocation = "IA!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = NONE

	active_msg = "Przywołujesz dwa przeklęte ostrza."
	deactive_msg = "Chowasz przeklęte ostrza."
	projectile_amount = 2
	projectile_type = /obj/item/projectile/floating_blade/haunted
	projectile_effect = /obj/effect/floating_blade/haunted
