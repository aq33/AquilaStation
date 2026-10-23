///Assoc list of ["z_level"] = list(cores)
GLOBAL_LIST_EMPTY(data_cores)

/obj/machinery/ai/data_core
	name = "rdzeń danych SI"
	desc = "Złożony system komputerowy, który emuluje funkcje nerwowe żywej istoty niemal natychmiast. Tu mieszka sztuczna inteligencja."
	icon = 'aquila/icons/obj/machines/ai_servers.dmi'
	icon_state = "core-offline"
	base_icon_state = "core"

	circuit = /obj/item/circuitboard/machine/ai_data_core
	active_power_usage = AI_DATA_CORE_POWER_USAGE
	idle_power_usage = 100
	use_power = IDLE_POWER_USE
	critical_machine = TRUE
	max_integrity = 400
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 50, "stamina" = 0)

	var/disableheat = FALSE
	///Limited to MAX_AI_DATA_CORE_TICKS. Decrement by 1 every time we have an invalid tick, opposite when valid
	var/valid_ticks = MAX_AI_DATA_CORE_TICKS
	COOLDOWN_DECLARE(warning_cooldown)

	///Heat production multiplied by this
	var/heat_modifier = 1
	///Power modifier, power modified by this. Be aware this indirectly changes heat since power => heat
	var/power_modifier = 1
	var/obj/item/stock_parts/cell/integrated_battery

/obj/machinery/ai/data_core/Initialize(mapload)
	. = ..()
	if(mapload)
		integrated_battery = new /obj/item/stock_parts/cell/high(src)
	update_list()
	RefreshParts()

/obj/machinery/ai/data_core/Destroy()
	update_list(TRUE)

	for(var/mob/living/silicon/ai/AI in contents)
		if(!AI.is_dying)
			AI.relocate()

	//Other AIs in this network will get alerted
	var/datum/ai_os/our_os = get_os()
	if(our_os)
		for(var/mob/living/silicon/ai/AI as anything in our_os.ai_list)
			if(!AI.mind && AI.deployed_shell?.mind)
				to_chat(AI.deployed_shell, span_userdanger("Uwaga! Rdzeń danych w [get_area_name(src, TRUE)] przestał działać! Sprawdź, czy to nie sabotaż."))
			else
				to_chat(AI, span_userdanger("Uwaga! <a href='byond://?src=[REF(AI)];go_to_machine=[REF(src)]'>Rdzeń danych</a> w [get_area_name(src, TRUE)] przestał działać! Sprawdź, czy to nie sabotaż."))
	QDEL_NULL(integrated_battery)
	return ..()

//Taken from gravity generator
/obj/machinery/ai/data_core/proc/update_list(removing = FALSE)
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/list/z_list = list()
	// take multi-z into account.
	if(is_station_level(T.z))
		for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
			z_list += z
	else
		z_list += T.z

	for(var/z in z_list)
		if(removing || QDELETED(src))
			LAZYREMOVE(GLOB.data_cores["[z]"], src)
		else
			LAZYOR(GLOB.data_cores["[z]"], src)

/obj/machinery/ai/data_core/onTransitZ(old_z, new_z)
	for(var/z in GLOB.data_cores)
		LAZYREMOVE(GLOB.data_cores[z], src)
	. = ..()
	update_list()

/obj/machinery/ai/data_core/JoinPlayerHere(mob/M, buckle)
	return

/obj/machinery/ai/data_core/get_cell()
	return integrated_battery

/obj/machinery/ai/data_core/RefreshParts()
	var/new_heat_mod = 1
	var/new_power_mod = 1
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		new_power_mod -= (C.rating - 1) / 50 //Max -24% at tier 4 parts, min -0% at tier 1

	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		new_heat_mod -= (M.rating - 1) / 15 //Max -40% at tier 4 parts, min -0% at tier 1

	heat_modifier = new_heat_mod
	power_modifier = new_power_mod
	active_power_usage = (AI_DATA_CORE_POWER_USAGE * power_modifier)

/obj/machinery/ai/data_core/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == integrated_battery)
		integrated_battery = null

/obj/machinery/ai/data_core/examine(mob/user)
	. = ..()
	var/holder_status = get_holder_status()
	if(holder_status)
		. += span_warning("Maszyna nie działa. Powód: [holder_status]")
	. += span_notice("Śruby mocujące są [anchored ? "dokręcone" : "luźne"].")
	if(isnull(integrated_battery))
		. += span_notice("Brakuje w nim <b>baterii zapasowej</b>.")
	else
		. += span_notice("Bateria zapasowa: [round(integrated_battery.percent())]%.")
	. += span_notice("Temperatura rdzenia: <b>[round(core_temp, 0.1)] K</b> (limit [get_os()?.get_temp_limit() || AI_TEMP_LIMIT] K).")

	var/list/ai_names = list()
	for(var/mob/living/silicon/ai/AI in contents)
		ai_names += isobserver(user) ? "[AI.name] ([ADMIN_FLW(AI.eyeobj)])" : AI.name
	if(length(ai_names))
		. += span_bold("Monitor wyświetla działające SI: [english_list(ai_names)]")

/obj/machinery/ai/data_core/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		if(!panel_open)
			balloon_alert(user, "panel zamknięty!")
			return TRUE
		var/had_battery = FALSE
		if(integrated_battery)
			user.put_in_hands(integrated_battery)
			had_battery = TRUE
		if(!user.transferItemToLoc(I, src))
			return TRUE
		integrated_battery = I
		balloon_alert(user, had_battery ? "bateria wymieniona" : "bateria włożona")
		return TRUE
	if(istype(I, /obj/item/ai_hijack_device))
		var/mob/living/silicon/ai/hosted_ai = locate() in contents
		if(hosted_ai)
			return I.afterattack(hosted_ai, user, TRUE)
	return ..()

/obj/machinery/ai/data_core/attack_hand(mob/living/user)
	var/mob/living/silicon/ai/hosted_ai = locate() in contents
	if(hosted_ai?.hijacking)
		return hosted_ai.attack_hand(user)
	return ..()

/obj/machinery/ai/data_core/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	I.play_tool_sound(src, 50)
	balloon_alert_to_viewers("odkręca panel...")
	if(!I.use_tool(src, user, 2 SECONDS))
		return TRUE
	default_deconstruction_screwdriver(user, "[base_icon_state]-open", base_icon_state, I)
	return TRUE

/obj/machinery/ai/data_core/crowbar_act(mob/living/user, obj/item/I)
	if(!panel_open)
		balloon_alert(user, "panel zamknięty!")
		return TRUE
	balloon_alert_to_viewers("rozbiera rdzeń...")
	if(!I.use_tool(src, user, 4 SECONDS))
		return TRUE
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/ai/data_core/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 4 SECONDS)
	return TRUE

/obj/machinery/ai/data_core/attack_ai(mob/living/silicon/ai/user)
	if(user in src)
		return ..()
	if(!valid_data_core(user) || !valid_holder())
		to_chat(user, span_warning("Ten rdzeń danych nie nadaje się do przeniesienia."))
		return ..()
	if(user.controlled_mech)
		to_chat(user, span_warning("Najpierw opuść sterowany mech."))
		return ..()
	if(!isaicore(user.loc))
		to_chat(user, span_warning("Musisz być w rdzeniu danych, by się przenieść."))
		return ..()
	if(user.nuking)
		var/confirmation_alert = tgui_alert(user, "Przeniesienie wyłączy urządzenie zagłady. Na pewno?", "Przenieść?", list("Przenieś", "Anuluj"))
		if(confirmation_alert != "Przenieś")
			return
	to_chat(user, span_notice("Przenosisz się do rdzenia danych w [get_area_name(src, TRUE)]..."))
	if(do_after(user, 4 SECONDS, FALSE, src) && valid_data_core(user) && isaicore(user.loc))
		transfer_AI(user)
		playsound(src, 'sound/machines/ping.ogg', 25, FALSE, 2)
		to_chat(user, span_notice("Przeniesienie zakończone."))

/obj/machinery/ai/data_core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(!. || QDELETED(src))
		return
	for(var/mob/living/silicon/ai/AI in contents)
		AI.disconnect_shell()

/obj/machinery/ai/data_core/proc/valid_data_core(mob/living/silicon/ai/user, ignore_z_levels = FALSE)
	if(!ignore_z_levels && user)
		// SI w sieci przenosi się tylko w obrębie swojej sieci, SI spoza sieci (na kafelku) w obrębie poziomu
		var/datum/ai_os/user_os = user.get_ai_os()
		if(user_os)
			if(get_os() != user_os)
				return FALSE
		else
			var/turf/user_turf = get_turf(user)
			if(!user_turf || !(src in GLOB.data_cores["[user_turf.z]"]))
				return FALSE

	return valid_ticks > 0

/obj/machinery/ai/data_core/process(delta_time)
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_DATA_CORE_TICKS)

	if(valid_holder())
		valid_ticks++
		use_power = ACTIVE_POWER_USE
		if((machine_stat & NOPOWER) && integrated_battery)
			integrated_battery.use(active_power_usage * GLOB.CELLRATE)
		COOLDOWN_RESET(src, warning_cooldown)
		update_icon()
		return

	valid_ticks--
	if(valid_ticks <= 0)
		use_power = IDLE_POWER_USE
	update_icon()
	if(!COOLDOWN_FINISHED(src, warning_cooldown))
		return
	COOLDOWN_START(src, warning_cooldown, AI_DATA_CORE_WARNING_COOLDOWN)
	//Other AIs in this network will get alerted
	var/datum/ai_os/our_os = get_os()
	if(our_os)
		for(var/mob/living/silicon/ai/AI as anything in our_os.ai_list)
			if(!AI.mind && AI.deployed_shell?.mind)
				to_chat(AI.deployed_shell, span_userdanger("Rdzeń danych w [get_area_name(src, TRUE)] zaraz przestanie działać! Potrzebna natychmiastowa interwencja."))
			else
				to_chat(AI, span_userdanger("<a href='byond://?src=[REF(AI)];go_to_machine=[REF(src)]'>Rdzeń danych</a> w [get_area_name(src, TRUE)] zaraz przestanie działać! Potrzebna natychmiastowa interwencja."))
			AI.playsound_local(AI, 'sound/machines/engine_alert2.ogg', 30)

/obj/machinery/ai/data_core/process_atmos()
	. = ..()
	if(!.)
		return FALSE

	var/ai_creating_heat = FALSE
	for(var/mob/living/silicon/ai/ai_contents in contents)
		ai_creating_heat = !ai_contents.technically_unpowered
		break //don't need to check every single AI

	if((machine_stat & (BROKEN|EMPED)) || !has_power() || disableheat || !ai_creating_heat)
		return FALSE

	var/temp_active_usage = (machine_stat & NOPOWER) ? idle_power_usage : active_power_usage
	var/temperature_increase = (temp_active_usage / AI_HEATSINK_CAPACITY) * heat_modifier
	core_temp += temperature_increase * AI_TEMPERATURE_MULTIPLIER
	return TRUE

/obj/machinery/ai/data_core/has_power()
	if((machine_stat & NOPOWER) && integrated_battery)
		if(integrated_battery.charge > active_power_usage * GLOB.CELLRATE)
			return TRUE
	return ..()

/obj/machinery/ai/data_core/proc/can_transfer_ai(mob/living/silicon/ai/user, ignore_z_levels = FALSE)
	if(QDELETED(src) || machine_stat & (BROKEN|EMPED) || !has_power())
		return FALSE
	if(!valid_data_core(user, ignore_z_levels) || !valid_holder())
		return FALSE
	return TRUE

/obj/machinery/ai/data_core/proc/transfer_AI(mob/living/silicon/ai/AI)
	if(AI.nuking)
		INVOKE_ASYNC(AI, TYPE_PROC_REF(/mob/living/silicon/ai, ShutOffDoomsdayDevice))
	var/datum/ai_os/old_os = AI.get_ai_os()
	. = AI.forceMove(src)
	if(AI.eyeobj)
		AI.eyeobj.setLoc(get_turf(src))
	AI.last_used_data_core = src
	update_icon()
	var/datum/ai_os/new_os = get_os()
	if(old_os && old_os != new_os)
		old_os.remove_ai(AI)
	new_os?.add_ai(AI)
	return .

/obj/machinery/ai/data_core/update_icon_state()
	if((machine_stat & (BROKEN|EMPED)) || !has_power() || valid_ticks <= 0)
		icon_state = panel_open ? "[base_icon_state]-open" : "[base_icon_state]-offline"
	else
		icon_state = panel_open ? "[base_icon_state]-open" : base_icon_state
	return ..()

/obj/machinery/ai/data_core/primary
	name = "główny rdzeń danych SI"
	desc = "Złożony system komputerowy, który emuluje funkcje nerwowe żywej istoty niemal natychmiast. Wyblakła karteczka mówi: „Główny rdzeń danych SI”."
	circuit = /obj/item/circuitboard/machine/ai_data_core/primary

/obj/machinery/ai/data_core/primary/Initialize(mapload)
	. = ..()
	if(mapload)
		new /obj/item/paper/ai_control_code(src)

/obj/machinery/ai/data_core/Moved(atom/OldLoc, Dir)
	. = ..()
	for(var/mob/living/silicon/ai/internal_ai in contents)
		if(internal_ai.builtInCamera?.can_use())
			GLOB.cameranet.updatePortableCamera(internal_ai.builtInCamera)
