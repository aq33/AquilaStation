/obj/machinery/computer/curer
	name = "Cure Research Machine"
	desc = "Grows antibodies from a blood sample into a vaccine, and materializes a blood sample out of a growth dish."
	icon_state = "dna"
	/// Ile ticków zostało do końca produkcji szczepionki.
	var/curing = 0
	/// Czy materializator patogenu się jeszcze ładuje.
	var/virusing = FALSE

	var/obj/item/reagent_containers/glass/tube/container = null

/obj/machinery/computer/curer/Destroy()
	if(!QDELETED(container))
		container.forceMove(drop_location())
	container = null
	return ..()

/obj/machinery/computer/curer/attackby(obj/item/tool, mob/user, params)
	if(istype(tool, /obj/item/reagent_containers/glass/tube))
		if(container)
			to_chat(user, span_warning("There is already a container inside \the [src]."))
			return TRUE
		if(!user.transferItemToLoc(tool, src))
			return TRUE
		container = tool
		playsound(src, 'sound/machines/click.ogg', vol = 50, vary = TRUE)
		SStgui.update_uis(src)
		return TRUE

	if(isvirusdish(tool))
		if(virusing)
			to_chat(user, span_warning("The pathogen materializer is still recharging."))
			return TRUE

		var/obj/item/weapon/virusdish/dish = tool
		// AQ: Monke bralo tu viruses z POWIERZCHNI szalki (tool:viruses), nie jej patogen
		if(!istype(dish.contained_virus))
			to_chat(user, span_warning("\The [dish] holds no pathogen."))
			return TRUE

		var/obj/item/reagent_containers/glass/tube/product = new(drop_location())
		var/list/data = list(
			"blood_DNA" = null,
			"blood_type" = get_blood_type(BLOOD_TYPE_O_MINUS),
			"resistances" = null,
			"trace_chem" = null,
			"viruses" = list(dish.contained_virus.Copy()),
			"immunity" = list(),
		)
		product.reagents.add_reagent(/datum/reagent/blood, 30, data)
		virusing = TRUE
		addtimer(VARSET_CALLBACK(src, virusing, FALSE), 2 MINUTES)
		visible_message(span_notice("\The [src] materializes a blood sample."))
		SStgui.update_uis(src)
		return TRUE

	return ..()

/obj/machinery/computer/curer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DiseaseCurer", "Cure Research Machine")
		// AQ: u nas okna TGUI nie odswieżaja sie same, a tu leci produkcja
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/curer/ui_data(mob/user)
	var/list/data = list()
	data["curing"] = curing > 0
	data["virusing"] = virusing
	data["container"] = container?.name
	data["has_blood"] = FALSE

	var/list/antibodies = list()
	if(container)
		var/datum/reagent/blood/blood = locate() in container.reagents.reagent_list
		if(blood)
			data["has_blood"] = TRUE
			// AQ: Monke czytalo tu stara bitflage data["antibodies"]; u nas przeciwciala
			// siedza w data["immunity"] = list(sila, lista antygen -> poziom)
			var/list/blood_data = blood.data
			var/list/immune_system = length(blood_data) ? blood_data["immunity"] : null
			if(length(immune_system) >= 2)
				var/list/levels = immune_system[2]
				for(var/antigen in levels)
					if(levels[antigen] <= 0)
						continue
					antibodies += list(list(
						"name" = "[antigen]",
						"level" = round(levels[antigen], 1),
					))

	data["antibodies"] = antibodies
	return data

/obj/machinery/computer/curer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("antibody")
			if(curing > 0 || !container)
				return TRUE
			var/datum/reagent/blood/blood = locate() in container.reagents.reagent_list
			if(!blood)
				to_chat(user, span_warning("No blood sample detected."))
				return TRUE
			curing = 10
			return TRUE

		if("eject")
			if(!container)
				return TRUE
			container.forceMove(drop_location())
			if(Adjacent(user))
				user.put_in_hands(container)
			container = null
			return TRUE

/obj/machinery/computer/curer/process()
	. = ..()

	if(machine_stat & (NOPOWER|BROKEN))
		return
	use_power(500)

	if(curing <= 0)
		return

	curing -= 1
	if(curing <= 0 && container)
		createcure(container)
	SStgui.update_uis(src)

/obj/machinery/computer/curer/proc/createcure(obj/item/reagent_containers/glass/tube/source)
	var/datum/reagent/blood/blood = locate() in source.reagents.reagent_list
	if(!blood)
		return

	var/obj/item/reagent_containers/glass/tube/product = new(drop_location())
	var/list/data = list()
	var/list/blood_data = blood.data
	var/list/immunity = length(blood_data) ? blood_data["immunity"] : null
	if(length(immunity) >= 2)
		data["antigen"] = immunity[2]

	product.reagents.add_reagent(/datum/reagent/vaccine, 30, data)
	visible_message(span_notice("\The [src] dispenses a vaccine."))
