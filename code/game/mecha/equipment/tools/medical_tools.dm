// Sleeper, Medical Beam, and Syringe gun

/obj/item/mecha_parts/mecha_equipment/medical
	mech_flags = EXOSUIT_MODULE_MEDICAL

/obj/item/mecha_parts/mecha_equipment/medical/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/can_attach(obj/mecha/medical/M)
	if(..() && istype(M))
		return 1


/obj/item/mecha_parts/mecha_equipment/medical/attach(obj/mecha/M)
	..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
		return 1

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper
	name = "montowany sleeper"
	desc = "Wyposażenie medycznych egzoszkieletów. Montowany sleeper, który stabilizuje pacjentów i potrafi wstrzykiwać odczynniki z zapasów egzoszkieletu."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	energy_drain = 20
	range = MECHA_MELEE
	equip_cooldown = 20
	var/mob/living/carbon/patient = null
	var/inject_amount = 10
	salvageable = 0

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Exit(atom/movable/O)
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/action(mob/living/carbon/target)
	if(!action_checks(target))
		return
	if(!istype(target))
		return
	if(!patient_insertion_check(target))
		return
	occupant_message("<span class='notice'>Zaczynasz wkładać [target] do [src]...</span>")
	chassis.visible_message("<span class='warning'>[chassis] zaczyna wkładać [target] do [src].</span>")
	if(do_after_cooldown(target))
		if(!patient_insertion_check(target))
			return
		target.forceMove(src)
		patient = target
		START_PROCESSING(SSobj, src)
		update_equip_info()
		occupant_message("<span class='notice'>[target] umieszczony w [src]. Funkcje podtrzymywania życia aktywne.</span>")
		chassis.visible_message("<span class='warning'>[chassis] wkłada [target] do [src].</span>")
		log_message("[target] loaded. Life support functions engaged.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/patient_insertion_check(mob/living/carbon/target)
	if(target.buckled)
		occupant_message("<span class='warning'>[target] nie zmieści się w kapsule, bo jest przypięty do [target.buckled]!</span>")
		return
	if(target.has_buckled_mobs())
		occupant_message("<span class='warning'>[target] nie zmieści się w kapsule z powodu przyczepionych do niego stworzeń!</span>")
		return
	if(patient)
		occupant_message("<span class='warning'>Kapsuła jest już zajęta!</span>")
		return
	return 1

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/go_out()
	if(!patient)
		return
	patient.forceMove(get_turf(src))
	occupant_message("[patient] wyrzucony. Funkcje podtrzymywania życia wyłączone.")
	log_message("[patient] ejected. Life support functions disabled.", LOG_MECHA)
	STOP_PROCESSING(SSobj, src)
	patient = null
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/detach()
	if(patient)
		occupant_message("<span class='warning'>Nie można odłączyć [src] – wyposażenie jest zajęte!</span>")
		return
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/get_equip_info()
	var/output = ..()
	if(output)
		var/temp = ""
		if(patient)
			temp = "<br />\[Pacjent: [patient] ([patient.stat > 1 ? "*ZMARŁY*" : "Zdrowie: [patient.health]%"])\]<br /><a href='byond://?src=[REF(src)];view_stats=1'>Pokaż statystyki</a>|<a href='byond://?src=[REF(src)];eject=1'>Wyrzuć</a>"
		return "[output] [temp]"
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Topic(href,href_list)
	..()
	if(!chassis || usr != chassis.occupant)
		return
	if(href_list["eject"])
		go_out()
	if(href_list["view_stats"])
		ui_interact(usr)
	return

// AQUILA: statystyki pacjenta w oknie TGUI (dawniej okno HTML "msleeper")
/obj/item/mecha_parts/mecha_equipment/medical/sleeper/ui_interact(mob/user, datum/tgui/ui)
	if(!patient)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechaSleeper", "[patient]")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/ui_status(mob/user, datum/ui_state/state)
	if(!chassis || user != chassis.occupant || !patient)
		return UI_CLOSE
	if(user.incapacitated())
		return UI_DISABLED
	return UI_INTERACTIVE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/ui_data(mob/user)
	var/list/data = list()
	if(!patient)
		return data
	data["patient_name"] = "[patient]"
	data["stat"] = patient.stat
	data["health"] = patient.health
	data["body_temperature"] = patient.bodytemperature
	data["brute"] = patient.getBruteLoss()
	data["oxy"] = patient.getOxyLoss()
	data["tox"] = patient.getToxLoss()
	data["burn"] = patient.getFireLoss()
	data["clone"] = !!patient.getCloneLoss()
	data["brain"] = !!patient.getOrganLoss(ORGAN_SLOT_BRAIN)
	data["traumas"] = !!length(patient.get_traumas())
	var/list/blood_reagents = list()
	if(patient.reagents)
		for(var/datum/reagent/R in patient.reagents.reagent_list)
			if(R.volume > 0)
				blood_reagents += list(list("name" = R.name, "volume" = round(R.volume, 0.01)))
	data["reagents"] = blood_reagents
	var/list/available = list()
	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG = locate(/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun) in chassis
	if(SG?.reagents)
		for(var/datum/reagent/R in SG.reagents.reagent_list)
			if(R.volume > 0)
				available += list(list("name" = R.name, "volume" = round(R.volume, 0.01), "ref" = REF(R)))
	data["has_syringe_gun"] = !!SG
	data["available_reagents"] = available
	data["inject_amount"] = inject_amount
	return data

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			go_out()
			return TRUE
		if("inject")
			var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG = locate() in chassis
			if(!SG)
				return
			var/datum/reagent/R = locate(params["ref"]) in SG.reagents.reagent_list
			if(istype(R))
				inject_reagent(R, SG)
			return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/inject_reagent(datum/reagent/R,obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG)
	if(!R || !patient || !SG || !(SG in chassis.equipment))
		return 0
	var/to_inject = min(R.volume, inject_amount)
	if(to_inject && patient.reagents.get_reagent_amount(R.type) + to_inject <= inject_amount*2)
		occupant_message("Wstrzykiwanie [patient] [to_inject] j. [R.name].")
		log_message("Injecting [patient] with [to_inject] units of [R.name].", LOG_MECHA)
		log_combat(chassis.occupant, patient, "injected", "[name] ([R] - [to_inject] units)")
		SG.reagents.trans_id_to(patient,R.type,to_inject)
		update_equip_info()
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/update_equip_info()
	if(..())
		SStgui.update_uis(src)
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/container_resist(mob/living/user)
	go_out()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/process()
	if(..())
		return
	if(!chassis.has_charge(energy_drain))
		set_ready_state(1)
		log_message("Deactivated.", LOG_MECHA)
		occupant_message("[src] dezaktywowany – brak zasilania.")
		STOP_PROCESSING(SSobj, src)
		return
	var/mob/living/carbon/M = patient
	if(!M)
		return
	if(M.health > 0)
		M.adjustOxyLoss(-1)
	M.AdjustStun(-80)
	M.AdjustKnockdown(-80)
	M.AdjustParalyzed(-80)
	M.AdjustImmobilized(-80)
	M.AdjustUnconscious(-80)
	if(M.reagents.get_reagent_amount(/datum/reagent/medicine/epinephrine) < 5)
		M.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)
	chassis.use_power(energy_drain)
	update_equip_info()




///////////////////////////////// Syringe Gun ///////////////////////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	name = "wyrzutnia strzykawek egzoszkieletu"
	desc = "Wyposażenie medycznych egzoszkieletów. Syntezator chemikaliów z wyrzutnią strzykawek. Odczynniki w środku są utrzymywane w stazie, więc nie zachodzą żadne reakcje."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "syringegun"
	var/list/syringes
	var/list/known_reagents
	var/list/processed_reagents
	var/max_syringes = 10
	var/max_volume = 75 //max reagent volume
	var/synth_speed = 5 //[num] reagent units per cycle
	energy_drain = 10
	var/mode = 0 //0 - fire syringe, 1 - analyze reagents.
	range = MECHA_MELEE|MECHA_RANGED
	equip_cooldown = 10

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Initialize(mapload)
	. = ..()
	create_reagents(max_volume, NO_REACT)
	syringes = new
	known_reagents = list(/datum/reagent/medicine/epinephrine="Epinefryna",/datum/reagent/medicine/charcoal="Węgiel aktywowany")
	processed_reagents = new

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/can_attach(obj/mecha/medical/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[<a href=\"byond://?src=[REF(src)];toggle_mode=1\">[mode? "Analizuj" : "Wystrzel"]</a>\]<br />\[Strzykawki: [syringes.len]/[max_syringes] | Odczynniki: [reagents.total_volume]/[reagents.maximum_volume]\]<br /><a href='byond://?src=[REF(src)];show_reagents=1'>Lista odczynników</a>"
	return

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/action(atom/movable/target)
	if(!action_checks(target))
		return
	if(istype(target, /obj/item/reagent_containers/syringe))
		return load_syringe(target)
	if(istype(target, /obj/item/storage))//Loads syringes from boxes
		for(var/obj/item/reagent_containers/syringe/S in target.contents)
			load_syringe(S)
		return
	if(mode)
		return analyze_reagents(target)
	if(!syringes.len)
		occupant_message("<span class=\"alert\">Nie załadowano strzykawek.</span>")
		return
	if(reagents.total_volume<=0)
		occupant_message("<span class=\"alert\">Brak dostępnych odczynników do załadowania strzykawki.</span>")
		return
	var/turf/trg = get_turf(target)
	var/obj/item/reagent_containers/syringe/mechsyringe = syringes[1]
	mechsyringe.forceMove(get_turf(chassis))
	reagents.trans_to(mechsyringe, min(mechsyringe.volume, reagents.total_volume), transfered_by = chassis.occupant)
	syringes -= mechsyringe
	mechsyringe.icon = 'icons/obj/chemical.dmi'
	mechsyringe.icon_state = "syringeproj"
	playsound(chassis, 'sound/items/syringeproj.ogg', 50, 1)
	log_message("Launched [mechsyringe] from [src], targeting [target].", LOG_MECHA)
	var/mob/originaloccupant = chassis.occupant
	spawn(0)
		src = null //if src is deleted, still process the syringe
		for(var/i=0, i<6, i++)
			if(!mechsyringe)
				break
			if(step_towards(mechsyringe,trg))
				var/list/mobs = new
				for(var/mob/living/carbon/M in mechsyringe.loc)
					mobs += M
				var/mob/living/carbon/M = safepick(mobs)
				if(M)
					var/R
					mechsyringe.visible_message("<span class=\"attack\"> Strzykawka trafia [M]!</span>")
					if(M.can_inject(null, 1))
						if(mechsyringe.reagents)
							for(var/datum/reagent/A in mechsyringe.reagents.reagent_list)
								R += "[A.name] ([num2text(A.volume)]"
						mechsyringe.icon_state = initial(mechsyringe.icon_state)
						mechsyringe.icon = initial(mechsyringe.icon)
						mechsyringe.reagents.reaction(M, INJECT)
						mechsyringe.reagents.trans_to(M, mechsyringe.reagents.total_volume, transfered_by = originaloccupant)
						M.take_bodypart_damage(2)
						log_combat(originaloccupant, M, "shot", "syringegun")
					break
				else if(mechsyringe.loc == trg)
					mechsyringe.icon_state = initial(mechsyringe.icon_state)
					mechsyringe.icon = initial(mechsyringe.icon)
					mechsyringe.update_icon()
					break
			else
				mechsyringe.icon_state = initial(mechsyringe.icon_state)
				mechsyringe.icon = initial(mechsyringe.icon)
				mechsyringe.update_icon()
				break
			sleep(1)
	return 1


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Topic(href,href_list)
	..()
	if(!chassis || usr != chassis.occupant)
		return
	if (href_list["toggle_mode"])
		mode = !mode
		update_equip_info()
		return
	if (href_list["show_reagents"])
		ui_interact(usr)
	return

// AQUILA: syntezator odczynników w oknie TGUI (dawniej okno HTML "msyringegun")
/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechaSyringeGun", name)
		ui.open()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/ui_status(mob/user, datum/ui_state/state)
	if(!chassis || user != chassis.occupant)
		return UI_CLOSE
	if(user.incapacitated())
		return UI_DISABLED
	return UI_INTERACTIVE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/ui_data(mob/user)
	var/list/data = list()
	data["mode"] = mode
	data["syringes"] = length(syringes)
	data["max_syringes"] = max_syringes
	data["total_volume"] = round(reagents.total_volume, 0.001)
	data["maximum_volume"] = reagents.maximum_volume
	data["synth_speed"] = synth_speed
	var/list/current = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.volume > 0)
			current += list(list("name" = R.name, "volume" = round(R.volume, 0.001), "id" = "[R.type]"))
	data["reagents"] = current
	var/list/known = list()
	for(var/reagent_id in known_reagents)
		known += list(list("id" = "[reagent_id]", "name" = known_reagents[reagent_id], "processing" = (reagent_id in processed_reagents)))
	data["known_reagents"] = known
	return data

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_mode")
			mode = !mode
			update_equip_info()
			return TRUE
		if("select_reagents")
			var/list/selected = params["reagents"]
			if(!islist(selected))
				return
			processed_reagents.len = 0
			var/m = 0
			var/message
			for(var/reagent_text in selected)
				if(m>=synth_speed)
					break
				var/reagent = text2path(reagent_text)
				if(reagent && (reagent in known_reagents) && !(reagent in processed_reagents))
					message += "[m ? ", " : null][known_reagents[reagent]]"
					processed_reagents += reagent
					m++
			if(processed_reagents.len)
				message += " dodano do produkcji"
				START_PROCESSING(SSobj, src)
				occupant_message(message)
				occupant_message("Rozpoczęto przetwarzanie odczynników.")
				log_message("Reagent processing started.", LOG_MECHA)
			return TRUE
		if("purge_reagent")
			var/reagent = text2path(params["id"])
			if(reagent)
				reagents.del_reagent(reagent)
			return TRUE
		if("purge_all")
			reagents.clear_reagents()
			return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/load_syringe(obj/item/reagent_containers/syringe/S)
	if(syringes.len<max_syringes)
		if(get_dist(src,S) >= 2)
			occupant_message("Strzykawka jest za daleko.")
			return 0
		for(var/obj/structure/D in S.loc)//Basic level check for structures in the way (Like grilles and windows)
			if(!(D.CanPass(S,src.loc)))
				occupant_message("Nie można załadować strzykawki.")
				return 0
		for(var/obj/machinery/door/D in S.loc)//Checks for doors
			if(!(D.CanPass(S,src.loc)))
				occupant_message("Nie można załadować strzykawki.")
				return 0
		S.reagents.trans_to(src, S.reagents.total_volume, transfered_by = chassis.occupant)
		S.forceMove(src)
		syringes += S
		occupant_message("Strzykawka załadowana.")
		update_equip_info()
		return 1
	occupant_message("Komora strzykawek [src] jest pełna.")
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/analyze_reagents(atom/A)
	if(get_dist(src,A) >= 4)
		occupant_message("Obiekt jest za daleko.")
		return 0
	if(!A.reagents || ismob(A))
		occupant_message("<span class=\"alert\">Nie uzyskano informacji o odczynnikach z [A].</span>")
		return 0
	occupant_message("Analiza odczynników...")
	for(var/datum/reagent/R in A.reagents.reagent_list)
		if(!(R.chem_flags & CHEMICAL_NOT_SYNTH) && add_known_reagent(R.type,R.name))
			occupant_message("Odczynnik przeanalizowany, zidentyfikowany jako [R.name] i dodany do bazy danych.")
			SStgui.update_uis(src)
	occupant_message("Analiza zakończona.")
	return 1

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/add_known_reagent(r_id,r_name)
	if(!(r_id in known_reagents))
		known_reagents += r_id
		known_reagents[r_id] = r_name
		return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/update_equip_info()
	if(..())
		SStgui.update_uis(src)
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/on_reagent_change(changetype)
	..()
	update_equip_info()
	return


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/process()
	if(..())
		return
	if(!processed_reagents.len || reagents.total_volume >= reagents.maximum_volume || !chassis.has_charge(energy_drain))
		occupant_message("<span class=\"alert\">Zatrzymano przetwarzanie odczynników.</a>")
		log_message("Reagent processing stopped.", LOG_MECHA)
		STOP_PROCESSING(SSobj, src)
		return
	var/amount = synth_speed / processed_reagents.len
	for(var/reagent in processed_reagents)
		reagents.add_reagent(reagent,amount)
		chassis.use_power(energy_drain)

///////////////////////////////// Medical Beam ///////////////////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
	name = "medyczny miotacz wiązki egzoszkieletu"
	desc = "Wyposażenie medycznych egzoszkieletów. Wytwarza skupioną wiązkę medycznych nanitów."
	icon_state = "mecha_medigun"
	energy_drain = 10
	range = MECHA_MELEE|MECHA_RANGED
	equip_cooldown = 0
	var/obj/item/gun/medbeam/mech/medigun
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 8000, /datum/material/plasma = 3000, /datum/material/gold = 8000, /datum/material/diamond = 2000)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Initialize(mapload)
	. = ..()
	medigun = new(src)


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Destroy()
	qdel(medigun)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/process()
	if(..())
		return
	medigun.process()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/action(atom/target)
	medigun.process_fire(target, loc)


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	medigun.LoseTarget()
	return ..()
