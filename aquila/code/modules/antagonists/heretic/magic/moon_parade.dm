/datum/action/cooldown/spell/pointed/projectile/moon_parade
	name = "Lunar parade"
	desc = "Wypuszcza paradę - każdy na jej drodze musi do niej dołączyć i cierpi na halucynacje."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_parade"
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'aquila/sound/effects/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "L'N'R P'R'D!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "Szykujesz się, by wciągnąć ich do parady!"
	deactive_msg = "Uciszasz muzykę i wstrzymujesz paradę... na razie."
	cast_range = 12
	projectile_type = /obj/item/projectile/moon_parade
	antimagic_flags = MAGIC_RESISTANCE_MOON

/obj/item/projectile/moon_parade
	name = "Lunar parade"
	// AQUILA - stan ikony z tg w naszym pliku
	icon = 'aquila/icons/effects/heretic_lockmoon.dmi'
	icon_state = "lunar_parade"
	damage = 0
	damage_type = BURN
	// AQUILA - tg: 0.2 pola na tik; u nas speed to dziesiąte sekundy na pole
	speed = 5
	range = 75
	ricochets_max = 40
	ricochet_chance = 500
	ricochet_incidence_leeway = 0
	projectile_piercing = PASSMOB|PASSVEHICLE
	///looping sound datum for our projectile.
	var/datum/looping_sound/moon_parade/soundloop
	// A list of the people we hit
	var/list/mobs_hit = list()

/obj/item/projectile/moon_parade/Initialize(mapload)
	. = ..()
	soundloop = new(src,  TRUE)

/obj/item/projectile/moon_parade/prehit_pierce(atom/A)
	if(!isliving(firer) || !isliving(A))
		return ..()

	var/mob/living/caster = firer
	var/mob/living/victim = A

	if(caster == victim)
		return PROJECTILE_PIERCE_PHASE

	if(!caster.mind)
		return PROJECTILE_PIERCE_HIT

	var/datum/antagonist/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
	if(monster?.master == caster.mind)
		return PROJECTILE_PIERCE_PHASE

	var/datum/antagonist/lunatic/lunatic = victim.mind?.has_antag_datum(/datum/antagonist/lunatic)
	if(lunatic?.ascended_heretic == caster.mind)
		return PROJECTILE_PIERCE_PHASE

	// Anti-magic destroys the projectile for consistency and counterplay
	if(victim.can_block_magic(MAGIC_RESISTANCE_MOON))
		visible_message(span_warning("Parada uderza w [victim] i nagle ogarnia cię fala jasności umysłu!"))
		return PROJECTILE_DELETE_WITHOUT_HITTING

	return ..()

/obj/item/projectile/moon_parade/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(. == BULLET_ACT_BLOCK || !isliving(target))
		return

	var/mob/living/victim = target

	if(!was_hit_already(victim))
		victim.apply_status_effect(/datum/status_effect/moon_parade, src)
		mobs_hit += WEAKREF(victim)

	victim.add_mood_event("Moon Insanity", /datum/mood_event/moon_insanity)
	victim.cause_hallucination(/datum/hallucination/delusion/preset/moon, name)
	victim.adjust_sanity(-20)

/obj/item/projectile/moon_parade/proc/was_hit_already(mob/living/victim)
	for(var/datum/weakref/ref as anything in mobs_hit)
		var/mob/living/hit_victim = ref.resolve()
		if(hit_victim == victim)
			return TRUE
	return FALSE

/obj/item/projectile/moon_parade/Destroy()
	mobs_hit.Cut()
	soundloop.stop()
	return ..()
