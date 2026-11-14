// AQUILA - zapis mapy hex obok starmap.json: gdzie okręt skończył rundę. Następna runda zaczyna się w tym samym kaflu,
// chyba że załoga wybrała inny okręt. Do tego kopie kampanii: automatyczna na koniec rundy (ostatnie 10),
// ręczna przez admina i przed resetem kampanii. Przywrócenie działa przy następnym starcie świata.

/datum/controller/subsystem/star_system
	/// Przywrócona kopia czeka na restart: Shutdown nie może jej nadpisać
	var/campaign_restore_pending = FALSE

/datum/controller/subsystem/star_system/save(_destination_path = SSmapping.config?.starmap_path)
	if(campaign_restore_pending && _destination_path == SSmapping.config?.starmap_path)
		log_game("Starmap save skipped: a campaign backup was restored for the next round.")
		return 1
	. = ..()
	var/campaign_file = _destination_path && _destination_path == SSmapping.config?.starmap_path
	if(campaign_reset_pending && campaign_file)
		fdel(HEXMAP_SAVE_PATH) // nowa kampania: okręt startuje jak w pierwszej rundzie
		return
	// Tylko po udanym zapisie kampanii (save() zwraca 0) i tylko pliku kampanii, nie pliku tymczasowego kopii
	if(. != 0 || !campaign_file || !initialized || !GLOB.hexmap?.built)
		return
	if(hexmap_write(HEXMAP_SAVE_PATH))
		campaign_backup("auto")

/// Zapisuje stan mapy hex do pliku. Zwraca TRUE przy powodzeniu.
/datum/controller/subsystem/star_system/proc/hexmap_write(path)
	var/obj/structure/overmap/main_ship = find_main_overmap()
	var/datum/star_system/S = main_ship ? ships[main_ship]?["current_system"] : null
	var/datum/hex/H = GLOB.hexmap.hex_of_system(S)
	var/list/data = list(
		"version" = HEXMAP_SAVE_VERSION,
		"map_name" = SSmapping.config?.map_name,
		"ship_hex" = H?.id,
		"ship_system" = (S && !istype(S, /datum/star_system/random)) ? S.name : null,
		"saved_at" = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss"),
	)
	fdel(path)
	rustg_file_write(json_encode(data), path)
	return fexists(path)

/// Czytany zapis mapy hex albo null
/proc/hexmap_read_save(path = HEXMAP_SAVE_PATH)
	if(!fexists(path))
		return
	var/list/data
	try
		data = json_decode(rustg_file_read(path))
	catch
		return
	if(!islist(data) || data["version"] != HEXMAP_SAVE_VERSION)
		return
	return data

/**
 * Układ, w którym okręt zaczyna rundę: zapisany kafel, jeśli to ten sam okręt, inaczej start trybu (zwykle Argo).
 * Hook w setup_overmap_mode() (overmap_mode.dm, AQ EDIT).
 */
/datum/controller/subsystem/star_system/proc/campaign_start_system(default_name, save_path = HEXMAP_SAVE_PATH)
	RETURN_TYPE(/datum/star_system)
	var/datum/star_system/fallback = system_by_id(default_name)
	if(!GLOB.hexmap?.built)
		return fallback
	var/list/data = hexmap_read_save(save_path)
	if(!data || data["map_name"] != SSmapping.config?.map_name)
		return fallback
	var/datum/star_system/named = data["ship_system"] ? system_by_id(data["ship_system"]) : null
	if(named)
		return named
	var/datum/hex/H = GLOB.hexmap.hex_by_id(data["ship_hex"])
	if(!H || GLOB.hexmap.blocks(H))
		return fallback
	log_game("Campaign: [SSmapping.config.map_name] starts where it ended the last round, hex [H.id].")
	return GLOB.hexmap.system_for(H)

// ===== kopie kampanii =====

/// Robi kopię kampanii z bieżącego stanu, bez ruszania plików, z których startuje następna runda. Zwraca nazwę kopii albo null.
/datum/controller/subsystem/star_system/proc/campaign_backup(kind = "manual", label)
	if(!initialized || !GLOB.hexmap?.built)
		return
	var/name = "[time2text(world.realtime, "YYYY-MM-DD_hh-mm-ss")]_[kind][label ? "_[hex_backup_label(label)]" : ""]"
	var/dir = "[CAMPAIGN_BACKUP_DIR][name]/"
	var/starmap_tmp = "config/starmap/_kopia_tmp.json"
	if(save(starmap_tmp)) // save() zwraca 1 przy błędzie
		fdel(starmap_tmp)
		return
	fcopy(starmap_tmp, "[dir]starmap.json")
	fdel(starmap_tmp)
	hexmap_write("[dir]hexmap.json")
	if(!fexists("[dir]starmap.json"))
		return
	if(kind == "auto")
		prune_auto_backups()
	log_game("Campaign backup [name] created.")
	return name

/datum/controller/subsystem/star_system/proc/prune_auto_backups()
	var/list/autos = list()
	for(var/entry in flist(CAMPAIGN_BACKUP_DIR))
		if(findtext(entry, "_auto") && copytext(entry, -1) == "/")
			autos += entry
	autos = sort_list(autos) // nazwy zaczynają się datą, więc to kolejność od najstarszej
	while(length(autos) > CAMPAIGN_BACKUP_AUTO_KEEP)
		fdel("[CAMPAIGN_BACKUP_DIR][autos[1]]")
		autos.Cut(1, 2)

/// Lista kopii od najnowszej
/proc/campaign_backup_list()
	. = list()
	for(var/entry in flist(CAMPAIGN_BACKUP_DIR))
		if(copytext(entry, -1) == "/" && fexists("[CAMPAIGN_BACKUP_DIR][entry]starmap.json"))
			. += copytext(entry, 1, -1)
	. = reverseRange(sort_list(.))

/// Wstawia kopię na miejsce plików kampanii. Zadziała przy następnym starcie świata. Zwraca TRUE przy powodzeniu.
/datum/controller/subsystem/star_system/proc/campaign_restore(name)
	var/dir = "[CAMPAIGN_BACKUP_DIR][name]/"
	var/starmap_path = campaign_starmap_path()
	if(!starmap_path || !fexists("[dir]starmap.json"))
		return FALSE
	campaign_backup("przed-przywroceniem")
	if(!fcopy("[dir]starmap.json", starmap_path))
		return FALSE
	fdel(HEXMAP_SAVE_PATH)
	if(fexists("[dir]hexmap.json"))
		fcopy("[dir]hexmap.json", HEXMAP_SAVE_PATH)
	campaign_restore_pending = TRUE
	return TRUE

/datum/admins/proc/campaign_backups_admin()
	set category = "Server"
	set name = "Campaign Backups"
	set desc = "Kopie kampanii mapy gwiezdnej: zapisz teraz albo przywróć"
	if(!check_rights(R_SERVER))
		return
	var/info = "Kopie kampanii: automatyczna na koniec każdej rundy (ostatnie [CAMPAIGN_BACKUP_AUTO_KEEP]), ręczne i przed resetem kampanii."
	if(SSstar_system.campaign_restore_pending)
		info += " Przywrócona kopia czeka na restart."
	var/choice = tgui_alert(usr, info, "Kopie kampanii", list("Zapisz kopię teraz", "Przywróć kopię", "Anuluj"))
	if(choice == "Zapisz kopię teraz")
		var/label = tgui_input_text(usr, "Krótki opis kopii (opcjonalnie)", "Kopia kampanii", max_length = 40)
		var/name = SSstar_system.campaign_backup("manual", label)
		if(!name)
			to_chat(usr, "<span class='warning'>Nie udało się zapisać kopii kampanii.</span>")
			return
		log_admin("[key_name(usr)] created campaign backup [name].")
		message_admins("[key_name_admin(usr)] zapisuje kopię kampanii: [name].")
	else if(choice == "Przywróć kopię")
		var/list/backups = campaign_backup_list()
		if(!length(backups))
			to_chat(usr, "<span class='warning'>Nie ma żadnych kopii kampanii.</span>")
			return
		var/name = tgui_input_list(usr, "Którą kopię przywrócić? Zadziała przy następnym starcie świata, obecna runda nie zapisze już kampanii.", "Przywróć kopię kampanii", backups)
		if(!name)
			return
		if(tgui_alert(usr, "Przywrócić kampanię z kopii [name]? Obecny stan zostanie zachowany jako osobna kopia.", "Przywróć kopię kampanii", list("Przywróć", "Anuluj")) != "Przywróć")
			return
		if(!SSstar_system.campaign_restore(name))
			to_chat(usr, "<span class='warning'>Nie udało się przywrócić kopii [name].</span>")
			return
		log_admin("[key_name(usr)] restored campaign backup [name] for the next round.")
		message_admins("[key_name_admin(usr)] przywraca kopię kampanii [name]. Zadziała po restarcie świata.")

/// Opis kopii do nazwy folderu: tylko litery, cyfry i myślniki
/proc/hex_backup_label(text)
	var/static/regex/bad = regex(@"[^A-Za-z0-9-]+", "g")
	return copytext(bad.Replace(text, "-"), 1, 30)
