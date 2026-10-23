// AQUILA - kuźnia amunicji: rytmiczna minigra kowadła (na wzór /datum/anvil_challenge z Monkestation).
// U Monke nuty idą po HUD-zie i łapie się kliki przez COMSIG_CLIENT_CLICK_DIRTY, którego nie mamy,
// więc nuty są w oknie TGUI, a gracz wciska klawisze. Serwer losuje rozkład nut, klient mierzy odchyłki,
// serwer sprawdza je z własnym zegarem. Pudła obniżają klasę zapisaną na formie.

/// Okno trafienia (ms) bez pingu, jak ±0,2 s w Monke
#define ANVIL_HIT_WINDOW 200
/// Ile trwa wstęp przed pierwszą nutą (ms)
#define ANVIL_LEAD_IN 2500
/// Ile serwer czeka po ostatniej nucie, zanim sam zakończy kucie (ms)
#define ANVIL_GRACE 2000
/// Poniżej tej celności klasa spada
#define ANVIL_PERFECT_ACCURACY 0.9
/// O ile celności mniej na każdą klasę w dół
#define ANVIL_ACCURACY_PER_CLASS 0.15

/datum/munitions_anvil_game
	var/obj/machinery/munitions_forge/anvil/anvil
	var/mob/user
	var/obj/item/munition_part/part
	/// Nuty: lista list("time" = ms od startu, "key" = "space"/"q"/"e")
	var/list/notes = list()
	/// Indeks nuty -> TRUE (trafiona) albo FALSE (pudło)
	var/list/results = list()
	var/difficulty = 1
	/// REALTIMEOFDAY w chwili startu (ds)
	var/start_time
	/// Okno trafienia z pingiem gracza (ms)
	var/hit_window = ANVIL_HIT_WINDOW
	var/finish_timer

/datum/munitions_anvil_game/New(obj/machinery/munitions_forge/anvil/anvil, mob/user, obj/item/munition_part/part)
	src.anvil = anvil
	src.user = user
	src.part = part
	difficulty = calculate_difficulty()
	if(user.client)
		hit_window = ANVIL_HIT_WINDOW + clamp(round(user.client.avgping), 0, 300)
	generate_notes(part.forging_notes())
	start_time = REALTIMEOFDAY
	var/list/last = notes[length(notes)]
	finish_timer = addtimer(CALLBACK(src, PROC_REF(finish)), round((last["time"] + ANVIL_GRACE) / 100), TIMER_STOPPABLE)
	RegisterSignal(part, COMSIG_PARENT_QDELETING, PROC_REF(abort))
	RegisterSignal(part, COMSIG_MOVABLE_MOVED, PROC_REF(abort))

/datum/munitions_anvil_game/Destroy(force, ...)
	deltimer(finish_timer)
	if(part)
		UnregisterSignal(part, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
	var/obj/machinery/munitions_forge/anvil/old_anvil = anvil
	anvil = null
	part = null
	user = null
	old_anvil?.game_over(src)
	return ..()

/// Klasa z formy i twardość materiału, jak (hardness+density)/30 w Monke
/datum/munitions_anvil_game/proc/calculate_difficulty()
	. = 1 + part.quality.level
	var/obj/item/munition_part/body/body = part
	if(istype(body) && body.material)
		if(body.material.hardness >= 8)
			. += 2
		else if(body.material.hardness >= 5)
			. += 1

/// Ile rodzajów uderzeń: od trudności 3 dochodzi lekkie (Q), od 5 mocne (E)
/datum/munitions_anvil_game/proc/key_types()
	if(difficulty >= 5)
		return list("space", "q", "e")
	if(difficulty >= 3)
		return list("space", "q")
	return list("space")

/// Serie po 1-5 nut co 0,5-1 s, szybciej przy wysokiej trudności (jak generate_anvil_beats)
/datum/munitions_anvil_game/proc/generate_notes(count)
	var/list/keys = key_types()
	var/time = ANVIL_LEAD_IN
	var/speed = 1
	if(difficulty >= 7)
		speed = 0.65
	else if(difficulty >= 5)
		speed = 0.8
	while(length(notes) < count)
		var/burst = min(rand(1, 5), count - length(notes))
		for(var/i in 1 to burst)
			time += round(rand(500, 1000) * speed)
			notes += list(list("time" = time, "key" = pick(keys)))
		// przerwa między seriami
		time += 600

/datum/munitions_anvil_game/proc/elapsed_ms()
	return (REALTIMEOFDAY - start_time) * 100

/// Gracz wcisnął klawisz przy nucie index, klient zmierzył odchyłkę delta (ms)
/datum/munitions_anvil_game/proc/register_hit(index, key, delta)
	if(!isnum(index) || index < 1 || index > length(notes) || !isnull(results["[index]"]))
		return
	var/list/note = notes[index]
	// klient mierzy czas sam; serwer pilnuje tylko, żeby nuta była mniej więcej teraz
	var/server_delta = elapsed_ms() - note["time"]
	var/good = (key == note["key"]) && isnum(delta) && abs(delta) <= hit_window && server_delta > -1500 && server_delta < hit_window + 1500
	results["[index]"] = good
	if(good)
		playsound(anvil, 'sound/effects/clang.ogg', 25, TRUE)
		if(prob(30))
			do_sparks(1, TRUE, anvil)
	else
		playsound(anvil, 'sound/weapons/genhit.ogg', 25, TRUE)

/datum/munitions_anvil_game/proc/register_miss(index)
	if(!isnum(index) || index < 1 || index > length(notes) || !isnull(results["[index]"]))
		return
	results["[index]"] = FALSE
	playsound(anvil, 'sound/weapons/genhit.ogg', 25, TRUE)

/datum/munitions_anvil_game/proc/hits()
	. = 0
	for(var/key in results)
		if(results[key])
			.++

/datum/munitions_anvil_game/proc/misses()
	. = 0
	for(var/key in results)
		if(!results[key])
			.++

/// Ile klas w dół przy danej celności
/proc/anvil_quality_drop(accuracy)
	if(accuracy >= ANVIL_PERFECT_ACCURACY)
		return 0
	return CEILING((ANVIL_PERFECT_ACCURACY - accuracy) / ANVIL_ACCURACY_PER_CLASS, 1)

/datum/munitions_anvil_game/proc/finish()
	if(QDELETED(part) || QDELETED(anvil))
		qdel(src)
		return
	var/accuracy = length(notes) ? hits() / length(notes) : 1
	var/datum/munition_quality/final_quality = lower_munition_quality(part.quality, anvil_quality_drop(accuracy))
	var/had_quality = part.quality
	part.forging_finished(final_quality, accuracy)
	anvil.ping()
	if(user)
		var/msg = "Kończysz kuć [part]: [round(accuracy * 100)]% celnych uderzeń."
		if(final_quality != had_quality)
			to_chat(user, "<span class='warning'>[msg] Przez pudła wychodzi tylko klasa [final_quality.roman].</span>")
		else
			to_chat(user, "<span class='notice'>[msg] Trzyma klasę [final_quality.roman].</span>")
	qdel(src)

/// Gracz zamknął okno, odszedł albo część zniknęła z kowadła
/datum/munitions_anvil_game/proc/abort()
	SIGNAL_HANDLER
	if(user && part && !QDELETED(part))
		to_chat(user, "<span class='warning'>Przerywasz kucie. [part] trzeba będzie kuć od nowa.</span>")
	qdel(src)

/datum/munitions_anvil_game/proc/ui_payload()
	. = list(
		"notes" = notes,
		"window" = hit_window,
		"difficulty" = difficulty,
		"part" = part?.name,
		"target_class" = part?.quality.roman,
		"start_ref" = REF(src),
	)

// ---------------------------------------------------------------- okno na kowadle

/obj/machinery/munitions_forge/anvil/ui_interact(mob/user, datum/tgui/ui)
	if(!game || user != game.user)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MunitionsAnvil", name)
		ui.open()

/obj/machinery/munitions_forge/anvil/ui_static_data(mob/user)
	return game ? game.ui_payload() : list()

/obj/machinery/munitions_forge/anvil/ui_data(mob/user)
	. = list()
	if(game)
		.["hits"] = game.hits()
		.["misses"] = game.misses()

/obj/machinery/munitions_forge/anvil/ui_act(action, list/params)
	. = ..()
	if(. || !game || usr != game.user)
		return
	if(!held_hammer(usr))
		to_chat(usr, "<span class='warning'>Odkładasz młot i przestajesz kuć.</span>")
		game.abort()
		return TRUE
	switch(action)
		if("hit")
			game.register_hit(text2num(params["index"]), params["key"], text2num(params["delta"]))
			return TRUE
		if("miss")
			game.register_miss(text2num(params["index"]))
			return TRUE

/obj/machinery/munitions_forge/anvil/ui_close(mob/user)
	. = ..()
	if(game && user == game.user)
		game.abort()

#undef ANVIL_HIT_WINDOW
#undef ANVIL_LEAD_IN
#undef ANVIL_GRACE
#undef ANVIL_PERFECT_ACCURACY
#undef ANVIL_ACCURACY_PER_CLASS
