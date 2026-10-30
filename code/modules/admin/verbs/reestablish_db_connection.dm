/client/proc/reestablish_db_connection()
	set category = "Server"
	set name = "Reestablish DB Connection"
	if (!CONFIG_GET(flag/sql_enabled))
		to_chat(usr, "<span class='adminnotice'>Baza danych nie jest włączona!</span>")
		return

	if (SSdbcore.IsConnected())
		if (!check_rights(R_DEBUG,0))
			alert("Baza danych jest już połączona! (Tylko osoby z +debug mogą wymusić ponowne połączenie)", "Baza danych jest już połączona!")
			return

		var/reconnect = alert("Baza danych jest już połączona! Jeśli *WIESZ*, że to nieprawda, możesz wymusić ponowne połączenie", "Baza danych jest już połączona!", "Wymuś ponowne połączenie", "Anuluj")
		if (reconnect != "Wymuś ponowne połączenie")
			return

		SSdbcore.Disconnect()
		log_admin("[key_name(usr)] has forced the database to disconnect")
		message_admins("[key_name_admin(usr)] <b>wymusza</b> rozłączenie bazy danych!")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Force Reestablished Database Connection") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	log_admin("[key_name(usr)] is attempting to re-established the DB Connection")
	message_admins("[key_name_admin(usr)] próbuje przywrócić połączenie z bazą danych")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Reestablished Database Connection") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	SSdbcore.failed_connections = 0
	if(!SSdbcore.Connect())
		message_admins("Połączenie z bazą danych nie powiodło się: " + SSdbcore.ErrorMsg())
	else
		message_admins("Przywrócono połączenie z bazą danych")
