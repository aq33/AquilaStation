/mob/living/Initialize(mapload)
	. = ..()
	set_hydration(rand(HYDRATION_LEVEL_START_MIN, HYDRATION_LEVEL_START_MAX))
	if(CONFIG_GET(flag/shitting_enabled))
		set_defecation(rand(DEFECATION_NONE, DEFECATION_SOMEWHAT))

///Adjust the need to defecate of a mob
/mob/living/proc/adjust_defecation(var/change)
	defecation = max(0, defecation + change)
	urination = clamp(urination, 0, defecation) // mocz to część tej samej potrzeby
	return TRUE

///Force set the mob need to defecate
/mob/living/proc/set_defecation(var/change)
	defecation = max(0, change)
	urination = clamp(urination, 0, defecation)
	return TRUE

/// Kał w spodnie (popuszczenie). Mocz oddaje release_urine() w urination.dm. Kamera tego nie zgłasza (mimowolne).
/mob/living/proc/actually_shit_myself()
	if(!CONFIG_GET(flag/shitting_enabled))
		return FALSE
	bodily_visible_message(
		"<span class='warning'>[src] popuścił[gender == FEMALE ? "a" : ""] w spodnie!</span>",
		"<span class='warning'>Popuścił[gender == FEMALE ? "aś" : "eś"] w spodnie!</span>")

	bodily_disgust(DISGUST_LEVEL_VERYGROSS, TRUE)

	bodily_playsound(src, 'aquila/sound/creatures/fart.ogg', 100)
	new /obj/effect/decal/cleanable/feces(get_turf(src))
	var/datum/reagent/consumable/castor_oil/oil = reagents?.get_reagent(/datum/reagent/consumable/castor_oil)
	oil?.purge(src)
	return TRUE

/mob/living/carbon/human/actually_shit_myself()
	. = ..()
	if(.)
		set_hygiene(HYGIENE_LEVEL_DISGUSTING)

/// Trwa wypróżnianie z alertu, żeby nie kliknąć dwa razy (nazwa celowo różna od defecation, żeby nie pomylić w VV)
/mob/living/var/toilet_busy = FALSE

/// Wypróżnienie na żądanie (kliknięcie w alert): w ubraniu zostaje smród, nago tylko kupa na podłodze
/mob/living/proc/defecate_here()
	if(toilet_busy)
		return FALSE
	if(!CONFIG_GET(flag/shitting_enabled))
		to_chat(src, "<span class='warning'>Wypróżnianie się zostało wyłączone w konfiguracji serwera.</span>")
		return FALSE
	if(defecation <= DEFECATION_VERY)
		to_chat(src, "<span class='notice'>Nie potrzebujesz skorzystać z ubikacji.</span>")
		return FALSE
	if(incapacitated())
		to_chat(src, "<span class='warning'>Nie jesteś teraz w stanie.</span>")
		return FALSE
	var/obj/structure/toilet/toilet = locate() in get_turf(src)
	if(toilet)
		toilet_busy = TRUE
		if(do_after(src, 3 SECONDS, target = toilet))
			toilet.shit(src)
		toilet_busy = FALSE
		return TRUE
	var/clothed = is_wearing_pants()
	if(clothed)
		to_chat(src, "<span class='warning'>Załatwiasz się w ubraniu... będzie śmierdzieć.</span>")
	else
		to_chat(src, "<span class='notice'>Kucasz w miejscu...</span>")
	toilet_busy = TRUE
	var/success = do_after(src, 3 SECONDS, target = src)
	toilet_busy = FALSE
	if(!success)
		return FALSE
	finish_defecate_here(clothed)
	return TRUE

/// Skutek wypróżnienia poza ubikacją: oddaje kał i mocz naraz. W ubraniu jak popuszczenie (smród), nago na podłogę bez utraty higieny.
/mob/living/proc/finish_defecate_here(clothed)
	var/urine_need = urination
	var/feces_need = feces_need()
	set_defecation(DEFECATION_NONE)
	if(urine_need)
		release_urine(urine_need, clothed, TRUE, !feces_need, !feces_need) // przy kale wystarczy jeden komunikat i jedno zgłoszenie kamery
	if(clothed)
		if(feces_need)
			actually_shit_myself()
			report_public_bodily_function("Publiczne wypróżnianie się", "załatwiała się")
		return
	if(!feces_need)
		return
	bodily_visible_message(
		"<span class='warning'>[src] załatwia się na podłogę!</span>",
		"<span class='notice'><i>Ale ulga...</i></span>")
	bodily_disgust(DISGUST_LEVEL_GROSS, FALSE)
	bodily_playsound(src, 'aquila/sound/creatures/fart.ogg', 100)
	new /obj/effect/decal/cleanable/feces(get_turf(src))
	var/datum/reagent/consumable/castor_oil/oil = reagents?.get_reagent(/datum/reagent/consumable/castor_oil)
	oil?.purge(src)
	report_public_bodily_function("Publiczne wypróżnianie się", "załatwiała się")

/// Czy coś zakrywa krocze (wtedy wypróżnienie idzie w spodnie)
/mob/living/proc/is_wearing_pants()
	return FALSE

/mob/living/carbon/human/is_wearing_pants()
	var/obj/item/clothing/uniform = w_uniform
	var/obj/item/clothing/suit = wear_suit
	return (uniform && (uniform.body_parts_covered & GROIN)) || (suit && (suit.body_parts_covered & GROIN))

///Adjust the thirst of a mob
/mob/living/proc/adjust_hydration(var/change)
	hydration = max(0, hydration + change)

///Force set the mob thirst
/mob/living/proc/set_hydration(var/change)
	hydration = max(0, change)

// Szarpnięcie przy ogłuszeniu pałką: port z BeeStation-Hornet (code/modules/mob/living/living.dm)
/mob/living/proc/do_stun_animation()
	var/matrix/rotation_matrix = matrix()
	rotation_matrix.Turn(5)
	var/matrix/reset_matrix = matrix()
	reset_matrix.Turn(-5)
	// Offset animation
	var/start_x = rand(-2, 2)
	var/start_y = rand(-1, 1)
	animate(src, time = 1, pixel_x = start_x, pixel_y = start_y, easing = ELASTIC_EASING, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	for (var/i in 1 to 4)
		var/dx = rand(-4, 2)
		var/dy = rand(-4, 2)
		animate(time = 1, pixel_x = dx, pixel_y = dy, easing = ELASTIC_EASING, flags = ANIMATION_RELATIVE)
		animate(time = 0, pixel_x = -dx, pixel_y = -dy, easing = ELASTIC_EASING, flags = ANIMATION_RELATIVE)
	// Cofnięcie tylko własnego przesunięcia, żeby nie zgubić offsetu leżenia
	animate(time = 1, pixel_x = -start_x, pixel_y = -start_y, flags = ANIMATION_RELATIVE)
	// Rotational Animation
	animate(src, time = 3, transform = rotation_matrix, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
	animate(time = 2, flags = ANIMATION_RELATIVE)
	animate(time = 1, transform = reset_matrix, flags = ANIMATION_RELATIVE)

// Kamera nie zostaje w kontenerze, z którego postać wyszła zwykłym Move() (zgłoszenie: po wpadnięciu do zsypu
// kamera stała na zsypie, a postacią dało się chodzić gdzie indziej; pomagało dopiero wyjście z gry).
// Kamerę na postać przestawia tylko forceMove() (reset_perspective w /mob/living/forceMove), a BYOND pozwala
// wyjść z obiektu ruchem: get_step() z wnętrza kontenera daje kafel obok niego i Move() tam po prostu przechodzi.
/mob/living/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(client && OldLoc && !isturf(OldLoc) && isturf(loc) && client.eye == OldLoc)
		reset_perspective()
