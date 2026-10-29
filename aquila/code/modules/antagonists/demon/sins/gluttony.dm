/obj/effect/proc_holder/spell/targeted/forcewall/gluttony
	name = "Ściana obżarstwa"
	desc = "Tworzy magiczną barierę, przez którą przejdą tylko grubasy."
	school = "transmutation"
	charge_max = 150
	clothes_req = FALSE
	invocation = "ŻREĆ"
	invocation_type = "shout"
	sound = 'sound/magic/forcewall.ogg'
	action_icon = 'aquila/icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "blob"
	action_background_icon_state = "bg_demon"
	range = -1
	include_user = TRUE
	cooldown_min = 50 //12 deciseconds reduction per rank
	wall_type = /obj/effect/gluttony/timed

/obj/effect/proc_holder/spell/targeted/shapeshift/demon/gluttony //emergency get out of jail card, but better. It also eats everything.
	name = "Postać demona obżarstwa"
	desc = "Przybierasz swoją prawdziwą demoniczną postać. Jest silna, ale bardzo rzuca się w oczy. Pełnia demonicznej natury w tym świecie bardzo cię wyczerpuje \
	i w tej postaci powoli tracisz życie, a do tego jesteś szczególnie wrażliwy na święte wpływy. \
	Pamiętaj, że niskie zdrowie przechodzi między postaciami. Jeśli jesteś ciężko ranny, atakuj żywych śmiertelników, by wysysać z nich energię życiową! \
	Jako demon obżarstwa możesz też pożerać zwłoki, by się leczyć."
	shapeshift_type = /mob/living/simple_animal/lesserdemon/gluttony

/mob/living/simple_animal/lesserdemon/gluttony //capable of devouring corpses for health
	name = "demon obżarstwa"
	real_name = "demon obżarstwa"
	icon_state = "lesserdaemon_gluttony"
	icon_living = "lesserdaemon_gluttony"

/mob/living/simple_animal/lesserdemon/gluttony/UnarmedAttack(mob/living/L)
	if(isliving(L)) //Eat Corpses to regen health
		if(L.stat == DEAD)
			if(do_after(src, 3 SECONDS, target = L))
				devour(L)
			return
	return ..()

/mob/living/simple_animal/lesserdemon/gluttony/proc/devour(mob/living/L)
	if(QDELETED(L))
		return FALSE
	visible_message(
		span_danger("[src] pożera [L]!"),
		span_userdanger("Pożerasz [L], odzyskując zdrowie!"))
	adjustBruteLoss(-50)
	L.gib()
	return TRUE

/obj/effect/gluttony/timed
	///Time in deciseconds before it deletes itself.
	var/timeleft = 15 SECONDS

/obj/effect/gluttony/timed/Initialize(mapload)
	. = ..()
	if(timeleft)
		QDEL_IN(src, timeleft)
