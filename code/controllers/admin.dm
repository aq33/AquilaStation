// Debug verbs.
/client/proc/restart_controller(controller in list("Master", "Failsafe"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restartuje jeden z kontrolerów pętli gry (ostrożnie!)"

	if(!holder)
		return
	switch(controller)
		if("Master")
			Recreate_MC()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart Master Controller")
		if("Failsafe")
			new /datum/controller/failsafe()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Restart Failsafe Controller")

	message_admins("Admin [key_name_admin(usr)] restartuje kontroler [controller].")
