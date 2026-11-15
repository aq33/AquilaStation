// AQUILA - koniec kampanii wojny frakcji (raport/ftl_mapa_07). Nanotrasen przegrywa, gdy HEX_WAR_END_ROUNDS rund z rzędu
// wróg trzyma jego kwaterę przez co najmniej połowę rundy. Syndykat przegrywa tylko wtedy, gdy okręt gracza zdobędzie jego
// kwaterę w Abassi (sztaby AI tam nie idą): gracz dobija Syndykat. Wynik liczy zapis kampanii na koniec rundy; wtedy powstaje
// kopia kampanii, mapa gwiezdna wraca do domyślnej (jak „Hard Restart + New Campaign” admina), a wynik ogłasza start następnej rundy.

/// Strony, które mogą przegrać przez utratę kwatery na kilka rund (Syndykat przegrywa przez zdobycie kwatery przez gracza)
GLOBAL_LIST_INIT(hex_war_end_sides, list("nanotrasen"))

/datum/hex_war
	/// Ile rund z rzędu strona kończy bez kwatery głównej
	var/list/hq_lost_rounds = list()
	/// Koniec tej rundy już policzony (zapis kampanii może przyjść więcej niż raz)
	var/round_tallied = FALSE
	/// Tury tej rundy i ile z nich kwatera strony była w rękach wroga (kwatera przechodzi z rąk do rąk co kilka minut,
	/// więc o rundzie decyduje to, kto ją trzymał przez większość rundy, nie stan w chwili zapisu)
	var/round_turns = 0
	var/list/hq_hostile_turns = list()
	/// Okręt gracza zdobył kwaterę Syndykatu: wojna kończy się zwycięstwem z końcem rundy
	var/syndicate_defeated = FALSE
	/// Kolejne tury, w których okręt gracza stoi w kwaterze Syndykatu bez wrogich flot
	var/capture_turns = 0

/// Czy frakcja trzyma którąś ze swoich kwater (nie zajętą przez wroga)
/datum/hex_war/proc/hq_held(faction)
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.owner == faction && S.has_facility(HEX_FAC_HQ) && !hex_factions_hostile(faction, S.alignment))
			return TRUE
	return FALSE

/// Co turę: która strona ma kwaterę w rękach wroga (wołane w run_turn)
/datum/hex_war/proc/track_hq_control()
	round_turns++
	for(var/faction in GLOB.hex_war_end_sides)
		if(!hq_held(faction))
			hq_hostile_turns[faction] = (hq_hostile_turns[faction] || 0) + 1

/// Czy strona straciła kwaterę w tej rundzie: wróg trzymał ją przez co najmniej połowę tur (bez tur: stan teraz)
/datum/hex_war/proc/hq_lost_this_round(faction)
	if(!round_turns)
		return !hq_held(faction)
	return (hq_hostile_turns[faction] || 0) * 2 >= round_turns

/// Co turę: okręt gracza w kwaterze Syndykatu (wołane w run_turn)
/datum/hex_war/proc/track_player_capture()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/datum/star_system/S = ship ? SSstar_system.ships[ship]?["current_system"] : null
	player_capture_step(S, ship?.faction)

/// Krok zdobywania: kwatera Syndykatu bez wrogich flot przez HEX_WAR_PLAYER_CAPTURE_TURNS tur przechodzi na stronę okrętu.
/// Zwraca TRUE, gdy kwatera właśnie padła.
/datum/hex_war/proc/player_capture_step(datum/star_system/S, faction)
	if(syndicate_defeated || !S || !faction || S.owner != "syndicate" || !S.has_facility(HEX_FAC_HQ) || !hex_factions_hostile(faction, "syndicate"))
		capture_turns = 0
		return FALSE
	if(length(hex_hostile_fleets_in(S, faction)))
		capture_turns = 0
		return FALSE
	capture_turns++
	if(capture_turns < HEX_WAR_PLAYER_CAPTURE_TURNS)
		priority_announce("Obrona kwatery głównej Syndykatu w układzie [S] rozbita. Utrzymajcie układ jeszcze kilka minut, żeby ją zająć.", "Dowództwo Floty White Rapids")
		return FALSE
	syndicate_defeated = TRUE
	capture_turns = 0
	S.alignment = faction
	log_game("HEXWAR: the player's ship took the Syndicate headquarters in [S]")
	priority_announce("Kwatera główna Syndykatu w układzie [S] zajęta. Syndykat przegrywa wojnę w sektorze, kampania zakończy się z końcem rundy.", "Dowództwo Floty White Rapids")
	return TRUE

/// Koniec rundy: liczy rundy bez kwatery. Zwraca stronę, która przegrała wojnę, albo null.
/datum/hex_war/proc/round_end_tally()
	. = syndicate_defeated ? "syndicate" : null
	var/list/lost_now = list()
	for(var/faction in GLOB.hex_war_end_sides)
		lost_now[faction] = hq_lost_this_round(faction)
	round_turns = 0
	hq_hostile_turns = list()
	for(var/faction in GLOB.hex_war_end_sides)
		if(!lost_now[faction])
			hq_lost_rounds[faction] = 0
			continue
		hq_lost_rounds[faction] = (hq_lost_rounds[faction] || 0) + 1
		log_game("HEXWAR: [faction] ends round [hq_lost_rounds[faction]] in a row without its headquarters")
		if(!. && hq_lost_rounds[faction] >= HEX_WAR_END_ROUNDS)
			. = faction

/// Tekst wyniku wojny dla graczy
/proc/hex_war_end_text(loser)
	if(loser == "syndicate")
		return "Wojna zakończona: okręt Nanotrasen zajął kwaterę główną Syndykatu. Nanotrasen wygrywa wojnę w sektorze."
	return "Wojna zakończona: Nanotrasen przez [HEX_WAR_END_ROUNDS] rundy z rzędu nie odbiło swojej kwatery głównej. Syndykat wygrywa wojnę w sektorze."

/// Przegrana wojna: kopia kampanii, mapa gwiezdna i mapa hex od nowa, wynik do ogłoszenia w następnej rundzie
/datum/controller/subsystem/star_system/proc/hex_war_end_campaign(loser)
	var/path = campaign_starmap_path()
	log_game("HEXWAR: the war is over, [loser] lost its headquarters for [HEX_WAR_END_ROUNDS] rounds in a row")
	if(!path || !campaign_backup("koniec-wojny"))
		log_game("HEXWAR: the campaign backup failed, the campaign is kept instead of starting a new one")
		return FALSE
	var/list/result = reset_campaign_starmap(path)
	if(!result["success"])
		log_game("HEXWAR: the starmap reset failed ([result["error"]]), the campaign is kept")
		return FALSE
	campaign_reset_pending = TRUE
	fdel(HEXMAP_SAVE_PATH)
	ship_structure_wipe_all("koniec wojny frakcji")
	fdel(HEX_WAR_END_FILE)
	rustg_file_write(json_encode(list("loser" = loser, "at" = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss"))), HEX_WAR_END_FILE)
	message_admins("Wojna frakcji zakończona: [loser] stracił kwaterę główną na [HEX_WAR_END_ROUNDS] rundy. Następna runda zaczyna nową kampanię (kopia: Server → Campaign Backups).")
	return TRUE

/// Start rundy po zakończonej wojnie: ogłoszenie wyniku i nowej kampanii
/datum/hex_war/proc/announce_war_end()
	if(!fexists(HEX_WAR_END_FILE))
		return
	var/list/data
	try
		data = json_decode(rustg_file_read(HEX_WAR_END_FILE))
	catch
		data = null
	fdel(HEX_WAR_END_FILE)
	if(!islist(data) || !data["loser"])
		return
	priority_announce("[hex_war_end_text(data["loser"])] Rozpoczyna się nowa kampania.", "Dowództwo Floty White Rapids")
