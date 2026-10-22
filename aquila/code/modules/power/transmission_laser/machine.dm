// Laser przesyłu mocy (PTL), port z Monkestation 2.0 (monkestation/code/modules/power/power_transmission_laser), ikony z Goonstation.
// Ładuje się z nadwyżki sieci przez terminal za plecami i wysyła ją wiązką w kosmos, a CentCom płaci za każdy wysłany megawat.

#define PTL_KW 1e3
#define PTL_MW 1e6
#define PTL_GW 1e9
#define PTL_TW 1e12
#define PTL_PW 1e15
#define PTL_EW 1e18
#define PTL_ZW 1e21
#define PTL_YW 1e24
#define PTL_RW 1e27
#define PTL_QW 1e30

/// Poniżej tego ładunku laser nie strzela
#define PTL_MINIMUM_POWER PTL_MW
/// Drugi człon wzoru sprzedaży dąży do tylu kredytów na tick
#define PTL_MINIMUM_BAR 25

/obj/machinery/power/transmission_laser
	name = "laser przesyłu mocy"
	desc = "Wysyła moc gigantyczną wiązką lasera do stacji przetwarzania energii Nanotrasen. Nie stawaj na linii strzału."
	icon = 'aquila/icons/obj/power/pt_laser.dmi'
	icon_state = "ptl"
	max_integrity = 10000
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_ENGINE)
	// 3x3 kratki
	bound_width = 96
	bound_height = 96

	/// Terminal na kratce za laserem, z którego ciągniemy moc
	var/obj/machinery/power/terminal/terminal = null
	/// Ile mocy wysyłamy w tym ticku
	var/output_level = 0
	/// Pojemność lasera
	var/capacity = INFINITY
	/// Zgromadzony ładunek
	var/charge = 0
	/// Czy w ostatnim ticku coś weszło
	var/inputting = FALSE
	/// Nadwyżka sieci dostępna w ostatnim ticku
	var/input_available = 0
	/// Czy laser przyjmuje moc
	var/turned_on = FALSE
	/// Czy laser ma strzelać
	var/firing = FALSE
	/// Czy wiązka stoi na mapie
	var/laser_active = FALSE
	/// Wszystkie kratki wiązki, do skasowania po wyłączeniu
	var/list/laser_effects = list()
	/// Mnożnik jednostki wejścia z panelu (W, kW, MW...)
	var/power_format_multi = 1
	/// Mnożnik jednostki wyjścia z panelu
	var/power_format_multi_output = 1
	/// Łącznie sprzedana moc
	var/total_power = 0
	/// Próg sprzedanej mocy, po którym leci kolejne ogłoszenie
	var/announcement_treshold = PTL_MW
	/// Łącznie zarobione kredyty
	var/total_earnings = 0
	/// Kredyty, które nie trafiły jeszcze na konta
	var/unsent_earnings = 0
	/// Liczba wejścia z panelu (0-999), przed mnożnikiem
	var/input_number = 0
	/// Liczba wyjścia z panelu (0-999), przed mnożnikiem
	var/output_number = 0
	/// Ile faktycznie ciągniemy w tym ticku
	var/input_pulling = 0
	/// Timer cyklicznego raportu co 30 minut
	var/announcement_timer

/obj/machinery/power/transmission_laser/setDir(newdir)
	. = ..()
	// Sprite z Goona ma tylko poziome lufy (SOUTH jak EAST, NORTH jak WEST), więc dla N/S obracamy go o 90 stopni
	transform = (dir & (NORTH|SOUTH)) ? matrix().Turn(90) : matrix()

/obj/machinery/power/transmission_laser/Initialize(mapload)
	. = ..()
	setDir(dir)
	var/turf/back_turf = get_step(get_back_turf(), turn(dir, 180))
	terminal = locate(/obj/machinery/power/terminal) in back_turf
	if(!terminal)
		set_machine_stat(machine_stat | BROKEN)
		update_appearance()
		return
	terminal.master = src
	update_appearance()

/obj/machinery/power/transmission_laser/Destroy()
	deltimer(announcement_timer)
	QDEL_LIST(laser_effects)
	if(terminal)
		terminal.master = null
		terminal = null
	return ..()

/obj/machinery/power/transmission_laser/disconnect_terminal()
	terminal = null
	firing = FALSE
	output_level = 0
	set_machine_stat(machine_stat | BROKEN)
	destroy_lasers()
	update_appearance()

/// Środek kwadratu 3x3 (loc to lewy dolny róg)
/obj/machinery/power/transmission_laser/proc/get_center_turf()
	return locate(x + 1, y + 1, z)

/obj/machinery/power/transmission_laser/proc/get_back_turf()
	var/turf/center = get_center_turf()
	if(!center)
		return
	return get_step(center, turn(dir, 180))

/obj/machinery/power/transmission_laser/proc/get_front_turf()
	var/turf/center = get_center_turf()
	if(!center)
		return
	return get_step(center, dir)

/obj/machinery/power/transmission_laser/examine(mob/user)
	. = ..()
	if(!terminal)
		. += "<span class='warning'>Laser nie ma terminala zasilania za sobą!</span>"
	. += "<span class='notice'>Niewysłane kredyty: [unsent_earnings].</span>"
	. += "<span class='notice'>Laser zarobił łącznie [total_earnings] kredytów.</span>"
	. += "<span class='notice'>Laser sprzedał łącznie [ptl_readable_power(total_power)].</span>"

/obj/machinery/power/transmission_laser/update_overlays()
	. = ..()
	if((machine_stat & BROKEN) || !charge)
		. += "unpowered"
		return
	if(input_available > 0)
		. += "green_light"
		. += emissive_appearance(icon, "green_light")
	if(turned_on)
		. += "red_light"
		. += emissive_appearance(icon, "red_light")
	if(firing) // strzał z zapasu działa też przy wyłączonym poborze
		. += "firing"
		. += emissive_appearance(icon, "firing")
	var/charge_level = return_charge()
	if(charge_level == 6)
		. += "charge_full"
		. += emissive_appearance(icon, "charge_full")
	else if(charge_level > 0)
		. += "charge_[charge_level]"
		. += emissive_appearance(icon, "charge_[charge_level]")

/// Poziom ładunku od 0 do 6 względem ustawionego wyjścia
/obj/machinery/power/transmission_laser/proc/return_charge()
	if(!output_level)
		return 0
	return min(round((charge / abs(output_level)) * 6), 6)

/obj/machinery/power/transmission_laser/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>Zwierasz blokadę dostępu [src].</span>")

/obj/machinery/power/transmission_laser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TransmissionLaser")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/power/transmission_laser/ui_data(mob/user)
	var/list/data = list()
	data["output"] = output_level
	data["total_earnings"] = total_earnings
	data["unsent_earnings"] = unsent_earnings
	data["held_power"] = charge
	data["max_capacity"] = capacity
	data["max_grid_load"] = input_available
	data["accepting_power"] = turned_on
	data["sucking_power"] = inputting
	data["firing"] = firing
	data["broken"] = !!(machine_stat & BROKEN)
	data["power_format"] = power_format_multi
	data["input_number"] = input_number
	data["avalible_input"] = input_available
	data["output_number"] = output_number
	data["output_multiplier"] = power_format_multi_output
	data["input_total"] = input_number * power_format_multi
	data["output_total"] = output_number * power_format_multi_output
	return data

/obj/machinery/power/transmission_laser/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!(obj_flags & EMAGGED) && !allowed(usr))
		to_chat(usr, "<span class='warning'>Brak dostępu.</span>")
		return
	// Drabinka jednostek z panelu; u nas silnik daje megawaty, więc kończymy na TW
	var/static/list/units = list("W" = 1, "KW" = PTL_KW, "MW" = PTL_MW, "GW" = PTL_GW, "TW" = PTL_TW)
	switch(action)
		if("toggle_input")
			turned_on = !turned_on
			log_game("[key_name(usr)] [turned_on ? "włączył" : "wyłączył"] pobór mocy lasera przesyłu w [AREACOORD(src)]")
			update_appearance()
			return TRUE
		if("toggle_output")
			firing = !firing
			log_game("[key_name(usr)] [firing ? "włączył" : "wyłączył"] strzał lasera przesyłu w [AREACOORD(src)]")
			update_appearance()
			return TRUE
		if("set_input")
			input_number = clamp(text2num(params["set_input"]), 0, 999)
			return TRUE
		if("set_output")
			output_number = clamp(text2num(params["set_output"]), 0, 999)
			return TRUE
		if("input_unit")
			if(params["unit"] in units)
				power_format_multi = units[params["unit"]]
			return TRUE
		if("output_unit")
			if(params["unit"] in units)
				power_format_multi_output = units[params["unit"]]
			return TRUE

/obj/machinery/power/transmission_laser/process()
	if(!terminal)
		return
	input_available = terminal.surplus()
	if(machine_stat & BROKEN)
		return

	if(total_power >= announcement_treshold)
		send_ptl_announcement()

	var/last_disp = return_charge()
	var/last_chrg = inputting
	var/last_fire = firing

	// Wyłączone wejście zatrzymuje tylko pobór, strzał leci dalej z zapasu (w Monke zamrażało wiązkę)
	input_pulling = turned_on ? min(input_available, input_number * power_format_multi) : 0
	if(input_pulling > 0)
		terminal.add_load(input_pulling)
		charge += input_pulling
		inputting = TRUE
	else
		inputting = FALSE

	if(charge < PTL_MINIMUM_POWER)
		firing = FALSE

	if(!firing) // Wyłączony ręcznie albo ładunek spadł poniżej minimum
		if(laser_active)
			destroy_lasers()
		output_level = 0
	else
		output_level = min(charge, output_number * power_format_multi_output)
		if(!length(laser_effects))
			setup_lasers()
		sell_power(output_level)
		charge -= output_level
		if(charge < PTL_MINIMUM_POWER) // zapas wyczerpany w tym ticku, nie zostawiamy wiązki do następnego
			firing = FALSE
			destroy_lasers()
			output_level = 0

	if(last_disp != return_charge() || last_chrg != inputting || last_fire != firing)
		update_appearance()

/// Wzór z Monke: log10(MW + 1)^2 plus człon nasycający się do PTL_MINIMUM_BAR
/obj/machinery/power/transmission_laser/proc/calculate_credits(power_amount)
	var/mw_power = power_amount / PTL_MW
	var/generated_cash = log(10, mw_power + 1) ** 2
	generated_cash += (4 * mw_power * PTL_MINIMUM_BAR) / (4 * mw_power + PTL_MINIMUM_BAR)
	return round(generated_cash)

/obj/machinery/power/transmission_laser/proc/sell_power(power_amount)
	var/generated_cash = calculate_credits(power_amount)
	if(generated_cash < 0)
		return
	total_power += power_amount
	total_earnings += generated_cash
	unsent_earnings += generated_cash

	// 50% inżynieria, 25% cargo, 25% sec, jak w Monke
	var/datum/bank_account/department/engineering_bank_account = SSeconomy.get_dep_account(ACCOUNT_ENG)
	var/datum/bank_account/department/cargo_bank_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/datum/bank_account/department/security_bank_account = SSeconomy.get_dep_account(ACCOUNT_SEC)
	var/medium_cut = unsent_earnings * 0.25
	var/high_cut = unsent_earnings * 0.5
	if(security_bank_account)
		security_bank_account.adjust_money(medium_cut)
		unsent_earnings -= medium_cut
	if(cargo_bank_account)
		cargo_bank_account.adjust_money(medium_cut)
		unsent_earnings -= medium_cut
	if(engineering_bank_account)
		engineering_bank_account.adjust_money(high_cut)
		unsent_earnings -= high_cut

/// Stawia wiązkę od kratki przed laserem do krawędzi mapy albo pierwszej ściany
/obj/machinery/power/transmission_laser/proc/setup_lasers()
	var/turf/target = get_step(get_front_turf(), dir)
	var/sanity = max(world.maxx, world.maxy)
	while(target && sanity-- > 0)
		if(isclosedturf(target)) // AQUILA: wiązka nie przebija kadłuba ani ścian
			break
		new /obj/effect/transmission_beam(target, src) // wiązka sama dopisuje się do laser_effects
		target = get_step(target, dir)
	laser_active = TRUE

/obj/machinery/power/transmission_laser/proc/destroy_lasers()
	if(!firing) // na wypadek ręcznego włączenia z powrotem
		QDEL_LIST(laser_effects)
		laser_active = FALSE

/// Wołane, gdy coś wejdzie w wiązkę
/obj/machinery/power/transmission_laser/proc/atom_entered_beam(obj/effect/transmission_beam/triggered, mob/living/victim)
	if(!isliving(victim) || victim.incorporeal_move || (victim.status_flags & GODMODE))
		return
	var/mw_power = output_level / PTL_MW
	if(mw_power <= 25)
		victim.adjustFireLoss(mw_power * 15)
		victim.visible_message("<span class='danger'>[victim] wchodzi w wiązkę lasera i zaczyna się palić!</span>", "<span class='userdanger'>Wiązka lasera przepala cię na wylot!</span>")
		return
	log_combat(src, victim, "zgibował wiązką lasera przesyłu", null, "[ptl_readable_power(output_level)]")
	if(mw_power <= 50)
		victim.gib()
		return
	explosion(victim, 3, 2, 2)
	victim.gib()

/// Moc w czytelnych jednostkach do ogłoszeń i examine
/proc/ptl_readable_power(amount)
	if(amount >= PTL_EW)
		return "[round(amount / PTL_EW, 0.01)] EW"
	if(amount >= PTL_PW)
		return "[round(amount / PTL_PW, 0.01)] PW"
	if(amount >= PTL_TW)
		return "[round(amount / PTL_TW, 0.01)] TW"
	if(amount >= PTL_GW)
		return "[round(amount / PTL_GW, 0.01)] GW"
	if(amount >= PTL_MW)
		return "[round(amount / PTL_MW, 0.01)] MW"
	return "[round(amount)] W"
