// AQUILA - overclock z narastającym ciepłem i bezpiecznikami (wzór: overheat z Yogstation na tym samym /obj/mecha,
// overclock_mode z tg). Overclock przyspiesza krok i przeładowanie wyposażenia, ale grzeje mecha.
// Powyżej AQ_MECHA_HEAT_DANGER mech traci integralność, przy AQ_MECHA_HEAT_MAX przepala się bezpiecznik:
// overclock się wyłącza, a wyposażenie na chwilę gaśnie. Bez bezpieczników (albo z wyłączonym zabezpieczeniem)
// mech przy maksimum dalej się smaży i łapie uszkodzenia wewnętrzne. Bezpieczniki wymienia się kablem przy otwartej klapie.

/obj/mecha
	/// Ciepło mecha (0..AQ_MECHA_HEAT_MAX)
	var/aq_heat = 0
	/// Mnożnik grzania (radiatory pasywne go nie ruszają, zbiornik ciepła zmniejsza)
	var/aq_heat_modifier = 1
	/// Mnożnik chłodzenia biernego
	var/aq_cooling_modifier = 1
	/// Czy overclock jest włączony
	var/aq_overclock = FALSE
	/// O ile overclock przyspiesza krok (dzielnik step_in, jak overclock_coeff w tg)
	var/aq_overclock_coeff = 1.5
	/// step_in sprzed overclocku
	var/aq_overclock_saved_step
	/// Sprawne bezpieczniki
	var/aq_fuses = AQ_MECHA_FUSES
	/// Czy zabezpieczenie termiczne (bezpieczniki) jest włączone
	var/aq_fuse_safety = TRUE
	/// Przycisk akcji overclocku
	var/datum/action/innate/mecha/aq_overclock/aq_overclock_action = new

/obj/mecha/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	aq_overclock_action.Grant(user, src)

/obj/mecha/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	aq_overclock_action.Remove(user)

/obj/mecha/Destroy()
	. = ..()
	QDEL_NULL(aq_overclock_action)

/obj/mecha/process(delta_time)
	. = ..()
	if(QDELETED(src))
		return
	aq_process_heat(delta_time || 2)

/obj/mecha/proc/aq_process_heat(delta_time)
	if(aq_overclock)
		if(!has_charge(step_energy_drain))
			aq_set_overclock(FALSE)
		else
			use_power(step_energy_drain * delta_time)
			aq_adjust_heat(AQ_MECHA_OVERCLOCK_HEAT * delta_time)
	else if(aq_heat)
		aq_adjust_heat(-AQ_MECHA_PASSIVE_COOLING * aq_cooling_modifier * delta_time)
	for(var/obj/item/mecha_parts/mecha_equipment/aq_cooling/cooler in equipment)
		cooler.cool(delta_time)
	// Gorące otoczenie (pożar, lawa) dogrzewa mecha
	var/datum/gas_mixture/environment = loc?.return_air()
	if(environment && environment.return_temperature() > max_temperature)
		aq_adjust_heat(2 * delta_time)
	if(aq_heat >= AQ_MECHA_HEAT_DANGER)
		take_damage(delta_time * (1 + 2 * (aq_heat - AQ_MECHA_HEAT_DANGER) / (AQ_MECHA_HEAT_MAX - AQ_MECHA_HEAT_DANGER)), BURN, null, FALSE)
		if(aq_heat >= AQ_MECHA_HEAT_MAX && (!aq_fuse_safety || !aq_fuses) && prob(10 * delta_time))
			check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL, MECHA_INT_SHORT_CIRCUIT), TRUE)

/// Zmienia ciepło; dodatnie grzanie zależy od modułu skanującego (jak w Yogstation) i zbiorników ciepła
/obj/mecha/proc/aq_adjust_heat(amount)
	if(amount > 0)
		amount *= aq_heat_modifier
		if(scanmod)
			amount *= 1.2 - (scanmod.rating * 0.1)
	var/old = aq_heat
	aq_heat = round(clamp(aq_heat + amount, 0, AQ_MECHA_HEAT_MAX), 0.1)
	if(old < AQ_MECHA_HEAT_WARNING && aq_heat >= AQ_MECHA_HEAT_WARNING)
		occupant_message("<span class='warning'>Temperatura systemów rośnie.</span>")
	if(old < AQ_MECHA_HEAT_DANGER && aq_heat >= AQ_MECHA_HEAT_DANGER)
		occupant_message("<span class='danger'>Przegrzanie! Pancerz zaczyna się topić.</span>")
		if(occupant)
			SEND_SOUND(occupant, sound('sound/machines/warning-buzzer.ogg', volume = 50))
	if(amount > 0 && aq_heat >= AQ_MECHA_HEAT_MAX)
		aq_blow_fuse()
	infra_luminosity = initial(infra_luminosity) * (1 + aq_heat / AQ_MECHA_HEAT_DANGER)

/// Przepala bezpiecznik: wyłącza overclock i na chwilę wyposażenie
/obj/mecha/proc/aq_blow_fuse()
	if(!aq_fuse_safety || aq_fuses <= 0)
		return FALSE
	aq_fuses--
	aq_set_overclock(FALSE)
	equipment_disabled = TRUE
	spark_system.start()
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
	occupant_message("<span class='userdanger'>Bezpiecznik termiczny przepalony! Overclock wyłączony, wyposażenie restartuje się. Zostało bezpieczników: [aq_fuses].</span>")
	log_message("Thermal fuse blown ([aq_fuses] left).", LOG_MECHA)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/mecha, restore_equipment)), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	return TRUE

/obj/mecha/proc/aq_set_overclock(state)
	if(state == aq_overclock)
		return
	if(state && (!aq_fuses && aq_fuse_safety))
		occupant_message("<span class='warning'>Brak sprawnych bezpieczników, zabezpieczenie blokuje overclock.</span>")
		return
	aq_overclock = state
	if(state)
		aq_overclock_saved_step = step_in
		step_in = max(1, round(step_in / aq_overclock_coeff, 0.5))
		occupant_message("<span class='danger'>Overclock włączony: szybszy krok i przeładowanie, rosnące ciepło.</span>")
	else
		if(aq_overclock_saved_step)
			step_in = aq_overclock_saved_step
		aq_overclock_saved_step = null
		occupant_message("<span class='notice'>Overclock wyłączony.</span>")
	aq_overclock_action.button_icon_state = "mech_overload_[state ? "on" : "off"]"
	aq_overclock_action.UpdateButtonIcon()
	log_message("Toggled overclock: [state].", LOG_MECHA)

/// Po każdym użyciu modułu: ciepło (i zdjęcie maskowania, utility.dm)
/obj/item/mecha_parts/mecha_equipment/proc/aq_on_used()
	if(chassis && aq_heat_cost)
		chassis.aq_adjust_heat(aq_heat_cost)

/obj/item/mecha_parts/mecha_equipment/start_cooldown()
	. = ..()
	aq_on_used()

// rdzeniowe start_cooldown() broni energetycznej nie woła ..()
/obj/item/mecha_parts/mecha_equipment/weapon/energy/start_cooldown()
	. = ..()
	aq_on_used()

/obj/item/mecha_parts/mecha_equipment
	/// Ile ciepła daje jedno użycie (broń wręcz z Yogstation, ciężka broń)
	var/aq_heat_cost = 0

/obj/item/mecha_parts/mecha_equipment/set_ready_state(state)
	if(!state && chassis?.aq_overclock && equip_cooldown)
		// gotowość wraca szybciej: osobny krótszy timer, właściwy po starcie i tak zastanie gotowy moduł
		addtimer(CALLBACK(src, PROC_REF(aq_overclock_ready)), max(1, equip_cooldown / chassis.aq_overclock_coeff))
	return ..()

/obj/item/mecha_parts/mecha_equipment/proc/aq_overclock_ready()
	if(chassis?.aq_overclock && !equip_ready)
		set_ready_state(TRUE)

/datum/action/innate/mecha/aq_overclock
	name = "Overclock"
	desc = "Przyspiesza mecha kosztem ciepła i energii."
	button_icon_state = "mech_overload_off"

/datum/action/innate/mecha/aq_overclock/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.aq_set_overclock(!chassis.aq_overclock)

// ---------------------------------------------------------------- bezpieczniki w serwisie
/obj/mecha/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil) && construction_state == MECHA_OPEN_HATCH && !(internal_damage & MECHA_INT_SHORT_CIRCUIT) && aq_fuses < AQ_MECHA_FUSES)
		var/obj/item/stack/cable_coil/coil = W
		if(!coil.use(AQ_MECHA_FUSE_CABLE))
			to_chat(user, "<span class='warning'>Potrzebujesz [AQ_MECHA_FUSE_CABLE] odcinków kabla na bezpiecznik.</span>")
			return
		aq_fuses++
		to_chat(user, "<span class='notice'>Wymieniasz przepalony bezpiecznik termiczny ([aq_fuses]/[AQ_MECHA_FUSES]).</span>")
		return
	return ..()

/obj/mecha/examine(mob/user)
	. = ..()
	if(aq_heat >= AQ_MECHA_HEAT_WARNING)
		. += "<span class='warning'>Od kadłuba bije żar.</span>"
	if(aq_fuses < AQ_MECHA_FUSES)
		. += "<span class='notice'>Sprawne bezpieczniki termiczne: [aq_fuses]/[AQ_MECHA_FUSES]. Wymienia się je kablem przy otwartej klapie.</span>"

// ---------------------------------------------------------------- chłodzenie (Yogstation: radiator, active cooling, heat sink)
/obj/item/mecha_parts/mecha_equipment/aq_cooling
	name = "chłodzenie egzoszkieletu"
	desc = "Ogólny układ chłodzenia."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "radiator"
	selectable = FALSE
	aq_slot = AQ_MECHA_POWER
	/// Ile ciepła zbiera na sekundę
	var/cooling_rate = 1.5

/obj/item/mecha_parts/mecha_equipment/aq_cooling/proc/cool(delta_time)
	if(!chassis?.aq_heat)
		return
	chassis.aq_adjust_heat(-cooling_rate * delta_time)

/obj/item/mecha_parts/mecha_equipment/aq_cooling/passive
	name = "montowana pętla radiatora"
	desc = "Pasywny radiator dla egzoszkieletów. Wolniejszy od aktywnego chłodzenia, ale nie potrzebuje prądu. W próżni prawie nie działa."
	cooling_rate = 1.5

/obj/item/mecha_parts/mecha_equipment/aq_cooling/passive/cool(delta_time)
	var/datum/gas_mixture/air = chassis?.loc?.return_air()
	if(!air || air.return_pressure() < HAZARD_LOW_PRESSURE)
		return ..(delta_time * 0.25)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_cooling/active
	name = "aktywny układ chłodzenia"
	desc = "Zasilany radiator z obiegiem cieczy. Zużywa prąd na pompowanie chłodziwa, ale szybko zbija ciepło."
	icon_state = "aq_active_cooling"
	cooling_rate = 3
	energy_drain = 10

/obj/item/mecha_parts/mecha_equipment/aq_cooling/active/cool(delta_time)
	if(!chassis || chassis.equipment_disabled || !chassis.aq_heat)
		return
	if(!chassis.has_charge(energy_drain * delta_time))
		return
	chassis.use_power(energy_drain * delta_time)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_heat_sink
	name = "zbiornik ciepła"
	desc = "Duży zbiornik ciepła: mech grzeje się wolniej i dłużej utrzyma overclock, ale też wolniej stygnie."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "heatsink"
	selectable = FALSE
	aq_slot = AQ_MECHA_POWER
	var/heat_mult = 0.75

/obj/item/mecha_parts/mecha_equipment/aq_heat_sink/attach(obj/mecha/M)
	. = ..()
	M.aq_heat_modifier *= heat_mult
	M.aq_cooling_modifier *= heat_mult

/obj/item/mecha_parts/mecha_equipment/aq_heat_sink/detach(atom/moveto)
	var/obj/mecha/M = chassis
	. = ..()
	if(M && !chassis)
		M.aq_heat_modifier /= heat_mult
		M.aq_cooling_modifier /= heat_mult
