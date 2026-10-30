// AQUILA - port z Yogstation (yogstation/code/datums/mutations/extendoarm.dm)
// Ręka leci jako pocisk: chwyta przedmiot, odkłada trzymany albo klika (attack_hand) cel i wraca.

/datum/mutation/extendoarm
	name = "Wydłużona ręka"
	desc = "Pacjent potrafi wydłużyć ręce i chwytać przedmioty z daleka."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Twoje ręce są rozciągliwe.</span>"
	text_lose_indication = "<span class='warning'>Twoje ręce znów są sztywne.</span>"
	action_path = /datum/action/cooldown/spell/pointed/projectile/extendoarm
	instability = 30

/datum/action/cooldown/spell/pointed/projectile/extendoarm
	name = "Ręka"
	desc = "Wydłuż rękę, żeby coś chwycić albo odłożyć."
	icon_icon = 'aquila/icons/mutations/yog/actions.dmi'
	button_icon_state = "arm"
	cooldown_time = 5 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	cast_range = 50
	aim_assist = FALSE
	projectile_type = /obj/item/projectile/extendo_arm
	active_msg = "Rozluźniasz rękę!"
	deactive_msg = "Napinasz rękę z powrotem."
	projectile_amount = 64

/datum/action/cooldown/spell/pointed/projectile/extendoarm/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_user = owner
	if(carbon_user.handcuffed) // nie łączy się z odpinaniem ręki
		return FALSE
	if(!carbon_user.hand_bodyparts[carbon_user.active_hand_index])
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_NODISMEMBER))
		if(feedback)
			owner.balloon_alert(owner, "nie możesz odczepić ręki!")
		return FALSE
	var/obj/item/held = owner.get_active_held_item()
	if(held && !owner.canUnEquip(held))
		if(feedback)
			owner.balloon_alert(owner, "nie możesz puścić przedmiotu!")
		return FALSE

/datum/action/cooldown/spell/pointed/projectile/extendoarm/ready_projectile(obj/item/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/obj/item/projectile/extendo_arm/firing_arm = to_fire
	var/mob/living/carbon/carbon_user = user
	if(!istype(firing_arm) || !istype(carbon_user))
		return
	if(carbon_user.dna && !carbon_user.dna.species.use_skintones && carbon_user.dna.features["mcolor"])
		firing_arm.add_atom_colour("#[carbon_user.dna.features["mcolor"]]", FIXED_COLOUR_PRIORITY)

	firing_arm.set_homing_target(target)
	firing_arm.beam = firing_arm.Beam(carbon_user, icon_state = "2-full", time = 20 SECONDS, maxdistance = 150)

	var/obj/item/held = carbon_user.get_active_held_item()
	if(held && carbon_user.dropItemToGround(held, FALSE))
		firing_arm.grab(held)
	firing_arm.arm = carbon_user.hand_bodyparts[carbon_user.active_hand_index]
	firing_arm.arm.drop_limb()
	firing_arm.arm.forceMove(firing_arm)

/obj/item/projectile/extendo_arm
	name = "ręka"
	icon = 'aquila/icons/mutations/yog/projectiles.dmi'
	icon_state = "arm"
	suppressed = TRUE
	damage = 0
	nodamage = TRUE
	range = 100
	speed = 2
	hitsound = null
	homing = TRUE
	homing_turn_speed = 360
	var/obj/item/grabbed
	var/obj/item/bodypart/arm
	var/returning = FALSE
	var/datum/beam/beam

// Ręka jest odczepiana i wkładana do pocisku przed fire(), a kolizje sprawdzają impacted już wtedy
/obj/item/projectile/extendo_arm/Initialize(mapload)
	. = ..()
	LAZYINITLIST(impacted)

// Nic nie dostaje pociskiem: ręka robi swoje i leci dalej albo wraca
/obj/item/projectile/extendo_arm/prehit_pierce(atom/target)
	if(returning)
		return PROJECTILE_PIERCE_PHASE
	if(grabbed)
		ungrab()
	else if(isitem(target))
		var/obj/item/I = target
		if(!I.anchored)
			grab(I)
	else if(firer && !isturf(target))
		var/mob/user = firer
		target.attack_hand(user)
	go_home()
	return PROJECTILE_PIERCE_PHASE

/obj/item/projectile/extendo_arm/Range()
	var/turf/here = get_turf(src)
	if(returning)
		if(firer && here == get_turf(firer))
			return_to_owner()
			return
	else if(original && here == get_turf(original))
		// Doleciała na puste pole: odkłada trzymany przedmiot i wraca
		if(grabbed)
			ungrab()
		go_home()
	return ..()

/obj/item/projectile/extendo_arm/proc/go_home()
	if(returning)
		return
	returning = TRUE
	icon_state = "armreverse"
	range = decayedRange
	ignore_source_check = TRUE
	if(firer)
		set_homing_target(firer)
		setAngle(get_angle(src, firer))
		next_homing_process = 0

// Koniec zasięgu w drodze powrotnej: ręka wraca do właściciela, zamiast spaść gdzieś po drodze
/obj/item/projectile/extendo_arm/on_range()
	if(returning && firer && !QDELETED(firer))
		return_to_owner()
		return
	return ..()

/obj/item/projectile/extendo_arm/proc/return_to_owner()
	var/mob/living/carbon/user = firer
	if(arm && istype(user) && !QDELETED(user))
		arm.attach_limb(user, TRUE)
		arm = null
		var/obj/item/item = ungrab()
		if(item)
			user.put_in_hands(item)
	qdel(src)

/obj/item/projectile/extendo_arm/proc/grab(obj/item/I)
	if(!I)
		return
	I.forceMove(src)
	var/image/IM = image(I, src)
	IM.appearance_flags = RESET_COLOR // inaczej kolor skóry przechodzi na przedmiot
	grabbed = I
	overlays += IM

/obj/item/projectile/extendo_arm/proc/ungrab()
	if(!grabbed)
		return
	grabbed.forceMove(drop_location())
	overlays.Cut()
	. = grabbed
	grabbed = null

/obj/item/projectile/extendo_arm/Destroy()
	if(grabbed)
		grabbed.forceMove(drop_location())
		grabbed = null
	if(arm)
		arm.forceMove(drop_location())
		arm = null
	QDEL_NULL(beam)
	return ..()
