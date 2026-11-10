// AQUILA - statystyki postaci zapisywane między rundami (baza danych, bez bazy plik JSON).
//
// Nic nie jest liczone co tick: w trakcie rundy liczniki rosną tylko przy zdarzeniach (zgon, operacja, reanimacja,
// wykopana ruda, kajdanki, strzał, grzywna, obsłużony robot w restauracji, zniszczony okręt wroga) na umyśle gracza.
// Reszta (rundy, przeżycia, cele, misje, zarobki) jest liczona raz na koniec rundy.
// Postać to para ckey + imię postaci. Podgląd: Esc → Statystyki albo czasownik OOC „Statystyki”.

/// Plik zapasowy, gdy baza danych nie działa: ckey => imię postaci => statystyka => wartość
#define CHARACTER_STATS_FALLBACK_FILE "data/character_stats.json"
/// Statystyka, która trzyma najlepszy wynik zamiast sumy
#define CHARACTER_STAT_BEST_EARNINGS "earnings_best"

/// Czy statystyki tej rundy zostały już zapisane
GLOBAL_VAR_INIT(character_stats_saved, FALSE)
/// Czy tabela statystyk w bazie była już w tej rundzie sprawdzona (CREATE TABLE IF NOT EXISTS raz na rundę)
GLOBAL_VAR_INIT(character_stats_table_ready, FALSE)
GLOBAL_DATUM_INIT(character_stats_ui, /datum/character_stats_ui, new)

/datum/mind
	/// Liczniki statystyk postaci z tej rundy (statystyka => ile), patrz record_character_stat()
	var/list/aquila_stats

/// Dolicza graczowi sterującemu mobem statystykę jego postaci w tej rundzie
/proc/record_character_stat(mob/user, stat, amount = 1)
	record_mind_stat(user?.mind, stat, amount)

/// Dolicza statystykę postaci umysłowi gracza (np. przy zgonie, gdy ciało mogło już zniknąć)
/proc/record_mind_stat(datum/mind/player_mind, stat, amount = 1)
	if(!player_mind?.key || !stat || !amount)
		return
	LAZYINITLIST(player_mind.aquila_stats)
	player_mind.aquila_stats[stat] += amount

/// Statystyki rundy jako wiersze do zapisu: lista list("ckey", "character_name", "stat", "value")
/proc/character_stats_round_rows(list/minds = SSticker.minds)
	. = list()
	var/list/mission = GLOB.roundend_report_ui.roundend_mission()
	var/mission_won = mission?["won"]
	var/first_death_name = SSblackbox.first_death?["name"]
	// zarobek należy do postaci, której konto się liczyło (ckey + imię właściciela konta), nie do każdej postaci gracza
	var/list/earnings_by_character = list()
	for(var/list/result as anything in GLOB.economy_round_results)
		if(result["counted"])
			earnings_by_character["[result["ckey"]]|[result["name"]]"] = result["balance"]

	for(var/datum/mind/player_mind as anything in minds)
		if(!player_mind?.key || !player_mind.assigned_role || !player_mind.name)
			continue
		var/player_ckey = ckey(player_mind.key)
		var/list/stats = player_mind.aquila_stats ? player_mind.aquila_stats.Copy() : list()
		stats["rounds"] += 1
		// Zgony liczy record_mind_stat() przy śmierci, więc wyjście przez kriokomorę (ciało usunięte bez śmierci) nie jest zgonem
		var/mob/living/body = player_mind.current
		if(isliving(body) && body.stat != DEAD)
			stats["survived"] += 1
			if(EMERGENCY_ESCAPED_OR_ENDGAMED && (body.onCentCom() || body.onSyndieBase()))
				stats["escaped"] += 1
		if(first_death_name && first_death_name == player_mind.name)
			stats["first_death"] += 1
		if(length(player_mind.antag_datums))
			stats["antag_rounds"] += 1
			for(var/datum/antagonist/antag as anything in player_mind.antag_datums)
				for(var/datum/objective/objective as anything in antag.objectives)
					if(objective.check_completion())
						stats["antag_objectives"] += 1
		else if(mission_won)
			stats["missions_won"] += 1
		for(var/datum/objective/crew/crew_objective as anything in player_mind.crew_objectives)
			if(crew_objective.check_completion())
				stats["crew_objectives"] += 1
		var/earned = earnings_by_character["[player_ckey]|[player_mind.name]"]
		if(earned)
			stats["earnings_total"] += earned
			stats[CHARACTER_STAT_BEST_EARNINGS] = earned

		var/character_name = copytext_char(player_mind.name, 1, 65) // VARCHAR(64) liczy znaki, nie bajty
		for(var/stat in stats)
			var/value = round(stats[stat])
			if(value > 0)
				. += list(list("ckey" = player_ckey, "character_name" = character_name, "stat" = stat, "value" = value))

/// Tworzy tabelę, jeśli jej nie ma (schemat jest też w SQL/beestation_schema.sql); raz na rundę
/proc/character_stats_ensure_table()
	if(!SSdbcore.Connect())
		return FALSE
	if(GLOB.character_stats_table_ready)
		return TRUE
	var/datum/DBQuery/query_create = SSdbcore.NewQuery({"
		CREATE TABLE IF NOT EXISTS [format_table_name("character_stats")] (
			`ckey` VARCHAR(32) NOT NULL,
			`character_name` VARCHAR(64) NOT NULL,
			`stat` VARCHAR(32) NOT NULL,
			`value` BIGINT UNSIGNED NOT NULL DEFAULT 0,
			PRIMARY KEY (`ckey`, `character_name`, `stat`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
	"})
	var/success = query_create.Execute()
	qdel(query_create)
	GLOB.character_stats_table_ready = success
	return success

/// Zapisuje statystyki rundy raz na rundę: sumy, a przy najlepszym zarobku maksimum
/proc/character_stats_save_round()
	if(GLOB.character_stats_saved)
		return
	GLOB.character_stats_saved = TRUE
	var/list/rows = character_stats_round_rows()
	if(!length(rows))
		return
	if(character_stats_ensure_table())
		SSdbcore.MassInsert(format_table_name("character_stats"), rows, duplicate_key = "\nON DUPLICATE KEY UPDATE value = IF(stat = '[CHARACTER_STAT_BEST_EARNINGS]', GREATEST(value, VALUES(value)), value + VALUES(value))", warn = TRUE, async = FALSE) // zaraz restart świata, jak w rankingu zarobków
		return
	character_stats_merge_file(rows)

/// Dopisuje wiersze do pliku zapasowego
/proc/character_stats_merge_file(list/rows, file_path = CHARACTER_STATS_FALLBACK_FILE)
	var/list/all_stats = character_stats_load_file(file_path)
	for(var/list/row as anything in rows)
		var/list/characters = all_stats[row["ckey"]] || list()
		var/list/stats = characters[row["character_name"]] || list()
		if(row["stat"] == CHARACTER_STAT_BEST_EARNINGS)
			stats[row["stat"]] = max(stats[row["stat"]], row["value"])
		else
			stats[row["stat"]] += row["value"]
		characters[row["character_name"]] = stats
		all_stats[row["ckey"]] = characters
	rustg_file_write(json_encode(all_stats), file_path)

/proc/character_stats_load_file(file_path = CHARACTER_STATS_FALLBACK_FILE)
	if(!fexists(file_path))
		return list()
	var/list/data = json_decode(rustg_file_read(file_path))
	if(!islist(data))
		return list()
	// ckey => postać => statystyka: wpisy w innym kształcie (uszkodzony plik) są pomijane
	. = list()
	for(var/player_ckey in data)
		var/list/characters = data[player_ckey]
		if(!istext(player_ckey) || !islist(characters))
			continue
		var/list/valid_characters = list()
		for(var/character_name in characters)
			var/list/stats = characters[character_name]
			if(!istext(character_name) || !islist(stats))
				continue
			var/list/valid_stats = list()
			for(var/stat in stats)
				if(istext(stat) && isnum(stats[stat]))
					valid_stats[stat] = stats[stat]
			valid_characters[character_name] = valid_stats
		.[player_ckey] = valid_characters

/// Statystyki postaci gracza: imię postaci => statystyka => wartość
/proc/character_stats_load(player_ckey)
	. = list()
	if(!player_ckey)
		return
	if(character_stats_ensure_table())
		var/datum/DBQuery/query_stats = SSdbcore.NewQuery(
			"SELECT character_name, stat, value FROM [format_table_name("character_stats")] WHERE ckey = :ckey",
			list("ckey" = player_ckey)
		)
		if(query_stats.Execute())
			while(query_stats.NextRow())
				var/list/stats = .[query_stats.item[1]] || list()
				stats[query_stats.item[2]] = text2num(query_stats.item[3])
				.[query_stats.item[1]] = stats
		qdel(query_stats)
		return
	var/list/all_stats = character_stats_load_file()
	var/list/characters = all_stats[player_ckey]
	return islist(characters) ? characters : list()

/datum/controller/subsystem/ticker/display_report(popcount)
	. = ..()
	character_stats_save_round()

// --- Okno ---

/// Okno „Statystyki”: statystyki postaci gracza i ranking zarobków wszech czasów (także w menu pod Esc)
/client/verb/character_stats()
	set name = "Statystyki"
	set category = "OOC"
	set desc = "Statystyki twoich postaci i ranking zarobków ze wszystkich rund."

	GLOB.character_stats_ui.ui_interact(mob)

/datum/character_stats_ui

/datum/character_stats_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/character_stats_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterStats")
		ui.set_autoupdate(TRUE) // liczniki bieżącej rundy
		ui.open()

/// Liczniki tej rundy zmieniają się w trakcie gry, więc idą w danych odświeżanych przy aktualizacji okna
/datum/character_stats_ui/ui_data(mob/user)
	return list("round_stats" = user.mind?.aquila_stats || list())

/datum/character_stats_ui/ui_static_data(mob/user)
	var/list/characters = list()
	var/list/loaded = character_stats_load(user.client?.ckey)
	for(var/character_name in loaded)
		characters += list(list("name" = character_name, "stats" = loaded[character_name]))
	if(!GLOB.economy_leaderboard_loaded)
		economy_load_leaderboard()
	return list(
		"characters" = characters,
		"current" = user.mind?.name,
		"leaderboard" = GLOB.economy_leaderboard,
		"my_ckey" = user.ckey,
	)

// --- Liczniki zdarzeń ---

/// Udana operacja (tylko „ważne” operacje, jak w blackboksie) jest liczona w /datum/surgery_operation/proc/success()

/// Zgon: umysł zapamiętany przed śmiercią, bo przy gibie albo rozpyleniu ciało oddaje go duchowi
/mob/living/death(gibbed)
	var/was_dead_before = stat == DEAD
	var/datum/mind/dying_mind = mind
	. = ..()
	if(!was_dead_before)
		record_mind_stat(dying_mind, "deaths")

/obj/item/shockpaddles/do_help(mob/living/carbon/H, mob/living/user)
	var/was_dead = H.stat == DEAD
	. = ..()
	if(was_dead && !QDELETED(H) && H.stat != DEAD)
		record_character_stat(user, "revives")

/turf/closed/mineral/gets_drilled(mob/user)
	if(ismob(user) && mineralType && mineralAmt > 0)
		record_character_stat(user, "ore_mined", mineralAmt)
	return ..()

/obj/item/restraints/handcuffs/apply_cuffs(mob/living/carbon/target, mob/user, dispense = 0)
	var/was_cuffed = target.handcuffed
	. = ..()
	if(!was_cuffed && target.handcuffed && user != target)
		record_character_stat(user, "arrests")

/obj/item/gun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, aimed = FALSE)
	. = ..()
	if(.)
		record_character_stat(user, "shots_fired")

/datum/datacore/addCitation(id = "", datum/data/crime/crime)
	. = ..()
	if(ismob(usr))
		record_character_stat(usr, "fines_issued")

/datum/venue/on_get_order(mob/living/simple_animal/robot_customer/customer_pawn, obj/item/order_item)
	var/server_ckey = order_item?.fingerprintslast
	. = ..()
	if(server_ckey)
		record_character_stat(get_mob_by_ckey(server_ckey), "restaurant_orders")

/obj/structure/overmap/syndicate/ai
	/// Ostatnie trafienie przyszło od statku graczy (główny statek albo statek z załogą), patrz Destroy()
	var/last_hit_by_players = FALSE

/obj/structure/overmap/syndicate/ai/bullet_act(obj/item/projectile/P)
	var/obj/structure/overmap/firer = P?.overmap_firer
	last_hit_by_players = istype(firer) && (firer.role == MAIN_OVERMAP || length(firer.mobs_in_ship))
	return ..()

/// Zniszczony okręt Syndykatu, który ostatnio oberwał od statku graczy: liczy się każdej żywej osobie na głównym statku
/obj/structure/overmap/syndicate/ai/Destroy()
	if(obj_integrity <= 0 && last_hit_by_players)
		var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
		for(var/mob/living/carbon/human/crew in GLOB.alive_mob_list)
			if(crew.mind?.key && main_ship && crew.get_overmap() == main_ship)
				record_character_stat(crew, "ships_destroyed")
	return ..()

#undef CHARACTER_STATS_FALLBACK_FILE
#undef CHARACTER_STAT_BEST_EARNINGS
