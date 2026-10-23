/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void
	name = "Void Blast"
	desc = "Wystrzeliwuje przed siebie stożek mroźnej pustki, zamrażając wszystko na swojej drodze. \
		Wrogowie w stożku odniosą lekkie obrażenia, zostaną spowolnieni i będą stopniowo wychładzani. \
		Trafione obiekty zamarzną i mogą pęknąć, a podłoga pokryje się śliskim lodem - \
		choć w temperaturze pokojowej szybko odtaje."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	button_icon_state = "icebeam"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "FR'ZE!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	// In room temperature, the ice won't last very long
	// ...but in space / freezing rooms, it will stick around
	turf_freeze_type = TURF_WET_ICE
	unfreeze_turf_duration = 1 MINUTES
	// Applies an "infinite" version of basic void chill
	// (This stacks with mansus grasp's void chill)
	frozen_status_effect_path = /datum/status_effect/void_chill/lasting
	unfreeze_mob_duration = 30 SECONDS
	// Does a smidge of damage
	on_freeze_brute_damage = 12
	on_freeze_burn_damage = 10
	// Also freezes stuff (Which will likely be unfrozen similarly to turfs)
	unfreeze_object_duration = 30 SECONDS

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(IS_HERETIC_OR_MONSTER(target_mob))
		return

	return ..()
