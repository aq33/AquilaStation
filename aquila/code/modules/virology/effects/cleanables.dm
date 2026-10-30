GLOBAL_LIST_EMPTY(infected_cleanables)

/obj/effect/decal/cleanable/Initialize(mapload, list/datum/disease/diseases)
	..()
	// AQ: nasz rdzeń dostaje listę chorób, ale jej nie trzyma (robi to tylko komponent infective),
	// a patogeny muszą w plamie zostać, żeby dalej zarażały przez kontakt i powietrze.
	for(var/datum/disease/acute/infection in diseases)
		if(istype(infection))
			LAZYOR(src.diseases, infection)
	return INITIALIZE_HINT_LATELOAD

/obj/effect/decal/cleanable/LateInitialize(mapload_arg)
	//cleanables can get infected in many different ways when they spawn so it's much easier to handle the pathogen overlay here after a delay
	addtimer(CALLBACK(src, PROC_REF(setup_diseases)), 0.1 SECONDS)

/obj/effect/decal/cleanable/proc/setup_diseases()
	if(!length(src.diseases) || QDELETED(src))
		return
	GLOB.infected_cleanables += src
	if (!pathogen)
		pathogen = image('aquila/icons/virology/effects.dmi', src, "pathogen_blood")
		pathogen.plane = HUD_PLANE
		pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
	for (var/mob/L in GLOB.virus_viewers)
		if (L.client)
			L.client.images |= pathogen

/obj/effect/decal/cleanable/Destroy()
	GLOB.infected_cleanables -= src
	return ..()

/obj/effect/decal/cleanable/Entered(mob/living/perp)
	..()
	infection_attempt(perp)

/obj/effect/decal/cleanable/infection_attempt(mob/living/perp)
	//Now if your feet aren't well protected, or are bleeding, you might get infected.
	var/block = 0
	var/bleeding = 0
	if (perp.lying & LYING_DOWN)
		block = perp.check_contact_sterility(BODY_ZONE_EVERYTHING)
		bleeding = perp.check_bodypart_bleeding(BODY_ZONE_EVERYTHING)
	else
		block = perp.check_contact_sterility(BODY_ZONE_LEGS)
		bleeding = perp.check_bodypart_bleeding(BODY_ZONE_LEGS)

	for(var/datum/disease/acute/contained_virus in diseases)
		if (!block && (contained_virus.spread_flags & DISEASE_SPREAD_CONTACT_SKIN))
			perp.infect_disease(contained_virus, notes="(Contact, from [(perp.lying & LYING_DOWN)?"lying":"standing"] over [src]])")
		else if (bleeding && (contained_virus.spread_flags & DISEASE_SPREAD_BLOOD))
			perp.infect_disease(contained_virus, notes="(Blood, from [(perp.lying & LYING_DOWN)?"lying":"standing"] over [src]])")
