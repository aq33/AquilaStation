//This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/getserverlogs()
	set name = "Get Server Logs"
	set desc = "Przeglądaj/pobieraj pliki logów."
	set category = "Admin"
	if(!check_rights(R_SERVER))
		return

	browseserverlogs()

/client/proc/getcurrentlogs()
	set name = "Get Current Logs"
	set desc = "Przeglądaj/pobieraj pliki logów bieżącej rundy."
	set category = "Admin"

	browseserverlogs("[GLOB.log_directory]/")

/client/proc/browseserverlogs(path = "data/logs/")
	if(IsAdminAdvancedProcCall())
		log_admin_private("BROWSEFILES: Admin proc call blocked")
		message_admins("BROWSEFILES: zablokowano wywołanie procki przez admina")
		return null

	path = browse_files(path)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] otwiera plik: [path]")
	switch(alert("Pokaż (w grze), Otwórz (w edytorze tekstu systemu) czy Pobierz?", path, "Pokaż", "Otwórz", "Pobierz"))
		if ("Pokaż")
			src << browse(HTML_SKELETON("<pre style='word-wrap: break-word;'>[html_encode(rustg_file_read(path))]</pre>"), list2params(list("window" = "viewfile.[path]")))
		if ("Otwórz")
			src << run(file(path))
		if ("Pobierz")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Próbuję wysłać [path]. Przy bardzo dużym pliku może to potrwać dobrych kilka minut.")
	return
