//replaces the old Ticklag verb, fps is easier to understand
/client/proc/set_server_fps()
	set category = "Debug"
	set name = "Set Server FPS"
	set desc = "Ustawia szybkość gry w klatkach na sekundę. Może zepsuć grę"

	if(!check_rights(R_DEBUG))
		return

	var/cfg_fps = CONFIG_GET(number/fps)
	var/new_fps = round(input("Ustawia liczbę klatek gry na sekundę. Może zepsuć grę (domyślnie: [cfg_fps])","FPS", world.fps) as num|null)

	if(new_fps <= 0)
		to_chat(src, "<span class='danger'>Błąd: set_server_fps(): nieprawidłowa wartość world.fps. Nic nie zmieniono.</span>")
		return
	if(new_fps > cfg_fps * 1.5)
		if(alert(src, "Ustawiasz wysoką wartość fps:\n\t[new_fps] klatek na sekundę\n\tconfig.fps = [cfg_fps]","Uwaga!","Potwierdź","PRZERWIJ-PRZERWIJ-PRZERWIJ") != "Potwierdź")
			return

	var/msg = "[key_name(src)] has modified world.fps to [new_fps]"
	log_admin(msg, 0)
	message_admins(msg, 0)
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Set Server FPS", "[new_fps]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	CONFIG_SET(number/fps, new_fps)
	world.fps = new_fps
