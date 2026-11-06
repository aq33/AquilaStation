/client/proc/spawn_floor_cluwne()
	set category = "Fun"
	set name = "Unleash Floor Cluwne"
	set desc = "Wybierz konkretny cel albo pozwól na losowy wybór i stwórz na stacji podłogowego cluwne'a. Uwaga: więcej niż jeden może sprawiać problemy!"
	var/target

	if(!check_rights(R_FUN))
		return

	var/turf/T = get_turf(usr)
	target = input("Masz na myśli konkretny cel? Pamiętaj, że prawidłowe są tylko żywe, ludzkie cele, które nie są cluwne'ami.", "Cel", target) as null|anything in GLOB.player_list
	if(target && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(T)
		FC.force_target(H)
		if(alert("Usunąć się po śmierci celu czy szukać kolejnych celów?",,"Usuń","Więcej celów")=="Usuń")
			FC.delete_after_target_killed = TRUE
	else
		new /mob/living/simple_animal/hostile/floor_cluwne(T)
	log_admin("[key_name(usr)] spawned floor cluwne.")
	message_admins("[key_name(usr)] tworzy podłogowego cluwne'a.")
