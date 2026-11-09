// AQUILA - Zatkane ubikacje (nowe, nie ma tego w Monke).
// Muszla trzyma to, co do niej trafiło (kał i mocz). Spłukanie zabiera zawartość, ale czasem toaleta się zatyka:
// wtedy woda nie schodzi, a każde kolejne spłukanie przelewa wodę ze spłuczki razem z zawartością muszli na podłogę
// (przez spill_reagents, więc 50 j. wody to od razu kałuża). Odtyka się przepychaczką.

/// Szansa na zatkanie przy spłukiwaniu pustej muszli
#define TOILET_CLOG_CHANCE_EMPTY 1
/// Szansa na zatkanie przy spłukiwaniu muszli z zawartością
#define TOILET_CLOG_CHANCE_WASTE 8
/// Najwięcej kup, które wylatują przy jednym przelaniu
#define TOILET_OVERFLOW_MAX_FECES 3

/obj/structure/toilet
	/// Czy toaleta jest zatkana
	var/clogged = FALSE
	/// Ile jednostek moczu jest w muszli
	var/bowl_urine = 0
	/// Ile kup jest w muszli
	var/bowl_feces = 0

/obj/structure/toilet/examine(mob/user)
	. = ..()
	if(clogged)
		. += "<span class='warning'>Woda w muszli stoi niebezpiecznie wysoko. Toaleta jest zatkana, spłukanie ją przeleje. Przepchaj ją <b>przepychaczką</b>.</span>"
	else if(open && (bowl_urine || bowl_feces) && !user.censors_bodily_functions())
		. += "<span class='notice'>Ktoś nie spuścił wody.</span>"

/// Coś trafia do muszli (wypróżnienie, mocz)
/obj/structure/toilet/proc/receive_waste(urine_units = 0, feces = 0)
	bowl_urine += max(0, urine_units)
	bowl_feces += max(0, feces)

/obj/structure/toilet/flush(mob/user, silent = FALSE)
	var/had_waste = bowl_urine || bowl_feces
	. = ..()
	if(!.)
		return
	if(clogged)
		overflow(user)
		return
	if(prob(had_waste ? TOILET_CLOG_CHANCE_WASTE : TOILET_CLOG_CHANCE_EMPTY))
		clogged = TRUE
		visible_message("<span class='warning'>Woda w [src] bulgocze i podchodzi aż pod deskę. Coś ją zatkało!</span>")
		return
	bowl_urine = 0
	bowl_feces = 0

/// Zatkana toaleta przelewa wodę ze spłukania i zawartość muszli na podłogę
/obj/structure/toilet/proc/overflow(mob/user)
	var/turf/T = get_turf(src)
	if(!T)
		return
	visible_message("<span class='danger'>[src] się przelewa!</span>")
	var/datum/reagents/spilled = new(TOILET_FLUSH_VOLUME + bowl_urine + 10, NO_REACT)
	spilled.add_reagent(reagent_id, TOILET_FLUSH_VOLUME, no_react = TRUE)
	if(bowl_urine)
		spilled.add_reagent(/datum/reagent/ammonia/urine, bowl_urine, reagtemp = T20C, no_react = TRUE)
	T.spill_reagents(spilled)
	qdel(spilled)
	for(var/i in 1 to min(bowl_feces, TOILET_OVERFLOW_MAX_FECES))
		new /obj/effect/decal/cleanable/feces(T)
	bowl_urine = 0
	bowl_feces = 0
	for(var/mob/living/L in viewers(7, T))
		if(!L.censors_bodily_functions())
			L.adjust_disgust(DISGUST_LEVEL_GROSS)

/obj/structure/toilet/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	if(!clogged)
		return ..()
	user.balloon_alert_to_viewers("przepycha toaletę...")
	if(!do_after(user, (reinforced ? 2 SECONDS : 4 SECONDS), target = src))
		return TRUE
	clogged = FALSE
	bowl_urine = 0
	bowl_feces = 0
	user.balloon_alert_to_viewers("przepchane")
	playsound(src, 'sound/effects/slosh.ogg', 30, TRUE)
	to_chat(user, "<span class='notice'>Coś głośno chlupie i woda w [src] schodzi.</span>")
	return TRUE

#undef TOILET_CLOG_CHANCE_EMPTY
#undef TOILET_CLOG_CHANCE_WASTE
#undef TOILET_OVERFLOW_MAX_FECES
