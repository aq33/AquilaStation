// AQUILA - brakujące kawałki do mutacji z Yogstation

// --- Zaklęcie strzelające pociskiem (tg /datum/action/cooldown/spell/pointed/projectile) ---

/datum/action/cooldown/spell/pointed/projectile
	/// Jakim pociskiem strzelamy
	var/obj/item/projectile/projectile_type
	/// Ile strzałów na jedno włączenie celowania
	var/projectile_amount = 1
	/// Ile strzałów zostało
	var/current_amount = 0
	/// Ile pocisków na jeden strzał
	var/projectiles_per_fire = 1

/datum/action/cooldown/spell/pointed/projectile/New(Target)
	. = ..()
	if(projectile_amount > 1)
		unset_after_click = FALSE

// Pociskiem można strzelić w cokolwiek, także we własne pole
/datum/action/cooldown/spell/pointed/projectile/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/projectile/on_activation(mob/on_who)
	. = ..()
	current_amount = projectile_amount

/datum/action/cooldown/spell/pointed/projectile/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(projectile_amount > 1 && current_amount)
		StartCooldown(cooldown_time * ((projectile_amount - current_amount) / projectile_amount))
		current_amount = 0

/datum/action/cooldown/spell/pointed/projectile/cast(atom/cast_on)
	. = ..()
	if(!isturf(owner.loc))
		return FALSE
	var/turf/caster_turf = get_turf(owner)
	var/turf/caster_front_turf = get_step(owner, owner.dir)
	fire_projectile(cast_on)
	owner.newtonian_move(get_dir(caster_front_turf, caster_turf))
	if(current_amount <= 0)
		unset_click_ability(owner, refund_cooldown = FALSE)
	return TRUE

/datum/action/cooldown/spell/pointed/projectile/after_cast(atom/cast_on)
	. = ..()
	// Zostały strzały, więc bez odnowienia
	if(current_amount > 0)
		reset_spell_cooldown()

/datum/action/cooldown/spell/pointed/projectile/proc/fire_projectile(atom/target)
	current_amount--
	for(var/i in 1 to projectiles_per_fire)
		var/obj/item/projectile/to_fire = new projectile_type(get_turf(owner))
		ready_projectile(to_fire, target, owner, i)
		if(QDELETED(to_fire))
			continue
		to_fire.fire()
	return TRUE

/datum/action/cooldown/spell/pointed/projectile/proc/ready_projectile(obj/item/projectile/to_fire, atom/target, mob/user, iteration)
	to_fire.firer = owner
	to_fire.fired_from = get_turf(owner)
	to_fire.preparePixelProjectile(target, owner)

// --- Odporność na rany (tg TRAIT_HARDLY_WOUNDED) ---

/// Rzadziej łapie rany (tg)
#define TRAIT_HARDLY_WOUNDED "hardly_wounded"
/// Gęste kości z mutacji Bone Densification: trochę mniejsze obrażenia liczone do ran
#define TRAIT_YOG_DENSE_BONES "yog_dense_bones"

// Lekkie rany nie mają pancerza ran, więc odporność zmniejsza obrażenia, od których losuje się rana
/mob/living/carbon/check_wounding(obj/item/bodypart/limb, damage, wound_type)
	if(HAS_TRAIT(src, TRAIT_YOG_DENSE_BONES))
		damage *= 0.9
	if(HAS_TRAIT(src, TRAIT_HARDLY_WOUNDED))
		damage *= 0.85
	return ..()
