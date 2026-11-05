/obj/machinery/power/am_control_unit
	name = "jednostka sterująca antymaterią"
	desc = "To urządzenie wstrzykuje antymaterię do podłączonych jednostek osłonowych. Im więcej antymaterii, tym więcej energii. Przykręć je kluczem, by je zainstalować."
	icon = 'icons/obj/machines/antimatter.dmi'
	icon_state = "control"
	anchored = FALSE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 1000

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED

	var/list/obj/machinery/am_shielding/linked_shielding
	var/list/obj/machinery/am_shielding/linked_cores
	var/obj/item/am_containment/fueljar
	var/update_shield_icons = 0
	var/stability = 100
	var/exploding = 0

	var/active = 0//On or not
	var/fuel_injection = 2//How much fuel to inject
	var/shield_icon_delay = 0//delays resetting for a short time
	var/reported_core_efficiency = 0

	var/power_cycle = 0
	var/power_cycle_delay = 4//How many ticks till produce_power is called
	var/stored_core_stability = 0
	var/stored_core_stability_delay = 0

	var/stored_power = 0//Power to deploy per tick


/obj/machinery/power/am_control_unit/Initialize(mapload)
	. = ..()
	linked_shielding = list()
	linked_cores = list()
	investigate_log("has been created.", INVESTIGATE_ENGINES)

/obj/machinery/power/am_control_unit/Destroy()//Perhaps damage and run stability checks rather than just del on the others
	for(var/obj/machinery/am_shielding/AMS in linked_shielding)
		AMS.control_unit = null
		qdel(AMS)
	QDEL_NULL(fueljar)
	investigate_log("has been destroyed.", INVESTIGATE_ENGINES)
	return ..()


/obj/machinery/power/am_control_unit/process()
	if(exploding)
		explosion(get_turf(src),8,12,18,12)
		if(src)
			qdel(src)

	if(update_shield_icons && !shield_icon_delay)
		check_shield_icons()
		update_shield_icons = 0

	if(machine_stat & (NOPOWER|BROKEN) || !active)//can update the icons even without power
		return

	if(!fueljar)//No fuel but we are on, shutdown
		toggle_power()
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
		return

	add_avail(stored_power)

	power_cycle++
	if(power_cycle >= power_cycle_delay)
		produce_power()
		power_cycle = 0

	return


/obj/machinery/power/am_control_unit/proc/produce_power()
	playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
	var/core_power = reported_core_efficiency//Effectively how much fuel we can safely deal with
	if(core_power <= 0)
		return 0//Something is wrong
	var/core_damage = 0
	var/fuel = fueljar.usefuel(fuel_injection)

	stored_power = (fuel/core_power)*fuel*200000
	//Now check if the cores could deal with it safely, this is done after so you can overload for more power if needed, still a bad idea
	if(fuel > (2*core_power))//More fuel has been put in than the current cores can deal with
		if(prob(50))
			core_damage = 1//Small chance of damage
		if((fuel-core_power) > 5)
			core_damage = 5//Now its really starting to overload the cores
		if((fuel-core_power) > 10)
			core_damage = 20//Welp now you did it, they wont stand much of this
		if(core_damage == 0)
			return
		for(var/obj/machinery/am_shielding/AMS in linked_cores)
			AMS.stability -= core_damage
			AMS.check_stability(1)
		playsound(src.loc, 'sound/effects/bang.ogg', 50, 1)
	return


/obj/machinery/power/am_control_unit/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			if(active)
				toggle_power()
			stability -= rand(15,30)
		if(2)
			if(active)
				toggle_power()
			stability -= rand(10,20)

/obj/machinery/power/am_control_unit/blob_act(obj/structure/blob/B)
	stability -= 20
	if(prob(100-stability))//Might infect the rest of the machine
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			AMS.blob_act(B)
		qdel(src)
		return
	check_stability()
	return


/obj/machinery/power/am_control_unit/ex_act(severity, target)
	stability -= (80 - (severity * 20))
	check_stability()
	return


/obj/machinery/power/am_control_unit/bullet_act(obj/item/projectile/Proj)
	. = ..()
	if(Proj.flag != "bullet")
		stability -= Proj.force
		check_stability()


/obj/machinery/power/am_control_unit/power_change()
	..()
	if(machine_stat & NOPOWER)
		if(active)
			toggle_power(1)
		else
			use_power = NO_POWER_USE

	else if(!machine_stat && anchored)
		use_power = IDLE_POWER_USE

	return


/obj/machinery/power/am_control_unit/update_icon()
	if(active)
		icon_state = "control_on"
	else icon_state = "control"
	//No other icons for it atm


/obj/machinery/power/am_control_unit/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		if(!anchored)
			W.play_tool_sound(src, 75)
			user.visible_message("[user.name] mocuje [src.name] do podłogi.", \
				"<span class='notice'>Przykręcasz śruby kotwiczące do podłogi.</span>", \
				"<span class='italics'>Słyszysz grzechotkę.</span>")
			src.anchored = TRUE
			connect_to_network()
		else if(!linked_shielding.len > 0)
			W.play_tool_sound(src, 75)
			user.visible_message("[user.name] odczepia [src.name].", \
				"<span class='notice'>Wykręcasz śruby kotwiczące.</span>", \
				"<span class='italics'>Słyszysz grzechotkę.</span>")
			src.anchored = FALSE
			disconnect_from_network()
		else
			to_chat(user, "<span class='warning'>Po przykręceniu i połączeniu z jednostką osłonową [src.name] nie może zostać przesunięty!</span>")

	else if(istype(W, /obj/item/am_containment))
		if(fueljar)
			to_chat(user, "<span class='warning'>W środku już jest [fueljar]!</span>")
			return

		if(!user.transferItemToLoc(W, src))
			return
		fueljar = W
		user.visible_message("[user.name] ładuje [W.name] do [src.name].", \
				"<span class='notice'>Ładujesz [W.name].</span>", \
				"<span class='italics'>Słyszysz łupnięcie.</span>")
	else
		return ..()


/obj/machinery/power/am_control_unit/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/welder.ogg', 100, 1)
		else
			return
	if(damage >= 20)
		stability -= damage/2
		check_stability()

/obj/machinery/power/am_control_unit/proc/add_shielding(obj/machinery/am_shielding/AMS, AMS_linking = 0)
	if(!istype(AMS))
		return 0
	if(!anchored)
		return 0
	if(!AMS_linking && !AMS.link_control(src))
		return 0
	linked_shielding.Add(AMS)
	update_shield_icons = 1
	return 1


/obj/machinery/power/am_control_unit/proc/remove_shielding(obj/machinery/am_shielding/AMS)
	if(!istype(AMS))
		return 0
	linked_shielding.Remove(AMS)
	update_shield_icons = 2
	if(active)
		toggle_power()
	return 1


/obj/machinery/power/am_control_unit/proc/check_stability()//TODO: make it break when low also might want to add a way to fix it like a part or such that can be replaced
	if(stability <= 0)
		qdel(src)
	return


/obj/machinery/power/am_control_unit/proc/toggle_power(powerfail = 0)
	active = !active
	investigate_log("turned [active ? "ON" : "OFF"] by [usr ? key_name(usr) : "outside forces"] at [AREACOORD(src)]", INVESTIGATE_ENGINES)
	message_admins("Antymateria [active ? "WŁĄCZONA" : "WYŁĄCZONA"] przez [usr ? ADMIN_LOOKUPFLW(usr) : "siły zewnętrzne"] w [ADMIN_VERBOSEJMP(src)]")
	if(active)
		use_power = ACTIVE_POWER_USE
		visible_message("[src.name] się uruchamia.")
	else
		use_power = !powerfail
		visible_message("[src.name] się wyłącza.")
	update_icon()
	return


/obj/machinery/power/am_control_unit/proc/check_shield_icons()//Forces icon_update for all shields
	if(shield_icon_delay)
		return
	shield_icon_delay = 1
	if(update_shield_icons == 2)//2 means to clear everything and rebuild
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			if(AMS.processing)
				AMS.shutdown_core()
			AMS.control_unit = null
			addtimer(CALLBACK(AMS, TYPE_PROC_REF(/obj/machinery/am_shielding, controllerscan)), 10)
		linked_shielding = list()
	else
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			AMS.update_icon()
	addtimer(CALLBACK(src, PROC_REF(reset_shield_icon_delay)), 20)

/obj/machinery/power/am_control_unit/proc/reset_shield_icon_delay()
	shield_icon_delay = 0

/obj/machinery/power/am_control_unit/proc/check_core_stability()
	if(stored_core_stability_delay || linked_cores.len <= 0)
		return
	stored_core_stability_delay = 1
	stored_core_stability = 0
	for(var/obj/machinery/am_shielding/AMS in linked_cores)
		stored_core_stability += AMS.stability
	stored_core_stability/=linked_cores.len
	addtimer(CALLBACK(src, PROC_REF(reset_stored_core_stability_delay)), 40)

/obj/machinery/power/am_control_unit/proc/reset_stored_core_stability_delay()
	stored_core_stability_delay = 0

/obj/machinery/power/am_control_unit/ui_interact(mob/user, datum/tgui/ui)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AntimatterControl", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/power/am_control_unit/ui_data(mob/user)
	var/list/data = list()
	data["active"] = active
	data["stability"] = stability
	data["shielding"] = length(linked_shielding)
	data["cores"] = length(linked_cores)
	data["efficiency"] = reported_core_efficiency
	data["core_stability"] = stored_core_stability
	data["stored_power"] = display_power(stored_power)
	data["has_jar"] = !!fueljar
	data["fuel"] = fueljar?.fuel
	data["fuel_max"] = fueljar?.fuel_max
	data["fuel_injection"] = fuel_injection
	return data

/obj/machinery/power/am_control_unit/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(machine_stat & (BROKEN|NOPOWER))
		return

	switch(action)
		if("togglestatus")
			toggle_power()
			return TRUE
		if("refreshicons")
			update_shield_icons = 1
			return TRUE
		if("ejectjar")
			if(fueljar)
				fueljar.forceMove(drop_location())
				fueljar = null
				//fueljar.control_unit = null currently it does not care where it is
				//update_icon() when we have the icon for it
			return TRUE
		if("strengthup")
			fuel_injection++
			investigate_log("increased to [fuel_injection] by [key_name(usr)] at [AREACOORD(src)]", INVESTIGATE_ENGINES)
			return TRUE
		if("strengthdown")
			fuel_injection--
			if(fuel_injection < 0)
				fuel_injection = 0
			investigate_log("decreased to [fuel_injection] by [key_name(usr)] at [AREACOORD(src)]", INVESTIGATE_ENGINES)
			return TRUE
		if("refreshstability")
			check_core_stability()
			return TRUE
