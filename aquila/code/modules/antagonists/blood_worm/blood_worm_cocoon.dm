// AQUILA - kokon krwawego robaka: dojrzewanie i rozmnażanie (port z tgstation#93787, #95356, #96017)

/datum/action/cooldown/spell/blood_worm/cocoon
	cooldown_time = 30 SECONDS
	var/cocoon_type = null
	var/obj/structure/blood_worm_cocoon/cocoon = null
	var/new_worm_type = null
	var/total_blood_required = 0
	var/timer_id = null
	var/cocoon_time = 30 SECONDS
	/// Tekst potwierdzenia przed wejściem do kokonu
	var/confirm_text = ""
	/// Czy gracz właśnie odpowiada na pytanie albo robak się owija
	var/starting = FALSE

/datum/action/cooldown/spell/blood_worm/cocoon/New(Target)
	. = ..()
	button.maptext_x = 1
	button.maptext_y = 2

/datum/action/cooldown/spell/blood_worm/cocoon/Grant(mob/grant_to)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_worm_stat_changed), override = TRUE)
		update_cooldown_text()

/datum/action/cooldown/spell/blood_worm/cocoon/Remove(mob/remove_from)
	if(!QDELETED(cocoon))
		cancel()
	if(remove_from)
		UnregisterSignal(remove_from, COMSIG_MOB_STATCHANGE)
	return ..()

/datum/action/cooldown/spell/blood_worm/cocoon/Destroy()
	if(!QDELETED(cocoon))
		cancel()
	return ..()

// Gdy nie ma odnowienia, na przycisku widać postęp wzrostu
/datum/action/cooldown/spell/blood_worm/cocoon/update_cooldown_text()
	if(!button)
		return
	var/time_left = max(next_use_time - world.time, 0)
	if(owner && time_left)
		return ..()
	var/mob/living/simple_animal/hostile/blood_worm/worm = target
	if(!istype(worm) || !total_blood_required)
		button.maptext = ""
		return
	var/percentage = min(round(worm.get_consumed_blood() / total_blood_required * 100), 100)
	button.maptext = MAPTEXT("<span style='text-align: center'>[percentage]%</span>")

/datum/action/cooldown/spell/blood_worm/cocoon/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	. = ..()
	update_cooldown_text()

/datum/action/cooldown/spell/blood_worm/cocoon/can_cast_spell(feedback = TRUE)
	if(!isbloodworm(owner) || starting)
		return FALSE
	if(!ispath(cocoon_type, /obj/structure/blood_worm_cocoon) || !ispath(new_worm_type, /mob/living/simple_animal/hostile/blood_worm))
		return FALSE
	if(!isturf(owner.loc))
		if(feedback)
			owner.balloon_alert(owner, "zejdź na podłogę!")
		return FALSE
	if(!check_consumed_blood(feedback))
		return FALSE
	if(!QDELETED(cocoon))
		return FALSE
	return ..()

/datum/action/cooldown/spell/blood_worm/cocoon/before_cast(atom/cast_on)
	return ..() | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/blood_worm/cocoon/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(start_cocoon))

/datum/action/cooldown/spell/blood_worm/cocoon/proc/start_cocoon()
	starting = TRUE
	if(tgui_alert(owner, confirm_text, name, list("Tak", "Nie"), 30 SECONDS) != "Tak")
		starting = FALSE
		return
	starting = FALSE
	if(!IsAvailable(TRUE))
		return
	starting = TRUE
	owner.visible_message("<span class='danger'>[owner] zaczyna wyrastać kokon!</span>", \
		"<span class='notice'>Zaczynasz wyrastać kokon.</span>", "<span class='italics'>Słyszysz mięsiste splatanie!</span>")
	var/success = do_after(owner, 5 SECONDS, FALSE, null, TRUE, CALLBACK(src, PROC_REF(check_consumed_blood)))
	starting = FALSE
	if(!success || !QDELETED(cocoon))
		return

	owner.visible_message("<span class='danger'>[owner] zamyka się w kokonie!</span>", \
		"<span class='green'>Zamykasz się w świeżym kokonie!</span>", "<span class='italics'>Mięsiste splatanie cichnie!</span>")

	cocoon = new cocoon_type(get_turf(owner))
	playsound(cocoon, 'sound/effects/blobattack.ogg', 60, TRUE)
	owner.forceMove(cocoon)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	ADD_TRAIT(owner, TRAIT_MUTE, REF(src))
	ADD_TRAIT(owner, TRAIT_EMOTEMUTE, REF(src))
	var/mob/living/living_owner = owner
	living_owner.update_mobility()

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_worm_moved))
	RegisterSignal(cocoon, COMSIG_PARENT_QDELETING, PROC_REF(on_cocoon_qdel))

	handle_timer()

/// Nadpisz dla innego odliczania, np. ankiety duchów u dorosłego
/datum/action/cooldown/spell/blood_worm/cocoon/proc/handle_timer()
	timer_id = addtimer(CALLBACK(src, PROC_REF(finalize)), cocoon_time, TIMER_UNIQUE | TIMER_STOPPABLE)

/// Wylęg z kokonu
/datum/action/cooldown/spell/blood_worm/cocoon/proc/finalize()
	if(QDELETED(cocoon) || QDELETED(owner))
		return
	var/mob/living/simple_animal/hostile/blood_worm/old_worm = owner
	var/obj/structure/blood_worm_cocoon/old_cocoon = cocoon
	var/turf/cocoon_turf = get_turf(old_cocoon)
	var/mob/living/simple_animal/hostile/blood_worm/new_worm = new new_worm_type(cocoon_turf)

	transfer(old_worm, new_worm)

	for(var/mob/living/unfortunate_observer in view(3, cocoon_turf))
		if(new_worm.faction_check_mob(unfortunate_observer))
			continue
		if(unfortunate_observer.stat == DEAD)
			continue
		unfortunate_observer.visible_message("<span class='danger'>[unfortunate_observer] zostaje oblany falą żrącej krwi!</span>", \
			"<span class='userdanger'>Oblewa cię fala żrącej krwi! AŁA!</span>", "<span class='italics'>Słyszysz skwierczenie!</span>")
		unfortunate_observer.Knockdown(3 SECONDS)
		unfortunate_observer.adjustFireLoss(rand(30, 50))
		var/range = 4 - get_dist(cocoon_turf, unfortunate_observer)
		if(range > 0)
			unfortunate_observer.throw_at(get_ranged_target_turf_direct(cocoon_turf, unfortunate_observer, range), range, 2)

	for(var/turf/open/splash_turf in view(3, cocoon_turf))
		if(prob(100 - get_dist(cocoon_turf, splash_turf) * 20))
			new /obj/effect/decal/cleanable/blood(splash_turf)

	playsound(cocoon_turf, 'sound/effects/splat.ogg', 100, TRUE)
	shared_unregister_cocoon()
	qdel(old_worm)

/// Przenosi gracza i postępy na nowego robaka
/datum/action/cooldown/spell/blood_worm/cocoon/proc/transfer(mob/living/simple_animal/hostile/blood_worm/old_worm, mob/living/simple_animal/hostile/blood_worm/new_worm)
	old_worm.mind?.transfer_to(new_worm)
	new_worm.id_number = old_worm.id_number
	new_worm.update_worm_name()
	// Ktoś zamieniony w robaka zachowuje swoje imię w umyśle
	if(new_worm.mind?.name == old_worm.real_name)
		new_worm.mind.name = new_worm.real_name
	new_worm.consumed_normal_blood = old_worm.consumed_normal_blood
	new_worm.consumed_synth_blood = old_worm.consumed_synth_blood
	new_worm.cocoon_action?.StartCooldown()
	new_worm.cocoon_action?.update_cooldown_text()

/// Przerywa inkubację i niszczy kokon
/datum/action/cooldown/spell/blood_worm/cocoon/proc/cancel()
	if(QDELETED(cocoon))
		cocoon = null
	else
		cocoon.visible_message("<span class='danger'>[cocoon] rozpada się, wyrzucając [owner] ze środka.</span>", \
			blind_message = "<span class='italics'>Słyszysz plaśnięcie!</span>", ignored_mobs = list(owner))
		playsound(cocoon, 'sound/effects/splat.ogg', 60, TRUE)
	if(!QDELETED(owner) && owner.stat != DEAD)
		to_chat(owner, "<span class='userdanger'>Twój kokon się rozpada!</span>")
	StartCooldown(10 SECONDS)
	shared_unregister_cocoon()

/datum/action/cooldown/spell/blood_worm/cocoon/proc/shared_unregister_cocoon()
	if(owner)
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		REMOVE_TRAITS_IN(owner, REF(src))
		var/mob/living/living_owner = owner
		living_owner.update_mobility()
	if(cocoon)
		UnregisterSignal(cocoon, COMSIG_PARENT_QDELETING)
	if(!QDELETED(owner) && cocoon && owner.loc == cocoon)
		owner.forceMove(cocoon.drop_location())
	if(!QDELETED(cocoon))
		qdel(cocoon)
	cocoon = null
	if(timer_id)
		deltimer(timer_id)
		timer_id = null

/datum/action/cooldown/spell/blood_worm/cocoon/proc/on_worm_stat_changed(datum/source, new_stat)
	SIGNAL_HANDLER
	if(cocoon && new_stat == DEAD)
		cancel()

/datum/action/cooldown/spell/blood_worm/cocoon/proc/on_worm_moved(datum/source)
	SIGNAL_HANDLER
	if(cocoon && owner.loc != cocoon)
		cancel()

/datum/action/cooldown/spell/blood_worm/cocoon/proc/on_cocoon_qdel(datum/source)
	SIGNAL_HANDLER
	cancel()

/// Czy robak wypił dość krwi, żeby dojrzeć
/datum/action/cooldown/spell/blood_worm/cocoon/proc/check_consumed_blood(feedback = FALSE)
	var/mob/living/simple_animal/hostile/blood_worm/worm = target
	var/total_consumed_blood = worm.get_consumed_blood()
	if(total_consumed_blood < total_blood_required)
		if(feedback)
			worm.balloon_alert(worm, "dopiero [FLOOR(total_consumed_blood / total_blood_required * 100, 1)]% wzrostu!")
		return FALSE
	return TRUE

/obj/structure/blood_worm_cocoon
	icon = 'aquila/icons/mob/blood_worm_32x32.dmi'
	density = TRUE
	anchored = TRUE

/obj/structure/blood_worm_cocoon/Destroy()
	// Robak w środku nie może zniknąć razem z kokonem
	for(var/mob/living/inside in contents)
		inside.forceMove(drop_location())
	return ..()

// Larwa -> młody

/datum/action/cooldown/spell/blood_worm/cocoon/hatchling
	name = "Dojrzewanie"
	desc = "Zamknij się w kokonie i wyjdź z niego jako młody krwawy robak."
	button_icon_state = "mature_hatchling"
	cocoon_type = /obj/structure/blood_worm_cocoon/hatchling
	new_worm_type = /mob/living/simple_animal/hostile/blood_worm/juvenile
	total_blood_required = 500
	confirm_text = "Na pewno? Po 30 sekundach staniesz się młodym robakiem: dostaniesz więcej siły i zdolność plucia żrącą krwią, ale stracisz możliwość chodzenia rurami wentylacji."

/datum/action/cooldown/spell/blood_worm/cocoon/hatchling/transfer(mob/living/simple_animal/hostile/blood_worm/old_worm, mob/living/simple_animal/hostile/blood_worm/new_worm)
	. = ..()
	log_game("[key_name(new_worm)] finished maturing into a juvenile blood worm")

/obj/structure/blood_worm_cocoon/hatchling
	name = "mały krwawy kokon"
	desc = "Kokon, w którym dojrzewa larwa krwawego robaka. Jego powierzchnia powoli faluje."
	icon_state = "cocoon-small"
	max_integrity = 100

/obj/structure/blood_worm_cocoon/hatchling/examine(mob/user)
	. = ..()
	. += "<span class='warning'>Można go rozbić, żeby robak nie dojrzał.</span>"

// Młody -> dorosły

/datum/action/cooldown/spell/blood_worm/cocoon/juvenile
	name = "Dojrzewanie"
	desc = "Zamknij się w kokonie i wyjdź z niego jako dorosły krwawy robak."
	button_icon_state = "mature_juvenile"
	cocoon_type = /obj/structure/blood_worm_cocoon/juvenile
	new_worm_type = /mob/living/simple_animal/hostile/blood_worm/adult
	total_blood_required = 1500
	confirm_text = "Na pewno? Po 30 sekundach staniesz się dorosłym robakiem: dostaniesz dużo więcej siły, a poza nosicielem prawym klikiem z Plucia krwią plujesz serią. Dorosły nie wciśnie się już pod drzwi."

/datum/action/cooldown/spell/blood_worm/cocoon/juvenile/transfer(mob/living/simple_animal/hostile/blood_worm/old_worm, mob/living/simple_animal/hostile/blood_worm/new_worm)
	. = ..()
	log_game("[key_name(new_worm)] finished maturing into an adult blood worm")

/obj/structure/blood_worm_cocoon/juvenile
	name = "średni krwawy kokon"
	desc = "Kokon, w którym dojrzewa młody krwawy robak. Jego powierzchnia powoli faluje."
	icon_state = "cocoon-medium"
	max_integrity = 150

/obj/structure/blood_worm_cocoon/juvenile/examine(mob/user)
	. = ..()
	. += "<span class='warning'>Można go rozbić, żeby robak nie dojrzał, ale wygląda na dość wytrzymały.</span>"

// Dorosły: rozmnażanie

/datum/action/cooldown/spell/blood_worm/cocoon/adult
	name = "Rozmnażanie"
	desc = "Zamknij się w kokonie i wypuść z niego 4 nowe larwy, w tym siebie."
	button_icon_state = "reproduce"
	cocoon_type = /obj/structure/blood_worm_cocoon/adult
	new_worm_type = /mob/living/simple_animal/hostile/blood_worm/hatchling
	total_blood_required = 0
	confirm_text = "Na pewno? Po 30 sekundach wyklują się 4 nowe larwy, w tym ty."
	/// Ile larw oprócz nas
	var/num_hatchlings = 3
	var/list/candidates = null

/datum/action/cooldown/spell/blood_worm/cocoon/adult/handle_timer()
	cocoon.balloon_alert(owner, "pytamy duchy")
	var/list/polled = pollGhostCandidates("Chcesz zagrać jako świeżo wyklęty krwawy robak? (x[num_hatchlings])", ROLE_BLOOD_WORM, /datum/role_preference/midround_ghost/blood_worm, cocoon_time, POLL_IGNORE_BLOOD_WORM, alert_pic = cocoon)
	candidates = list()
	// Bierzemy tylu, ilu trzeba (tgstation#95356: działa też z jednym chętnym)
	while(length(polled) && length(candidates) < num_hatchlings)
		candidates += pick_n_take(polled)

	var/num_candidates = length(candidates)
	if(QDELETED(cocoon))
		send_apology_to_candidates()
		return
	if(num_candidates <= 0)
		owner.balloon_alert(owner, "brak chętnych!")
		cancel()
		return
	if(num_candidates < num_hatchlings && tgui_alert(owner, "Chętnych na larwy jest tylko [num_candidates]/[num_hatchlings]. Rozmnażać się mimo to?", "Za mało duchów", list("Tak", "Nie"), 10 SECONDS) != "Tak")
		cancel()
		return
	if(QDELETED(cocoon))
		send_apology_to_candidates()
		return
	finalize()

/datum/action/cooldown/spell/blood_worm/cocoon/adult/finalize()
	if(QDELETED(cocoon))
		return
	for(var/mob/candidate as anything in candidates)
		if(QDELETED(candidate) || !candidate.key || !candidate.client)
			continue
		var/mob/living/simple_animal/hostile/blood_worm/hatchling/new_hatchling = new(cocoon.drop_location())
		var/datum/mind/fresh_mind = new /datum/mind(candidate.key)
		fresh_mind.active = TRUE
		fresh_mind.transfer_to(new_hatchling, force_key_move = TRUE)
		fresh_mind.add_antag_datum(/datum/antagonist/blood_worm/infestation)
		log_game("[key_name(new_hatchling)] hatched as a blood worm from a reproduction cocoon")
	return ..()

/datum/action/cooldown/spell/blood_worm/cocoon/adult/transfer(mob/living/simple_animal/hostile/blood_worm/old_worm, mob/living/simple_animal/hostile/blood_worm/new_worm)
	. = ..()
	new_worm.reset_consumed_blood()
	new_worm.cocoon_action?.update_cooldown_text()
	SEND_SIGNAL(new_worm, COMSIG_BLOOD_WORM_REPRODUCED)
	log_game("[key_name(new_worm)] finished reproducing, turning back into a hatchling blood worm")

/datum/action/cooldown/spell/blood_worm/cocoon/adult/cancel()
	send_apology_to_candidates()
	return ..()

/datum/action/cooldown/spell/blood_worm/cocoon/adult/shared_unregister_cocoon()
	candidates = null
	return ..()

/datum/action/cooldown/spell/blood_worm/cocoon/adult/proc/send_apology_to_candidates()
	for(var/mob/candidate as anything in candidates)
		if(QDELETED(candidate) || !candidate.client)
			continue
		to_chat(candidate, "<span class='warning'>Kokon krwawego robaka, w którym miałeś się wykluć, został zniszczony. Przykro nam.</span>")

/obj/structure/blood_worm_cocoon/adult
	name = "duży krwawy kokon"
	desc = "Kokon dorosłego krwawego robaka. W środku widać wiele niewyraźnych cieni."
	icon_state = "cocoon-large"
	max_integrity = 200

/obj/structure/blood_worm_cocoon/adult/examine(mob/user)
	. = ..()
	. += "<span class='warning'>Można go rozbić, żeby robak się nie rozmnożył, ale wygląda na bardzo wytrzymały.</span>"

// Robaki z przemiany dojrzewają w robaki z przemiany

/datum/action/cooldown/spell/blood_worm/cocoon/hatchling/polymorph
	new_worm_type = /mob/living/simple_animal/hostile/blood_worm/juvenile/polymorph

/datum/action/cooldown/spell/blood_worm/cocoon/juvenile/polymorph
	new_worm_type = /mob/living/simple_animal/hostile/blood_worm/adult/polymorph
