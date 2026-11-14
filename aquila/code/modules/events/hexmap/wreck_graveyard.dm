// AQUILA - cmentarzysko wraków: przez 10–20 minut radio ogólne łapie wezwania pomocy z wraków, a obok statku dryfuje wrak do rozbiórki (port z CEV-Eris code/game/gamemodes/events/space_weather.dm)

/// Niewidzialny nadawca wezwań z wraków (jego nazwa jest podpisem w radiu)
/obj/effect/abstract/aquila_hex_distress_voice
	name = "Nadawanie awaryjne"

/datum/round_event_control/aquila_hex_wreck_graveyard
	name = "Wreck Graveyard"
	typepath = /datum/round_event/aquila_hex_wreck_graveyard
	weight = 10
	min_players = 0
	max_occurrences = 1
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_wreck_graveyard
	startWhen = 1
	announceWhen = 3
	endWhen = 350
	/// Wrak, który pojawił się obok statku (tylko do ogłoszenia, potem może go wciągnąć magnes)
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck
	/// Podpis wezwań w radiu
	var/obj/effect/abstract/aquila_hex_distress_voice/voice

/datum/round_event/aquila_hex_wreck_graveyard/setup()
	endWhen = rand(300, 600) // 10–20 minut

/datum/round_event/aquila_hex_wreck_graveyard/start()
	wreck = spawn_wreck(SSstar_system.find_main_overmap())
	if(wreck)
		announce_to_ghosts(wreck)

/datum/round_event/aquila_hex_wreck_graveyard/announce(fake)
	var/wreck_spawned = !fake && !QDELETED(wreck)
	wreck = null
	if(wreck_spawned)
		priority_announce("W pobliżu statku wykryto dryfujące wraki stacji kosmicznej. Systemy telekomunikacyjne nie odpowiadają za ewentualne obciążenie psychiki załogi. \
			Jeden z wraków dryfuje w zasięgu magnesu na asteroidy.", "Cmentarzysko wraków")
		return
	priority_announce("W pobliżu statku wykryto dryfujące wraki stacji kosmicznej. Systemy telekomunikacyjne nie odpowiadają za ewentualne obciążenie psychiki załogi.", "Cmentarzysko wraków")

/datum/round_event/aquila_hex_wreck_graveyard/tick()
	if(activeFor % 50) // co 50 ticków, jak w oryginale
		return
	var/message = pick_distress_message()
	if(message)
		transmit(message)

/datum/round_event/aquila_hex_wreck_graveyard/end()
	priority_announce("Dryfujące wraki oddaliły się od statku.", "Cmentarzysko wraków")

/datum/round_event/aquila_hex_wreck_graveyard/kill()
	wreck = null
	QDEL_NULL(voice)
	return ..()

/// Wezwanie z wraku: składane z kawałków, gotowe z listy albo (rzadko) nic
/datum/round_event/aquila_hex_wreck_graveyard/proc/pick_distress_message()
	switch(rand(1, 3))
		if(1)
			var/message = pick("Wszyscy zaraz zginiemy... ", "Zmieniają się w te pajęcze mutanty... ", "Siłą nawracają nas jednego po drugim... ", "Zostałem sam... ")
			message += pick("Uciekajcie, póki możecie.", "Pomocy!", "Niech aniołowie mają nas w opiece...", "Już... za późno.")
			return message
		if(2)
			return pick(
				"Błogosławieni aniołowie, prowadźcie nas w bezpieczne miejsce!",
				"Towarzysze, schwytaliśmy ostatnich ocalałych z tego wraku. Czekamy na ewakuację w-",
				"Ktokolwiek to słyszy, UCIEKAJCIE, PÓKI MOŻECIE!",
				"Ledwo utrzymujemy to miejsce. Ktokolwiek odbierze ten sygnał, zabierzcie nas z-",
				"Kończą się nam zapasy jedzenia i wody. Mamy pieniądze. Pomóżcie nam, ktokolwiek, błagam...",
				"DO WSZYSTKICH, KTÓRZY JESZCZE SĄ LOJALNI: OSTATNI BÓJ STACZAMY W STERÓWCE.",
				"Zaspawajcie wentylację. Zaspawajcie wentylację! ZASPAWAJCIE WENTYLACJĘ!!",
				"Ochrona... nie żyje. Medyczny zaraz pójdzie w jej ślady. Te potwory znają tylko głód, pożarły większość załogi, a wciąż im mało... Nie próbujcie pomagać. Ta stacja jest stracona.",
			)
		if(3)
			if(prob(2))
				return "Ech, ci wszyscy ludzie są do niczego. Po prostu nie daj się trafić i bij wszystko, aż padnie."

/// Nadaje wezwanie na kanale ogólnym przez automatyczny system ogłoszeń
/datum/round_event/aquila_hex_wreck_graveyard/proc/transmit(message)
	if(!length(GLOB.announcement_systems))
		return FALSE
	var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
	if(!announcer.is_operational)
		return FALSE
	if(!voice)
		voice = new
	announcer.radio.talk_into(voice, message, null)
	return TRUE

/// Stawia wrak w zasięgu magnesu okrętu. Bez okrętu w układzie gwiezdnym nic nie robi.
/datum/round_event/aquila_hex_wreck_graveyard/proc/spawn_wreck(obj/structure/overmap/near)
	if(!near?.current_system || !near.z)
		return null
	var/turf/spot = aquila_hex_overmap_spot_beside(near, aquila_hex_magnet_distance(near))
	if(!spot)
		return null
	var/obj/structure/overmap/asteroid/shipbreak_wreck/new_wreck = new(spot)
	aquila_hex_overmap_place(new_wreck, near, spot)
	return new_wreck
