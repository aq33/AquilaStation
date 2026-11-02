GLOBAL_VAR_INIT(save_area_executing, FALSE)

/datum/mapGenerator/save_area
	buildmode_name = "Zapisz obszar"
	modules = list(/datum/mapGeneratorModule/save_area)
	var/min_x = 0
	var/min_y = 0
	var/max_x = 0
	var/max_y = 0

/datum/mapGenerator/save_area/defineRegion(turf/Start, turf/End, replace = 0)
	min_x = min(Start.x,End.x)
	min_y = min(Start.y,End.y)
	max_x = max(Start.x,End.x)
	max_y = max(Start.y,End.y)
	..()

/datum/mapGeneratorModule/save_area
	var/areaName = "default.dm"

//This could be optimised by making turfs that are the same go in the same, but this is a quick bodge solution so yea, fun job for coder here :)
/datum/mapGeneratorModule/save_area/generate()
	var/datum/mapGenerator/save_area/L = mother
	if(!istype(L))
		return
	//If someone somehow gets build mode, stop them from using this.
	if(!check_rights(R_ADMIN))
		message_admins("[ckey(usr)] próbuje uruchomić generator zapisu mapy, ale nie ma wystarczających uprawnień.")
		to_chat(usr, "<span class='warning'>Musisz mieć uprawnienia R_ADMIN, żeby tego użyć.</span>")
		return
	//Emergency check
	if(L.map.len > 1600)
		var/confirm = alert("Ehm, na pewno? Obszar jest dość duży.", "Uruchom generator", "Tak", "Nie")
		if(confirm != "Tak")
			return

	if(GLOB.save_area_executing)
		to_chat(usr, "<span class='warning'>Ktoś już używa generatora! Spróbuj za chwilę.</span>")
		return

	to_chat(usr, "<span class='warning'>Zapisywanie, proszę czekać...</span>")
	GLOB.save_area_executing = TRUE

	//Log just in case something happens
	log_game("[key_name(usr)] ran the save level map generator on [L.map.len] turfs.")
	message_admins("[key_name(usr)] uruchamia generator zapisu mapy na [L.map.len] turfach.")

	//Step 1: Get the data (This can take a while)
	var/dat = "//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE\n"
	dat += convert_map_to_tgm(L.map)

	//Step 2: Write the data to a file
	var/filedir = file("data/temp.dmm")
	if(fexists(filedir))
		fdel(filedir)
	WRITE_FILE(filedir, "[dat]")

	//Step 3: Give the file to client for download
	usr << ftp(filedir)

	//Step 4: Remove the file from the server (hopefully we can find a way to avoid step)
	fdel(filedir)
	log_game("[L.map.len] turfs have been saved by [ckey(usr)]")
	alert("Obszar zapisany pomyślnie.", "Sukces!", "OK")
	GLOB.save_area_executing = FALSE
