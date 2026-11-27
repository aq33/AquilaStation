// AQUILA - Przebudzenie uśpionych agentów: Syndykat przejmuje na chwilę radio okrętu i nadaje serię liczb jak stacja numeryczna, a 1-2 słuchających członków załogi budzi się jako zdrajcy ze skrytką z zaopatrzeniem (port z goonstation/goonstation code/modules/events/sleeperagent.dm i code/modules/events/minor/dead_drops.dm; kod Goona na licencji CC BY-NC-SA 3.0, projekt niekomercyjny)
// Goon plays VOX numbers to everyone whose radio is on the common frequency, then wakes 0-2 of them as sleeper agents
// (its own antagonist), and a separate minor event later hides a keypad dead drop for each agent. Ours writes the
// numbers into the headsets as Polish words with a static sound (no VOX), wakes 1-2 listeners as our traitor
// (/datum/antagonist/traitor) and hides one small box per agent in a closet of a safe room (on the floor when the room
// has no free closet), with a few telecrystals, a Syndicate encryption key and cigarettes, no keypad. The listeners are
// filtered like the candidates of our dynamic midround traitor (autotraitor): the living traitor preference, the traitor
// ban, the living hours, no antagonist or special role yet, no silicons, ghost roles or restricted jobs (the protected
// jobs only when the config protects them, as in configure_ruleset()). The crew hears of it only after somebody woke up.
// Goon never wakes anyone 25% of the time; ours does not broadcast at all without a candidate.

/datum/round_event_control/aquila_hex_sleeper_agent
	name = "Przebudzenie uśpionych agentów"
	typepath = /datum/round_event/aquila_hex_sleeper_agent
	weight = 5
	min_players = 15
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/aquila_hex_sleeper_agent
	fakeable = FALSE
	startWhen = 3
	announceWhen = -1 // ogłoszenie idzie w end(), dopiero gdy ktoś się obudził
	/// Słuchacze, którzy mogą się obudzić (weakrefy do ludzi)
	var/list/candidate_refs = list()
	/// Ilu agentów obudzi audycja
	var/agents_to_wake = 1
	/// Nadane liczby
	var/numbers_text
	/// Obudzeni agenci (umysły)
	var/list/datum/mind/awakened = list()
	/// Schowane skrytki (weakrefy)
	var/list/datum/weakref/drop_refs = list()

/datum/round_event/aquila_hex_sleeper_agent/setup()
	endWhen = startWhen + 6 // ok. 12 s audycji
	agents_to_wake = prob(65) ? 1 : 2

/datum/round_event/aquila_hex_sleeper_agent/start()
	var/list/listeners = aquila_hex_radio_listeners()
	var/list/candidates = aquila_hex_sleeper_candidates(listeners)
	if(!length(candidates))
		log_game("Awaken Sleeper Agents: nobody listening on the radio can become a traitor, cancelling the event.")
		return kill()
	for(var/mob/living/carbon/human/candidate as anything in candidates)
		candidate_refs += WEAKREF(candidate)
	numbers_text = aquila_hex_numbers_broadcast()
	broadcast(listeners, "<span class='syndradio'><b>\[???\] Nieznany głos</b> mówi monotonnie: \"[numbers_text]\"</span>")
	message_admins("Przebudzenie uśpionych agentów: audycja liczb w radiu, kandydatów: [length(candidates)].")

/datum/round_event/aquila_hex_sleeper_agent/end()
	var/list/candidates = list()
	for(var/datum/weakref/candidate_ref as anything in candidate_refs)
		var/mob/living/carbon/human/candidate = candidate_ref.resolve()
		if(aquila_hex_sleeper_candidate_ok(candidate))
			candidates += candidate
	broadcast(aquila_hex_radio_listeners(), "<span class='syndradio'><b>\[???\] Nieznany głos</b> mówi: \"Powtarzam: [numbers_text] Koniec transmisji.\"</span>")
	for(var/i in 1 to min(agents_to_wake, length(candidates)))
		awaken(pick_n_take(candidates))
	if(!length(awakened))
		log_game("Awaken Sleeper Agents: no candidate was still valid at the end of the broadcast.")
		return
	priority_announce("Syndykat na chwilę przejął wasze łącza radiowe i nadał audycję stacji numerycznej. Takie audycje budzą uśpionych agentów. Zachowajcie czujność wobec członków załogi, którzy zaczną się dziwnie zachowywać.", "Wywiad Nanotrasen")

/datum/round_event/aquila_hex_sleeper_agent/kill()
	candidate_refs.Cut()
	return ..()

/// Wysyła tekst do słuchawek wszystkich słuchaczy z trzaskiem zakłóceń
/datum/round_event/aquila_hex_sleeper_agent/proc/broadcast(list/listeners, message)
	for(var/mob/living/listener as anything in listeners)
		to_chat(listener, message)
		listener.playsound_local(get_turf(listener), 'sound/misc/interference.ogg', 30, FALSE)

/// Budzi członka załogi jako zdrajcę, jeśli dalej spełnia warunki; zwraca antagonistę albo null
/datum/round_event/aquila_hex_sleeper_agent/proc/awaken(mob/living/carbon/human/sleeper)
	if(!aquila_hex_sleeper_candidate_ok(sleeper))
		return null
	return make_agent(sleeper)

/// Robi z człowieka z umysłem uśpionego agenta (traitor_datum - gotowy datum zdrajcy, domyślnie nowy) i chowa dla niego skrytkę
/datum/round_event/aquila_hex_sleeper_agent/proc/make_agent(mob/living/carbon/human/sleeper, datum/antagonist/traitor/traitor_datum)
	if(!sleeper?.mind)
		return null
	if(!traitor_datum)
		traitor_datum = new
	to_chat(sleeper, "<span class='userdanger'>Te liczby... znasz je. W głowie coś przeskakuje i nagle pamiętasz, kim naprawdę jesteś. Syndykat cię obudził.</span>")
	var/datum/antagonist/traitor/traitor = sleeper.mind.add_antag_datum(traitor_datum)
	if(!traitor)
		return null
	awakened += sleeper.mind
	var/obj/item/storage/box/aquila_hex_sleeper_drop/drop = hide_drop(sleeper)
	if(drop)
		drop_refs += WEAKREF(drop)
		var/hint = drop.hiding_hint()
		to_chat(sleeper, "<span class='syndradio'>W audycji był też kod skrytki: Syndykat zostawił ci zaopatrzenie w miejscu: [hint].</span>")
		sleeper.mind.store_memory("Skrytka Syndykatu po przebudzeniu: [hint].")
	message_admins("[ADMIN_LOOKUPFLW(sleeper)] budzi się jako uśpiony agent (zdrajca) w evencie [control?.name].")
	log_game("[key_name(sleeper)] was awakened as a sleeper agent (traitor) by an event.")
	return traitor

/// Chowa skrytkę agenta w wolnej szafce bezpiecznego pomieszczenia (albo na podłodze, gdy szafki nie ma); zwraca skrytkę
/datum/round_event/aquila_hex_sleeper_agent/proc/hide_drop(mob/living/carbon/human/sleeper)
	var/obj/structure/closet/hideout = aquila_hex_sleeper_closet()
	if(hideout)
		return new /obj/item/storage/box/aquila_hex_sleeper_drop(hideout, sleeper?.mind)
	var/list/room = aquila_hex_room_turfs(1)
	if(length(room))
		return new /obj/item/storage/box/aquila_hex_sleeper_drop(room[1], sleeper?.mind)
	return null

/// Członkowie załogi z włączoną słuchawką na uszach, którzy słyszą, na poziomach statku
/proc/aquila_hex_radio_listeners()
	. = list()
	for(var/mob/living/carbon/human/listener in GLOB.player_list)
		if(listener.stat == DEAD || !listener.can_hear())
			continue
		var/turf/listener_turf = get_turf(listener)
		if(!listener_turf || !is_station_level(listener_turf.z))
			continue
		var/obj/item/radio/headset = listener.ears
		if(istype(headset) && headset.on && headset.listening)
			. += listener

/// Słuchacze, którzy mogą zostać zdrajcami według warunków midroundowego zdrajcy z dynamic
/proc/aquila_hex_sleeper_candidates(list/listeners)
	. = list()
	for(var/mob/living/carbon/human/listener as anything in listeners)
		if(aquila_hex_sleeper_candidate_ok(listener))
			. += listener

/// Warunki midroundowego zdrajcy (/datum/dynamic_ruleset/midround/autotraitor): preferencja, ban, godziny, brak roli, zawód
/proc/aquila_hex_sleeper_candidate_ok(mob/living/carbon/human/candidate)
	if(!istype(candidate) || QDELETED(candidate) || candidate.stat == DEAD || !candidate.client || !candidate.mind)
		return FALSE
	if(issilicon(candidate) || is_centcom_level(candidate.z))
		return FALSE
	var/datum/mind/candidate_mind = candidate.mind
	if(candidate_mind.special_role || length(candidate_mind.antag_datums))
		return FALSE
	if(candidate_mind.assigned_role in GLOB.exp_specialmap[EXP_TYPE_SPECIAL]) // rola ducha
		return FALSE
	if(candidate_mind.assigned_role in aquila_hex_sleeper_restricted_roles())
		return FALSE
	var/datum/antagonist/traitor/traitor_type = /datum/antagonist/traitor
	return candidate.client.should_include_for_role(
		banning_key = initial(traitor_type.banning_key),
		role_preference_key = /datum/role_preference/midround_living/traitor,
		poll_ignore_key = /datum/role_preference/midround_living/traitor,
		req_hours = initial(traitor_type.required_living_playtime),
	)

/// Zawody, które nie mogą zostać midroundowym zdrajcą: zakazane w regule dynamic i chronione, gdy config je chroni
/proc/aquila_hex_sleeper_restricted_roles()
	var/datum/dynamic_ruleset/midround/autotraitor/rules = new
	. = rules.restricted_roles.Copy()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		. |= rules.protected_roles
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		. |= JOB_NAME_ASSISTANT
	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		. |= GLOB.command_positions
	qdel(rules)

/// Cztery grupy po trzy cyfry słownie, jak w audycji stacji numerycznej
/proc/aquila_hex_numbers_broadcast()
	var/static/list/digits = list("zero", "jeden", "dwa", "trzy", "cztery", "pięć", "sześć", "siedem", "osiem", "dziewięć")
	var/list/groups = list()
	for(var/group in 1 to 4)
		var/list/words = list()
		for(var/i in 1 to 3)
			words += digits[rand(1, 10)]
		groups += capitalize(jointext(words, "-"))
	return "[jointext(groups, ". ")]."

/// Losowa zamknięta, ale nie zaryglowana i nie zaspawana szafka w bezpiecznym pomieszczeniu statku (bez tuneli,
/// ochrony i zamkniętych obszarów); sprawdza najwyżej 15 losowych pomieszczeń
/proc/aquila_hex_sleeper_closet()
	var/list/area_types = GLOB.the_station_areas.Copy()
	var/areas_checked = 0
	while(length(area_types) && areas_checked < 15)
		var/area_type = pick_n_take(area_types)
		if(aquila_hex_closed_area_type(area_type) || ispath(area_type, /area/maintenance) || ispath(area_type, /area/security) || ispath(area_type, /area/space))
			continue
		areas_checked++
		var/list/closets = list()
		for(var/turf/T as anything in get_area_turfs(area_type))
			if(!is_station_level(T.z))
				continue
			for(var/obj/structure/closet/closet in T)
				if(closet.opened || closet.locked || closet.welded || istype(closet, /obj/structure/closet/secure_closet) || istype(closet, /obj/structure/closet/supplypod))
					continue
				closets += closet
		if(length(closets))
			return pick(closets)

/// Skrytka uśpionego agenta: zwykłe z wyglądu pudełko z zaopatrzeniem od Syndykatu
/obj/item/storage/box/aquila_hex_sleeper_drop
	name = "pudełko z częściami zamiennymi"
	desc = "Szare pudełko z naklejką „Części zamienne – nie otwierać”. Ktoś wyraźnie chciał, żeby nikt go nie otwierał."
	/// Umysł agenta, dla którego jest skrytka (weakref)
	var/datum/weakref/owner_ref

/obj/item/storage/box/aquila_hex_sleeper_drop/Initialize(mapload, datum/mind/owner)
	. = ..()
	if(owner)
		owner_ref = WEAKREF(owner)

/obj/item/storage/box/aquila_hex_sleeper_drop/PopulateContents()
	new /obj/item/stack/telecrystal(src, 3)
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/paper/aquila_hex_sleeper_note(src)

/// Opis miejsca skrytki dla agenta: pomieszczenie i, gdy leży w szafce, jaka to szafka
/obj/item/storage/box/aquila_hex_sleeper_drop/proc/hiding_hint()
	var/area/drop_area = get_area(src)
	var/where = drop_area ? drop_area.name : "nieznane miejsce"
	if(istype(loc, /obj/structure/closet))
		return "[where], w środku: [loc.name]"
	return "[where], na podłodze"

/obj/item/paper/aquila_hex_sleeper_note
	name = "złożona kartka"
	default_raw_text = "Agencie,<br><br>skoro to czytasz, audycja zadziałała. Kryształy wymienisz w swoim łączu, klucz włóż do słuchawek, a papierosy wypal za pomyślność operacji.<br><br>Ta kartka nie zjada się sama. Zjedz ją ty.<br><br>- Twój oficer prowadzący"
