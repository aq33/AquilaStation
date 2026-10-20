/**
 * A Brujah exclusive ability that acts as an enhanced version of "Brawn"
 * 'vitaecost' and 'cooldown_time' vary depending on what the power is used for.
 * Lots of code has been copied over from Brawn wherever inheritance might prove insufficient.
 * Comments from copied code have been removed (they can still be found in their original location.)
**/

/datum/action/vampire/targeted/brawn/brash
	name = "Zuchwałość"
	desc = "Rozbijaj większość konstrukcji przytłaczającą siłą. Czas odnowienia i koszt zależą od tego, co niszczysz."
	button_icon_state = "power_strength_brujah"
	power_explanation = "To wzmocniona wersja zwykłej mocy 'Krzepa'.\n\
		Użyj na osobie, żeby posłać ją w powietrze. Użyj, gdy jesteś skrępowany, trzymany albo uwięziony w szafce, żeby się uwolnić.\n\
		Uderzenie cyborga oprócz zwykłych obrażeń tymczasowo go unieruchamia. \n\
		Na poziomie 2 możesz przebijać się przez niezablokowane śluzy. \n\
		Na poziomie 3 możesz przebijać się przez zablokowane śluzy. \n\
		Na poziomie 4 możesz przebijać się przez zwykłe ściany i okna. \n\
		Na poziomie 5 możesz przebijać się przez wzmocnione ściany i okna. \n\
		Wyższe poziomy zwiększają obrażenia i powalenie."
	power_flags = BP_AM_VERY_DYNAMIC_COOLDOWN
	vitaecost = 0 // Set on use
	cooldown_time = 1 SECONDS // Same as above
	damage_coefficient = 1.625
	brujah = TRUE
	level_current = 1

/datum/action/vampire/targeted/brawn/brash/two
	level_current = 2

/datum/action/vampire/targeted/brawn/brash/three
	level_current = 3

/datum/action/vampire/targeted/brawn/brash/four
	level_current = 4

/datum/action/vampire/targeted/brawn/brash/five
	level_current = 5

/// Hit an atom, set vitaecost, set cooldown time, play a sound, and deconstruct the atom
/// with this one convenient proc!
/datum/action/vampire/targeted/brawn/brash/proc/hit_with_style(atom/target_atom, sound, vol as num, cost as num, cooldown)
	if(!isobj(target_atom))
		return

	var/obj/target_obj = target_atom
	owner.do_attack_animation(target_obj)
	vitaecost = cost
	cooldown_time = cooldown
	playsound(target_atom, sound, 75, TRUE)
	target_obj.deconstruct(FALSE)

/datum/action/vampire/targeted/brawn/brash/FireTargetedPower(atom/target_atom)
	. = ..()
	// People
	if(isliving(target_atom))
		vitaecost = 50
		cooldown_time = 10 SECONDS
		return

	// Closets
	if(istype(target_atom, /obj/structure/closet))
		vitaecost = 50
		cooldown_time = 7 SECONDS
		return

	// Girders
	if(istype(target_atom, /obj/structure/girder))
		hit_with_style(target_atom, 'sound/effects/bang.ogg', 60, 300, 5 SECONDS)
		return

	// Grilles
	if(istype(target_atom, /obj/structure/grille))
		hit_with_style(target_atom, 'sound/effects/grillehit.ogg', 50, 10, 0.5 SECONDS)
		return

	// Windows
	if(istype(target_atom, /obj/structure/window))
		var/obj/structure/window/window = target_atom
		if(istype(target_atom, /obj/structure/window/reinforced) && level_current < 5)
			window.balloon_alert(owner, "wymagany poziom 5!")
			return
		else if(level_current < 4)
			window.balloon_alert(owner, "wymagany poziom 4!")
			return

		if(istype(window, /obj/structure/window/reinforced) || istype(window, /obj/structure/window/plasma))
			hit_with_style(window, 'sound/effects/bang.ogg', 30, 50, 15 SECONDS)
		else
			hit_with_style(window, 'sound/effects/bang.ogg', 20, 75, 10 SECONDS)
		return

	// Windoors
	if(istype(target_atom, /obj/machinery/door/window))
		hit_with_style(target_atom, 'sound/effects/bang.ogg', 50, 35, 5 SECONDS)
		return

	// Tables
	if(istype(target_atom, /obj/structure/table))
		hit_with_style(target_atom, 'sound/effects/bang.ogg', 35, 25, 5 SECONDS)
		return

	// Walls
	if(iswallturf(target_atom))
		if(isindestructiblewall(target_atom))
			target_atom.balloon_alert(owner, "tej ściany nie da się zniszczyć!")
			return

		if(istype(target_atom, /turf/closed/wall/r_wall) && level_current < 5)
			target_atom.balloon_alert(owner, "wymagany poziom 5!")
			return
		else if(level_current < 4)
			target_atom.balloon_alert(owner, "wymagany poziom 4!")
			return

		rip_and_tear(owner, target_atom)

/// Copied over from '/datum/element/wall_tearer/proc/rip_and_tear' with appropriate adjustment.
/datum/action/vampire/targeted/brawn/brash/proc/rip_and_tear(mob/living/tearer, atom/target)
	var/tear_time = 0.75 SECONDS
	var/reinforced_multiplier = 5
	var/rip_time = (istype(target, /turf/closed/wall/r_wall) ? tear_time * reinforced_multiplier : tear_time)

	if(istype(target, /turf/closed/wall/r_wall))
		vitaecost = 100
		cooldown_time = 20 SECONDS
	else
		vitaecost = 85
		cooldown_time = 15 SECONDS

	while(istype(target, /turf/closed/wall))
		var/turf/closed/wall/wall = target

		tearer.visible_message(span_warning("[tearer] z furią rozdziera: [wall]!"))
		playsound(tearer, 'sound/machines/airlock_alien_prying.ogg', vol = 50, vary = TRUE, frequency = 2)
		wall.balloon_alert(tearer, "rozdzierasz...")

		if(vampire_do_after(tearer, delay = rip_time, target = wall, interaction_key = "vampire interaction"))
			playsound(tearer, 'sound/effects/meteorimpact.ogg', 100, TRUE)
			tearer.do_attack_animation(wall)
			wall.dismantle_wall(1)
			return
		else
			tearer.balloon_alert(tearer, "przerwano!")
			return

/// TODO: check if switch statements work with istype()
/datum/action/vampire/targeted/brawn/brash/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	if(isobj(target_atom))
		var/obj/target_obj = target_atom
		if(target_obj.resistance_flags & INDESTRUCTIBLE)
			return FALSE
	if(isliving(target_atom))
		return TRUE
	if(istype(target_atom, /obj/machinery/door/airlock))
		return TRUE
	if(istype(target_atom, /obj/structure/table))
		return TRUE
	if(istype(target_atom, /obj/structure/closet))
		return TRUE
	if(istype(target_atom, /obj/structure/girder))
		return TRUE
	if(istype(target_atom, /obj/structure/grille))
		return TRUE
	if(istype(target_atom, /obj/structure/window))
		return TRUE
	if(iswallturf(target_atom))
		return TRUE

	return FALSE
