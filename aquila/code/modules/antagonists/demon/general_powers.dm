/obj/effect/proc_holder/spell/targeted/shapeshift/demon //emergency get out of jail card.
	name = "Postać pomniejszego demona"
	desc = "Przybierasz swoją prawdziwą demoniczną postać. Jest silna, ale bardzo rzuca się w oczy. Pełnia demonicznej natury w tym świecie bardzo cię wyczerpuje \
	i w tej postaci powoli tracisz życie, a do tego jesteś szczególnie wrażliwy na święte wpływy. \
	Pamiętaj, że niskie zdrowie przechodzi między postaciami. Jeśli jesteś ciężko ranny, atakuj żywych śmiertelników, by wysysać z nich energię życiową!"
	invocation = "DRŻYJCIE, ŚMIERTELNICY!!"
	shapeshift_type = /mob/living/simple_animal/lesserdemon
	action_icon = 'aquila/icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "daemontransform"
	action_background_icon_state = "bg_demon"

/mob/living/simple_animal/lesserdemon
	name = "demon"
	real_name = "demon"
	desc = "Duże, groźne stworzenie pokryte twardymi czerwonymi łuskami."
	speak_emote = list("rechocze")
	emote_hear = list("rechocze","skrzeczy")
	response_help  = "rozmyśla się i nie dotyka"
	response_disarm = "macha rękami na"
	response_harm   = "uderza"
	icon = 'aquila/icons/mob/mob.dmi'
	icon_state = "lesserdaemon"
	icon_living = "lesserdaemon"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speed = 0.25
	combat_mode = TRUE
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	deathmessage = "wyje z gniewu i strachu, padając pokonany!"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY
	faction = list("hell")
	attacktext = "dziko rozszarpuje"
	maxHealth = 200
	health = 200
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage = 20
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	loot = (/obj/effect/decal/cleanable/blood)
	del_on_death = TRUE

/mob/living/simple_animal/lesserdemon/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(istype(W, /obj/item/nullrod))
		visible_message(span_warning("[src] wrzeszczy z nieświętego bólu po ciosie!"), \
						span_cult("Gdy trafia cię [W], czujesz, jak święta moc przeszywa twoją postać, rozrywając ją!"))
		adjustBruteLoss(22) //22 extra damage from the nullrod while in your true form. On average this means 40 damage is taken now.

/mob/living/simple_animal/lesserdemon/UnarmedAttack(mob/living/L, proximity)//10 hp healed from landing a hit.
	if(isliving(L))
		if(L.stat != DEAD && !L.anti_magic_check(TRUE, TRUE)) //demons do not gain succor from the dead or holy
			adjustHealth(-maxHealth * 0.05)
	return ..()

/mob/living/simple_animal/lesserdemon/Life()
	. = ..()
	if(!.)
		return
	if(istype(get_area(src), /area/chapel)) //being a non-carbon will not save you!
		visible_message(span_warning("[src] zaczyna się topić!"), span_danger("Twoja dusza topi się w świętym pomieszczeniu!"), "Słyszysz skwierczenie.")
		adjustHealth(20) //20 damage every ~2 seconds. About 20 seconds for a full HP demon to melt apart in the chapel.
	else //You passively lose 2 health every 2 seconds, don't stay in demon form for too long.
		adjustHealth(2)

//not really a general power, but more than 1 sin has it
/obj/effect/proc_holder/spell/targeted/touch/torment
	name = "Udręka"
	desc = "Spowija twoją rękę mściwą mocą. Uderzenie nią mocno osłabia ofiarę, choć nie zostawia widocznych obrażeń."
	hand_path = /obj/item/melee/touch_attack/torment
	school = "evocation"
	charge_max = 20 SECONDS
	clothes_req = FALSE
	action_icon = 'aquila/icons/mob/actions/humble/actions_humble.dmi'
	action_icon_state = "mutate"
	action_background_icon_state = "bg_demon"

/obj/item/melee/touch_attack/torment
	name = "Mściwa dłoń"
	desc = "Pełna pogardy masa nienawistnej energii, gotowa do ciosu."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	color = "#9c1d1d"
	catchphrase = "CIERP!"

/obj/item/melee/touch_attack/torment/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isliving(target) || target == user)
		return
	var/mob/living/victim = target
	if(victim.anti_magic_check())
		to_chat(user, span_warning("[victim] opiera się twojej udręce!"))
		to_chat(victim, span_warning("Wokół twojego umysłu tańczy ohydne uczucie agonii, po czym nagle się rozwiewa."))
		return ..()
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	victim.blur_eyes(15) //huge array of relatively minor effects.
	victim.Jitter(5)
	victim.confused = max(victim.confused, 5)
	victim.adjust_disgust(40)
	victim.hallucination += 10
	victim.Immobilize(3 SECONDS)
	victim.Stun(1 SECONDS)
	victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)
	victim.visible_message(span_danger("[victim] krzywi się z bólu, łapiąc się na chwilę za głowę!"))
	victim.emote("scream")
	to_chat(victim, span_warning("Czujesz wybuch bólu w swoim umyśle!"))
	return ..()

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/sin
	name = "Demoniczne przejście"
	desc = "Na chwilę obracasz się w żar i popiół, więc swobodnie przenikasz przez obiekty."
	clothes_req = FALSE
	charge_max = 50 SECONDS
	cooldown_min = 50 SECONDS
	jaunt_duration = 3 SECONDS
	jaunt_in_time = 0.5 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/sin/play_sound(type, mob/living/target)
	if(type == "enter")
		playsound(get_turf(target), 'sound/magic/fireball.ogg', 50, TRUE, -1)
