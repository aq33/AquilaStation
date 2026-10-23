/obj/item/void_prison
	name = "void prison"
	desc = "Mała szklana kula pełna wirującej ciemności. W dotyku jest zimna i pochłania całe światło wokół."
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "voidball"
	pickup_sound = 'aquila/sound/items/handling/materials/glass_pick_up.ogg'
	drop_sound = 'aquila/sound/items/handling/materials/glass_drop.ogg'

/obj/item/void_prison/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.5)

/obj/item/void_prison/attack_self(mob/living/user, modifiers)
	. = ..()
	if(.)
		return

	playsound(src, SFX_SHATTER, 50, TRUE)
	playsound(src, 'sound/magic/voidblink.ogg', 50, FALSE)
	if(IS_HERETIC_OR_MONSTER(user))
		to_chat(user, span_mansus("Rozbijasz [src], uwalniając wokół jego moc!"))
		for(var/mob/living/nearby_mob in view(3, user))
			if(IS_HERETIC_OR_MONSTER(nearby_mob))
				continue
			if(nearby_mob.has_status_effect(/datum/status_effect/eldritch))
				continue
			if(nearby_mob.can_block_magic(MAGIC_RESISTANCE))
				nearby_mob.visible_message(
					span_danger("Wirująca, zimna pustka oplata [nearby_mob], ale fala gorąca rozrywa ją na strzępy!"),
					span_userdanger("Przed tobą otwiera się ziejąca pustka, ale wielka fala gorąca ją rozrywa! Jesteś chroniony!")
				)
				continue
			nearby_mob.visible_message(
				span_danger("Wirująca, zimna pustka oplata [nearby_mob]!"),
				span_userdanger("Przed tobą otwiera się ziejąca pustka! Pochłania cię ciemność i trafiasz w kompletną nicość..."),
			)
			nearby_mob.apply_status_effect(/datum/status_effect/void_prison)

	else if(user.can_block_magic(MAGIC_RESISTANCE))
		to_chat(user, span_hypnophrase("Rozbijasz [src], ale jego moc zaczyna cię otaczać!"))
		user.visible_message(
			span_danger("Wirująca, zimna pustka oplata [user], ale fala gorąca rozrywa ją na strzępy!"),
			span_userdanger("Przed tobą otwiera się ziejąca pustka, ale wielka fala gorąca ją rozrywa! Jesteś chroniony!")
		)

	else
		to_chat(user, span_hypnophrase("Rozbijasz [src], ale jego moc zaczyna cię otaczać!"))
		user.visible_message(
			span_danger("Wirująca, zimna pustka oplata [user]!"),
			span_userdanger("Przed tobą otwiera się ziejąca pustka! Pochłania cię ciemność i trafiasz w kompletną nicość..."),
		)
		user.apply_status_effect(/datum/status_effect/void_prison)

	qdel(src)
	return TRUE

/datum/status_effect/void_prison
	id = "void_prison"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/void_prison
	///The overlay that gets applied to whoever has this status active
	var/obj/effect/abstract/voidball/stasis_overlay
	/// AQUILA - u nas nieśmiertelność to flaga GODMODE (TRAIT_GODMODE nic nie robi); czy to my ją nadaliśmy
	var/gave_godmode = FALSE

/datum/status_effect/void_prison/on_creation(mob/living/new_owner)
	. = ..()
	if(QDELETED(src) || !owner)
		return
	stasis_overlay = new /obj/effect/abstract/voidball(new_owner)
	RegisterSignal(stasis_overlay, COMSIG_PARENT_QDELETING, PROC_REF(clear_overlay))
	new_owner.vis_contents += stasis_overlay
	stasis_overlay.animate_opening()
	addtimer(CALLBACK(src, PROC_REF(enter_prison), new_owner), 1 SECONDS)

/datum/status_effect/void_prison/on_remove()
	if(!IS_HERETIC(owner))
		owner.apply_status_effect(/datum/status_effect/void_chill, 1)
	if(gave_godmode)
		owner.status_flags &= ~GODMODE
		gave_godmode = FALSE
	if(stasis_overlay)
		//Free our prisoner
		owner.remove_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM, TRAIT_FORCE_WHISPER), TRAIT_STATUS_EFFECT(id))
		owner.forceMove(get_turf(stasis_overlay))
		stasis_overlay.forceMove(owner)
		owner.vis_contents += stasis_overlay
		//Animate closing the ball
		stasis_overlay.animate_closing()
		stasis_overlay.icon_state = "voidball_closed"
		QDEL_IN(stasis_overlay, 1.1 SECONDS)
		stasis_overlay = null
	return ..()

///Freezes our prisoner in place
/datum/status_effect/void_prison/proc/enter_prison(mob/living/prisoner)
	if(QDELETED(src) || QDELETED(stasis_overlay))
		return
	stasis_overlay.forceMove(prisoner.loc)
	prisoner.forceMove(stasis_overlay)
	prisoner.add_traits(list(TRAIT_GODMODE, TRAIT_NO_TRANSFORM, TRAIT_FORCE_WHISPER), TRAIT_STATUS_EFFECT(id))
	if(!(prisoner.status_flags & GODMODE))
		prisoner.status_flags |= GODMODE
		gave_godmode = TRUE

///Makes sure to clear the ref in case the voidball ever suddenly disappears
/datum/status_effect/void_prison/proc/clear_overlay()
	SIGNAL_HANDLER
	stasis_overlay = null

//----Voidball effect
/obj/effect/abstract/voidball
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "voidball_effect"
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_ID

///Plays a opening animation
/obj/effect/abstract/voidball/proc/animate_opening()
	flick("voidball_opening", src)

///Plays a closing animation
/obj/effect/abstract/voidball/proc/animate_closing()
	flick("voidball_closing", src)

//---- Screen alert
/atom/movable/screen/alert/status_effect/void_prison
	name = "Void Prison"
	desc = "Ziejąca pustka spowija twoją śmiertelną powłokę." //Go straight to jail, do not pass GO, do not collect 200$
	// AQUILA - u nas alerty nie mają nakładki na tło (use_user_hud_icon/overlay_icon), więc ikona wprost
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "voidball_effect"
