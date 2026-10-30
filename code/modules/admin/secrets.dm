GLOBAL_DATUM_INIT(admin_secrets, /datum/admin_secrets, new)

/datum/admin_secrets


/datum/admin_secrets/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_secrets/ui_interact(mob/user, datum/tgui/ui)
	if(!check_rights(0))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin_private("[user.ckey] opened the Secrets panel.")
		ui = new(user, src, "AdminSecretsPanel", "Panel sekretów")
		ui.open()

/datum/admin_secrets/ui_static_data(mob/user)
	/*
	Each command is a list that will be read like [Name, Action(see ui_act)]
	"omg but you could have done it like X"
	But I didn't. This is how I did it. And it works (THIS STOPPED WORKING WITH TGUI 4 PORT!). And it's simple.
	And lets us keep each command entry to one line. Gotta stay compact, yo.
	*/
	var/list/data = list()
	data["Categories"] = list()

	data["Categories"]["Sekrety ogólne"] = list(
		list("Log adminów", "admin_log"),
		list("Log mentorów", "mentor_log"),
		list("Pokaż listę adminów", "show_admins")
		)

	if(check_rights(R_ADMIN,0))
		data["Categories"]["Sekrety adminów"] = list(
			list("Wylecz wszystkie istniejące choroby", "clear_virus"),
			list("Zaszczep na wszystkie istniejące choroby", "delete_virus"),
			list("Lista zamachowców", "list_bombers"),
			list("Pokaż ostatnie sygnalizatory ([length(GLOB.lastsignalers)])", "list_signalers"),
			list("Pokaż ostatnie zmiany praw ([length(GLOB.lawchanges)])", "list_lawchanges"),
			list("Pokaż prawa SI", "showailaws"),
			list("Pokaż tryb gry", "showgm"),
			list("Pokaż manifest załogi", "manifest"),
			list("Lista DNA (krew)", "DNA"),
			list("Lista odcisków palców", "fingerprints"),
			list("Włącz/wyłącz CTF", "ctfbutton"),
			list("Przywróć Thunderdome do stanu domyślnego", "tdomereset"),
			list("Zmień nazwę stacji", "set_name"),
			list("Przywróć nazwę stacji", "reset_name"),
			list("Ustaw tryb zmiany nocnej", "night_shift_set")
			)

		data["Categories"]["Promy"] += list(
			list("Przesuń prom Centrali", "moveferry"),
			list("Przełącz prom przylotów", "togglearrivals"),
			list("Przesuń prom górniczy", "moveminingshuttle"),
			list("Przesuń prom obozu pracy", "movelaborshuttle")
			)

	if(check_rights(R_FUN,0))
		data["Categories"]["Sekrety rozrywkowe"] += list(
			list("Wywołaj epidemię", "virus"),
			list("Zamień wszystkich ludzi w małpy", "monkey"),
			list("Chińskie bajki", "anime"),
			list("Zmień gatunek wszystkich ludzi", "allspecies"),
			list("Zasil wszystkie obszary", "power"),
			list("Odetnij zasilanie wszystkim obszarom", "unpower"),
			list("Naładuj wszystkie SMES-y", "quickpower"),
			list("Tryb potrójnej SI (użyj w lobby)", "tripleAI"),
			list("Masowy antag (każdy jest zdrajcą)", "traitor_all"),
			list("Przyzwij broń", "guns"),
			list("Przyzwij magię", "magic"),
			list("Przyzwij zdarzenia (przełącz)", "events"),
			list("Może zostać tylko jeden!", "onlyone"),
			list("Może zostać tylko jeden! (z opóźnieniem 40 s)", "delayed_onlyone"),
			list("Ogłup wszystkich graczy", "dumbify"),
			list("Zrób ze wszystkich Australijczyków", "aussify"),
			list("Tryb egalitarnej stacji", "eagles"),
			list("Tryb anarchokapitalistycznej stacji", "ancap"),
			list("Zbij wszystkie światła", "blackout"),
			list("Napraw wszystkie światła", "whiteout"),
			list("Podłoga to lawa! (NIEBEZPIECZNE: strasznie słabe)", "floorlava"),
			list("Stwórz własną burzę portali", "customportal"),
			list("Odwróć kierunki ruchu klientów", "flipmovement"),
			list("Wylosuj kierunki ruchu klientów", "randommovement"),
			list("Ustaw ręcznie każdy kierunek ruchu", "custommovement"),
			list("Przywróć domyślne kierunki ruchu", "resetmovement"),
			list("Zmień limit bomb", "changebombcap"),
			list("Masowa purrbacja", "masspurrbation"),
			list("Masowo zdejmij purrbację", "massremovepurrbation"),
			list("Pełna immersja dla wszystkich", "massimmerse"),
			list("Cofnij pełną immersję wszystkich", "unmassimmerse"),
			list("Udostępnij graczom wszystkie zwierzęta", "animalsentience")
			)

	if(check_rights(R_DEBUG,0))
		data["Categories"]["Podwyższony poziom ochrony"] = list(
			list("Ustaw dostęp do wszystkich drzwi technicznych tylko dla inżynierii i aresztu", "maint_access_engiebrig"),
			list("Ustaw dostęp do wszystkich drzwi technicznych tylko dla aresztu", "maint_access_brig"),
			list("Zdejmij limit policjantów", "infinite_sec")
			)

	return data

/datum/admin_secrets/ui_act(action, params)
	var/datum/admins/admin_datum = GLOB.admin_datums[usr.ckey]
	if(!admin_datum) // Should have already been blocked by ui_state, but juuust in case
		message_admins("[usr] wysyła żądanie do panelu sekretów bez wystarczających uprawnień.")
		log_admin_private("[usr] sent a request to interact with the secrets panel without sufficient rights.")
		return
	var/datum/round_event/E
	var/ok = 0
	switch(action)
		if("admin_log")
			var/dat
			for(var/l in GLOB.admin_log)
				dat += "<li>[l]</li>"
			if(!GLOB.admin_log.len)
				dat += "Nikt nic w tej rundzie nie zrobił!"
			var/datum/browser/browser = new(usr, "admin_log", "Logi adminów", 600, 500)
			browser.set_content(dat)
			browser.open()

		if("mentor_log") // hippie start -- access mentor log
			admin_datum.MentorLogSecret() // hippie end

		if("show_admins")
			var/dat
			if(GLOB.admin_datums)
				for(var/ckey in GLOB.admin_datums)
					var/datum/admins/D = GLOB.admin_datums[ckey]
					dat += "[ckey] - [D.rank.name]<br>"
				var/datum/browser/browser = new(usr, "showadmins", "Obecni admini", 600, 500)
				browser.set_content(dat)
				browser.open()

		if("tdomereset")
			if(!check_rights(R_ADMIN))
				return
			var/delete_mobs = alert("Usunąć wszystkie moby?","Potwierdź","Tak","Nie","Anuluj")
			if(delete_mobs == "Anuluj" || !delete_mobs)
				return

			log_admin("[key_name(usr)] reset the thunderdome to default with delete_mobs==[delete_mobs].", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] przywraca Thunderdome do stanu domyślnego (usuwanie mobów: [delete_mobs]).</span>")

			var/area/thunderdome = GLOB.areas_by_type[/area/tdome/arena]
			if(delete_mobs == "Tak")
				for(var/mob/living/mob in thunderdome)
					qdel(mob) //Clear mobs
			for(var/obj/obj in thunderdome)
				if(!istype(obj, /obj/machinery/camera) && !istype(obj, /obj/effect/landmark/arena))
					qdel(obj) //Clear objects

			var/area/template = GLOB.areas_by_type[/area/tdome/arena_source]
			template.copy_contents_to(thunderdome)

		if("clear_virus")

			var/choice = input("Czy na pewno chcesz usunąć wszystkie choroby?") in list("Tak", "Anuluj")
			if(choice == "Tak")
				message_admins("[key_name_admin(usr)] leczy wszystkie choroby.")
				for(var/thing in SSdisease.active_diseases)
					var/datum/disease/D = thing
					D.cure(0)
		if("delete_virus")
			var/choice = input("Czy na pewno chcesz zaszczepić wszystkie choroby?") in list("Tak", "Anuluj")
			if(choice == "Tak")
				message_admins("[key_name_admin(usr)] szczepi na wszystkie choroby.")
				for(var/thing in SSdisease.active_diseases)
					var/datum/disease/D = thing
					D.cure()
		if("set_name")
			if(!check_rights(R_ADMIN))
				return
			var/new_name = capped_input(usr, "Podaj nową nazwę stacji.", "Co?")
			if(!new_name)
				return
			set_station_name(new_name)
			log_admin("[key_name(usr)] renamed the station to \"[new_name]\".")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] zmienia nazwę stacji na: [new_name].</span>")
			priority_announce("[command_name()] zmienia nazwę stacji na \"[new_name]\".", sound = SSstation.announcer.get_rand_alert_sound())
		if("night_shift_set")
			if(!check_rights(R_ADMIN))
				return
			var/val = alert(usr, "Na co chcesz ustawić zmianę nocną? To nadpisze system automatyczny, dopóki nie ustawisz z powrotem trybu automatycznego.", "Zmiana nocna", "Wł.", "Wył.", "Automatycznie")
			switch(val)
				if("Automatycznie")
					if(CONFIG_GET(flag/enable_night_shifts))
						SSnightshift.can_fire = TRUE
						SSnightshift.fire()
					else
						SSnightshift.update_nightshift(FALSE, TRUE)
				if("Wł.")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(TRUE, TRUE)
				if("Wył.")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(FALSE, TRUE)

		if("reset_name")
			if(!check_rights(R_ADMIN))
				return
			var/new_name = new_station_name()
			set_station_name(new_name)
			log_admin("[key_name(usr)] reset the station name.")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] przywraca nazwę stacji.</span>")
			priority_announce("[command_name()] zmienia nazwę stacji na \"[new_name]\".", sound = SSstation.announcer.get_rand_alert_sound())

		if("list_bombers")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Lista zamachowców</B><HR>"
			for(var/l in GLOB.bombers)
				dat += text("[l]<BR>")
			usr << browse(HTML_SKELETON(dat), "window=bombers")

		if("list_signalers")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Ostatnie sygnalizatory ([length(GLOB.lastsignalers)]).</B><HR>"
			for(var/sig in GLOB.lastsignalers)
				dat += "[sig]<BR>"
			usr << browse(HTML_SKELETON(dat), "window=lastsignalers;size=800x500")

		if("list_lawchanges")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Ostatnie zmiany praw ([length(GLOB.lawchanges)]).</B><HR>"
			for(var/sig in GLOB.lawchanges)
				dat += "[sig]<BR>"
			usr << browse(HTML_SKELETON(dat), "window=lawchanges;size=800x500")

		if("moveminingshuttle")
			if(!check_rights(R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Mining Shuttle"))
			if(!SSshuttle.toggleShuttle("mining","mining_home","mining_away"))
				message_admins("[key_name_admin(usr)] przesuwa prom górniczy")
				log_admin("[key_name(usr)] moved the mining shuttle")

		if("movelaborshuttle")
			if(!check_rights(R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Labor Shuttle"))
			if(!SSshuttle.toggleShuttle("laborcamp","laborcamp_home","laborcamp_away"))
				message_admins("[key_name_admin(usr)] przesuwa prom obozu pracy")
				log_admin("[key_name(usr)] moved the labor shuttle")

		if("moveferry")
			if(!check_rights(R_ADMIN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send CentCom Ferry"))
			if(!SSshuttle.toggleShuttle("ferry","ferry_home","ferry_away"))
				message_admins("[key_name_admin(usr)] przesuwa prom Centrali")
				log_admin("[key_name(usr)] moved the CentCom ferry")

		if("togglearrivals")
			if(!check_rights(R_ADMIN))
				return
			var/obj/docking_port/mobile/arrivals/A = SSshuttle.arrivals
			if(A)
				var/new_perma = !A.perma_docked
				A.perma_docked = new_perma
				SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Permadock Arrivals Shuttle", "[new_perma ? "Enabled" : "Disabled"]"))
				message_admins("[key_name_admin(usr)] [new_perma ? "zatrzymuje" : "uruchamia"] prom przylotów")
				log_admin("[key_name(usr)] [new_perma ? "stopped" : "started"] the arrivals shuttle")
			else
				to_chat(usr, "<span class='admin'>Nie ma promu przylotów</span>")
		if("showailaws")
			if(!check_rights(R_ADMIN))
				return
			admin_datum.output_ai_laws()
		if("showgm")
			if(!check_rights(R_ADMIN))
				return
			if(!SSticker.HasRoundStarted())
				alert("Gra jeszcze się nie zaczęła!")
			else if (SSticker.mode)
				alert("Tryb gry to [SSticker.mode.name]")
			else alert("Z jakiegoś powodu jest SSticker, ale nie ma trybu gry")
		if("manifest")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Manifest załogi.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Imię</th><th>Stanowisko</th></tr>"
			for(var/datum/data/record/t in GLOB.data_core.general)
				dat += "<tr><td>[t.fields["name"]]</td><td>[t.fields["rank"]]</td></tr>"
			dat += "</table>"
			usr << browse(HTML_SKELETON(dat), "window=manifest;size=440x410")
		if("DNA")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>DNA z krwi.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Imię</th><th>DNA</th><th>Grupa krwi</th></tr>"
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.blood_type]</td></tr>"
			dat += "</table>"
			usr << browse(HTML_SKELETON(dat), "window=DNA;size=440x410")
		if("fingerprints")
			if(!check_rights(R_ADMIN))
				return
			var/dat = "<B>Odciski palców.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Imię</th><th>Odciski palców</th></tr>"
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[rustg_hash_string(RUSTG_HASH_MD5, H.dna.uni_identity)]</td></tr>"
			dat += "</table>"
			usr << browse(HTML_SKELETON(dat), "window=fingerprints;size=440x410")

		if("monkey")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Monkeyize All Humans"))
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				spawn(0)
					H.monkeyize()
			ok = 1

		if("allspecies")
			if(!check_rights(R_FUN))
				return
			var/result = input(usr, "Wybierz nowy gatunek","Gatunek") as null|anything in GLOB.species_list
			if(result)
				SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Species Change", "[result]"))
				log_admin("[key_name(usr)] turned all humans into [result]", 1)
				message_admins("\blue [key_name_admin(usr)] zmienia gatunek wszystkich ludzi na: [result]")
				var/newtype = GLOB.species_list[result]
				for(var/mob/living/carbon/human/H in GLOB.carbon_list)
					H.set_species(newtype)

		if("tripleAI")
			if(!check_rights(R_FUN))
				return
			usr.client.triple_ai()
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Triple AI"))

		if("power")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All APCs"))
			log_admin("[key_name(usr)] made all areas powered", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] zasila wszystkie obszary</span>")
			power_restore()

		if("unpower")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Depower All APCs"))
			log_admin("[key_name(usr)] made all areas unpowered", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] odcina zasilanie wszystkim obszarom</span>")
			power_failure()

		if("quickpower")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All SMESs"))
			log_admin("[key_name(usr)] made all SMESs powered", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] ładuje wszystkie SMES-y</span>")
			power_restore_quick()

		if("traitor_all")
			if(!check_rights(R_FUN))
				return
			if(!SSticker.HasRoundStarted())
				alert("Gra jeszcze się nie zaczęła!")
				return
			if(!GLOB.admin_objective_list)
				generate_admin_objective_list()
			if(!GLOB.admin_antag_list)
				generate_admin_antag_list()
			//Get Antag Type
			var/default_antag
			var/selected_antag = input("Wybierz typ antagonisty:", "Typ antagonisty", default_antag) as null|anything in GLOB.admin_antag_list
			selected_antag = GLOB.admin_antag_list[selected_antag]
			if(!selected_antag)
				return
			//Get Objective
			var/def_value
			var/selected_type = input("Wybierz typ celu:", "Typ celu", def_value) as null|anything in GLOB.admin_objective_list
			selected_type = GLOB.admin_objective_list[selected_type]
			if(!selected_type)
				return
			var/objective_explanation = new selected_type
			var/datum/objective/new_objective = objective_explanation
			new_objective.admin_edit(usr)
			//Get Percentage
			var/def_percentage
			var/selected_percentage = input("Procent załogi do nawrócenia (0-100):", "Procent antagonistów", def_percentage) as num|null
			if(!selected_percentage)
				return
			selected_percentage = selected_percentage > 100 ? 100 : selected_percentage
			selected_percentage = selected_percentage < 0 ? 0 : selected_percentage
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Antag", "[objective_explanation]"))
			//Pick antags
			var/list/choices = list()
			var/list/chosenPlayers = list()
			for(var/player in GLOB.player_list)
				choices.Add(player)
			var/antagCount = round(GLOB.player_list.len * (selected_percentage / 100) + 0.999)
			for(var/i in 0 to antagCount)
				if(choices.len == 0)
					break
				var/chosenPlayer = pick(choices)
				choices.Remove(chosenPlayer)
				chosenPlayers.Add(chosenPlayer)
			//Make the antags
			for(var/mob/living/H in chosenPlayers)
				if(!(ishuman(H)||istype(H, /mob/living/silicon/)))
					continue
				if(H.stat == DEAD || !H.client || !H.mind || ispAI(H))
					continue
				if(is_special_character(H))
					continue
				var/datum/antagonist/T = new selected_antag()
				T.give_objectives = FALSE
				var/datum/antagonist/A = H.mind.add_antag_datum(T)
				A.objectives = list()
				new_objective.owner = H
				A.objectives += new_objective
				log_objective(A, new_objective.explanation_text, usr)
				var/obj_count = 1
				to_chat(T.owner, "<span class='alertsyndie'>Twoi zleceniodawcy zaktualizowali twoje cele.</span>")
				for(var/objective in A.objectives)
					var/datum/objective/O = objective
					to_chat(T.owner, "<B>Cel #[obj_count]</B>: [O.explanation_text]")
					obj_count++
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] używa sekretu masowego antaga. Cel: [objective_explanation]</span>")
			log_admin("[key_name(usr)] used mass antag secret. Objective is: [objective_explanation]")

		if("changebombcap")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Bomb Cap"))

			var/newBombCap = input(usr,"Jaki ma być nowy limit bomb? (podaj zasięg lekkich obrażeń, czyli trzecią liczbę w zapisie (1,2,3)). Musi być większy niż 4.", "Nowy limit bomb", GLOB.MAX_EX_LIGHT_RANGE) as num|null
			if (!CONFIG_SET(number/bombcap, newBombCap))
				return

			message_admins("<span class='boldannounce'>[key_name_admin(usr)] zmienia limit bomb na [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]</span>")
			log_admin("[key_name(usr)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]")

		if("blackout")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Break All Lights"))
			message_admins("[key_name_admin(usr)] zbija wszystkie światła")
			for(var/obj/machinery/light/L in GLOB.machines)
				L.break_light_tube()

		if("anime")
			if(!check_rights(R_FUN))
				return
			var/animetype = alert("Czy chcesz, by zmieniono ubrania?",,"Tak","Nie","Anuluj")

			var/droptype
			if(animetype =="Tak")
				droptype = alert("Uczynić mundury niemożliwymi do zdjęcia?",,"Tak","Nie","Anuluj")

			if(animetype == "Anuluj" || droptype == "Anuluj" || !animetype || (!droptype && animetype == "Tak"))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Chinese Cartoons"))
			message_admins("[key_name_admin(usr)] robi ze wszystkiego kawaii.")
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				SEND_SOUND(H, sound(SSstation.announcer.event_sounds[ANNOUNCER_ANIMES]))

				if(H.dna.species.id == SPECIES_HUMAN)
					if(H.dna.features["tail_human"] == "None" || H.dna.features["ears"] == "None")
						var/obj/item/organ/ears/cat/ears = new
						var/obj/item/organ/tail/cat/tail = new
						ears.Insert(H, drop_if_replaced=FALSE)
						tail.Insert(H, drop_if_replaced=FALSE)
					var/list/honorifics = list("[MALE]" = list("kun"), "[FEMALE]" = list("chan","tan"), "[NEUTER]" = list("san"), "[PLURAL]" = list("san")) //John Robust -> Robust-kun
					var/list/names = splittext(H.real_name," ")
					var/forename = names.len > 1 ? names[2] : names[1]
					var/newname = "[forename]-[pick(honorifics["[H.gender]"])]"
					H.fully_replace_character_name(H.real_name,newname)
					H.update_mutant_bodyparts()
					if(animetype == "Tak")
						var/seifuku = pick(typesof(/obj/item/clothing/under/costume/schoolgirl))
						var/obj/item/clothing/under/costume/schoolgirl/I = new seifuku
						var/olduniform = H.w_uniform
						H.temporarilyRemoveItemFromInventory(H.w_uniform, TRUE, FALSE)
						H.equip_to_slot_or_del(I, ITEM_SLOT_ICLOTHING)
						qdel(olduniform)
						if(droptype == "Tak")
							ADD_TRAIT(I, TRAIT_NODROP, ADMIN_TRAIT)
				else
					to_chat(H, "Nie jesteś wystarczająco kawaii.")

		if("whiteout")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Fix All Lights"))
			message_admins("[key_name_admin(usr)] naprawia wszystkie światła")
			for(var/obj/machinery/light/L in GLOB.machines)
				L.fix()

		if("floorlava")
			SSweather.run_weather(/datum/weather/floor_is_lava)

		if("virus")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Virus Outbreak"))
			switch(alert("Chcesz losową chorobę czy masz coś na myśli?",,"Stwórz własną","Losowa","Wybierz"))
				if("Stwórz własną")
					AdminCreateVirus(usr.client)
				if("Losowa")
					E = new /datum/round_event/disease_outbreak()
				if("Wybierz")
					var/virus = input("Wybierz wirusa do rozprzestrzenienia", "ZAGROŻENIE BIOLOGICZNE") as null|anything in sortList(typesof(/datum/disease, GLOBAL_PROC_REF(cmp_typepaths_asc)))
					E = new /datum/round_event/disease_outbreak{}()
					var/datum/round_event/disease_outbreak/DO = E
					DO.virus_type = virus

		if("dumbify")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Braindamage"))
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				to_chat(H, "<span class='boldannounce'>Nagle czujesz się głupi.</span>")
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60, 80)
			message_admins("[key_name_admin(usr)] ogłupia wszystkich")

		if("aussify") //for rimjobtide
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Australian"))
			var/s = sound('sound/misc/downunder.ogg')
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				to_chat(H, "<span class='boldannounce'>Nagle czujesz się jak kangur.</span>")
				var/matrix/M = H.transform
				H.transform = M.Scale(1,-1) //flip em upside down
				SEND_SOUND(H, s)
			message_admins("[key_name_admin(usr)] robi ze wszystkich Australijczyków")

		if("eagles")//SCRAW
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Egalitarian Station"))
			for(var/obj/machinery/door/airlock/W in GLOB.machines)
				if(is_station_level(W.z) && !istype(get_area(W), /area/bridge) && !istype(get_area(W), /area/crew_quarters) && !istype(get_area(W), /area/security/prison))
					W.req_access = list()
			message_admins("[key_name_admin(usr)] włącza tryb egalitarnej stacji")
			priority_announce("Aktywowano nadpisanie sterowania śluzami przez Centralę. Wykorzystajcie ten czas, by lepiej poznać współpracowników.", null, SSstation.announcer.get_rand_report_sound())

		if("ancap")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Anarcho-capitalist Station"))
			SSeconomy.full_ancap = !SSeconomy.full_ancap
			message_admins("[key_name_admin(usr)] przełącza tryb anarchokapitalistyczny")
			if(SSeconomy.full_ancap)
				priority_announce("NAP obowiązuje teraz w pełni.", null, SSstation.announcer.get_rand_report_sound())
			else
				priority_announce("NAP został odwołany.", null, SSstation.announcer.get_rand_report_sound())




		if("guns")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Guns"))
			var/survivor_probability = 0
			switch(alert("Czy ma to stworzyć antagonistów ocalałych?",,"Bez antagów","Część antagów","Wszyscy antagami!"))
				if("Część antagów")
					survivor_probability = 25
				if("Wszyscy antagami!")
					survivor_probability = 100

			rightandwrong(SUMMON_GUNS, usr, survivor_probability)

		if("magic")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Magic"))
			var/survivor_probability = 0
			switch(alert("Czy ma to stworzyć antagonistów ocalałych?",,"Bez antagów","Część antagów","Wszyscy antagami!"))
				if("Część antagów")
					survivor_probability = 25
				if("Wszyscy antagami!")
					survivor_probability = 100

			rightandwrong(SUMMON_MAGIC, usr, survivor_probability)

		if("events")
			if(!check_rights(R_FUN))
				return
			if(!SSevents.wizardmode)
				if(alert("Czy chcesz włączyć przyzywanie zdarzeń?",,"Tak","Nie") == "Tak")
					summonevents()
					SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Activate"))

			else
				switch(alert("Co chcesz zrobić?",,"Nasil przyzywanie zdarzeń","Wyłącz przyzywanie zdarzeń","Nic"))
					if("Nasil przyzywanie zdarzeń")
						summonevents()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Intensify"))
					if("Wyłącz przyzywanie zdarzeń")
						SSevents.toggleWizardmode()
						SSevents.resetFrequency()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Disable"))

		if("dorf")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Dwarf Beards"))
			for(var/mob/living/carbon/human/B in GLOB.carbon_list)
				B.facial_hair_style = "Dward Beard"
				B.update_hair()
			message_admins("[key_name_admin(usr)] włącza tryb krasnoludów")

		if("onlyone")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
			usr.client.only_one()
			sound_to_playing_players('sound/misc/highlander.ogg')

		if("delayed_onlyone")
			if(!check_rights(R_FUN))
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
			usr.client.only_one_delayed()
			sound_to_playing_players('sound/misc/highlander_delayed.ogg')

		if("maint_access_brig")
			if(!check_rights(R_DEBUG))
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list(ACCESS_BRIG)
			message_admins("[key_name_admin(usr)] ustawia wszystkie drzwi techniczne tylko na dostęp aresztu.")
		if("maint_access_engiebrig")
			if(!check_rights(R_DEBUG))
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list()
					M.req_one_access = list(ACCESS_BRIG,ACCESS_ENGINE)
			message_admins("[key_name_admin(usr)] ustawia wszystkie drzwi techniczne tylko na dostęp inżynierii i aresztu.")
		if("infinite_sec")
			if(!check_rights(R_DEBUG))
				return
			var/datum/job/J = SSjob.GetJob(JOB_NAME_SECURITYOFFICER)
			if(!J)
				return
			J.total_positions = -1
			J.spawn_positions = -1
			message_admins("[key_name_admin(usr)] zdejmuje limit policjantów.")

		if("ctfbutton")
			if(!check_rights(R_ADMIN))
				return
			toggle_all_ctf(usr)
		if("masspurrbation")
			if(!check_rights(R_FUN))
				return
			mass_purrbation()
			message_admins("[key_name_admin(usr)] daje wszystkim \
				purrbację!")
			log_admin("[key_name(usr)] has put everyone on purrbation.")
		if("massremovepurrbation")
			if(!check_rights(R_FUN))
				return
			mass_remove_purrbation()
			message_admins("[key_name_admin(usr)] zdejmuje wszystkim \
				purrbację.")
			log_admin("[key_name(usr)] has removed everyone from purrbation.")

		if("massimmerse")
			if(!check_rights(R_FUN))
				return
			mass_immerse()
			message_admins("[key_name_admin(usr)] daje wszystkim \
				pełną immersję!")
			log_admin("[key_name(usr)] has Fully Immersed everyone.")
		if("unmassimmerse")
			if(!check_rights(R_FUN))
				return
			mass_immerse(remove=TRUE)
			message_admins("[key_name_admin(usr)] cofa wszystkim \
				pełną immersję!")
			log_admin("[key_name(usr)] has Un-Fully Immersed everyone.")
		if("animalsentience")
			for(var/mob/living/simple_animal/L in GLOB.alive_mob_list)
				var/turf/T = get_turf(L)
				if(!T || !is_station_level(T.z))
					continue
				if((L in GLOB.player_list) || L.mind || (L.flags_1 & HOLOGRAM_1))
					continue
				L.set_playable(ROLE_SENTIENT_ANIMAL)

		if("flipmovement")
			if(!check_rights(R_FUN))
				return
			if(alert("Odwrócić wszystkie sterowanie ruchem?","Potwierdź","Tak","Anuluj") != "Tak")
				return
			var/list/movement_keys = SSinput.movement_keys
			for(var/i in 1 to movement_keys.len)
				var/key = movement_keys[i]
				movement_keys[key] = turn(movement_keys[key], 180)
			message_admins("[key_name_admin(usr)] odwraca wszystkie kierunki ruchu.")
			log_admin("[key_name(usr)] has flipped all movement directions.")

		if("randommovement")
			if(!check_rights(R_FUN))
				return
			if(alert("Wylosować całe sterowanie ruchem?","Potwierdź","Tak","Anuluj") != "Tak")
				return
			var/list/movement_keys = SSinput.movement_keys
			for(var/i in 1 to movement_keys.len)
				var/key = movement_keys[i]
				movement_keys[key] = turn(movement_keys[key], 45 * rand(1, 8))
			message_admins("[key_name_admin(usr)] losuje wszystkie kierunki ruchu.")
			log_admin("[key_name(usr)] has randomized all movement directions.")

		if("custommovement")
			if(!check_rights(R_FUN))
				return
			if(alert("Czy na pewno chcesz zmienić każdy klawisz ruchu?","Potwierdź","Tak","Anuluj") != "Tak")
				return
			var/list/movement_keys = SSinput.movement_keys
			var/list/new_movement = list()
			for(var/i in 1 to movement_keys.len)
				var/key = movement_keys[i]

				var/msg = "Podaj nowy kierunek ruchu po naciśnięciu [key]. Np. northeast"
				var/title = "Nowy kierunek dla [key]"
				var/new_direction = text2dir(capped_input(usr, msg, title))
				if(!new_direction)
					new_direction = movement_keys[key]

				new_movement[key] = new_direction
			SSinput.movement_keys = new_movement
			message_admins("[key_name_admin(usr)] ustawia wszystkie kierunki ruchu.")
			log_admin("[key_name(usr)] has configured all movement directions.")

		if("resetmovement")
			if(!check_rights(R_FUN))
				return
			if(alert("Czy na pewno chcesz przywrócić domyślne klawisze ruchu?","Potwierdź","Tak","Anuluj") != "Tak")
				return
			SSinput.setup_default_movement_keys()
			message_admins("[key_name_admin(usr)] przywraca domyślne klawisze ruchu.")
			log_admin("[key_name(usr)] has reset all movement keys.")

		if("customportal")
			if(!check_rights(R_FUN))
				return

			var/list/settings = list(
				"mainsettings" = list(
					"typepath" = list("desc" = "Ścieżka do stworzenia", "type" = "datum", "path" = "/mob/living", "subtypesonly" = TRUE, "value" = /mob/living/simple_animal/hostile/poison/bees),
					"humanoutfit" = list("desc" = "Strój, jeśli człowiek", "type" = "datum", "path" = "/datum/outfit", "subtypesonly" = TRUE, "value" = /datum/outfit),
					"amount" = list("desc" = "Liczba na portal", "type" = "number", "value" = 1),
					"portalnum" = list("desc" = "Łączna liczba portali", "type" = "number", "value" = 10),
					"offerghosts" = list("desc" = "Daj duchom sterować mobami", "type" = "boolean", "value" = "No"),
					"minplayers" = list("desc" = "Minimalna liczba duchów", "type" = "number", "value" = 1),
					"playersonly" = list("desc" = "Twórz tylko moby sterowane przez duchy", "type" = "boolean", "value" = "No"),
					"ghostpoll" = list("desc" = "Pytanie do duchów", "type" = "string", "value" = "Czy chcesz zagrać jako najeźdźca z portalu (%TYPE%)?"),
					"delay" = list("desc" = "Czas między portalami w decysekundach", "type" = "number", "value" = 50),
					"color" = list("desc" = "Kolor portalu", "type" = "color", "value" = "#00FF00"),
					"playlightning" = list("desc" = "Odtwórz dźwięki piorunów przy ogłoszeniu", "type" = "boolean", "value" = "Yes"),
					"announce_players" = list("desc" = "Wygłoś ogłoszenie", "type" = "boolean", "value" = "Yes"),
					"announcement" = list("desc" = "Ogłoszenie", "type" = "string", "value" = "Wykryto potężną anomalię bluespace zmierzającą ku %STATION%. Przygotujcie się na uderzenie."),
				)
			)

			message_admins("[key_name(usr)] tworzy własną burzę portali...")
			var/list/prefreturn = presentpreflikepicker(usr,"Ustawienia burzy portali", "Ustawienia burzy portali", Button1="Ok", width = 600, StealFocus = 1,Timeout = 0, settings=settings)

			if (prefreturn["button"] == 1)
				var/list/prefs = settings["mainsettings"]

				if (prefs["amount"]["value"] < 1 || prefs["portalnum"]["value"] < 1)
					to_chat(usr, "Liczba portali i mobów do stworzenia musi wynosić co najmniej 1")
					return

				var/mob/pathToSpawn = prefs["typepath"]["value"]
				if (!ispath(pathToSpawn))
					pathToSpawn = text2path(pathToSpawn)

				if (!ispath(pathToSpawn))
					to_chat(usr, "Nieprawidłowa ścieżka: [pathToSpawn]")
					return

				var/list/candidates = list()

				if (prefs["offerghosts"]["value"] == "Yes")
					candidates = pollGhostCandidates(replacetext(prefs["ghostpoll"]["value"], "%TYPE%", initial(pathToSpawn.name)), BAN_ROLE_ALL_ANTAGONISTS, ignore_category = FALSE)

				if (prefs["playersonly"]["value"] == "Yes" && length(candidates) < prefs["minplayers"]["value"])
					message_admins("Za mało chętnych do burzy portali: minimum to [prefs["minplayers"]["value"]], a zgłosiło się [length(candidates)]")
					return

				if (prefs["announce_players"]["value"] == "Yes")
					portalAnnounce(prefs["announcement"]["value"], (prefs["playlightning"]["value"] == "Yes" ? TRUE : FALSE))

				var/mutable_appearance/storm = mutable_appearance('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball_fast", FLY_LAYER)
				storm.color = prefs["color"]["value"]

				message_admins("[key_name_admin(usr)] tworzy własną burzę portali: portali [prefs["portalnum"]["value"]], z każdego wyjdzie [prefs["amount"]["value"]] × [pathToSpawn]")
				log_admin("[key_name(usr)] has created a customized portal storm that will spawn [prefs["portalnum"]["value"]] portals, each of them spawning [prefs["amount"]["value"]] of [pathToSpawn]")

				var/outfit = prefs["humanoutfit"]["value"]
				if (!ispath(outfit))
					outfit = text2path(outfit)

				for (var/i in 1 to prefs["portalnum"]["value"])
					if (length(candidates)) // if we're spawning players, gotta be a little tricky and also not spawn players on top of NPCs
						var/ghostcandidates = list()
						for (var/j in 1 to min(prefs["amount"]["value"], length(candidates)))
							ghostcandidates += pick_n_take(candidates)
							addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(doPortalSpawn), get_random_station_turf(), pathToSpawn, length(ghostcandidates), storm, ghostcandidates, outfit), i*prefs["delay"]["value"])
					else if (prefs["playersonly"]["value"] != "Yes")
						addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(doPortalSpawn), get_random_station_turf(), pathToSpawn, prefs["amount"]["value"], storm, null, outfit), i*prefs["delay"]["value"])

	if(E)
		E.processing = FALSE
		if(E.announceWhen>0)
			if(alert(usr, "Czy chcesz powiadomić załogę?", "Uwaga", "Tak", "Nie") != "Tak")
				E.announceChance = 0
		E.processing = TRUE
	if (usr)
		log_admin("[key_name(usr)] used secret [action]")
		if (ok)
			to_chat(world, text("<B>[] aktywuje sekret!</B>", usr.key))

/proc/portalAnnounce(announcement, playlightning)
	set waitfor = 0
	if (playlightning)
		sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
		sleep(80)
	priority_announce(replacetext(announcement, "%STATION%", station_name()), sound = SSstation.announcer.get_rand_alert_sound())
	if (playlightning)
		sleep(20)
		sound_to_playing_players('sound/magic/lightningbolt.ogg')

/proc/doPortalSpawn(turf/loc, mobtype, numtospawn, portal_appearance, players, humanoutfit)
	for (var/i in 1 to numtospawn)
		var/mob/spawnedMob = new mobtype(loc)
		if (length(players))
			var/mob/chosen = players[1]
			if (chosen.client)
				chosen.client.prefs.active_character.copy_to(spawnedMob)
				spawnedMob.key = chosen.key
			players -= chosen
		if (ishuman(spawnedMob) && ispath(humanoutfit, /datum/outfit))
			var/mob/living/carbon/human/H = spawnedMob
			H.equipOutfit(humanoutfit)
	var/turf/T = get_step(loc, SOUTHWEST)
	flick_overlay_static(portal_appearance, T, 15)
	playsound(T, 'sound/magic/lightningbolt.ogg', rand(80, 100), 1)
