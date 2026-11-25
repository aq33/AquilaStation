// Rozdarcia Fobetora: uraz mózgu mięsoczłowieka (Fulpstation, fulp_modules/features/species/beefmen/phobetor_trauma.dm).
// Odmiana proroctwa bluespace: mięsoczłowiek widzi pary rozdarć, wie, dokąd prowadzą, ale przejdzie tylko wtedy,
// gdy nikt nie patrzy na żadną ze stron. Przejście przy niskiej poczytalności daje halucynacje i zły nastrój.
// U nas rozdarcie to /obj/effect/hallucination/simple (jak strumień bluespace), w tg client_image_holder.

/datum/brain_trauma/special/bluespace_prophet/phobetor
	name = "Bezsenny śniący"
	desc = "Pacjent po niewyobrażalnych przejściach psychicznych wierzy, że potrafi podróżować między metafizycznymi krainami snu."
	scan_desc = "przebudzony śpiący"
	gain_text = "<span class='notice'>Coś pęka ci w umyśle i budzisz się. <i>Naprawdę</i> się budzisz.</span>"
	lose_text = "<span class='warning'>Znów zapadasz w bezsenny sen nieprzebudzonych.</span>"
	random_gain = FALSE
	/// Pierwsze rozdarcie z każdej pary, od najstarszego
	var/list/created_firsts = list()
	/// Wypalony: rozdarcia są półprzezroczyste i nieczynne
	var/burnt_out = FALSE

/datum/brain_trauma/special/bluespace_prophet/phobetor/on_gain()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))

/datum/brain_trauma/special/bluespace_prophet/phobetor/on_lose(silent)
	for(var/obj/effect/hallucination/simple/phobetor/tear as anything in created_firsts)
		qdel(tear)
	created_firsts.Cut()
	UnregisterSignal(owner, COMSIG_LIVING_REVIVE)
	return ..()

/datum/brain_trauma/special/bluespace_prophet/phobetor/on_life()
	if(world.time < next_portal)
		return
	next_portal = world.time + 10 SECONDS

	// Najstarsza para znika po swoim czasie (usuwa też drugą stronę)
	if(length(created_firsts))
		var/obj/effect/hallucination/simple/phobetor/oldest = created_firsts[1]
		if(QDELETED(oldest) || world.time >= oldest.created_on + oldest.exist_length)
			created_firsts -= oldest
			if(!QDELETED(oldest))
				qdel(oldest)

	var/turf/first_turf = random_valid_floor(owner, 6, 0)
	if(!first_turf)
		return
	var/turf/second_turf = random_valid_floor(first_turf, 20, 6)
	if(!second_turf)
		return

	var/obj/effect/hallucination/simple/phobetor/first = new(first_turf, owner)
	var/obj/effect/hallucination/simple/phobetor/second = new(second_turf, owner)
	first.link_with(second, owner)
	second.link_with(first, owner)
	created_firsts += first
	if(burnt_out)
		first.deactivate()

/// Losowe pole podłogi w odległości min_range..check_range od atomu, wolne od gęstych obiektów, z dozwoloną teleportacją
/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/random_valid_floor(atom/center_atom, check_range = 8, min_range = 0)
	var/turf/center = get_turf(center_atom)
	if(!center)
		return null
	var/turf/target = locate(center.x + rand(min_range, check_range) * pick(-1, 1), center.y + rand(min_range, check_range) * pick(-1, 1), center.z)
	if(!check_turf_is_valid(target))
		return null
	return target

/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/check_turf_is_valid(turf/open_turf)
	if(!istype(open_turf, /turf/open/floor) || open_turf.density)
		return FALSE
	var/area/turf_area = get_area(open_turf)
	if(turf_area.teleport_restriction != TELEPORT_ALLOW_ALL)
		return FALSE
	for(var/obj/object in open_turf)
		if(object.density)
			return FALSE
	return TRUE

/// Po przejściu w obłędzie rozdarcia gasną na kilka minut
/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/burn_out(timer = 5 MINUTES)
	burnt_out = TRUE
	to_chat(owner, span_warning("Czujesz, jak znów osuwasz się w bezsenny sen..."))
	for(var/obj/effect/hallucination/simple/phobetor/tear as anything in created_firsts)
		tear.deactivate()
	if(timer)
		addtimer(CALLBACK(src, PROC_REF(restore)), timer, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/restore()
	if(!burnt_out)
		return
	burnt_out = FALSE
	to_chat(owner, span_hypnophrase("Twoje oczy otwierają się razem z niewidzialnymi ścieżkami."))
	for(var/obj/effect/hallucination/simple/phobetor/tear as anything in created_firsts)
		tear.activate()

/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/on_revive(datum/source, full_heal, admin_revive)
	SIGNAL_HANDLER
	if(full_heal)
		restore()

/obj/effect/hallucination/simple/phobetor
	name = "rozdarcie Fobetora"
	desc = "Podwymiarowe rozdarcie rzeczywistości, przejście dla tych, którzy przebudzili się z bezsennego snu."
	image_icon = 'aquila/icons/mob/species/beefman/phobetor_tear.dmi'
	image_state = "phobetor_tear"
	image_layer = ABOVE_MOB_LAYER
	/// Jak długo istnieje para rozdarć
	var/exist_length = 50 SECONDS
	var/created_on
	/// Druga strona rozdarcia
	var/obj/effect/hallucination/simple/phobetor/linked_to
	/// Jedyny, kto widzi rozdarcie i może przez nie przejść
	var/mob/living/carbon/seer
	/// Nieczynne rozdarcie (wypalenie) jest półprzezroczyste
	var/tear_active = TRUE

/obj/effect/hallucination/simple/phobetor/Initialize(mapload, mob/living/carbon/T)
	. = ..()
	created_on = world.time

/obj/effect/hallucination/simple/phobetor/Destroy()
	if(linked_to)
		var/obj/effect/hallucination/simple/phobetor/other = linked_to
		linked_to = null
		if(other.linked_to == src)
			other.linked_to = null
		qdel(other)
	seer = null
	return ..()

/obj/effect/hallucination/simple/phobetor/proc/link_with(obj/effect/hallucination/simple/phobetor/other, mob/living/carbon/new_seer)
	linked_to = other
	seer = new_seer
	var/area/other_area = get_area(other)
	name = "[initial(name)] ([other_area.name])"
	desc = "[initial(desc)] To prowadzi do: [other_area.name]."

/obj/effect/hallucination/simple/phobetor/GetImage()
	var/image/tear_image = ..()
	tear_image.alpha = tear_active ? 255 : 128
	return tear_image

/obj/effect/hallucination/simple/phobetor/proc/activate()
	tear_active = TRUE
	Show()
	if(linked_to && !linked_to.tear_active)
		linked_to.activate()

/obj/effect/hallucination/simple/phobetor/proc/deactivate()
	tear_active = FALSE
	Show()
	if(linked_to?.tear_active)
		linked_to.deactivate()

/// Czy ktoś (żywy, z umysłem, widzący, nie silikon) patrzy na to pole. Ciemność kryje.
/obj/effect/hallucination/simple/phobetor/proc/check_location_seen(atom/subject, turf/target_turf)
	if(!isturf(target_turf))
		return FALSE
	if(target_turf.get_lumcount() < 0.1)
		return FALSE
	for(var/mob/living/viewer in viewers(target_turf))
		if(viewer == subject || !viewer.mind)
			continue
		if(issilicon(viewer) || isdrone(viewer) || isbot(viewer) || viewer.is_blind())
			continue
		return TRUE
	return FALSE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/hallucination/simple/phobetor/attack_hand(mob/living/user, list/modifiers)
	if(user != seer || !linked_to)
		return
	if(!tear_active)
		user.balloon_alert(user, "rozdarcie jest za słabe!")
		return
	if(!in_range(user, src))
		return
	if(user.incapacitated() || user.buckled || user.pulledby?.grab_state >= GRAB_AGGRESSIVE)
		user.balloon_alert(user, "nie teraz!")
		return
	if(locate(/obj/item/implant/tracking) in user.implants)
		user.balloon_alert(user, "coś cię obserwuje od środka!")
		return
	if(check_location_seen(user, get_turf(user)))
		user.balloon_alert(user, "nie, gdy ktoś patrzy!")
		return
	if(check_location_seen(user, get_turf(linked_to)))
		user.balloon_alert(user, "ktoś patrzy na drugą stronę!")
		return
	user.balloon_alert(user, "wślizgujesz się w rozdarcie")

	var/mob/living/carbon/carbon_user = user
	var/datum/component/mood/mood = user.GetComponent(/datum/component/mood)
	var/sanity = mood ? mood.sanity : SANITY_NEUTRAL
	var/datum/brain_trauma/special/bluespace_prophet/phobetor/trauma = carbon_user.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor)
	switch(sanity)
		if(-INFINITY to SANITY_CRAZY)
			to_chat(user, span_notice("...ale przez [src] przechodzi też <b>ktoś inny</b>."))
			playsound(user, 'sound/hallucinations/i_see_you1.ogg', 50, TRUE)
			user.adjust_hallucinations(5 MINUTES)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "phobetor_tear", /datum/mood_event/phobetor_crash)
			to_chat(user, span_userdanger("Obce wspomnienia wdzierają ci się do głowy!"))
			trauma?.burn_out()
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			if(prob(40))
				to_chat(user, span_smallnoticeital("Czujesz, że coś przeszło za tobą przez [src]."))
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "phobetor_tear", /datum/mood_event/phobetor_major)
				user.adjust_hallucinations(2 MINUTES)
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			if(prob(33))
				to_chat(user, span_smallnoticeital("...czy to była osoba w środku [src]?"))
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "phobetor_tear", /datum/mood_event/phobetor_major)
				user.adjust_hallucinations(1 MINUTES)
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			if(prob(25))
				to_chat(user, span_smallnoticeital("Kątem oka widzisz migoczący cień."))
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "phobetor_tear", /datum/mood_event/phobetor_minor)
				user.adjust_hallucinations(30 SECONDS)
		else
			if(prob(10))
				to_chat(user, span_smallnoticeital("Ta podróż nigdy nie jest przyjemna."))
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "phobetor_tear", /datum/mood_event/phobetor_minor)
	if(prob(5))
		playsound(user, pick(GLOB.creepy_ambience), 50, TRUE)
	user.playsound_local(null, 'sound/magic/wand_teleport.ogg', 30, FALSE, pressure_affected = FALSE)
	user.forceMove(get_turf(linked_to))

/datum/mood_event/phobetor_minor
	description = "<span class='warning'>Coś w tych rozdarciach mnie odpycha.</span>\n"
	mood_change = -2
	timeout = 1 MINUTES

/datum/mood_event/phobetor_minor/add_effects(param)
	switch(rand(1, 3))
		if(1)
			description = "<span class='warning'>Kraina snu wydaje się dziś ponura.</span>\n"
		if(2)
			description = "<span class='warning'>Nigdy nie lubiłem faktury tego snu.</span>\n"
		if(3)
			description = "<span class='warning'>Coś w tych rozdarciach mnie odpycha.</span>\n"

/datum/mood_event/phobetor_major
	description = "<span class='boldwarning'>Coś mnie śledzi przez rozdarcia.</span>\n"
	mood_change = -6
	timeout = 3 MINUTES

/datum/mood_event/phobetor_major/add_effects(param)
	switch(rand(1, 3))
		if(1)
			description = "<span class='boldwarning'>Nie byłem sam w krainie snu, jestem tego pewien.</span>\n"
		if(2)
			description = "<span class='boldwarning'>Ktoś na mnie poluje. Słyszę, jak pełza.</span>\n"
		if(3)
			description = "<span class='boldwarning'>Coś mnie śledzi przez rozdarcia.</span>\n"

/datum/mood_event/phobetor_crash
	description = "<span class='boldwarning'>Nie mogę zamknąć oczu...</span>\n"
	mood_change = -10
	timeout = 5 MINUTES

/datum/mood_event/phobetor_crash/add_effects(param)
	switch(rand(1, 5))
		if(1)
			description = "<span class='boldwarning'>Dziś nie przynieśli jedzenia...</span>\n"
		if(2)
			description = "<span class='boldwarning'>Gaz usypiający wciąż się podnosi... Nie mogę oddychać.</span>\n"
		if(3)
			description = "<span class='boldwarning'>Nie mogę zamknąć oczu...</span>\n"
		if(4)
			description = "<span class='boldwarning'>Lekarz ciągle coś mamrocze. Nie podoba mi się to.</span>\n"
		if(5)
			var/sleeper = random_unique_beefman_name()
			description = "<span class='boldwarning'>[sleeper] nie obudził się dzisiaj. Ani wczoraj.</span>\n"
