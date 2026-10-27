// Sprint i kondycja: port BeeStation/BeeStation-Hornet#14750 (tylko sprint).
// Kondycja i sprint dostają ludzie i małpy. Stara stamina (staminaloss, stamcrit) zostaje bez zmian.
// Wyczerpanie: w Bee pozwala tylko szeptać, u nas zadyszka w ogóle nie pozwala mówić (emotki dalej działają),
// spowolnienie mniejsze (SPRINT_STAMINA_EXHAUSTION_SLOWDOWN) i bez losowych stunów z niskiej kondycji.

/mob/living/carbon/Initialize(mapload)
	. = ..()
	if(ishuman(src) || ismonkey(src))
		sprint_stamina = new(src)
		AddComponent(/datum/component/carbon_sprint)

/mob/living/carbon/Destroy()
	QDEL_NULL(sprint_stamina)
	return ..()

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	. = ..()
	sprint_stamina?.refill()

///Prędkość sprintu nadpisuje prędkość biegu z configu
/mob/living/carbon/update_move_intent_slowdown()
	..()
	if(m_intent != MOVE_INTENT_RUN)
		return
	var/datum/component/carbon_sprint/sprint = GetComponent(/datum/component/carbon_sprint)
	if(!sprint?.sprinting)
		return
	var/mod = CONFIG_GET(number/movedelay/sprint_delay)
	if(!isnum_safe(mod))
		mod = 1.5
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, multiplicative_slowdown = mod)

///Wywoływane przy każdej zmianie kondycji
/mob/living/carbon/proc/on_sprint_stamina_update()
	if(!sprint_stamina)
		return
	var/fraction = sprint_stamina.get_fraction()
	var/exhausted = HAS_TRAIT_FROM(src, TRAIT_EXHAUSTED, SPRINT_STAMINA_TRAIT)
	if(!exhausted && fraction < SPRINT_STAMINA_EXHAUSTION_THRESHOLD)
		ADD_TRAIT(src, TRAIT_EXHAUSTED, SPRINT_STAMINA_TRAIT)
		add_movespeed_modifier(MOVESPEED_ID_SPRINT_EXHAUSTION, TRUE, 0, override = TRUE, multiplicative_slowdown = SPRINT_STAMINA_EXHAUSTION_SLOWDOWN)
		if(stat != DEAD)
			to_chat(src, "<span class='danger'>Brakuje ci tchu. Nie możesz sprintować ani mówić, dopóki nie złapiesz oddechu.</span>")
	else if(exhausted && (fraction > SPRINT_STAMINA_EXHAUSTION_RECOVERY_THRESHOLD || stat == DEAD))
		REMOVE_TRAIT(src, TRAIT_EXHAUSTED, SPRINT_STAMINA_TRAIT)
		remove_movespeed_modifier(MOVESPEED_ID_SPRINT_EXHAUSTION)
		if(stat != DEAD)
			to_chat(src, "<span class='notice'>Łapiesz oddech.</span>")
	update_sprint_stamina_hud()

/mob/living/carbon/death(gibbed)
	. = ..()
	on_sprint_stamina_update()

/mob/living/carbon/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	update_sprint_stamina_hud()

/mob/living/carbon/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced)
	// Zadyszka: zwykła mowa nie przechodzi, emotki (*) tak
	if(!forced && stat == CONSCIOUS && HAS_TRAIT(src, TRAIT_EXHAUSTED) && length(message) && copytext(trim_left(message), 1, 2) != "*")
		to_chat(src, "<span class='warning'>Dyszysz tak, że nie możesz wydusić słowa!</span>")
		return
	return ..()

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(stat == DEAD || !sprint_stamina)
		return
	if(HAS_TRAIT(src, TRAIT_EXHAUSTED))
		. += "<span class='warning'>Ta osoba jest wykończona i ledwo łapie oddech.</span>"
	else if(sprint_stamina.get_fraction() < SPRINT_STAMINA_EXHAUSTION_WARNING)
		. += "<span class='notice'>Ta osoba ciężko dyszy.</span>"
