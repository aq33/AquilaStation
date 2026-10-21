// TODO:
//	- Potentially roll HUDs and Records into one
//	- Shock collar/lock system for prisoner pAIs?
//  - Put cable in user's hand instead of on the ground
//  - Camera jack


/mob/living/silicon/pai/var/list/available_software = list(
															//Nightvision
															//T-Ray
															//radiation eyes
															//chem goggs
															//mesons
															"crew manifest" = 5,
															"digital messenger" = 5,
															"atmosphere sensor" = 5,
															"photography module" = 5,
															"remote signaller" = 10,
															"medical records" = 10,
															"security records" = 10,
															"camera zoom" = 10,
															"host scan" = 10,
															//"camera jack" = 10,
															//"heartbeat sensor" = 10,
															//"projection array" = 15,
															"medical HUD" = 20,
															"security HUD" = 20,
															"loudness booster" = 20,
															"newscaster" = 20,
															"door jack" = 25,
															"encryption keys" = 25,
															"universal translator" = 35
															)

/// Opens the pAI software interface (TGUI "PaiInterface")
/mob/living/silicon/pai/proc/paiInterface()
	ui_interact(src)

/mob/living/silicon/pai/ui_state(mob/user)
	return GLOB.self_state

/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface")
		ui.open()
		ui.set_autoupdate(TRUE)

/mob/living/silicon/pai/ui_static_data(mob/user)
	var/list/data = list()
	data["available"] = available_software
	return data

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["dead"] = (stat == DEAD)
	data["installed"] = software
	data["ram"] = ram
	data["master_name"] = master
	data["master_dna"] = master_dna
	data["directives"] = laws?.supplied
	data["prime_directive"] = laws?.zeroth
	data["med_hud"] = medHUD
	data["sec_hud"] = secHUD
	data["encryption_keys"] = encryptmod
	var/datum/language_holder/holder = get_language_holder()
	data["languages"] = holder?.omnitongue
	// Door jack
	var/door_jack = null
	if(cable)
		door_jack = cable.machine ? "connected" : "extended"
	data["door_jack"] = door_jack
	data["door_jack_compatible"] = istype(cable?.machine, /obj/machinery/door)
	data["hacking"] = hacking
	data["hack_progress"] = hackprogress
	// Remote signaller
	if(signaler)
		data["signaler_frequency"] = signaler.frequency
		data["signaler_code"] = signaler.code
		data["signaler_min_freq"] = MIN_FREE_FREQ
		data["signaler_max_freq"] = MAX_FREE_FREQ
	// Atmosphere sensor
	if(software.Find("atmosphere sensor"))
		data["atmos"] = get_atmos_ui_data()
	// Records
	data["records_type"] = records_view
	if(records_view == "medical" && software.Find("medical records"))
		data["records"] = get_records_ui_data(GLOB.data_core.medical, list("blood_type", "b_dna", "mi_dis", "mi_dis_d", "ma_dis", "ma_dis_d", "alg", "alg_d", "cdi", "cdi_d", "notes"))
	else if(records_view == "security" && software.Find("security records"))
		data["records"] = get_records_ui_data(GLOB.data_core.security, list("criminal", "crim", "crim_d", "notes"))
	return data

/// Odczyt atmosfery dla czujnika atmosfery
/mob/living/silicon/pai/proc/get_atmos_ui_data()
	var/turf/T = get_turf(loc)
	if(isnull(T))
		return null
	var/datum/gas_mixture/environment = T.return_air()
	if(!environment)
		return null
	var/list/atmos = list()
	atmos["pressure"] = round(environment.return_pressure(), 0.1)
	atmos["temperature"] = round(environment.return_temperature() - T0C)
	var/list/gases = list()
	var/total_moles = environment.total_moles()
	if(total_moles)
		for(var/id in environment.get_gases())
			var/gas_level = environment.get_moles(id) / total_moles
			if(gas_level > 0.01)
				gases += list(list("name" = GLOB.gas_data.names[id], "percent" = round(gas_level * 100)))
	atmos["gases"] = gases
	return atmos

/// Akta załogi dla oprogramowania akt medycznych i akt ochrony
/mob/living/silicon/pai/proc/get_records_ui_data(list/detail_records, list/detail_fields)
	var/list/records = list()
	if(!GLOB.data_core.general)
		return records
	for(var/datum/data/record/general in sortRecord(GLOB.data_core.general))
		var/list/fields = list(
			"id" = general.fields["id"],
			"name" = general.fields["name"],
			"rank" = general.fields["rank"],
			"gender" = general.fields["gender"],
			"age" = general.fields["age"],
			"fingerprint" = general.fields["fingerprint"],
			"p_stat" = general.fields["p_stat"],
			"m_stat" = general.fields["m_stat"],
		)
		var/datum/data/record/detail = find_record("id", general.fields["id"], detail_records)
		if(detail)
			for(var/field in detail_fields)
				fields[field] = detail.fields[field]
		records += list(fields)
	return records

/mob/living/silicon/pai/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(stat == DEAD)
		return
	switch(action)
		if("buy")
			var/target = params["selection"]
			if(!available_software.Find(target) || software.Find(target))
				return
			var/cost = available_software[target]
			if(ram < cost)
				to_chat(src, "<span class='warning'>Za mało dostępnej pamięci RAM.</span>")
				return
			software.Add(target)
			ram -= cost
			var/datum/hud/pai/pAIhud = hud_used
			pAIhud?.update_software_buttons()
			return TRUE
		if("check_dna")
			if(iscarbon(card.loc))
				CheckDNA(card.loc, src) //you should only be able to check when directly in hand, muh immersions?
			else
				to_chat(src, "<span class='warning'>Nikt cię nie niesie!</span>")
			return TRUE
		if("change_image")
			change_card_image()
			return TRUE
		if("radio")
			radio.attack_self(src)
			return TRUE
		if("software")
			var/selection = params["software"]
			if(!software.Find(selection))
				return
			use_software(selection, params["mode"], params["value"])
			return TRUE

/// Wybór obrazu wyświetlacza karty pAI
/mob/living/silicon/pai/proc/change_card_image()
	var/newImage = input(src, "Wybierz nowy obraz wyświetlacza.", "Obraz wyświetlacza", "Happy") as null|anything in sortList(list("Happy", "Cat", "Extremely Happy", "Face", "Laugh", "Off", "Sad", "Angry", "What", "Sunglasses"))
	if(!newImage || !card)
		return
	var/pID = 1
	switch(newImage)
		if("Happy")
			pID = 1
		if("Cat")
			pID = 2
		if("Extremely Happy")
			pID = 3
		if("Face")
			pID = 4
		if("Laugh")
			pID = 5
		if("Off")
			pID = 6
		if("Sad")
			pID = 7
		if("Angry")
			pID = 8
		if("What")
			pID = 9
		if("Null")
			pID = 10
		if("Sunglasses")
			pID = 11
	card.setEmotion(pID)

/// Obsługa przycisków zainstalowanego oprogramowania w PaiInterface
/mob/living/silicon/pai/proc/use_software(selection, mode, value)
	switch(selection)
		if("crew manifest")
			ai_roster()
		if("digital messenger")
			if(!modularInterface || !modularInterface.turn_on(src, open_ui = FALSE))
				return
			var/obj/item/computer_hardware/hard_drive/drive = modularInterface.all_components[MC_HDD]
			for(var/datum/computer_file/program/messenger/app in drive?.stored_files)
				modularInterface.open_program(src, app)
				modularInterface.interact(src)
				break
		if("atmosphere sensor")
			var/turf/T = get_turf(loc)
			if(T)
				atmosanalyzer_scan(src, T)
		if("photography module")
			switch(mode)
				if("camera")
					aicamera.toggle_camera_mode(src)
				if("printer")
					aicamera.viewpictures(src)
		if("camera zoom")
			aicamera.adjust_zoom(src)
		if("remote signaller")
			switch(mode)
				if("send")
					signaler.send_activation()
					audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*")
					playsound(src, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
				if("freq")
					var/new_frequency = text2num("[value]")
					if(!isnum_safe(new_frequency))
						return
					new_frequency = round(new_frequency)
					if(new_frequency < MIN_FREE_FREQ || new_frequency > MAX_FREE_FREQ)
						new_frequency = sanitize_frequency(new_frequency)
					signaler.set_frequency(new_frequency)
				if("code")
					var/new_code = text2num("[value]")
					if(!isnum_safe(new_code))
						return
					signaler.code = clamp(round(new_code), 1, 100)
		if("medical records")
			records_view = (records_view == "medical") ? null : "medical"
		if("security records")
			records_view = (records_view == "security") ? null : "security"
		if("host scan")
			switch(mode)
				if("target")
					if(iscarbon(card.loc))
						hostscan.attack(card.loc, src)
					else
						to_chat(src, "<span class='warning'>Nikt cię nie niesie!</span>")
				if("mode")
					hostscan.attack_self(src)
		if("medical HUD")
			medHUD = !medHUD
			var/datum/atom_hud/med = GLOB.huds[med_hud]
			if(medHUD)
				med.add_hud_to(src)
			else
				med.remove_hud_from(src)
		if("security HUD")
			secHUD = !secHUD
			var/datum/atom_hud/sec = GLOB.huds[sec_hud]
			if(secHUD)
				sec.add_hud_to(src)
			else
				sec.remove_hud_from(src)
		if("loudness booster")
			if(!internal_instrument)
				internal_instrument = new(src)
			internal_instrument.interact(src)
		if("newscaster")
			newscaster.ui_interact(src)
		if("door jack")
			switch(mode)
				if("cable")
					if(cable)
						return
					var/turf/T = get_turf(loc)
					cable = new /obj/item/pai_cable(T)
					T.visible_message("<span class='warning'>W [src] otwiera się port, z którego wysuwa się [cable] i od razu spada na podłogę.</span>", "<span class='italics'>Słyszysz ciche kliknięcie czegoś lekkiego i twardego spadającego na ziemię.</span>")
				if("hack")
					if(istype(cable?.machine, /obj/machinery/door))
						hackdoor = cable.machine
						hackloop()
				if("cancel")
					hackdoor = null
		if("encryption keys")
			encryptmod = TRUE
		if("universal translator")
			grant_all_languages(TRUE)
				// this is PERMAMENT.

/mob/living/silicon/pai/proc/CheckDNA(mob/living/carbon/M, mob/living/silicon/pai/P)
	if(!istype(M))
		return
	var/answer = input(M, "[P] prosi cię o próbkę DNA. Czy pozwolisz mu potwierdzić twoją tożsamość?", "[P] – sprawdzenie DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		M.visible_message("<span class='notice'>[M] przyciska kciuk do [P].</span>",\
						"<span class='notice'>Przyciskasz kciuk do [P].</span>",\
						"<span class='notice'>[P] wydaje ostre kliknięcie, pobierając materiał DNA od [M].</span>")
		if(!M.has_dna())
			to_chat(P, "<b>Nie wykryto DNA</b>")
			return
		to_chat(P, "<font color = red><h3>Ciąg UE [M]: [M.dna.unique_enzymes]</h3></font>")
		if(M.dna.unique_enzymes == P.master_dna)
			to_chat(P, "<b>DNA zgadza się z zapisanym DNA właściciela.</b>")
		else
			to_chat(P, "<b>DNA nie zgadza się z zapisanym DNA właściciela.</b>")
	else
		to_chat(P, "[M] nie wygląda na kogoś, kto dobrowolnie da próbkę DNA.")

// Door Jack - supporting proc
/mob/living/silicon/pai/proc/hackloop()
	var/turf/T = get_turf(src)
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(T.loc)
			to_chat(AI, "<font color = red><b>Alarm sieciowy: trwa łamanie szyfrowania metodą brute-force w [T.loc].</b></font>")
		else
			to_chat(AI, "<font color = red><b>Alarm sieciowy: trwa łamanie szyfrowania metodą brute-force. Nie można ustalić lokalizacji.</b></font>")
	hacking = TRUE
