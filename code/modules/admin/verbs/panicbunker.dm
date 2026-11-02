/client/proc/panicbunker()
	set category = "Server"
	set name = "Toggle Panic Bunker"
	if (!CONFIG_GET(flag/sql_enabled))
		to_chat(usr, "<span class='adminnotice'>Baza danych nie jest włączona!</span>")
		return

	var/new_pb = !CONFIG_GET(flag/panic_bunker)
	var/interview = CONFIG_GET(flag/panic_bunker_interview)
	var/time_rec = 0
	var/message = ""
	if(new_pb)
		time_rec = input(src, "Ile minut przeżytych w grze ma być wymagane?", "Ale jest burdel, co?", CONFIG_GET(number/panic_bunker_living)) as num
		message = input(src, "Co mają zobaczyć przy logowaniu? UWAGA: wygląda na to, że to się graczom NIE wyświetla.", "MMM", CONFIG_GET(string/panic_bunker_message)) as text
		message = replacetext(message, "%minutes%", time_rec)
		CONFIG_SET(number/panic_bunker_living, time_rec)
		CONFIG_SET(string/panic_bunker_message, message)

		var/interview_sys = alert(src, "Włączyć system rozmów? (Pozwala łączyć się graczom poniżej limitu godzin, ale wymaga ręcznego zatwierdzenia ich do gry)", "Włączyć rozmowy?", "Włącz", "Wyłącz")
		interview = interview_sys == "Włącz"
		CONFIG_SET(flag/panic_bunker_interview, interview)
	CONFIG_SET(flag/panic_bunker, new_pb)
	log_admin("[key_name(usr)] has toggled the Panic Bunker, it is now [new_pb ? "on and set to [time_rec] with a message of [message]. The interview system is [interview ? "enabled" : "disabled"]" : "off"].")
	message_admins("[key_name_admin(usr)] przełącza Panic Bunker, teraz jest [new_pb ? "włączony z wymogiem [time_rec] przeżytych minut. System rozmów jest [interview ? "włączony" : "wyłączony"]" : "wyłączony"].")
	if (new_pb && !SSdbcore.Connect())
		message_admins("Baza danych nie jest połączona! Panic bunker nie zadziała, dopóki połączenie nie zostanie przywrócone.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Panic Bunker", "[new_pb ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_interviews()
	set category = "Server"
	set name = "Toggle PB Interviews"
	if (!CONFIG_GET(flag/panic_bunker))
		to_chat(usr, "<span class='adminnotice'>UWAGA: Panic bunker nie jest włączony, więc ta zmiana nic nie da, dopóki go nie włączysz.</span>")
	var/new_interview = !CONFIG_GET(flag/panic_bunker_interview)
	CONFIG_SET(flag/panic_bunker_interview, new_interview)
	log_admin("[key_name(usr)] has toggled the Panic Bunker's interview system, it is now [new_interview ? "enabled" : "disabled"].")
	message_admins("[key_name(usr)] przełącza system rozmów Panic Bunkra, teraz jest [new_interview ? "włączony" : "wyłączony"].")
