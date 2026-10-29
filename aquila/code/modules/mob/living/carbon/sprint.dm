// Sprint: port BeeStation/BeeStation-Hornet#14750. Sprint dostają ludzie i małpy i płacą wspólną pulą staminy
// (aquila/code/modules/mob/living/stamina.dm). Wyczerpanie i stamcrit też są tam.

/mob/living/carbon/Initialize(mapload)
	. = ..()
	if(ishuman(src) || ismonkey(src))
		AddComponent(/datum/component/carbon_sprint)

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

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(stat == DEAD || !stamina)
		return
	if(HAS_TRAIT(src, TRAIT_EXHAUSTED))
		. += "<span class='warning'>Ta osoba jest wykończona i ledwo łapie oddech.</span>"
	else if(stamina.get_fraction() < STAMINA_EXHAUSTION_WARNING_MODIFIER && !HAS_TRAIT(src, TRAIT_NOBREATH))
		. += "<span class='notice'>Ta osoba ciężko dyszy.</span>"
