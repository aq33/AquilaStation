// cellular emporium
// The place where changelings go to buy their biological weaponry.

/datum/cellular_emporium
	var/name = "cellular emporium"
	var/datum/antagonist/changeling/changeling

/datum/cellular_emporium/New(my_changeling)
	. = ..()
	changeling = my_changeling

/datum/cellular_emporium/Destroy()
	changeling = null
	. = ..()


/datum/cellular_emporium/ui_state(mob/user)
	return GLOB.always_state

/datum/cellular_emporium/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CellularEmporium", "Komórkowe Emporium")
		ui.open()

/datum/cellular_emporium/ui_data(mob/user)
	var/list/data = list()

	var/can_readapt = changeling.canrespec
	var/genetic_points_remaining = changeling.geneticpoints
	var/absorbed_dna_count = changeling.absorbedcount
	var/true_absorbs = changeling.trueabsorbs

	data["can_readapt"] = can_readapt
	data["genetic_points_remaining"] = genetic_points_remaining
	data["absorbed_dna_count"] = absorbed_dna_count
	data["true_absorbs"] = true_absorbs // AQ EDIT - wymagania wchłonięć w oknie z tg

	var/list/abilities = list()

	for(var/path in changeling.all_powers)
		var/datum/action/changeling/ability = path

		var/dna_cost = initial(ability.dna_cost)
		if(dna_cost <= 0)
			continue

		var/list/AL = list()
		AL["name"] = initial(ability.name)
		AL["desc"] = initial(ability.desc)
		AL["helptext"] = initial(ability.helptext)
		AL["owned"] = changeling.has_sting(ability)
		var/req_dna = initial(ability.req_dna)
		var/req_absorbs = initial(ability.req_absorbs)
		AL["dna_cost"] = dna_cost
		AL["can_purchase"] = ((req_absorbs <= true_absorbs) && (req_dna <= absorbed_dna_count) && (dna_cost <= genetic_points_remaining))
		// AQ EDIT - ikony, wymagania i kategoria dla okna z tg
		AL["req_dna"] = req_dna
		AL["req_absorbs"] = req_absorbs
		AL["chemical_cost"] = initial(ability.chemical_cost)
		AL["icon"] = "[initial(ability.icon_icon)]"
		AL["icon_state"] = initial(ability.button_icon_state)
		AL["bg_icon"] = "[initial(ability.button_icon)]"
		AL["bg_icon_state"] = initial(ability.background_icon_state)
		AL["category"] = ispath(path, /datum/action/changeling/sting) ? "stings" : "abilities"

		abilities += list(AL)

	data["abilities"] = abilities

	return data

/datum/cellular_emporium/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("readapt")
			if(changeling.canrespec)
				changeling.readapt()
				. = TRUE
		if("evolve")
			var/sting_name = params["name"]
			changeling.purchase_power(sting_name)
			. = TRUE

/datum/action/innate/cellular_emporium
	name = "Cellular Emporium"
	icon_icon = 'icons/obj/drinks.dmi'
	button_icon_state = "changelingsting"
	background_icon_state = "bg_changeling"
	var/datum/cellular_emporium/cellular_emporium

/datum/action/innate/cellular_emporium/New(our_target)
	. = ..()
	button.name = name
	if(istype(our_target, /datum/cellular_emporium))
		cellular_emporium = our_target
	else
		CRASH("cellular_emporium action created with non emporium")

/datum/action/innate/cellular_emporium/Activate()
	cellular_emporium.ui_interact(owner)
