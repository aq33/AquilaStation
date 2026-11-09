// AQUILA - Mocz jako część potrzeby wypróżnienia.
// defecation to cała potrzeba (alert, nastrój i progi bez zmian), urination to jej część pochodząca z picia.
// - popuszczenie (próg DEFECATION_ACTUALLY_SHIT_YOURSELF): oddaje tylko to, czego jest więcej (kał albo mocz)
// - wypróżnienie na miejscu (alert): oddaje obie części
// - ubikacja: zeruje całą potrzebę, pisuar: tylko mocz
// - emotka *piss: sam mocz, do trzymanego pojemnika, ubikacji, pisuaru albo na podłogę
// Z Monke: plama i ciecz moczu, wpis do kartoteki przy kamerze, pęcherz klauna z lubrykantem.

/mob/living
	/// Część potrzeby wypróżnienia (defecation) pochodząca z picia, zawsze <= defecation
	var/urination = 0

/// Ile potrzeby przypada na kał
/mob/living/proc/feces_need()
	return max(0, defecation - urination)

/// Picie dokłada potrzebę jako mocz (tylko z pęcherzem)
/mob/living/proc/add_urine_need(amount)
	return

/mob/living/carbon/add_urine_need(amount)
	if(amount <= 0 || !CONFIG_GET(flag/shitting_enabled) || !getorganslot(ORGAN_SLOT_BLADDER))
		return
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		amount *= H.physiology.defecation_mod * (H.dna?.species?.shitmod || 1)
	if(adjust_defecation(amount))
		urination = min(urination + amount, defecation)

/mob/living/carbon/human/adjust_hydration(var/change)
	. = ..()
	if(change > 0 && !HAS_TRAIT(src, TRAIT_NOTHIRST))
		add_urine_need(change * URINATION_PER_HYDRATION)

/// Popuszczenie: wychodzi to, czego jest więcej
/mob/living/proc/accidental_release()
	if(!CONFIG_GET(flag/shitting_enabled))
		return
	if(urination > feces_need())
		var/urine_need = urination
		urination = 0
		adjust_defecation(-urine_need)
		release_urine(urine_need, is_wearing_pants(), FALSE, TRUE)
		return
	actually_shit_myself()
	set_defecation(urination) // zostaje sam mocz

/**
 * Oddaje mocz na kafelek.
 * need_amount - ile potrzeby oddajemy (mocz to URINE_UNITS_PER_NEED jednostek na jednostkę potrzeby)
 * clothed - w spodnie: smród, ale i tak cieknie na podłogę
 * voluntary - świadomie (emotka, alert), inaczej popuszczenie
 */
/mob/living/proc/release_urine(need_amount, clothed, voluntary = FALSE, show_message = TRUE)
	var/turf/T = get_turf(src)
	if(!T || need_amount <= 0)
		return
	var/obj/item/organ/bladder/bladder = getorganslot(ORGAN_SLOT_BLADDER)
	var/reagent_type = bladder?.pissin_reagent || /datum/reagent/ammonia/urine
	var/units = max(1, need_amount * URINE_UNITS_PER_NEED)

	if(show_message)
		if(clothed)
			bodily_visible_message(
				"<span class='warning'>[src] [voluntary ? "sika" : "popuszcza mocz"] w spodnie!</span>",
				"<span class='warning'>[voluntary ? "Sikasz" : "Popuszczasz mocz"] w spodnie!</span>")
		else
			bodily_visible_message(
				"<span class='warning'>[src] sika na podłogę!</span>",
				"<span class='notice'><i>Ale ulga...</i></span>")
		bodily_disgust(DISGUST_LEVEL_GROSS, FALSE)

	var/datum/reagents/urine = new(units + 1, NO_REACT)
	urine.add_reagent(reagent_type, units, reagtemp = URINE_TEMPERATURE, no_react = TRUE)
	T.spill_reagents(urine)
	qdel(urine)

	if(clothed && ishuman(src))
		var/mob/living/carbon/human/H = src
		H.set_hygiene(min(H.hygiene, HYGIENE_LEVEL_DIRTY))
	report_public_urination()

/// Kamera w zasięgu: wpis do kartoteki i status Poszukiwany (Monke: Automated Criminal Detection Service)
/mob/living/proc/report_public_urination()
	var/turf/T = get_turf(src)
	var/obj/machinery/camera/seen_by
	for(var/obj/machinery/camera/camera in view(7, T))
		if(camera.can_use() && get_dist(src, camera) <= camera.view_range)
			seen_by = camera
			break
	if(!seen_by)
		return
	var/datum/data/record/record = find_record("name", name, GLOB.data_core.security)
	if(!record)
		return
	var/area/A = get_area(T)
	var/datum/data/crime/crime = GLOB.data_core.createCrimeEntry("Publiczne oddawanie moczu", "Kamera nagrała tę osobę, gdy oddawała mocz w: [A?.name].", "Automatyczny system wykrywania wykroczeń", station_time_timestamp())
	GLOB.data_core.addCrime(record.fields["id"], crime)
	record.fields["criminal"] = "Arrest"
	for(var/mob/living/carbon/human/human in GLOB.carbon_list)
		human.sec_hud_set_security_status()

/// Emotka *piss: sam mocz
/mob/living/carbon/human/proc/urinate_voluntarily()
	if(urination < URINATION_MINIMUM)
		to_chat(src, "<span class='notice'>Jak się nie starasz, nic z tego.</span>")
		return
	if(incapacitated())
		to_chat(src, "<span class='warning'>Nie jesteś teraz w stanie.</span>")
		return
	var/obj/item/organ/bladder/bladder = getorganslot(ORGAN_SLOT_BLADDER)
	var/reagent_type = bladder?.pissin_reagent || /datum/reagent/ammonia/urine

	// Do trzymanego pojemnika
	var/obj/item/reagent_containers/held = get_active_held_item()
	if(istype(held) && held.is_refillable() && !held.reagents.holder_full())
		var/free_units = held.reagents.maximum_volume - held.reagents.total_volume
		var/need_used = min(urination, free_units / URINE_UNITS_PER_NEED)
		held.reagents.add_reagent(reagent_type, need_used * URINE_UNITS_PER_NEED, reagtemp = URINE_TEMPERATURE)
		urination -= need_used
		adjust_defecation(-need_used)
		bodily_visible_message(
			"<span class='notice'>[src] sika do [held].</span>",
			"<span class='notice'>Sikasz do [held].</span>")
		return

	var/turf/T = get_turf(src)
	if(locate(/obj/structure/toilet) in T)
		empty_bladder_into("ubikacji")
		return
	if(locate(/obj/structure/urinal) in T)
		empty_bladder_into("pisuaru")
		return

	var/urine_need = urination
	urination = 0
	adjust_defecation(-urine_need)
	release_urine(urine_need, is_wearing_pants(), TRUE, TRUE)

/// Mocz do ubikacji albo pisuaru: tylko część z picia
/mob/living/proc/empty_bladder_into(where)
	var/urine_need = urination
	urination = 0
	adjust_defecation(-urine_need)
	bodily_visible_message(
		"<span class='notice'>[src] ostrożnie sika do [where], nie roniąc ani kropli.</span>",
		"<span class='notice'><i>Ale ulga...</i></span>")

/// Pisuar: kliknięcie z potrzebą oddania moczu, poza combat mode
/obj/structure/urinal/attack_hand(mob/living/user)
	var/mob/living/carbon/C = user
	if(iscarbon(C) && !C.combat_mode && !C.pulling && !exposed && CONFIG_GET(flag/shitting_enabled) && C.urination >= URINATION_MINIMUM && C.getorganslot(ORGAN_SLOT_BLADDER))
		if(do_after(C, 2 SECONDS, target = src))
			C.empty_bladder_into("pisuaru")
		return TRUE
	return ..()
