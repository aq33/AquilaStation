/datum/plant_trait/roots/conductive
	name = "Włókna przewodzące"
	desc = "Ten gen sprawia, że korzenie zasilają kable pod rośliną. Działa także przez płyty podłogowe."
	genetic_cost = 1
	scales = "Wytwarzana moc rośnie z mocą cech."
	///Cable charge per sercond
	var/cable_charge = 2500


/datum/plant_trait/roots/conductive/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	START_PROCESSING(SSobj, src)

/datum/plant_trait/roots/conductive/process(delta_time)
	if(SEND_SIGNAL(parent.parent.plant_item.loc, COMSIG_PLANTER_PAUSE_PLANT))
		return
	var/obj/structure/cable/C = locate(/obj/structure/cable) in get_turf(parent.parent.plant_item)
	C?.powernet?.newavail += cable_charge*parent.trait_power*delta_time
