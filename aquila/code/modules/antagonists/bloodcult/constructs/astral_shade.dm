// AQUILA - projekcja astralna kultu „Cult 4” (vg, draft Monke #3867) na naszym simple_animal.

/mob
	var/datum/rune_spell/astraljourney/ajourn // AQUILA - Podróż Astralna przypisuje tu datum zaklęcia, nie runę

////////////////////////////////////////////////////////////////////////////////////////
GLOBAL_LIST_INIT(astral_projections, list())

/mob/living/simple_animal/astral_projection
	name = "projekcja astralna"
	real_name = "projekcja astralna"
	desc = "Fragment duszy kultysty, uwolniony od praw fizyki."
	icon = 'aquila/icons/bloodcult/mob.dmi'
	icon_state = "ghost-narsie"
	icon_living = "ghost-narsie"
	icon_dead = "ghost-narsie"
	movement_type = FLYING
	maxHealth = 1
	health = 1
	melee_damage = 0
	faction = list("cult")
	speed = 0.5
	density = FALSE
	invisibility = INVISIBILITY_OBSERVER
	see_invisible = SEE_INVISIBLE_OBSERVER
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	alpha = 127
	now_pushing = 1 //prevents pushing atoms
	spacewalk = TRUE
	wander = FALSE
	stop_automated_movement = TRUE
	status_flags = GODMODE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	see_in_dark = 100

	//keeps track of whether we're in "ghost" form or "slightly less ghost" form
	var/tangibility = FALSE

	//the cultist's original body
	var/mob/living/anchor

	var/incorporeal_appearance
	var/tangible_appearance

	var/time_last_speech = 0//speech bubble cooldown

	//sechud stuff
	var/cardjob = "hudunknown"

	var/projection_destroyed = FALSE
	var/direct_delete = FALSE

	var/last_devotion_gain = 0
	var/devotion_gain_delay = 60 SECONDS

	var/datum/action/cooldown/spell/astral_return/astral_return
	var/datum/action/cooldown/spell/astral_toggle/astral_toggle

/mob/living/simple_animal/astral_projection/Initialize(mapload)
	. = ..()
	GLOB.astral_projections += src
	last_devotion_gain = world.time

	astral_return = new(src)
	astral_toggle = new(src)

	astral_return.Grant(src)
	astral_toggle.Grant(src)

/mob/living/simple_animal/astral_projection/Login()
	..()
	if(!tangibility)
		overlay_fullscreen("astralborder", /atom/movable/screen/fullscreen/astral_border)
		update_fullscreen_alpha("astralborder", 255, 5)

/// Wspólny koniec projekcji: powrót do ciała albo (gdy ciało zginęło) przemiana w cienia
/mob/living/simple_animal/astral_projection/proc/end_projection()
	incorporeal_appearance = null
	tangible_appearance = null
	astral_return?.Remove(src)
	astral_toggle?.Remove(src)
	projection_destroyed = TRUE
	GLOB.astral_projections -= src
	//the projection has ended, let's return to our body
	if(anchor && anchor.stat != DEAD && client)
		if(key)
			if(tangibility)
				var/obj/effect/afterimage/A = new(loc, anchor, 10)
				A.setDir(dir)
			anchor.key = key
			to_chat(anchor, span_notice("Wracasz do swojego ciała."))
			anchor.ajourn = null
	//if our body was somehow already destroyed however, we'll become a shade right here
	else if(client)
		var/turf/T = get_turf(src)
		if(T)
			var/mob/living/simple_animal/shade/shade = new(T)
			playsound(T, 'sound/hallucinations/growl1.ogg', 50, 1)
			shade.name = "Cień [real_name]"
			shade.real_name = "[real_name]"
			mind?.transfer_to(shade)
			shade.key = key
			to_chat(shade, span_cult("Wygląda na to, że twoje ciało zostało zniszczone. Resztki twojej duszy dotarły do projekcji astralnej i połączyły się z nią w cienia."))
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE

/mob/living/simple_animal/astral_projection/proc/destroy_projection()
	if(projection_destroyed)
		return
	end_projection()
	sleep(2 SECONDS)
	anchor = null
	if(!direct_delete && !QDELETED(src))
		qdel(src)

/mob/living/simple_animal/astral_projection/Destroy()
	if(!projection_destroyed)
		end_projection()
	anchor = null
	QDEL_NULL(astral_return)
	QDEL_NULL(astral_toggle)
	mind = null // umysł należy do ciała, projekcja tylko go pożyczała
	return ..()

/mob/living/simple_animal/astral_projection/Life(seconds, times_fired)
	. = ..()
	if(projection_destroyed)
		return
	if(anchor)
		var/turf/T = get_turf(anchor)
		var/turf/U = get_turf(src)
		if(!T || !U || T.z != U.z)
			to_chat(src, span_warning("Nie jesteś w stanie utrzymać projekcji astralnej na taką odległość."))
			death()
			return
	else
		death()
		return

	if(world.time >= (last_devotion_gain + devotion_gain_delay))
		last_devotion_gain += devotion_gain_delay
		var/datum/antagonist/cult/cult_datum = mind?.has_antag_datum(/datum/antagonist/cult)
		cult_datum?.gain_devotion(50, DEVOTION_TIER_2, "astral_journey")

/mob/living/simple_animal/astral_projection/death(gibbed)
	INVOKE_ASYNC(src, PROC_REF(destroy_projection))

/mob/living/simple_animal/astral_projection/examine(mob/user)
	if(!tangibility)
		if((user == src) && anchor)
			to_chat(user, span_notice("Sprawdzasz, jak widzieliby cię inni, gdybyś był namacalny:"))
			return anchor.examine(user)
		else if(IS_CULTIST(user))
			return list(span_notice("To projekcja astralna."))
		else
			return list(span_cult("Chwila, coś tu nie gra."))//it's a g-g-g-g-ghost!
	else if(anchor)
		return anchor.examine(user)//examining the astral projection alone won't be enough to see through it, although the user might want to make sure they cannot be identified first.
	return ..()

//no pulling stuff around
/mob/living/simple_animal/astral_projection/start_pulling(atom/movable/AM, state, force = pull_force, supress_message = FALSE)
	return

//this should prevent most other edge cases
/mob/living/simple_animal/astral_projection/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, check_immobilized = FALSE, ignore_stasis = FALSE)
	return TRUE

//bullets instantly end us
/mob/living/simple_animal/astral_projection/bullet_act(obj/item/projectile/Proj, def_zone, piercing_hit = FALSE)
	. = ..()
	if(tangibility)
		death()

/mob/living/simple_animal/astral_projection/ex_act(severity, target, origin)
	if(tangibility)
		death()

//called once when we are created, shapes our appearance in the image of our anchor
/mob/living/simple_animal/astral_projection/proc/ascend(mob/living/body)
	if(!body)
		return
	anchor = body
	//memorizing our anchor's appearance so we can toggle to it
	tangible_appearance = body.appearance

	//getting our ghostly looks
	cut_overlays()
	if(ishuman(body))
		var/mob/living/carbon/human/H = body
		//instead of just adding an overlay of the body's uniform and suit, we'll first process them a bit so the leg part is mostly erased, for a ghostly look.
		for(var/layer_index in list(ID_LAYER, EARS_LAYER, GLASSES_LAYER, BELT_LAYER, BACK_LAYER, HEAD_LAYER, HANDCUFF_LAYER))
			if(H.overlays_standing[layer_index])
				add_overlay(H.overlays_standing[layer_index])

	//giving control to the player
	key = body.key

	//name  & examine stuff
	desc = body.desc
	gender = body.gender
	if(body.mind && body.mind.name)
		name = body.mind.name
	else
		if(body.real_name)
			name = body.real_name
		else
			if(gender == MALE)
				name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names_male))
			else
				name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names_female))
	real_name = name

	//important to trick sechuds
	var/list/target_id_cards = body.GetAllContents(/obj/item/card/id)
	if(length(target_id_cards))
		var/obj/item/card/id/card = target_id_cards[1]
		cardjob = card.assignment

	//memorizing our current appearance so we can toggle back to it later. Has to be done AFTER setting our new name.
	incorporeal_appearance = appearance

	//we don't transfer the mind but we keep a reference to it.
	mind = body.mind

/mob/living/simple_animal/astral_projection/proc/toggle_tangibility()
	if(tangibility)
		density = FALSE
		appearance = incorporeal_appearance
		movement_type = FLYING
		incorporeal_move = INCORPOREAL_MOVE_BASIC
		speed = 0.5
		overlay_fullscreen("astralborder", /atom/movable/screen/fullscreen/astral_border)
		update_fullscreen_alpha("astralborder", 255, 5)
		var/obj/effect/afterimage/A = new(loc, anchor, 10)
		A.setDir(dir)
	else
		density = TRUE
		appearance = tangible_appearance
		incorporeal_move = FALSE
		movement_type = GROUND
		see_invisible = SEE_INVISIBLE_OBSERVER
		speed = 1
		clear_fullscreen("astralborder", animated = 5)
		alpha = 0
		animate(src, alpha = 255, time = 10)

	tangibility = !tangibility

//saycode
/mob/living/simple_animal/astral_projection/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced)
	return ..(tangibility ? "[message]" : "..[message]", bubble_type, spans, sanitize, language, ignore_spam, forced)
