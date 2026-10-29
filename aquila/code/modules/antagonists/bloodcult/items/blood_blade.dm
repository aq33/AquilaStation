/obj/item/melee/blood_dagger
	name = "krwawy sztylet"
	icon = 'aquila/icons/bloodcult/cult.dmi'
	lefthand_file = 'aquila/icons/bloodcult/in_hands/swords_axes_l.dmi'
	righthand_file = 'aquila/icons/bloodcult/in_hands/swords_axes_r.dmi'
	icon_state = "blood_dagger"
	item_state = "blood_dagger"
	desc = "Bryła zakrzepłej krwi w kształcie noża. Można nią rzucić, by przygwoździć wroga."
	siemens_coefficient = 0.2
	sharpness = SHARP_EDGED
	force = 15.0
	w_class = WEIGHT_CLASS_GIGANTIC//don't want it stored anywhere case
	var/mob/originator = null
	var/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/dagger/linked_ui
	var/stacks = 0
	var/absorbed = 0

/obj/item/melee/blood_dagger/Destroy()
	if(linked_ui)
		linked_ui.dagger = null
		linked_ui.UpdateIcon()
		linked_ui = null
	var/turf/T = get_turf(src)
	playsound(T, 'aquila/sound/bloodcult/forge_over.ogg', 100, 0, -2)
	if (!absorbed && !locate(/obj/effect/decal/cleanable/blood/splatter) in T)
		var/obj/effect/decal/cleanable/blood/splatter/S = new (T)//splash
		if (color)
			S.color = color
			S.update_icon()
	..()

/obj/item/melee/blood_dagger/suicide_act(mob/living/user)
	user.visible_message(span_danger("[user] podrzyna sobie gardło [src]! Wygląda na to, że próbuje popełnić samobójstwo.") )

/obj/item/melee/blood_dagger/dropped(mob/user)
	..()
	qdel(src)

/obj/item/melee/blood_dagger/attack(mob/living/target, mob/living/carbon/human/user)
	if(target == user)
		if (stacks < 5)
			user.blood_volume -= 5
			stacks++
			playsound(user, 'sound/weapons/bladeslice.ogg', 30, 0, -2)
			to_chat(user, span_warning("[capitalize(src.name)] pobiera trochę twojej krwi.") )
		return
	if (IS_CULTIST(user) && !IS_CULTIST(target) && !target.stat == DEAD)
		var/datum/antagonist/cult/cult_datum = user.mind.has_antag_datum(/datum/antagonist/cult)
		if (target.mind)
			cult_datum.gain_devotion(30, DEVOTION_TIER_3, "attack_blooddagger", target)
		else
			cult_datum.gain_devotion(30, DEVOTION_TIER_2, "attack_blooddagger_nomind", target)
	..()
/obj/item/melee/blood_dagger/attack_hand(mob/living/user)
	if(!ismob(loc))
		qdel(src)
		return
	..()

/obj/item/melee/blood_dagger/attack_self(mob/user)
	if (ishuman(user) && IS_CULTIST(user))
		var/mob/living/carbon/human/H = user
		if (!H.cult_no_blood())
			to_chat(user, span_notice("Chowasz [src] z powrotem w swoim ciele[stacks ? ", razem z ukradzioną krwią" : ""].") )
			H.blood_volume += 5 + stacks * 5
		else
			to_chat(user, span_notice("Chowasz [src] w swoim ciele, ale krew nie znajduje naczyń, które mogłaby wypełnić.") )
		absorbed = 1
		playsound(H, 'aquila/sound/bloodcult/bloodyslice.ogg', 30, 0, -2)
		qdel(src)


/obj/item/melee/blood_dagger/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE, quickstart = TRUE)
	var/turf/starting = get_turf(thrower)
	var/obj/item/projectile/blooddagger/dagger = new (starting)
	dagger.stacks = stacks
	dagger.damage = 5 + stacks * 5
	dagger.icon_state = icon_state
	dagger.color = color
	dagger.preparePixelProjectile(target, starting)
	dagger.fire(direct_target = target)
	dagger.process()
	qdel(src)

/obj/item/melee/blood_dagger/attack(mob/living/attacked, mob/living/carbon/human/user)
	. = ..()
	if (ismob(attacked))
		var/mob/living/M = attacked
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			C.blood_volume -= 5
			if (stacks < 5)
				stacks++
				to_chat(user, span_warning("[capitalize(src.name)] kradnie trochę ich krwi.") )
