// AQUILA - SScassettes z Monkestation (cassette_manager.dm): wczytuje zatwierdzone kasety na starcie.
// Źródła: config/cassettes/*.json (dołączone do repo) i data/cassette_storage (zatwierdzone przez adminów w trakcie gry).
// Uszkodzony plik pomijamy z wpisem w logu - u Monke CRASH zatrzymywał cały podsystem.

SUBSYSTEM_DEF(cassettes)
	name = "Cassettes"
	flags = SS_NO_FIRE
	/// Przed atomami - kasety na mapie i stojaki losują z wczytanych już danych
	init_order = INIT_ORDER_ATOMS + 1
	/// id -> /datum/cassette
	var/list/datum/cassette/cassettes = list()
	/// id kasety -> lista ckeyów kupujących (każdy liczy się raz)
	var/list/purchases = list()

/datum/controller/subsystem/cassettes/Initialize(start_timeofday)
	load_builtin_cassettes()
	load_saved_cassettes()
	load_purchases()
	return ..()

/datum/controller/subsystem/cassettes/Recover()
	cassettes = SScassettes.cassettes
	purchases = SScassettes.purchases

/// Wczytuje i sprawdza jeden plik kasety; null przy błędzie
/datum/controller/subsystem/cassettes/proc/read_cassette_file(path, id)
	RETURN_TYPE(/datum/cassette)
	if(rustg_file_exists(path) != "true")
		return null
	var/raw = rustg_file_read(path)
	if(!rustg_json_is_valid(raw))
		log_game("Cassette file [path] has invalid JSON, skipping")
		return null
	var/list/data = json_decode(raw)
	if(!islist(data))
		return null
	var/datum/cassette/cassette = new
	cassette.import(data)
	cassette.id = id
	return cassette

/datum/controller/subsystem/cassettes/proc/load_builtin_cassettes()
	for(var/file_name in flist(CASSETTE_BUILTIN_DIR))
		if(copytext(file_name, -5) != ".json")
			continue
		var/id = copytext(file_name, 1, -5)
		var/datum/cassette/cassette = read_cassette_file(CASSETTE_BUILTIN_DIR + file_name, id)
		if(!cassette)
			continue
		cassette.status = CASSETTE_STATUS_APPROVED
		cassettes[id] = cassette

/datum/controller/subsystem/cassettes/proc/load_saved_cassettes()
	if(rustg_file_exists(CASSETTE_ID_FILE) != "true")
		return
	var/raw = rustg_file_read(CASSETTE_ID_FILE)
	if(!rustg_json_is_valid(raw))
		log_game("[CASSETTE_ID_FILE] has invalid JSON, no saved cassettes loaded")
		return
	for(var/id in json_decode(raw))
		var/datum/cassette/cassette = read_cassette_file(CASSETTE_FILE(id), id)
		if(cassette)
			cassettes[id] = cassette

/// Zapisuje listę zatwierdzonych kaset (bez wbudowanych z config/cassettes)
/datum/controller/subsystem/cassettes/proc/save_ids_json()
	var/list/ids = list()
	for(var/id in cassettes)
		var/datum/cassette/cassette = cassettes[id]
		if(cassette.status == CASSETTE_STATUS_APPROVED && rustg_file_exists(CASSETTE_FILE(id)) == "true")
			ids += id
	rustg_file_write(json_encode(ids), CASSETTE_ID_FILE)

/// Dopisuje zatwierdzoną kasetę: zapis na dysk i do pamięci
/datum/controller/subsystem/cassettes/proc/add_approved(datum/cassette/cassette)
	cassettes[cassette.id] = cassette
	cassette.save_to_file()
	save_ids_json()

/datum/controller/subsystem/cassettes/proc/load_cassette(id)
	RETURN_TYPE(/datum/cassette)
	if(istype(id, /datum/cassette))
		return id
	return id ? cassettes[id] : null

/// Kasety pasujące do filtrów (null = bez filtra)
/datum/controller/subsystem/cassettes/proc/filtered_cassettes(status, user_ckey, list/id_blacklist)
	RETURN_TYPE(/list)
	. = list()
	if(!isnull(user_ckey))
		user_ckey = ckey(user_ckey)
	for(var/id in cassettes)
		var/datum/cassette/cassette = cassettes[id]
		if(id_blacklist && (id in id_blacklist))
			continue
		if(!isnull(user_ckey) && ckey(cassette.author.ckey) != user_ckey)
			continue
		if(!isnull(status) && cassette.status != status)
			continue
		. += cassette

/// Do amount losowych, różnych kaset
/datum/controller/subsystem/cassettes/proc/unique_random_cassettes(amount = 1, status = CASSETTE_STATUS_APPROVED, user_ckey, list/id_blacklist)
	RETURN_TYPE(/list)
	. = list()
	var/list/candidates = filtered_cassettes(status, user_ckey, id_blacklist)
	for(var/i in 1 to min(amount, length(candidates)))
		. += pick_n_take(candidates)

/datum/controller/subsystem/cassettes/proc/load_purchases()
	if(rustg_file_exists(CASSETTE_PURCHASES_FILE) != "true")
		return
	var/raw = rustg_file_read(CASSETTE_PURCHASES_FILE)
	if(!rustg_json_is_valid(raw))
		return
	var/list/data = json_decode(raw)
	if(islist(data))
		purchases = data

/// Zakup w bibliotece; do rankingu każdy kupujący liczy się raz na kasetę
/datum/controller/subsystem/cassettes/proc/record_purchase(id, buyer_ckey)
	if(!id || !buyer_ckey)
		return
	var/list/buyers = purchases[id]
	if(!islist(buyers))
		buyers = list()
		purchases[id] = buyers
	if(buyer_ckey in buyers)
		return
	buyers += buyer_ckey
	rustg_file_write(json_encode(purchases), CASSETTE_PURCHASES_FILE)

/// Najczęściej kupowane zatwierdzone kasety: list(list("id", "name", "author", "purchases"))
/datum/controller/subsystem/cassettes/proc/top_cassettes(limit = 10)
	var/list/counts = list()
	for(var/id in purchases)
		var/datum/cassette/cassette = cassettes[id]
		if(cassette?.status != CASSETTE_STATUS_APPROVED)
			continue
		var/list/buyers = purchases[id]
		counts[id] = length(buyers)
	sortTim(counts, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	. = list()
	for(var/id in counts)
		if(length(.) >= limit)
			break
		var/datum/cassette/cassette = cassettes[id]
		. += list(list("id" = id, "name" = cassette.name, "author" = cassette.author.name, "purchases" = counts[id]))
