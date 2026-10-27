/datum/team/cult
	name = "Kult Nar'Sie"

	///The blood mark target (zostaje dla starego kodu: alert bloodsense, Nar'Sie, konstrukty)
	var/atom/blood_target
	///Image of the blood mark target
	var/image/blood_target_image
	///Timer for the blood mark expiration
	var/blood_target_reset_timer

	///Has narsie been summoned yet? (czyta to tryb gry przy napisach końcowych)
	var/narsie_summoned = FALSE

	//////NEW STUFF HERE
	var/stage = BLOODCULT_STAGE_NORMAL
	var/list/bloody_floors = list()
	var/cult_win = FALSE

	var/list/cult_reminders = list()

	var/list/bindings = list()

	var/cultist_cap = 1	//clamped between 5 and 9 depending on crew size. once the cap goes up it cannot go down.
	var/min_cultist_cap = 5
	var/max_cultist_cap = 9

	var/mentor_count = 0 	//so we don't loop through the member list if we already know there are no mentors in there

	var/cult_founding_time = 0
	var/last_process_time = 0
	var/delta = 1

	var/eclipse_progress = 0
	var/eclipse_target = 1800
	var/eclipse_window = 20 MINUTES //I Don't really know how much longer I can make this, for gods sake read your chat window that tells you, that you NEED to do the ritual
	var/eclipse_increments = 0
	var/eclipse_contributors = list()//associative list: /mind = score

	var/soon_announcement = FALSE
	var/overtime_announcement = FALSE

	var/bloodstone_rising_time = 0
	var/bloodstone_duration = 430 SECONDS
	var/bloodstone_target_time = 0

	var/datum/rune_spell/tearreality/tear_ritual = null
	var/obj/structure/cult/bloodstone/bloodstone = null		//we track the one spawned by the Tear Reality rune
	var/obj/eldritch/narsie/narsie = null

	//we track the mind of anyone that has been converted or made prisoner at least once.
	var/previously_made_prisoner = list()
	var/previously_converted = list()

	var/total_devotion = 0

	var/twister = FALSE

	var/list/deconverted = list()//tracking for scoreboard purposes (name = devotion)

	var/datum/bloodcult_ritual/bloodspill_ritual = null

	var/list/possible_rituals = list()
	var/list/rituals = list(RITUAL_FACTION_1, RITUAL_FACTION_2, RITUAL_FACTION_3)

	var/countdown_to_first_rituals = 5

	COOLDOWN_DECLARE(last_reminder)

/datum/team/cult/proc/setup_objectives()
	START_PROCESSING(SSobj, src)
	for (var/ritual_type in GLOB.bloodcult_faction_rituals)
		possible_rituals += new ritual_type()
	cult_founding_time = world.time
	initialize_rune_words()
	for (var/datum/mind/mind in members)
		to_chat(mind.current, span_cult("Nasza wspólnota musi pozostać mała i tajemna, dopóki nie nabierzemy pewności siebie."))
		previously_converted |= mind

/datum/team/cult/Destroy(force, ...)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/team/cult/proc/check_destroy()
	if(!length(members))
		qdel(src)

/// Umysły członków, którzy dalej mają antag kultu (umysł dekonwertowanego albo usuniętego kultysty może jeszcze chwilę wisieć w members).
/datum/team/cult/proc/get_cultist_datums()
	. = list()
	for (var/datum/mind/mind in members)
		var/datum/antagonist/cult/cultist = mind.has_antag_datum(/datum/antagonist/cult)
		if (cultist)
			. += cultist

/// Odświeża otwarte panele kultu wszystkich członków.
/datum/team/cult/proc/refresh_cult_panels(include_cultist_panel = FALSE)
	for (var/datum/mind/M in members)
		if ("Cult Panel" in M.active_uis)
			var/datum/mind_ui/m_ui = M.active_uis["Cult Panel"]
			if (m_ui.active)
				m_ui.Display()
		if (include_cultist_panel && ("Cultist Panel" in M.active_uis))
			var/datum/mind_ui/m_ui = M.active_uis["Cultist Panel"]
			if (m_ui.active)
				m_ui.Display()

/// Wiadomość do wszystkich członków kultu, którzy mają ciało.
/datum/team/cult/proc/message_members(message)
	for (var/datum/mind/mind in members)
		if (mind.current)
			to_chat(mind.current, message)

/datum/team/cult/proc/replace_rituals(slot)
	if (!slot || QDELETED(src))
		return
	if (rituals[slot])
		return

	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions())
			valid_rituals += R

	if (valid_rituals.len < 1)
		return

	var/datum/bloodcult_ritual/BR = pick(valid_rituals)
	rituals[slot] = BR
	possible_rituals -= BR
	BR.init_ritual()

	message_members(span_cult("Dostępny jest nowy rytuał..."))
	refresh_cult_panels()

/datum/team/cult/proc/UpdateCap()
	if (stage == BLOODCULT_STAGE_DEFEATED)
		cultist_cap = 0
		return
	if (stage == BLOODCULT_STAGE_NARSIE)
		cultist_cap = 666
		return
	var/living_players = 0
	var/new_cap = 0
	for (var/mob/M in GLOB.player_list)
		if (!M.client)
			continue
		if (isnewplayer(M))
			continue
		if (M.stat != DEAD)
			living_players++
	new_cap = clamp(round(living_players / 3), min_cultist_cap, max_cultist_cap)
	if (new_cap > cultist_cap)
		cultist_cap = new_cap
		message_members(span_cult("Załoga statku jest teraz na tyle liczna, że kult może liczyć <span class = 'userdanger'>[cultist_cap]</span> kultystów, plus po jednym konstrukcie każdego rodzaju."))

/datum/team/cult/proc/CanConvert(construct_type)
	var/list/free_construct_slots = list()
	var/cultist_count = 0
	for (var/datum/mind/mind in members)
		var/mob/M = mind.current
		//The first construct of each type doesn't take up a slot.
		if (istype(M, /mob/living/simple_animal/hostile/construct))
			var/mob/living/simple_animal/hostile/construct/C = M
			if (!(C.construct_type in free_construct_slots))
				free_construct_slots += C.construct_type
				continue
		//Living Humans, Shades and extra Constructs all count.
		if (isliving(M))
			if (M.stat != DEAD)
				cultist_count += 1

	if(construct_type && (!(construct_type in free_construct_slots)))
		return TRUE

	return (cultist_count < cultist_cap)

/// Sprawdza, czy klucz kończy któryś z rytuałów drużynowych. achiever - kultysta, który go spełnił (może być null).
/datum/team/cult/proc/check_ritual(key, extra, datum/antagonist/cult/achiever)
	switch(stage)
		if (BLOODCULT_STAGE_DEFEATED)//no more devotion gains if the bloodstone has been destroyed
			return
		if (BLOODCULT_STAGE_NARSIE)//or narsie has risen
			return
		if (BLOODCULT_STAGE_ECLIPSE)
			return

	if (!key)
		return
	for (var/ritual_slot in rituals)
		if (!rituals[ritual_slot])
			continue
		var/datum/bloodcult_ritual/faction_ritual = rituals[ritual_slot]
		if (!(key in faction_ritual.keys))
			continue
		if (!faction_ritual.key_found(extra))
			continue
		faction_ritual.complete()
		if (!faction_ritual.only_once)
			possible_rituals += faction_ritual
		rituals[ritual_slot] = null
		for (var/datum/mind/mind in members)
			var/mob/M = mind.current
			if (!M)
				continue
			if (achiever && mind == achiever.owner)
				to_chat(M, span_cult("Ukończyłeś rytuał i nagrodziłeś cały kult... wkrótce jego miejsce zajmie kolejny."))
			else
				to_chat(M, span_cult("Ktoś ukończył rytuał, nagradzając cały kult... wkrótce jego miejsce zajmie kolejny."))
		addtimer(CALLBACK(src, PROC_REF(replace_rituals), ritual_slot), 10 MINUTES)

/datum/team/cult/proc/stage(value)
	stage = value
	switch(stage)
		if (BLOODCULT_STAGE_READY)
			eclipse_trigger_cult()
			for(var/obj/structure/cult/spire/S in GLOB.cult_spires)
				S.upgrade(3)
			message_members(span_cultlarge("Nadszedł czas, by przywołać Nar'Sie. Zajrzyj do menu kultysty, by poznać rytuał, którego ona od was oczekuje. Na rozpoczęcie przywołania macie czas do końca Zaćmienia."))
			COOLDOWN_START(src, last_reminder, 1 MINUTES)
		if (BLOODCULT_STAGE_MISSED)
			message_members(span_cult("Zaćmienie minęło. Na tym statku nie rozedrzecie już rzeczywistości. Uciekajcie stąd żywi razem z resztą kultu, by spróbować innym razem."))
			for(var/obj/structure/cult/spire/S in GLOB.cult_spires)
				S.upgrade(1)
		if (BLOODCULT_STAGE_ECLIPSE)
			var/list/station_zs = SSmapping.levels_by_trait(ZTRAIT_STATION)
			for(var/datum/space_level/level as anything in SSmapping.z_list)
				if(!(level.z_value in station_zs))
					continue
				level.set_linkage(SELFLOOPING)

			INVOKE_ASYNC(src, PROC_REF(narnar_ghosts))
			bloodstone_rising_time = world.time
			bloodstone_target_time = world.time + bloodstone_duration
			addtimer(CALLBACK(src, PROC_REF(announce_bloodstone)), 3 SECONDS)//leaving just a moment for the blood stone to rise.
		if (BLOODCULT_STAGE_DEFEATED)
			priority_announce("Potwierdzono zniszczenie Krwawego Kamienia. Moc kultu na pokładzie została znacznie osłabiona.", "Operacje kultu udaremnione")
			if (GLOB.eclipse.eclipse_start_time && !GLOB.eclipse.eclipse_finished)//destruction of the blood stone instantly ends the Eclipse
				GLOB.eclipse.eclipse_end()
			for (var/obj/effect/new_rune/R in GLOB.runes)
				qdel(R)//new runes can be written, but any pre-existing one gets nuked.
			cultist_cap = 0
			INVOKE_ASYNC(src, PROC_REF(kill_mindless_cult_mobs))
			INVOKE_ASYNC(src, PROC_REF(decultify_ghosts))
			for(var/obj/structure/cult/spire/S in GLOB.cult_spires)
				S.upgrade(1)
			addtimer(CALLBACK(src, PROC_REF(defeat_messages)), 5 SECONDS)
		if (BLOODCULT_STAGE_NARSIE)
			if (bloodstone)
				narsie_summoned = TRUE
				cult_win = TRUE
				for (var/mob/M in GLOB.player_list)
					M.playsound_local(get_turf(M), 'aquila/sound/bloodcult/vg/effects/wind/wind_5_1.ogg', 100, 0)
				addtimer(CALLBACK(src, PROC_REF(spawn_narsie), bloodstone.loc), 5)
	refresh_cult_panels(include_cultist_panel = TRUE)

/datum/team/cult/proc/announce_bloodstone()
	priority_announce("Wzorce fluktuacji bluespace odpowiadają tym, które obserwowano podczas dawnych najazdów kultu Nar'Sie, co oznacza, że powstał Krwawy Kamień. Znajdźcie go i zniszczcie za wszelką cenę, inaczej ten statek przepadnie. Uważajcie na nieziemskie istoty, które mogą się pojawiać na pokładzie.", "Wykryto aktywność kultu")
	if (GLOB.security_level < SEC_LEVEL_RED)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(set_security_level), "red"), 2 SECONDS)

/datum/team/cult/proc/spawn_narsie(turf/location)
	if (!location || narsie)
		return
	narsie = new /obj/eldritch/narsie(location)
	//vg: każdy gracz z umysłem dostaje napis „Nar-Sie Has Risen” (mind_ui)
	for (var/mob/M in GLOB.player_list)
		if (M.mind)
			M.DisplayUI("Nar-Sie Has Risen")

/datum/team/cult/proc/kill_mindless_cult_mobs()
	set waitfor = FALSE
	for(var/mob/living/simple_animal/M in GLOB.mob_list)
		if(!M.client && (FACTION_CULT in M.faction) && M.stat != DEAD)
			M.death()
		CHECK_TICK

/datum/team/cult/proc/decultify_ghosts()
	set waitfor = FALSE
	for (var/mob/dead/observer/O in GLOB.player_list)
		O.bloodcult_decultify()
		sleep(rand(1, 5))

/datum/team/cult/proc/defeat_messages()
	set waitfor = FALSE
	message_members(span_cult("Wraz ze zniszczeniem Krwawego Kamienia rozdarcie zasłony zostało zaszyte, a ze statku wyparowała ogromna część okultystycznej energii."))
	sleep(3 SECONDS)
	message_members(span_cult("Twoja więź z Geometrą Krwi osłabła i nie pamiętasz już run tak łatwo jak wcześniej. Może pomoże ci w tym Tajemna Księga."))
	sleep(3 SECONDS)
	message_members(span_cult("Wreszcie wygląda na to, że ślady rytuału na twoim ciele nie zniknęły. Dużo trudniej będzie teraz przejść niezauważonym."))

/datum/team/cult/proc/narnar_ghosts()
	set waitfor = FALSE
	for (var/mob/dead/observer/O in GLOB.player_list)
		INVOKE_ASYNC(O, TYPE_PROC_REF(/atom, narsie_act))
		sleep(rand(1, 5))

/datum/team/cult/proc/HandleRecruitedRole(datum/antagonist/R)
	if (cult_reminders.len)
		to_chat(R.owner.current, span_notice("Inni kultyści podzielili się częścią swojej wiedzy. Znajdziesz ją w swojej pamięci (Notatki w zakładce IC)."))
		for (var/reminder in cult_reminders)
			R.owner.store_memory("Wspólna wiedza kultu: [reminder].")
	previously_converted |= R.owner
	if (R.owner.name in deconverted)
		deconverted -= R.owner.name

/datum/team/cult/proc/assign_rituals()
	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions())
			valid_rituals += R

	if (valid_rituals.len < 3)
		return

	for (var/ritual_slot in rituals)
		var/datum/bloodcult_ritual/BR = pick(valid_rituals)
		rituals[ritual_slot] = BR
		possible_rituals -= BR
		valid_rituals -= BR
		BR.init_ritual()

	refresh_cult_panels()

/datum/team/cult/process()
	if (cultist_cap >= 1) //The first call occurs in OnPostSetup()
		UpdateCap()

	switch(stage)
		if (BLOODCULT_STAGE_NORMAL)
			if (bloodspill_ritual)
				check_ritual("bloodspill", bloody_floors.len)
			//if there is at least one cultist alive, the eclipse comes forward
			calculate_eclipse_rate()
			for (var/datum/mind/mind in members)
				var/mob/M = mind.current
				if (isliving(M) && M.stat != DEAD)
					//we calculate the progress relative to the time since the last process so the overall time is independant from server lag and shit
					delta = 1
					if (last_process_time && (last_process_time < world.time))//carefully dealing with midnight rollover
						delta = (world.time - last_process_time)
						if(SSticker.initialized)
							delta /= SSticker.wait

					eclipse_progress += max(0.1, eclipse_increments) * delta
					if (eclipse_progress >= eclipse_target)
						stage(BLOODCULT_STAGE_READY)
					break
			last_process_time = world.time
			if (countdown_to_first_rituals)
				countdown_to_first_rituals--
				if (countdown_to_first_rituals <= 0)
					assign_rituals()
					for (var/datum/antagonist/cult/cult_datum as anything in get_cultist_datums())
						cult_datum.assign_rituals()
						var/mob/M = cult_datum.owner.current
						if (M)
							to_chat(M, span_cult("Choć oddanie zdobywasz większością działań kultu, masz teraz do odprawienia także kilka rytuałów. Zajrzyj do panelu kultu."))

		if (BLOODCULT_STAGE_MISSED)
			if (bloodspill_ritual)
				check_ritual("bloodspill", bloody_floors.len)
		if (BLOODCULT_STAGE_READY)
			if(COOLDOWN_FINISHED(src, last_reminder))
				message_members(span_cultlarge("Zaćmienie wciąż trwa, a wy nie rozpoczęliście jeszcze rytuału. Wasz czas się kończy."))
				COOLDOWN_START(src, last_reminder, 1 MINUTES)
			if (GLOB.eclipse.eclipse_finished)
				stage(BLOODCULT_STAGE_MISSED)
		if (BLOODCULT_STAGE_ECLIPSE)
			bloodstone?.update_icon()
			if (world.time >= bloodstone_target_time)
				stage(BLOODCULT_STAGE_NARSIE)

/datum/team/cult/proc/calculate_eclipse_rate()
	eclipse_increments = 0
	for (var/datum/antagonist/cult/R as anything in get_cultist_datums())
		var/mob/M = R.owner.current
		if (isliving(M) && M.stat != DEAD)
			if (M.occult_muted())
				eclipse_increments -= R.get_eclipse_increment()
			else
				eclipse_increments += R.get_eclipse_increment()


/datum/team/cult/proc/add_bloody_floor(turf/T)
	if (!istype(T))
		return
	if(is_station_level(T.z))
		bloody_floors[T] = T


/datum/team/cult/proc/remove_bloody_floor(turf/T)
	if (!istype(T))
		return
	bloody_floors -= T

/// Czy kult wygrał (dla trybu gry). TRUE przy Nar'Sie, Krwawym Kamieniu w chwili końca rundy albo ucieczce wolnych kultystów.
/datum/team/cult/proc/check_cult_victory()
	var/list/result = get_round_result()
	return result["won"]

/// Liczy wynik rundy kultu jak GetScoreboard z vg. Zwraca list("won" = TRUE/FALSE, "message" = tekst).
/datum/team/cult/proc/get_round_result()
	var/cult_won = FALSE
	var/end_message = "Kultowi nie udało się rozkwitnąć."

	if (stage == BLOODCULT_STAGE_NARSIE)
		cult_won = TRUE
		end_message = "Kult rozkwitł! Nar'Sie zgasiła kolejną pochodnię w pustce!"
	else if (stage == BLOODCULT_STAGE_DEFEATED)
		end_message = "Załoga złamała kult, niszcząc Krwawy Kamień!"
	else if (stage == BLOODCULT_STAGE_ECLIPSE)
		cult_won = TRUE
		end_message = "Kult odziedziczy ten statek!"
	else if (twister)
		end_message = "Kult niestety nie radzi sobie w twistera!"
	else if (SSshuttle.emergency?.mode == SHUTTLE_ENDGAME || GLOB.crew_transfer_risa)
		var/escaped_on_shuttle = 0
		var/escaped_on_pods = 0
		var/arrested_cultists = 0

		for (var/datum/antagonist/cult/C as anything in get_cultist_datums())
			var/mob/living/M = C.owner.current
			if (!istype(M) || M.stat == DEAD)
				continue
			if (issilicon(M))
				arrested_cultists++
				continue
			if (isbrain(M))
				continue
			var/turf/location = get_turf(M)
			if (!location)
				continue
			var/area/location_area = get_area(M)
			var/on_shuttle = GLOB.crew_transfer_risa || (SSshuttle.emergency && (location_area in SSshuttle.emergency.shuttle_areas))
			if (!on_shuttle)
				if (location.onCentCom())
					escaped_on_pods++
				continue
			// skuci albo w celi promu = aresztowani
			if (istype(location_area, /area/security/prison) || istype(location, /turf/open/floor/plasteel/shuttle/red) || istype(location, /turf/open/floor/mineral/plastitanium/red/brig))
				if (iscarbon(M))
					var/mob/living/carbon/carbon_cultist = M
					if (carbon_cultist.handcuffed)
						arrested_cultists++
						continue
			if (iscarbon(M))
				var/mob/living/carbon/carbon_cultist = M
				if (carbon_cultist.handcuffed)
					arrested_cultists++
					continue
			escaped_on_shuttle++

		if (escaped_on_shuttle)
			cult_won = TRUE
			end_message = "[escaped_on_shuttle] [escaped_on_shuttle > 1 ? "kultystów uciekło" : "kultysta uciekł"] razem z załogą, by szerzyć wpływy kultu dalej!"
		else if (escaped_on_pods)
			end_message = "Niektórzy kultyści tchórzliwie uciekli kapsułami, by ukrywać się przez kolejne stulecie!"
		else if (arrested_cultists)
			end_message = "Załoga pokonała kult! [arrested_cultists] [arrested_cultists > 1 ? "kultystów zostało aresztowanych i przekazanych" : "kultysta został aresztowany i przekazany"] Nanotrasenowi do izolacji."

	cult_win = cult_won
	return list("won" = cult_won, "message" = end_message)

/datum/team/cult/roundend_report()
	var/list/parts = list()
	var/list/result = get_round_result()

	parts += "<span class='header'>Kult Nar'Sie</span>"
	if (result["won"])
		parts += "<span class='greentext big'>[result["message"]]</span>"
	else
		parts += "<span class='redtext big'>[result["message"]]</span>"

	parts += "Zgromadzone oddanie: <b>[round(total_devotion)]</b>"
	switch(stage)
		if (BLOODCULT_STAGE_NORMAL)
			parts += "Postęp Zaćmienia: <b>[round((eclipse_progress/eclipse_target)*100)]%</b>"
		else
			if (GLOB.eclipse.eclipse_start_time)
				var/seconds_to_eclipse = (GLOB.eclipse.eclipse_start_time - cult_founding_time)/10
				parts += "Zaćmienie nadeszło po: <b>[round(seconds_to_eclipse/3600)]h [add_zero(num2text(round(seconds_to_eclipse/60) % 60), 2)]m [add_zero(num2text(round(seconds_to_eclipse) % 60), 2)]s</b>"

	parts += "<br><b>Najbardziej oddani słudzy Nar'Sie:</b>"

	//sorted by devotion, the most devoted first (vg wstawiał po kolei i budował listę od końca)
	var/list/sorted_members = list()
	for (var/datum/antagonist/cult/C as anything in get_cultist_datums())
		var/pos = 1
		while (pos <= sorted_members.len)
			var/datum/antagonist/cult/U = sorted_members[pos]
			if (C.devotion > U.devotion)
				break
			pos++
		sorted_members.Insert(pos, C)

	if (sorted_members.len)
		for (var/datum/antagonist/cult/C as anything in sorted_members)
			parts += C.get_scoreboard_line()
	else
		parts += "<i>Nikt.</i>"

	if (deconverted.len > 0)
		parts += "<br><b>Ci, którzy zawrócili:</b>"
		for (var/D in deconverted)
			parts += "<font color='#888888'>[D] (oddanie: [round(deconverted[D])])</font>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/// Sets a blood target for the cult.
/datum/team/cult/proc/set_blood_target(atom/new_target, mob/marker, duration = 90 SECONDS)
	if(QDELETED(new_target))
		CRASH("A null or invalid target was passed to set_blood_target.")

	if(duration != INFINITY && blood_target_reset_timer)
		return FALSE

	deltimer(blood_target_reset_timer)
	blood_target = new_target
	RegisterSignal(blood_target, COMSIG_PARENT_QDELETING, PROC_REF(unset_blood_target_and_timer))
	var/area/target_area = get_area(new_target)

	blood_target_image = image('icons/effects/cult_target.dmi', new_target, "glow", ABOVE_MOB_LAYER)
	blood_target_image.appearance_flags = RESET_COLOR
	blood_target_image.pixel_x = -new_target.pixel_x
	blood_target_image.pixel_y = -new_target.pixel_y

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		to_chat(cultist.current, span_bold(span_cultlarge("[marker ? "[marker] oznacza" : "Oznaczono"] [blood_target] w [target_area?.name] jako najważniejszy cel kultu, natychmiast tam idź!")))
		SEND_SOUND(cultist.current, sound(pick('sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg'), 0, 1, 75))
		cultist.current.client.images += blood_target_image

	if(duration != INFINITY)
		blood_target_reset_timer = addtimer(CALLBACK(src, PROC_REF(unset_blood_target)), duration, TIMER_STOPPABLE)
	return TRUE

/// Unsets our blood target when they get deleted.
/datum/team/cult/proc/unset_blood_target_and_timer(datum/source)
	SIGNAL_HANDLER

	deltimer(blood_target_reset_timer)
	unset_blood_target()

/// Unsets out blood target, clearing the images from all the cultists.
/datum/team/cult/proc/unset_blood_target()
	blood_target_reset_timer = null

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		if(QDELETED(blood_target))
			to_chat(cultist.current, span_bold(span_cultlarge("Cel krwawego znaku przepadł!")))
		else
			to_chat(cultist.current, span_bold(span_cultlarge("Krwawy znak wygasł!")))
		cultist.current.client.images -= blood_target_image

	if(blood_target)
		UnregisterSignal(blood_target, COMSIG_PARENT_QDELETING)
	blood_target = null

	QDEL_NULL(blood_target_image)
