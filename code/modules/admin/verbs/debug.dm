/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))
		return

	if(GLOB.Debug2)
		GLOB.Debug2 = 0
		message_admins("[key_name(src)] wyłącza debugowanie.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		GLOB.Debug2 = 1
		message_admins("[key_name(src)] włącza debugowanie.")
		log_admin("[key_name(src)] toggled debugging on.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Debug Two") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/Dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = get_turf(mob)
	if(!isturf(T))
		return
	atmosanalyzer_scan(usr, T, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Air Status In Location") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!SSticker.HasRoundStarted())
		alert("Poczekaj, aż gra się zacznie")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		var/mob/living/carbon/human/H = M
		spawn(0)
			H.Robotize()

	else
		alert("Nieprawidłowy mob")

/client/proc/cmd_admin_blobize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Blob"

	if(!SSticker.HasRoundStarted())
		alert("Poczekaj, aż gra się zacznie")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has blobized [M.key].")
		var/mob/living/carbon/human/H = M
		H.become_overmind()
	else
		alert("Nieprawidłowy mob")


/client/proc/cmd_admin_animalize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!SSticker.HasRoundStarted())
		alert("Poczekaj, aż gra się zacznie")
		return

	if(!M)
		alert("Wygląda na to, że ten mob nie istnieje. Zamknij panel i spróbuj ponownie.")
		return

	if(isnewplayer(M))
		alert("Mob nie może być typu new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(0)
		M.Animalize()


/client/proc/makepAI(turf/T in GLOB.mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Wskaż miejsce, w którym ma się pojawić urządzenie pAI, a potem klucz gracza, który nim pokieruje"

	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Wybierz gracza, który pokieruje pAI", "Stwórz pAI") in sortNames(available)
	if(!choice)
		return 0
	if(!isobserver(choice))
		var/confirm = input("[choice.key] nie jest teraz duchem. Na pewno chcesz wyrwać tego gracza z ciała i umieścić w tym pAI?", "Potwierdzenie pAI", "Nie") in list("Tak", "Nie")
		if(confirm != "Tak")
			return 0
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	pai.name = capped_input(choice, "Podaj imię swojego pAI:", "Imię pAI", "Osobista SI")
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/paiCandidate/candidate in SSpai.candidates)
		if(candidate.key == choice.key)
			SSpai.candidates.Remove(candidate)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make pAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_alienize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Alien"

	if(!SSticker.HasRoundStarted())
		alert("Poczekaj, aż gra się zacznie")
		return
	if(ishuman(M))
		INVOKE_ASYNC(M, /mob/living/carbon/human/proc/Alienize)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Alien") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien at [AREACOORD(M)].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] zmienia [ADMIN_LOOKUPFLW(M)] w obcego.</span>")
	else
		alert("Nieprawidłowy mob")

/client/proc/cmd_admin_slimeize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make slime"

	if(!SSticker.HasRoundStarted())
		alert("Poczekaj, aż gra się zacznie")
		return
	if(ishuman(M))
		INVOKE_ASYNC(M, /mob/living/carbon/human/proc/slimeize)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Slime") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a slime at [AREACOORD(M)].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] zmienia [ADMIN_LOOKUPFLW(M)] w szlama.</span>")
	else
		alert("Nieprawidłowy mob")


//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all(object as text)
	set category = "Debug"
	set name = "Del-All"

	var/list/matches = get_fancy_list_of_atom_types()
	if (!isnull(object) && object!="")
		matches = filter_fancy_list(matches, object)

	if(matches.len==0)
		return
	var/hsbitem = input(usr, "Wybierz obiekt do usunięcia.", "Usuń:") as null|anything in sortList(matches)
	if(hsbitem)
		hsbitem = matches[hsbitem]
		var/counter = 0
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				counter++
				qdel(O)
			CHECK_TICK
		log_admin("[key_name(src)] has deleted all ([counter]) instances of [hsbitem].")
		message_admins("[key_name_admin(src)] usuwa wszystkie instancje [hsbitem] (liczba: [counter]).")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete All") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] odbudowuje sieci energetyczne. Wywołano makepowernets().")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Powernets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if(!SSticker.HasRoundStarted())
		alert("Poczekaj, aż gra się zacznie")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = null
		if(worn)
			id = worn.GetID()
		if(id)
			id.icon_state = "gold"
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			id = new /obj/item/card/id/gold(H.loc)
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = JOB_NAME_CAPTAIN
			id.update_label()

			if(worn)
				if(istype(worn, /obj/item/modular_computer/tablet/pda))
					var/obj/item/modular_computer/tablet/pda/PDA = worn
					var/obj/item/computer_hardware/card_slot/card = PDA.all_components[MC_CARD]
					qdel(card.stored_card)
					if(card)
						card.try_insert(id, H)
				else if(istype(worn, /obj/item/storage/wallet))
					var/obj/item/storage/wallet/W = worn
					W.front_id = id
					id.forceMove(W)
					W.update_icon()
			else
				H.equip_to_slot(id,ITEM_SLOT_ID)

	else
		alert("Nieprawidłowy mob")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Grant Full Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] daje [M.key] pełny dostęp.</span>")

/client/proc/cmd_assume_direct_control(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Bezpośrednia interwencja"

	if(M.ckey)
		if(alert("Tym mobem steruje [M.key]. Na pewno chcesz przejąć nad nim kontrolę? [M.key] zostanie duchem.",,"Tak","Nie") != "Tak")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	if(!M || QDELETED(M))
		to_chat(usr, "<span class='warning'>Docelowy mob już nie istnieje.</span>")
		return
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] przejmuje bezpośrednią kontrolę nad: [M].</span>")
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = mob
	if(M.ckey)
		M.ghostize(FALSE)
	M.ckey = ckey
	if(isobserver(adminmob))
		qdel(adminmob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Assume Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_give_direct_control(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Give direct control"

	if(!M)
		return
	if(M.ckey)
		if(alert("Tym mobem steruje [M.key]. Na pewno chcesz oddać kontrolę nad nim komuś innemu? [M.key] zostanie duchem.",,"Tak","Nie") != "Tak")
			return
	var/client/newkey = input(src, "Wybierz gracza, który przejmie kontrolę.", "Nowy gracz") as null|anything in sortList(GLOB.clients)
	var/mob/oldmob = newkey.mob
	var/delmob = FALSE
	if((isobserver(oldmob) || alert("Usunąć starego moba gracza [newkey]?","Usunąć?","Tak","Nie") != "Nie"))
		delmob = TRUE
	if(!M || QDELETED(M))
		to_chat(usr, "<span class='warning'>Docelowy mob już nie istnieje, przerywam.</span>")
		return
	if(M.ckey)
		M.ghostize(FALSE)
	M.ckey = newkey.key
	if(delmob)
		qdel(oldmob)
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] oddaje bezpośrednią kontrolę nad [M] graczowi [newkey].</span>")
	log_admin("[key_name(usr)] gave away direct control of [M] to [newkey].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_test_atmos_controllers()
	set category = "Mapping"
	set name = "Test Atmos Monitoring Consoles"

	var/list/dat = list()

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Gra wciąż się wczytuje, zaczekaj!")
		return

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] używa komendy debugowania Test Atmos Monitor.</span>")
	log_admin("[key_name(usr)] used the Test Atmos Monitor debug command.")

	var/bad_shit = 0
	for(var/obj/machinery/computer/atmos_control/tank/console in GLOB.atmos_air_controllers)
		dat += "<h1>[console] w: [AREACOORD(console)]:</h1><br>"
		if(console.input_tag == console.output_tag)
			dat += "Błąd: input_tag jest taki sam jak output_tag, „[console.input_tag]”!<br>"
			bad_shit++
		if(!LAZYLEN(console.input_info))
			dat += "Nie znaleziono prawidłowego wtryskiwacza jako wejścia z tagiem [console.input_tag].<br>"
			bad_shit++
		if(!LAZYLEN(console.output_info))
			dat += "Nie znaleziono prawidłowej pompy ssącej jako wyjścia z tagiem [console.output_tag].<br>"
			bad_shit++
		if(!bad_shit)
			dat += "<B>STAN:</B> W NORMIE"
		else
			bad_shit = 0
		dat += "<br>"
		CHECK_TICK

	var/datum/browser/popup = new(usr, "testatmoscontroller", "Test konsol monitoringu atmosfery", 500, 750)
	popup.set_content(dat.Join())
	popup.open()

/client/proc/cmd_admin_areatest(on_station)
	set category = "Mapping"
	set name = "Test Areas"

	var/list/dat = list()
	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_multiple_APCs = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()
	var/list/station_areas_blacklist = typecacheof(list(/area/holodeck/rec_center, /area/shuttle, /area/engine/supermatter, /area/science/test_area, /area/space, /area/solar, /area/mine, /area/ruin, /area/asteroid))

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Gra wciąż się wczytuje, zaczekaj!")
		return

	var/log_message
	if(on_station)
		dat += "<b>Sprawdzam tylko obszary na poziomach z stacji.</b><br><br>"
		log_message = "station z-levels"
	else
		log_message = "all z-levels"

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] używa komendy debugowania Test Areas ([on_station ? "poziomy z stacji" : "wszystkie poziomy z"]).</span>")
	log_admin("[key_name(usr)] used the Test Areas debug command checking [log_message].")

	for(var/area/A in world)
		if(on_station)
			var/turf/picked = safepick(get_area_turfs(A.type))
			if(picked && is_station_level(picked.z))
				if(!(A.type in areas_all) && !is_type_in_typecache(A, station_areas_blacklist))
					areas_all.Add(A.type)
		else if(!(A.type in areas_all))
			areas_all.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/power/apc/APC in GLOB.apcs_list)
		var/area/A = APC.area
		if(!A)
			dat += "Pominięto [APC] w nieprawidłowym miejscu: [APC.loc]."
			continue
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)
		else if(A.type in areas_all)
			areas_with_multiple_APCs.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/airalarm/AA in GLOB.machines)
		var/area/A = get_area(AA)
		if(!A) //Make sure the target isn't inside an object, which results in runtimes.
			dat += "Pominięto [AA] w nieprawidłowym miejscu: [AA.loc].<br>"
			continue
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/requests_console/RC in GLOB.machines)
		var/area/A = get_area(RC)
		if(!A)
			dat += "Pominięto [RC] w nieprawidłowym miejscu: [RC.loc].<br>"
			continue
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light/L in GLOB.machines)
		var/area/A = get_area(L)
		if(!A)
			dat += "Pominięto [L] w nieprawidłowym miejscu: [L.loc].<br>"
			continue
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light_switch/LS in GLOB.machines)
		var/area/A = get_area(LS)
		if(!A)
			dat += "Pominięto [LS] w nieprawidłowym miejscu: [LS.loc].<br>"
			continue
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)
		CHECK_TICK

	for(var/obj/item/radio/intercom/I in GLOB.machines)
		var/area/A = get_area(I)
		if(!A)
			dat += "Pominięto [I] w nieprawidłowym miejscu: [I.loc].<br>"
			continue
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/camera/C in GLOB.machines)
		var/area/A = get_area(C)
		if(!A)
			dat += "Pominięto [C] w nieprawidłowym miejscu: [C.loc].<br>"
			continue
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)
		CHECK_TICK

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	if(areas_without_APC.len)
		dat += "<h1>OBSZARY BEZ APC:</h1>"
		for(var/areatype in areas_without_APC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_with_multiple_APCs.len)
		dat += "<h1>OBSZARY Z KILKOMA APC:</h1>"
		for(var/areatype in areas_with_multiple_APCs)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_air_alarm.len)
		dat += "<h1>OBSZARY BEZ ALARMU POWIETRZA:</h1>"
		for(var/areatype in areas_without_air_alarm)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_RC.len)
		dat += "<h1>OBSZARY BEZ KONSOLI ZGŁOSZEŃ:</h1>"
		for(var/areatype in areas_without_RC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_light.len)
		dat += "<h1>OBSZARY BEZ ŚWIATEŁ:</h1>"
		for(var/areatype in areas_without_light)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_LS.len)
		dat += "<h1>OBSZARY BEZ WŁĄCZNIKA ŚWIATŁA:</h1>"
		for(var/areatype in areas_without_LS)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_intercom.len)
		dat += "<h1>OBSZARY BEZ INTERKOMÓW:</h1>"
		for(var/areatype in areas_without_intercom)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_camera.len)
		dat += "<h1>OBSZARY BEZ KAMER:</h1>"
		for(var/areatype in areas_without_camera)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(!(areas_with_APC.len || areas_with_multiple_APCs.len || areas_with_air_alarm.len || areas_with_RC.len || areas_with_light.len || areas_with_LS.len || areas_with_intercom.len || areas_with_camera.len))
		dat += "<b>Brak problematycznych obszarów!</b>"

	var/datum/browser/popup = new(usr, "testareas", "Test obszarów", 500, 750)
	popup.set_content(dat.Join())
	popup.open()


/client/proc/cmd_admin_areatest_station()
	set category = "Mapping"
	set name = "Test Areas (STATION Z)"
	cmd_admin_areatest(TRUE)

/client/proc/cmd_admin_areatest_all()
	set category = "Mapping"
	set name = "Test Areas (ALL)"
	cmd_admin_areatest(FALSE)

/client/proc/cmd_admin_dress(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Select equipment"
	if(!check_rights(R_ADMIN))
		return
	if(!(ishuman(M) || isobserver(M)))
		alert("Nieprawidłowy mob")
		return

	// AQUILA: wybór stroju w oknie TGUI (port z tg: SelectEquipment)
	var/datum/select_equipment/ui = new(src, M)
	ui.ui_interact(mob)

/// Ubiera moba w podany strój (typ, obiekt własnego stroju albo "Naked"). Wywoływane z okna SelectEquipment i z holopadu admina.
/client/proc/admin_apply_outfit(mob/M, dresscode)
	if(!(ishuman(M) || isobserver(M)))
		alert("Nieprawidłowy mob")
		return

	if(!dresscode)
		return

	var/delete_pocket
	var/mob/living/carbon/human/H
	if(isobserver(M))
		H = M.change_mob_type(/mob/living/carbon/human, null, null, TRUE)
	else
		H = M
		if(H.l_store || H.r_store || H.s_store) //saves a lot of time for admins and coders alike
			if(alert("Upuścić przedmioty z kieszeni? „Nie” je usunie.", "Wybór stroju", "Tak", "Nie") != "Tak")
				delete_pocket = TRUE

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Select Equipment") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for (var/obj/item/I in H.get_equipped_items(delete_pocket))
		qdel(I)
	if(dresscode != "Naked")
		H.equipOutfit(dresscode)

	H.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(H)] to [dresscode].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] zmienia wyposażenie [ADMIN_LOOKUPFLW(H)] na: [dresscode].</span>")

/client/proc/robust_dress_shop()
	var/list/outfits = list("Naked","Własny","Jak profesja...","Jak profesja (plazmaman)...", "Debug")
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman) - typesof(/datum/outfit/debug)
	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path

	var/dresscode = input("Wybierz strój", "Szybka przebieralnia") as null|anything in outfits
	if(isnull(dresscode))
		return

	if(outfits[dresscode])
		dresscode = outfits[dresscode]



	if(dresscode == "Jak profesja...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path

		dresscode = input("Wybierz wyposażenie profesji", "Szybka przebieralnia") as null|anything in sortList(job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if(dresscode == "Jak profesja (plazmaman)...")
		var/list/job_paths = subtypesof(/datum/outfit/plasmaman)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path

		dresscode = input("Wybierz wyposażenie plazmamana", "Szybka przebieralnia") as null|anything in sortList(job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if(dresscode == "Debug")
		dresscode = /datum/outfit/debug
		if(isnull(dresscode))
			return

	if(dresscode == "Własny")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Wybierz strój", "Szybka przebieralnia") as null|anything in sortList(custom_names)
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return

	return dresscode

/*
 * AQUILA: okno wyboru stroju (port z tg: /datum/select_equipment, okno SelectEquipment).
 * Zwykłe stroje są przekazywane jako ścieżki typów, własne stroje admina (GLOB.custom_outfits) jako REF obiektu.
 */
/datum/select_equipment
	var/client/user
	var/mob/target_mob

	var/dummy_key

	//static list to share all the outfit typepaths between all instances of this datum.
	var/static/list/cached_outfits

	//a typepath if the selected outfit is a normal outfit;
	//an object if the selected outfit is a custom outfit
	var/datum/outfit/selected_outfit = /datum/outfit
	//serializable string for the UI to keep track of which outfit is selected
	var/selected_identifier = "/datum/outfit"
	/// Cached flat icon of the dummy wearing selected_outfit
	var/icon/cached_dummy_icon
	/// The selected_identifier cached_dummy_icon was last rendered for.
	var/cached_for_identifier

/datum/select_equipment/New(_user, mob/target)
	user = CLIENT_FROM_VAR(_user)
	target_mob = target

/datum/select_equipment/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SelectEquipment", "Wybór stroju")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/select_equipment/ui_state(mob/user)
	return GLOB.admin_state

/datum/select_equipment/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(target_mob))
		return UI_CLOSE
	return ..()

/datum/select_equipment/ui_close(mob/user, datum/tgui/tgui)
	unset_busy_human_dummy(dummy_key)
	qdel(src)

/datum/select_equipment/proc/init_dummy()
	dummy_key = "selectequipmentUI_[target_mob]"
	generate_dummy_lookalike(dummy_key, target_mob)
	unset_busy_human_dummy(dummy_key)

/datum/select_equipment/proc/outfit_entry(category, identifier, name, priority = FALSE, custom_entry = FALSE)
	if(custom_entry)
		return list("category" = category, "ref" = identifier, "name" = name, "priority" = priority)
	return list("category" = category, "path" = identifier, "name" = name, "priority" = priority)

/datum/select_equipment/proc/make_outfit_entries(category, list/outfit_list)
	var/list/entries = list()
	for(var/path in outfit_list)
		var/datum/outfit/outfit = path
		if(!initial(outfit.can_be_admin_equipped))
			continue
		entries += list(outfit_entry(category, path, initial(outfit.name)))
	return entries

//GLOB.custom_outfits lists outfit *objects* so we'll need to do some custom handling for it
/datum/select_equipment/proc/make_custom_outfit_entries(list/outfit_list)
	var/list/entries = list()
	for(var/datum/outfit/outfit as anything in outfit_list)
		entries += list(outfit_entry("Własne", REF(outfit), outfit.name, custom_entry = TRUE))
	return entries

/datum/select_equipment/ui_data(mob/user)
	var/list/data = list()
	if(!dummy_key)
		init_dummy()

	if(isnull(cached_dummy_icon) || cached_for_identifier != selected_identifier)
		cached_dummy_icon = get_flat_human_icon(null, null, null, dummy_key, list(SOUTH), selected_outfit)
		cached_for_identifier = selected_identifier

	data["icon64"] = icon2base64(cached_dummy_icon)
	data["name"] = "[target_mob]"
	data["custom_outfits"] = make_custom_outfit_entries(GLOB.custom_outfits)
	data["current_outfit"] = "[selected_identifier]"
	return data

/datum/select_equipment/ui_static_data(mob/user)
	var/list/data = list()
	if(!cached_outfits)
		cached_outfits = list()
		cached_outfits += list(outfit_entry("Ogólne", /datum/outfit, "Nago", priority = TRUE))
		cached_outfits += make_outfit_entries("Ogólne", subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman) - typesof(/datum/outfit/debug))
		cached_outfits += make_outfit_entries("Profesje", subtypesof(/datum/outfit/job))
		cached_outfits += make_outfit_entries("Plazmaludzie", subtypesof(/datum/outfit/plasmaman))
		cached_outfits += make_outfit_entries("Debug", typesof(/datum/outfit/debug))

	data["outfits"] = cached_outfits
	return data

/datum/select_equipment/proc/resolve_outfit(text)
	var/path = text2path(text)
	if(ispath(path, /datum/outfit))
		return path
	//don't bail yet - could be a custom outfit
	var/datum/outfit/custom_outfit = locate(text) in GLOB.custom_outfits
	if(istype(custom_outfit))
		return custom_outfit

/datum/select_equipment/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return
	. = TRUE
	switch(action)
		if("preview")
			var/datum/outfit/new_outfit = resolve_outfit(params["path"])
			if(ispath(new_outfit)) //got a typepath - that means we're dealing with a normal outfit
				selected_identifier = "[new_outfit]"
			else if(istype(new_outfit)) //got an initialized object - means it's a custom outfit
				selected_identifier = REF(new_outfit)
			else
				return
			selected_outfit = new_outfit

		if("applyoutfit")
			var/datum/outfit/new_outfit = resolve_outfit(params["path"])
			if(!new_outfit)
				return
			if(new_outfit == /datum/outfit)
				new_outfit = "Naked"
			usr.client?.admin_apply_outfit(target_mob, new_outfit)

		if("customoutfit")
			usr.client?.holder?.outfit_manager(usr)

/client/proc/startSinglo()

	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Uruchamia osobliwość i wszystkie maszyny, by na stację popłynął prąd"

	if(alert("Na pewno? To uruchomi silnik. Używaj tylko podczas debugowania!",,"Tak","Nie") != "Tak")
		return

	for(var/obj/machinery/power/emitter/E in GLOB.machines)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field/generator/F in GLOB.machines)
		if(F.active == 0)
			F.active = 1
			F.state = 2
			F.power = 250
			F.anchored = TRUE
			F.warming_up = 3
			F.start_fields()
			F.update_icon()

	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in GLOB.machines)
			if(G.anchored)
				var/obj/anomaly/singularity/S = new /obj/anomaly/singularity(get_turf(G), 50)
//				qdel(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in GLOB.machines)
		if(Rad.anchored)
			if(!Rad.loaded_tank)
				var/obj/item/tank/internals/plasma/Plasma = new/obj/item/tank/internals/plasma(Rad)
				Plasma.air_contents.set_moles(GAS_PLASMA, 70)
				Rad.drainratio = 0
				Rad.loaded_tank = Plasma
				Plasma.forceMove(Rad)

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in GLOB.machines)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "Na wypadek, gdy po prostu musisz wiedzieć"

	switch(input("Która lista?") in list("Gracze","Admini","Moby","Żywe moby","Martwe moby","Klienci","Dołączeni klienci"))
		if("Gracze")
			to_chat(usr, jointext(GLOB.player_list,","))
		if("Admini")
			to_chat(usr, jointext(GLOB.admins,","))
		if("Moby")
			to_chat(usr, jointext(GLOB.mob_list,","))
		if("Żywe moby")
			to_chat(usr, jointext(GLOB.alive_mob_list,","))
		if("Martwe moby")
			to_chat(usr, jointext(GLOB.dead_mob_list,","))
		if("Klienci")
			to_chat(usr, jointext(GLOB.clients,","))
		if("Dołączeni klienci")
			to_chat(usr, jointext(GLOB.joined_player_list,","))

/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Pokazuje log wszystkiego, co przeszło przez qdel."

	var/list/dellog = list("<B>Lista rzeczy, które przeszły w tej rundzie przez qdel</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp=GLOBAL_PROC_REF(cmp_qdel_item_time), associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if (I.qdel_flags & QDEL_ITEM_SUSPENDED_FOR_LAG)
			dellog += "<li>ZAWIESZONE Z POWODU LAGÓW</li>"
		if (I.failures)
			dellog += "<li>Niepowodzenia: [I.failures]</li>"
		dellog += "<li>Liczba qdel(): [I.qdels]</li>"
		dellog += "<li>Koszt Destroy(): [I.destroy_time]ms</li>"
		if (I.hard_deletes)
			dellog += "<li>Twarde usunięcia łącznie: [I.hard_deletes]</li>"
			dellog += "<li>Czas twardego usuwania: [I.hard_delete_time]ms</li>"
			dellog += "<li>Najdłuższy czas twardego usuwania: [I.hard_delete_max]ms</li>"
			if (I.hard_deletes_over_threshold)
				dellog += "<li>Twarde usunięcia ponad próg: [I.hard_deletes_over_threshold]</li>"
		if (I.slept_destroy)
			dellog += "<li>Uśpienia: [I.slept_destroy]</li>"
		if (I.no_respect_force)
			dellog += "<li>Zignorowane force: [I.no_respect_force]</li>"
		if (I.no_hint)
			dellog += "<li>Brak podpowiedzi: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	usr << browse(HTML_SKELETON(dellog.Join()), "window=dellog")

/client/proc/cmd_display_overlay_log()
	set category = "Debug"
	set name = "Display overlay Log"
	set desc = "Pokazuje log wszystkiego, co przeszło przez SSoverlays."

	render_stats(SSoverlays.stats, src)

/client/proc/cmd_display_init_log()
	set category = "Debug"
	set name = "Display Initialize() Log"
	set desc = "Pokazuje listę rzeczy, które nieprawidłowo obsłużyły Initialize()"

	var/datum/browser/browser = new(usr, "initlog", "Log Initialize", 500, 500)
	browser.set_content(replacetext(SSatoms.InitLog(), "\n", "<br>"))
	browser.open()

/client/proc/debug_huds(i as num)
	set category = "Debug"
	set name = "Debug HUDs"
	set desc = "Debuguj HUD-y danych lub antagonistów"

	if(!holder)
		return
	debug_variables(GLOB.huds[i])

/client/proc/jump_to_ruin()
	set category = "Debug"
	set name = "Jump to Ruin"
	set desc = "Pokazuje listę wszystkich postawionych ruin, do których można się teleportować."
	if(!holder)
		return
	var/list/names = list()
	for(var/i in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = i
		var/datum/map_template/ruin/template = ruin_landmark.ruin_template

		var/count = 1
		var/name = template.name
		var/original_name = name

		while(name in names)
			count++
			name = "[original_name] ([count])"

		names[name] = ruin_landmark

	var/ruinname = input("Wybierz ruinę", "Skok do ruiny") as null|anything in sortList(names)


	var/obj/effect/landmark/ruin/landmark = names[ruinname]

	if(istype(landmark))
		var/datum/map_template/ruin/template = landmark.ruin_template
		usr.forceMove(get_turf(landmark))
		to_chat(usr, "<span class='name'>[template.name]</span>")
		to_chat(usr, "<span class='italics'>[template.description]</span>")

/client/proc/place_ruin()
	set category = "Debug"
	set name = "Spawn Ruin"
	set desc = "Próbuje losowo postawić konkretną ruinę."
	if (!holder)
		return

	var/list/exists = list()
	for(var/landmark in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/L = landmark
		exists[L.ruin_template] = landmark

	var/list/names = list()
	names += "---- Poziomy dynamiczne ----"
	for(var/name in SSmapping.space_ruins_templates)
		names[name] = list(SSmapping.space_ruins_templates[name], ZTRAIT_DYNAMIC_LEVEL, /area/space)
	names += "---- Ruiny lawowe ----"
	for(var/name in SSmapping.lava_ruins_templates)
		names[name] = list(SSmapping.lava_ruins_templates[name], ZTRAIT_LAVA_RUINS, /area/lavaland/surface/outdoors/unexplored)

	var/ruinname = input("Wybierz ruinę", "Postaw ruinę") as null|anything in sortList(names)
	var/data = names[ruinname]
	if (!data)
		return
	var/datum/map_template/ruin/template = data[1]
	if (exists[template])
		var/response = alert("Ruina [template] już istnieje.", "Postaw ruinę", "Skocz", "Postaw kolejną", "Anuluj")
		if (response == "Skocz")
			usr.forceMove(get_turf(exists[template]))
			return
		else if (response != "Postaw kolejną")
			return

	var/len = GLOB.ruin_landmarks.len
	seedRuins(SSmapping.levels_by_trait(data[2]), max(1, template.cost), data[3], list(ruinname = template))
	if (GLOB.ruin_landmarks.len > len)
		var/obj/effect/landmark/ruin/landmark = GLOB.ruin_landmarks[GLOB.ruin_landmarks.len]
		log_admin("[key_name(src)] randomly spawned ruin [ruinname] at [COORD(landmark)].")
		usr.forceMove(get_turf(landmark))
		to_chat(src, "<span class='name'>[template.name]</span>")
		to_chat(src, "<span class='italics'>[template.description]</span>")
	else
		to_chat(src, "<span class='warning'>Nie udało się postawić: [template.name].</span>")

/client/proc/generate_ruin()
	set category = "Debug"
	set name = "Generate Ruin"
	set desc = "Losowo generuje kosmiczną ruinę."
	if (!holder)
		return
	var/ruin_size = input(src, "Rozmiar ruiny (NxN) (od 10 do 200)", "Rozmiar ruiny", 0) as num
	if(ruin_size < 10 || ruin_size >= 200)
		return
	var/response = alert(src, "Ruina zostanie postawiona w twoim obecnym miejscu.", "Postaw ruinę", "Postaw ruinę", "Anuluj")
	if (response != "Postaw ruinę")
		return
	var/border_size = (world.maxx - ruin_size) / 2
	generate_space_ruin(mob.x, mob.y, mob.z, border_size, border_size)
	log_admin("[key_name(src)] randomly generated a space ruin at [COORD(mob)].")

/client/proc/clear_dynamic_transit()
	set category = "Debug"
	set name = "Clear Dynamic Turf Reservations"
	set desc = "Zwalnia całą zarezerwowaną przestrzeń, przywracając stan z początku rundy."
	if(!holder)
		return
	var/answer = alert("UWAGA: TO WYCZYŚCI CAŁĄ ZAREZERWOWANĄ PRZESTRZEŃ DO ZERA! WSZYSTKIE LECĄCE PROMY, WINDY I ROBIONE WŁAŚNIE ZDJĘCIA ZOSTANĄ USUNIĘTE!", "Na pewno wyczyścić dynamiczne turfy?", "TAK", "NIE")
	if(answer != "TAK")
		return
	message_admins("<span class='adminnotice'>[key_name_admin(src)] czyści dynamiczną przestrzeń tranzytową.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Clear Dynamic Transit") // If...
	log_admin("[key_name(src)] cleared dynamic transit space.")
	SSmapping.wipe_reservations()				//this goes after it's logged, incase something horrible happens.

/client/proc/fucky_wucky()
	set category = "Debug"
	set name = "Fucky Wucky"
	set desc = "Poinformuj graczy, że małpki od kodu w naszej centrali bardzo ciężko pracują nad naprawą."

	if(!check_rights(R_DEBUG))
		return
	remove_verb(/client/proc/fucky_wucky)
	message_admins("<span class='adminnotice'>[key_name_admin(src)] robi fucky wucky.</span>")
	log_admin("[key_name(src)] did a fucky wucky.")
	for(var/m in GLOB.player_list)
		var/datum/asset/fuckywucky = get_asset_datum(/datum/asset/simple/fuckywucky)
		fuckywucky.send(m)
		SEND_SOUND(m, 'sound/misc/fuckywucky.ogg')
		to_chat(m, "<img src='[SSassets.transport.get_asset_url("fuckywucky.png")]'>")

	addtimer(CALLBACK(src, PROC_REF(restore_fucky_wucky)), 600)

/client/proc/restore_fucky_wucky()
	add_verb(/client/proc/fucky_wucky)

/client/proc/toggle_medal_disable()
	set category = "Debug"
	set name = "Toggle Achievement Disable"
	set desc = "Przełącza blokadę łączenia się z serwerem osiągnięć."

	if(!check_rights(R_DEBUG))
		return

	SSachievements.achievements_enabled = !SSachievements.achievements_enabled

	message_admins("<span class='adminnotice'>[key_name_admin(src)] [SSachievements.achievements_enabled ? "wyłącza" : "włącza"] blokadę serwera osiągnięć.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Achievement Disable") // If...
	log_admin("[key_name(src)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the achievement hub lockout.")

/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Otwiera przeglądarkę runtime'ów"

	if(!holder)
		return

	GLOB.error_cache.show_to(src)

/client/proc/pump_random_event()
	set category = "Debug"
	set name = "Pump Random Event"
	set desc = "Każe podsystemowi zdarzeń natychmiast wywołać nowe losowe zdarzenie. Niektóre zdarzenia mogą nastąpić bez powiadomienia."
	if(!holder)
		return

	SSevents.scheduled = world.time

	message_admins("<span class='adminnotice'>[key_name_admin(src)] wywołuje losowe zdarzenie.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Pump Random Event")
	log_admin("[key_name(src)] pumped a random event.")

/client/proc/start_line_profiling()
	set category = "Profile"
	set name = "Start Line Profiling"
	set desc = "Zaczyna profilowanie linia po linii dla linii kodu, które to obsługują"

	LINE_PROFILE_START

	message_admins("<span class='adminnotice'>[key_name_admin(src)] zaczyna profilowanie linia po linii.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Line Profiling")
	log_admin("[key_name(src)] started line by line profiling.")

/client/proc/stop_line_profiling()
	set category = "Profile"
	set name = "Stops Line Profiling"
	set desc = "Kończy profilowanie linia po linii dla linii kodu, które to obsługują"

	LINE_PROFILE_STOP

	message_admins("<span class='adminnotice'>[key_name_admin(src)] kończy profilowanie linia po linii.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stop Line Profiling")
	log_admin("[key_name(src)] stopped line by line profiling.")

/client/proc/show_line_profiling()
	set category = "Profile"
	set name = "Show Line Profiling"
	set desc = "Pokazuje dane z profilowania linii kodu, które to obsługują"

	var/sortlist = list(
		"Średni czas"		=	/proc/cmp_profile_avg_time_dsc,
		"Czas łączny"	=	/proc/cmp_profile_time_dsc,
		"Liczba wywołań"	=	/proc/cmp_profile_count_dsc
	)
	var/sort = input(src, "Sortowanie?", "Rodzaj sortowania", "Średni czas") as null|anything in sortlist
	if (!sort)
		return
	sort = sortlist[sort]
	profile_show(src, sort)

/client/proc/reload_configuration()
	set category = "Server"
	set name = "Reload Configuration"
	set desc = "Wymusza ponowne wczytanie domyślnej konfiguracji"
	if(!check_rights(R_DEBUG))
		return
	if(alert(usr, "Na pewno chcesz wczytać konfigurację z domyślnej ścieżki na dysku, kasując wszystkie zmiany z tej rundy?", "Na pewno zresetować?", "Nie", "Tak") == "Tak")
		//Reload the config
		config.admin_reload()
		//Reload badges
		load_badge_ranks()

/client/proc/modify_canister_gas(obj/machinery/portable_atmospherics/canister/C)
	if(!check_rights(R_DEBUG) || !C)
		return

	var/gas_to_add = input(usr, "Wybierz gaz do zmiany.", "Wybierz gaz.") as null|anything in GLOB.gas_data.ids
	var/amount = input(usr, "Podaj liczbę moli.", "Podaj ilość.", 0) as num
	var/temp = input(usr, "Podaj temperaturę (w kelwinach).", "Podaj temperaturę (K).", 0) as num


	C.air_contents.set_moles(gas_to_add, amount)
	C.air_contents.set_temperature(temp)
	C.update_icon()

	message_admins("<span class='adminnotice'>[key_name_admin(src)] zmienia zawartość: [C.name] w [AREACOORD(C)] - gaz: [gas_to_add], mole: [amount], temp.: [temp].</span>")
	log_admin("[key_name_admin(src)] modified \the [C.name] at [AREACOORD(C)] - Gas: [gas_to_add], Moles: [amount], Temp: [temp].")

/client/proc/give_all_spells()
	set category = "Debug"
	set name = "Give all spells"
	if(!check_rights(R_DEBUG))
		return
	for(var/type in GLOB.spells)
		var/obj/effect/proc_holder/spell/spell = new type
		mob.AddSpell(spell)

/// A debug verb to check the sources of currently running timers
/client/proc/check_timer_sources()
	set category = "Debug"
	set name = "Check Timer Sources"
	set desc = "Sprawdza źródła działających timerów"
	if (!check_rights(R_DEBUG))
		return

	var/bucket_list_output = generate_timer_source_output(SStimer.bucket_list)
	var/second_queue = generate_timer_source_output(SStimer.second_queue)

	var/datum/browser/browser = new(usr, "check_timer_sources", "Źródła timerów", 700, 700)
	browser.set_content({"
		<h3>bucket_list</h3>
		[bucket_list_output]

		<h3>second_queue</h3>
		[second_queue]
	"})
	browser.open()

/proc/generate_timer_source_output(list/datum/timedevent/events)
	var/list/per_source = list()

	// Collate all events and figure out what sources are creating the most
	for (var/_event in events)
		if (!_event)
			continue
		var/datum/timedevent/event = _event

		do
			if (event.source)
				if (per_source[event.source] == null)
					per_source[event.source] = 1
				else
					per_source[event.source] += 1
			event = event.next
		while (event && event != _event)

	// Now, sort them in order
	var/list/sorted = list()
	for (var/source in per_source)
		sorted += list(list("source" = source, "count" = per_source[source]))
	sorted = sortTim(sorted, PROC_REF(cmp_timer_data))

	// Now that everything is sorted, compile them into an HTML output
	var/output = "<table border='1'>"

	for (var/_timer_data in sorted)
		var/list/timer_data = _timer_data
		output += {"<tr>
			<td><b>[timer_data["source"]]</b></td>
			<td>[timer_data["count"]]</td>
		</tr>"}

	output += "</table>"

	return output

/proc/cmp_timer_data(list/a, list/b)
	return b["count"] - a["count"]

/*
 * Test Luminosity Changes vs Dview
 *
 * A simple debug verb that rapidly changes you current turf's
 * luminosity value and runs view() to test the performance
 * compared to dview()
*/
/client/proc/test_dview_to_lum_changes()
	set category = "Debug"
	set name = "Test Lum Changes"
	set desc = "Wielokrotnie zmienia jasność twojego turfa, by zmierzyć, ile to trwa"
	//Check if the user running this verb has sufficient privellages
	if (!check_rights(R_DEBUG))
		return
	//Get the turf of the user
	var/turf/T = get_turf(usr)
	//if the current turf is null, don't act
	if(!T)
		return

	//Count the total of view
	var/total_dview = 0
	var/total_lum = 0

	//Get the timer of the world
	var/timer_dview = TICK_USAGE
	//Run the DVIEW test
	for(var/i in 1 to 10000)
		var/list/L = dview(6, T)
		total_dview += length(L)
	//Get the results of the dview test
	var/total_time_dview = TICK_USAGE_TO_MS(timer_dview)

	//Get the timer of the world
	var/timer_lum_changes = TICK_USAGE
	//Run the LUM CHANGES test
	for(var/i in 1 to 10000)
		T.luminosity = 6
		var/list/L = view(6, T)
		total_lum += length(L)
		T.luminosity = 1
	//Get the result of the lum change test
	var/total_time_lum = TICK_USAGE_TO_MS(timer_lum_changes)

	//Print the results
	to_chat(usr, "<span class='notice'>10000 wywołań dview dało narzut [total_time_dview]ms. (znalezione obiekty: [total_dview])</span>")
	to_chat(usr, "<span class='notice'>10000 zmian jasności dało narzut [total_time_lum]ms. (znalezione obiekty: [total_lum])</span>")
