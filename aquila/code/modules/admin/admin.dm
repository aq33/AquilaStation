/datum/admins/proc/reloadwhitelist()
	set category = "Server"
	set desc="Wczytuje whitelistę z pliku od nowa"
	set name="Reload Whitelist"
	load_whitelist()
	log_admin("[key_name(usr)] reloaded whitelist from file.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] wczytuje whitelistę z pliku od nowa.</span>")
