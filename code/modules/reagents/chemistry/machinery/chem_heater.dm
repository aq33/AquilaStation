// AQ EDIT - podgrzewacz przepisany pod fermichem z tg (tgstation@b3949ec362): bufory pH, podgląd reakcji, grzanie w trakcie reakcji
/obj/machinery/chem_heater
	name = "podgrzewacz chemiczny"
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_heater

	/// The beaker inside this machine
	var/obj/item/reagent_containers/beaker = null
	/// The temperature this heater is trying to acheive
	var/target_temperature = 300
	/// The energy used by the heater to achieve the target temperature
	var/heater_coefficient = 0.05
	/// Is the heater on or off
	var/on = FALSE
	/// How much buffer are we transferig per click
	var/dispense_volume = 1

/obj/machinery/chem_heater/Initialize(mapload)
	. = ..()
	create_reagents(200, NO_REACT)
	//map placed heaters come with a bit of buffer to help get you started (tg: /obj/machinery/chem_heater/withbuffer)
	if(mapload)
		reagents.add_reagent(/datum/reagent/reaction_agent/basic_buffer, 20)
		reagents.add_reagent(/datum/reagent/reaction_agent/acidic_buffer, 20)

/obj/machinery/chem_heater/Destroy()
	if(beaker)
		UnregisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP)
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_heater/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_icon()

/obj/machinery/chem_heater/update_icon()
	if(beaker)
		icon_state = "mixer1b"
	else
		icon_state = "mixer0b"

/obj/machinery/chem_heater/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)
	ui_update()
	return

/**
 * Replace or eject the beaker inside this machine. Returns TRUE on success.
 * Arguments
 * * mob/living/user - the player operating this machine
 * * obj/item/reagent_containers/new_beaker - the new beaker to replace the current one if not null else it will just eject
 */
/obj/machinery/chem_heater/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		if(beaker.reagents)
			UnregisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP)
		beaker.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)
	if(new_beaker)
		beaker = new_beaker
		RegisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP, PROC_REF(on_reaction_step))
	else
		beaker = null
	update_icon()
	return TRUE

/obj/machinery/chem_heater/RefreshParts()
	heater_coefficient = 0.1
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		heater_coefficient *= M.rating

/obj/machinery/chem_heater/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Wyświetlacz stanu pokazuje: podgrzewanie odczynników z szybkością <b>[heater_coefficient*1000]%</b>.</span>"
		if(beaker)
			. += "<span class='notice'>W środku jest zlewka o pojemności [beaker.reagents.maximum_volume] jednostek.</span>"
			if(beaker.reagents.is_reacting)
				. += "<span class='notice'>Jej zawartość właśnie reaguje.</span>"
		. += "<span class='notice'>Bufory: kwaśny [reagents.get_reagent_amount(/datum/reagent/reaction_agent/acidic_buffer)]u, zasadowy [reagents.get_reagent_amount(/datum/reagent/reaction_agent/basic_buffer)]u.</span>"

/**
 * Heats the reagents of the currently inserted beaker only if machine is on & beaker has some reagents inside
 * Arguments
 * * delta_time - passed from process() or from the reaction step signal
 */
/obj/machinery/chem_heater/proc/heat_reagents(delta_time)
	//must be on and beaker must have something inside to heat
	if(!on || (machine_stat & (NOPOWER|BROKEN)) || !beaker || !beaker.reagents.total_volume)
		return FALSE
	//keep constant with the chemical acclimator please
	beaker.reagents.adjust_thermal_energy((target_temperature - beaker.reagents.chem_temp) * heater_coefficient * delta_time * beaker.reagents.heat_capacity())
	return TRUE

/obj/machinery/chem_heater/proc/on_reaction_step(datum/reagents/holder, num_reactions, delta_time)
	SIGNAL_HANDLER
	//adjust temp
	heat_reagents(delta_time)
	ui_update()

/obj/machinery/chem_heater/process(delta_time)
	..()
	//is_reacting is handled in on_reaction_step()
	if(!beaker || beaker.reagents.is_reacting)
		return
	if(heat_reagents(delta_time))
		//create new reactions after temperature adjust
		beaker.reagents.handle_reactions()

/obj/machinery/chem_heater/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I))
		return

	if(default_deconstruction_crowbar(I))
		return

	//droppers and syringes go straight into the beaker
	if(beaker && (istype(I, /obj/item/reagent_containers/dropper) || istype(I, /obj/item/reagent_containers/syringe)))
		var/obj/item/reagent_containers/injector = I
		injector.afterattack(beaker, user, TRUE)
		ui_update()
		return TRUE

	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE //no afterattack
		var/obj/item/reagent_containers/B = I
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>Dodajesz [B] do [src].</span>")
		ui_update()
		update_icon()
		return
	return ..()

/obj/machinery/chem_heater/on_deconstruction()
	replace_beaker()
	return ..()

/obj/machinery/chem_heater/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(on && beaker)
		. = TRUE

/obj/machinery/chem_heater/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/chem_heater/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemHeater")
		ui.open()

/obj/machinery/chem_heater/ui_data(mob/user)
	. = list()
	.["targetTemp"] = target_temperature
	.["isActive"] = on
	.["upgradeLevel"] = heater_coefficient * 10
	var/obj/item/held_item = user.get_active_held_item()
	.["hasBeakerInHand"] = istype(held_item, /obj/item/reagent_containers) && !(held_item.item_flags & ABSTRACT) && held_item.is_open_container()

	var/list/beaker_data = null
	var/chem_temp = 0
	if(beaker)
		beaker_data = list()
		beaker_data["maxVolume"] = beaker.volume
		beaker_data["pH"] = round(beaker.reagents.ph, 0.01)
		beaker_data["currentVolume"] = round(beaker.reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
		var/list/beaker_contents = list()
		for(var/datum/reagent/reagent as anything in beaker.reagents.reagent_list)
			beaker_contents += list(list("name" = reagent.name, "volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING), "purity" = round(reagent.purity, 0.01)))
		beaker_data["contents"] = beaker_contents
		chem_temp = beaker.reagents.chem_temp
	.["beaker"] = beaker_data
	.["currentTemp"] = chem_temp

	var/list/active_reactions = list()
	var/flashing = DISABLE_FLASHING //for use with alertAfter - since there is no alertBefore, I set the after to 0 if true, or to the max value if false
	for(var/datum/equilibrium/equilibrium as anything in beaker?.reagents.reaction_list)
		if(!length(equilibrium.reaction.results))//Incase of no result reactions
			continue
		var/datum/reagents/beaker_reagents = beaker.reagents
		var/datum/reagent/reagent = beaker_reagents.get_reagent(equilibrium.reaction.results[1]) //Reactions are named after their primary products
		if(!reagent)
			continue

		//check for danger levels primirarly overheating
		var/overheat = FALSE
		var/danger = FALSE
		var/purity_alert = 2 //same as flashing
		if(reagent.purity < equilibrium.reaction.purity_min)
			purity_alert = ENABLE_FLASHING//Because 0 is seen as null
			danger = TRUE
		if(flashing != ENABLE_FLASHING)//So that the pH meter flashes for ANY reactions out of optimal
			if(equilibrium.reaction.optimal_ph_min > beaker_reagents.ph || equilibrium.reaction.optimal_ph_max < beaker_reagents.ph)
				flashing = ENABLE_FLASHING
		if(equilibrium.reaction.is_cold_recipe)
			if(equilibrium.reaction.overheat_temp > beaker_reagents.chem_temp && equilibrium.reaction.overheat_temp != NO_OVERHEAT)
				danger = TRUE
				overheat = TRUE
		else
			if(equilibrium.reaction.overheat_temp < beaker_reagents.chem_temp)
				danger = TRUE
				overheat = TRUE

		//create ui data
		active_reactions += list(list(
			"name" = reagent.name,
			"danger" = danger,
			"overheat" = overheat,
			"purityAlert" = purity_alert,
			"quality" = equilibrium.reaction_quality,
			"inverse" = reagent.inverse_chem_val,
			"minPure" = equilibrium.reaction.purity_min,
			"reactedVol" = equilibrium.reacted_vol,
			"targetVol" = round(equilibrium.target_vol, 1)
			))

		//additional data for competitive reactions
		if(equilibrium.reaction.reaction_flags & REACTION_COMPETITIVE) //We have a compeitive reaction - concatenate the results for the different reactions
			for(var/list/entry as anything in active_reactions)
				if(entry["name"] == reagent.name) //If we have multiple reaction methods for the same result - combine them
					entry["reactedVol"] = equilibrium.reacted_vol
					entry["targetVol"] = round(equilibrium.target_vol, 1)//Use the first result reagent to name the reaction detected
					entry["quality"] = (entry["quality"] + equilibrium.reaction_quality) / 2
	.["activeReactions"] = active_reactions

	.["isFlashing"] = flashing
	.["acidicBufferVol"] = round(reagents.get_reagent_amount(/datum/reagent/reaction_agent/acidic_buffer), CHEMICAL_VOLUME_ROUNDING)
	.["basicBufferVol"] = round(reagents.get_reagent_amount(/datum/reagent/reaction_agent/basic_buffer), CHEMICAL_VOLUME_ROUNDING)
	.["dispenseVolume"] = dispense_volume

/obj/machinery/chem_heater/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			return TRUE
		if("temperature")
			var/target = text2num(params["target"])
			if(isnull(target))
				return FALSE
			target_temperature = clamp(target, 0, 1000)
			return TRUE
		if("eject")
			//Eject doesn't turn it off, so you can preheat for beaker swapping
			return replace_beaker(usr)
		if("insert")
			var/obj/item/reagent_containers/container = usr.get_active_held_item()
			if(istype(container) && !(container.item_flags & ABSTRACT) && container.is_open_container() && usr.transferItemToLoc(container, src))
				replace_beaker(usr, container)
			return TRUE
		if("acidBuffer")
			var/target = text2num(params["target"])
			if(!target)
				return FALSE
			return move_buffer(/datum/reagent/reaction_agent/acidic_buffer, target)
		if("basicBuffer")
			var/target = text2num(params["target"])
			if(!target)
				return FALSE
			return move_buffer(/datum/reagent/reaction_agent/basic_buffer, target)
		if("disp_vol")
			var/target = text2num(params["target"])
			if(!target)
				return FALSE
			dispense_volume = clamp(round(target), 1, 10)
			return TRUE

/**
 * Injects either acid/base buffer into the beaker
 * Arguments
 * * datum/reagent/buffer_type - the type of buffer[acid, base] to inject/withdraw
 * * volume - how much to volume to inject -ve values means withdraw
 */
/obj/machinery/chem_heater/proc/move_buffer(datum/reagent/buffer_type, volume)
	//no beaker
	if(!beaker)
		say("Brak zlewki!")
		return FALSE

	//trying to absorb buffer from currently inserted beaker
	if(volume < 0)
		if(!beaker.reagents.has_reagent(buffer_type))
			say("W zlewce nie ma: [initial(buffer_type.name)]! Włóż zlewkę z tym buforem.")
			return FALSE
		beaker.reagents.trans_id_to(src, buffer_type, (reagents.maximum_volume / 2) - reagents.get_reagent_amount(buffer_type))
		return TRUE

	//trying to inject buffer into currently inserted beaker
	reagents.trans_id_to(beaker, buffer_type, dispense_volume)
	return TRUE

/// Port Bee #11899: right click ejects the beaker (Alt-click still works)
/obj/machinery/chem_heater/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	AltClick(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/chem_heater/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_heater/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/// Debug heater with plenty of buffer and upgraded parts (tg: /obj/machinery/chem_heater/debug)
/obj/machinery/chem_heater/debug
	name = "debugowy podgrzewacz chemiczny"
	desc = "Teraz z jeszcze większą ilością buforów!"

/obj/machinery/chem_heater/debug/Initialize(mapload)
	. = ..()
	reagents.maximum_volume = 2000
	reagents.add_reagent(/datum/reagent/reaction_agent/basic_buffer, 1000)
	reagents.add_reagent(/datum/reagent/reaction_agent/acidic_buffer, 1000)
	heater_coefficient = 0.4 //hack way to upgrade
