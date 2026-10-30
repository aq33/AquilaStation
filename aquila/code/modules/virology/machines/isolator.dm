/// Ile ticków SSmachines zajmuje jedno izolowanie.
#define ISOLATOR_ISOLATION_TICKS 40

/obj/machinery/disease2/isolator
	name = "Pathogenic Isolator"
	desc = "Takes a syringe of blood, and isolates the pathogens inside into a dish."
	density = TRUE
	anchored = TRUE
	icon = 'aquila/icons/virology/virology.dmi'
	icon_state = "isolator"
	var/datum/disease/acute/isolated_disease = null
	var/isolating = 0
	// AQ: w Monke to bylo nietypowane i czytane operatorem : (beaker:reagents)
	var/obj/item/reagent_containers/syringe/beaker = null

/obj/machinery/disease2/isolator/Destroy()
	isolated_disease = null
	if(!QDELETED(beaker))
		beaker.forceMove(drop_location())
	beaker = null
	return ..()

/obj/machinery/disease2/isolator/attackby(obj/item/tool, mob/user, params)
	if(!istype(tool, /obj/item/reagent_containers/syringe))
		return NONE

	if(beaker)
		to_chat(user, span_warning("A syringe is already loaded into the machine."))
		return TRUE
	if(!user.transferItemToLoc(tool, src))
		return TRUE

	beaker = tool
	to_chat(user, span_notice("You add the syringe to the machine."))
	playsound(src, 'sound/machines/click.ogg', vol = 50, vary = TRUE)
	icon_state = "isolator_in"
	SStgui.update_uis(src)
	return TRUE

// AQ: stan sprawdzamy PRZED ..(), bo ..() otwiera juz okno TGUI przez interact()
/obj/machinery/disease2/isolator/attack_hand(mob/user, list/modifiers)
	if(machine_stat & BROKEN)
		to_chat(user, span_warning("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return TRUE
	return ..()

/obj/machinery/disease2/isolator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DiseaseIsolator", "Pathogenic Isolator")
		// AQ: u nas okna TGUI nie odswieżaja sie same, a tu leci postep izolowania
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/disease2/isolator/ui_data(mob/user)
	var/list/data = list()
	data["isolating"] = isolating > 0
	data["progress"] = isolating > 0 ? round(100 * (ISOLATOR_ISOLATION_TICKS - isolating) / ISOLATOR_ISOLATION_TICKS, 1) : 0
	data["beaker"] = beaker?.name
	data["empty"] = beaker ? !beaker.reagents.total_volume : TRUE

	var/list/pathogens = list()
	if(beaker)
		for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
			if(!length(reagent.data) || !("viruses" in reagent.data))
				continue
			// AQ: we krwi siedza tez stare /datum/disease bez uniqueID - pomijamy je
			for(var/datum/disease/acute/pathogen in reagent.data["viruses"])
				pathogens += list(list(
					"id" = pathogen.uniqueID,
					"name" = "[reagent.name]: pathogen #[pathogen.uniqueID]",
				))
	data["pathogens"] = pathogens

	return data

/obj/machinery/disease2/isolator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("eject")
			if(!beaker)
				return TRUE
			beaker.forceMove(drop_location())
			if(Adjacent(user))
				user.put_in_hands(beaker)
			beaker = null
			icon_state = "isolator"
			return TRUE

		if("isolate")
			if(isolating > 0 || !beaker)
				return TRUE
			var/chosen_id = text2num(params["id"])
			if(!isnum(chosen_id))
				return TRUE
			for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
				if(!length(reagent.data) || !("viruses" in reagent.data))
					continue
				for(var/datum/disease/acute/pathogen in virus_copylist(reagent.data["viruses"]))
					if(pathogen.uniqueID != chosen_id)
						continue
					isolated_disease = pathogen
					isolating = ISOLATOR_ISOLATION_TICKS
					icon_state = "isolator_processing"
					return TRUE
			return TRUE

/obj/machinery/disease2/isolator/process()
	if(isolating <= 0)
		return

	isolating -= 1
	if(isolating <= 0)
		if(isolated_disease)
			var/obj/item/weapon/virusdish/dish = new(drop_location())
			dish.contained_virus = isolated_disease.Copy()
			dish.contained_virus.log += "[ROUND_TIME()] <br />Transferred to Virus dish"
			dish.update_icon()
			visible_message(span_notice("\The [src] prints a growth dish."))
		isolated_disease = null
		icon_state = beaker ? "isolator_in" : "isolator"

	SStgui.update_uis(src)

#undef ISOLATOR_ISOLATION_TICKS
