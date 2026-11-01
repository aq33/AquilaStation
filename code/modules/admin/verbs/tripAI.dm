/client/proc/triple_ai()
	set category = "Fun"
	set name = "Create AI Triumvirate"

	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "Ta opcja działa obecnie tylko przed startem gry. Może się to kiedyś zmienić.")
		return

	var/datum/job/job = SSjob.GetJob(JOB_NAME_AI)
	if(!job)
		to_chat(usr, "Nie znaleziono profesji SI")
		return
	if(SSticker.triai)
		SSticker.triai = 0
		to_chat(usr, "Na starcie rundy pojawi się tylko jedna SI.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] wyłącza potrójną SI na starcie rundy.</span>")
	else
		SSticker.triai = 1
		to_chat(usr, "Na starcie rundy pojawi się Triumwirat SI.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] włącza potrójną SI na starcie rundy.</span>")
