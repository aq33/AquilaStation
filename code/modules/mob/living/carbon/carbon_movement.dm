/mob/living/carbon/movement_delay()
	. = ..()

	if(!get_leg_ignore() && legcuffed) //ignore the fact we lack legs
		. += legcuffed.slowdown

/mob/living/carbon/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)
	if(movement_type & FLYING)
		return 0
	if(!(lube&SLIDE_ICE))
		log_combat(src, (O ? O : get_turf(src)), "slipped on the", null, ((lube & SLIDE) ? "(LUBE)" : null))
	return loc.handle_slip(src, knockdown_amount, O, lube, paralyze, force_drop)

// AQ EDIT - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864): /mob/living/carbon/Process_Spacemove() z plecakiem
// i implantem dysz usunięte, plecaki, implant i moduł MOD odpowiadają na COMSIG_MOVABLE_SPACEMOVE w /datum/component/jetpack

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(. && !(movement_type & FLOATING)) //floating is easy
		if(HAS_TRAIT(src, TRAIT_NOHUNGER))
			set_nutrition(NUTRITION_LEVEL_FED - 1)	//just less than feeling vigorous
		else if(nutrition && stat != DEAD)
			adjust_nutrition(-(HUNGER_FACTOR/10))
			if(m_intent == MOVE_INTENT_RUN)
				adjust_nutrition(-(HUNGER_FACTOR/10))
	// AQ EDIT - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864): dźwięk dysz gra /datum/component/jetpack przy pchnięciu,
	// tutaj drugie allow_thrust() zużywało paliwo jeszcze raz (także w grawitacji)
