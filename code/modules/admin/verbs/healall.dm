/client/proc/healall()
	set name = "Heal Everybody"
	set desc = "Leczy każdego moba w grze"
	set category = "Fun"
	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return
	if(!check_rights(R_FUN))
		to_chat(src, "Do tej komendy potrzebujesz uprawnienia fun.")
		return
	if(i18n_alert(usr, src, "Potwierdzić uleczenie wszystkich?","Na pewno?","Tak","Nie") != "Tak") // AQ EDIT - i18n okienka
		return
	message_admins("[key_name_admin(usr)] leczy wszystkie żywe moby")
	log_admin("[key_name_admin(usr)] healed all living mobs")
	to_chat(world, "<b>Bogowie cudownie dali wszystkim nowe życie!</b>")
	for(var/mob/living/M in GLOB.mob_living_list)
		M.revive(TRUE, TRUE)
