// AQUILA - pulsar jako dodatkowe źródło zasilania okrętu (port z CEV-Eris, code/modules/pulsar_engine/, AGPL-3).
// Różnice względem Eris: bez satelity na osobnej mapie i bez portalu. Konsola orbity, zbiornik paliwa i mostek mocy
// stoją w maszynowni okrętu, a mapę orbity (20×20 pól) rysuje okno konsoli zamiast poziomu mapy. Z wydarzeń zostały
// burza promieniowania (satelita w głównej wiązce) i przeciążenie (za słaba osłona: szczeliny strzelające wiązkami).
// Liczby (moc, osłona, rozpad orbity, koszt ciągu) jak w Eris.

/// Bok mapy orbity
#define PULSAR_GRID 20
/// Moc mostka przy 100% mocy pulsara (W)
#define PULSAR_MAX_POWER 25000000
/// Ostrzeżenie przed burzą i przeciążeniem
#define PULSAR_EVENT_WARNING (3 MINUTES)
/// Najdłuższy odstęp między samoczynnymi przesunięciami satelity
#define PULSAR_ORBIT_DECAY (15 MINUTES)
/// Po rozłączeniu mostka nie da się go od razu połączyć
#define PULSAR_RECONNECT_COOLDOWN (5 MINUTES)
/// Co ile przy przeciążeniu pojawia się nowa fala szczelin
#define PULSAR_RIFT_WAVE (3 MINUTES)

GLOBAL_LIST_EMPTY(pulsar_consoles)

// ---------------------------------------------------------------- konsola orbity

/obj/machinery/pulsar_console
	name = "konsola orbity pulsara"
	desc = "Steruje satelitą krążącym wokół pulsara. Im bliżej gwiazdy, tym więcej mocy, ale tym mocniejszej osłony trzeba. Satelita w głównej wiązce ściąga na okręt burzę promieniowania."
	icon = 'aquila/icons/obj/machinery/pulsar_machinery.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 500
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	req_one_access = list(ACCESS_ENGINE, ACCESS_CE)
	/// Położenie satelity na mapie orbity (1..PULSAR_GRID - 1)
	var/sat_x = 15
	var/sat_y = 5
	/// Moc osłony satelity w procentach
	var/shield_power = 45
	var/obj/structure/pulsar_fuel_tank/tank
	var/obj/machinery/power/pulsar_bridge/bridge
	/// Kiedy satelita sam się przesunie
	var/next_decay = 0
	/// Kiedy nadejdzie burza (0 = brak ostrzeżenia)
	var/storm_at = 0
	var/storm_active = FALSE
	/// Kiedy nastąpi przeciążenie (0 = brak ostrzeżenia)
	var/overcharge_at = 0
	var/overcharge_active = FALSE
	var/next_rift_wave = 0
	var/list/obj/effect/pulsar_rift/rifts = list()
	var/obj/item/radio/radio

/obj/machinery/pulsar_console/Initialize(mapload)
	. = ..()
	GLOB.pulsar_consoles += src
	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_eng
	radio.listening = FALSE
	radio.recalculateChannels()
	next_decay = world.time + decay_time()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/pulsar_console/LateInitialize()
	. = ..()
	scan_for_tank()

/obj/machinery/pulsar_console/Destroy()
	GLOB.pulsar_consoles -= src
	end_storm()
	end_overcharge()
	if(tank?.console == src)
		tank.console = null
	tank = null
	if(bridge?.console == src)
		bridge.console = null
	bridge = null
	QDEL_NULL(radio)
	return ..()

/obj/machinery/pulsar_console/update_icon_state()
	. = ..()
	if(machine_stat & BROKEN)
		icon_state = "console_broken"
	else if(machine_stat & NOPOWER)
		icon_state = "console_off"
	else
		icon_state = "console"

/obj/machinery/pulsar_console/power_change()
	. = ..()
	update_appearance()

/// Wydarzenia działają tylko wtedy, gdy mostek ciągnie z pulsara moc
/obj/machinery/pulsar_console/proc/events_enabled()
	return bridge?.connected

/obj/machinery/pulsar_console/proc/scan_for_tank()
	if(tank?.console == src)
		tank.console = null
	tank = null
	for(var/obj/structure/pulsar_fuel_tank/candidate in get_area(src))
		tank = candidate
		candidate.console = src
		break
	return tank

/// Satelita w głównej wiązce: burza promieniowania
/obj/machinery/pulsar_console/proc/on_core_beam(x = sat_x, y = sat_y)
	return x == y

/// Satelita przy wiązce: najwięcej mocy, najmocniejsza osłona
/obj/machinery/pulsar_console/proc/on_side_beam(x = sat_x, y = sat_y)
	return abs(x - y) == 1

/// Pulsar leży na środku mapy orbity
/obj/machinery/pulsar_console/proc/pulsar_pos()
	return round((PULSAR_GRID - 1) / 2)

/// Moc pulsara w procentach (bez osłony): przy wiązce 150, dalej liniowo od odległości
/obj/machinery/pulsar_console/proc/produced_power()
	if(on_side_beam())
		return 150
	var/max_dist = PULSAR_GRID * sqrt(2)
	var/dist = sqrt((sat_x - pulsar_pos()) ** 2 + (sat_y - pulsar_pos()) ** 2)
	return max(0, round((max_dist - 2 * dist) * 100 / max_dist))

/obj/machinery/pulsar_console/proc/required_shielding()
	if(on_side_beam())
		return 60
	return max(30, 30 + produced_power() / 5)

/// Moc, która dochodzi do mostka (procent PULSAR_MAX_POWER)
/obj/machinery/pulsar_console/proc/effective_power()
	return produced_power() * (100 - shield_power) / 100

/// Ile moli paliwa kosztuje ruch: 4 przy czystej plazmie, więcej przy rozcieńczonej
/obj/machinery/pulsar_console/proc/thrust_cost()
	var/datum/gas_mixture/air = tank?.air_contents
	if(!air || air.total_moles() <= 0)
		return 100
	var/plasma_fraction = air.get_moles(GAS_PLASMA) / air.total_moles()
	if(plasma_fraction <= 0)
		return 100
	return CEILING(4 / plasma_fraction, 1)

/// Im mniej mocy, tym szybciej orbita się rozjeżdża (jak w Eris)
/obj/machinery/pulsar_console/proc/decay_time()
	return max(10, 100 - produced_power()) / 100 * PULSAR_ORBIT_DECAY

/// Przesuwa satelitę; ruch z konsoli zużywa paliwo, rozpad orbity nie
/obj/machinery/pulsar_console/proc/move_satellite(direction, use_fuel = TRUE)
	if(!(direction in GLOB.cardinals))
		return FALSE
	if(use_fuel)
		var/cost = thrust_cost()
		if(!tank || tank.air_contents.total_moles() < cost)
			return FALSE
		tank.air_contents.remove(cost)
		tank.update_appearance()
	var/new_x = sat_x
	var/new_y = sat_y
	if(direction & NORTH)
		new_y++
	if(direction & SOUTH)
		new_y--
	if(direction & EAST)
		new_x++
	if(direction & WEST)
		new_x--
	// Poza mapą: satelita odbija się w drugą stronę
	if(new_x < 1 || new_x > PULSAR_GRID - 1 || new_y < 1 || new_y > PULSAR_GRID - 1)
		new_x = sat_x - (new_x - sat_x)
		new_y = sat_y - (new_y - sat_y)
	sat_x = clamp(new_x, 1, PULSAR_GRID - 1)
	sat_y = clamp(new_y, 1, PULSAR_GRID - 1)
	next_decay = world.time + decay_time()
	check_events()
	return TRUE

/obj/machinery/pulsar_console/process(delta_time)
	if(world.time >= next_decay)
		move_satellite(pick(GLOB.cardinals), FALSE)
	check_events()
	if(overcharge_active)
		for(var/obj/effect/pulsar_rift/rift as anything in rifts)
			rift.discharge()
		if(world.time >= next_rift_wave)
			spawn_rift_wave(rand(4, 6))

/// Ostrzeżenia i wydarzenia: burza w głównej wiązce, przeciążenie przy za słabej osłonie
/obj/machinery/pulsar_console/proc/check_events()
	if(!events_enabled())
		end_storm()
		end_overcharge()
		return
	if(on_core_beam())
		if(!storm_at)
			storm_at = world.time + PULSAR_EVENT_WARNING
			radio.talk_into(src, "OSTRZEŻENIE: satelita pulsara wchodzi w wiązkę promieniowania! Burza za 3 minuty.", RADIO_CHANNEL_ENGINEERING)
		else if(!storm_active && world.time >= storm_at)
			start_storm()
	else if(storm_at)
		if(!storm_active)
			radio.talk_into(src, "Satelita pulsara ominął wiązkę promieniowania.", RADIO_CHANNEL_ENGINEERING)
		end_storm()

	if(shield_power < required_shielding())
		if(!overcharge_at)
			overcharge_at = world.time + PULSAR_EVENT_WARNING
			radio.talk_into(src, "OSTRZEŻENIE: za słaba osłona satelity pulsara! Przeciążenie za 3 minuty.", RADIO_CHANNEL_ENGINEERING)
		else if(!overcharge_active && world.time >= overcharge_at)
			start_overcharge()
	else if(overcharge_at)
		if(!overcharge_active)
			radio.talk_into(src, "Przeciążenie satelity pulsara zażegnane.", RADIO_CHANNEL_ENGINEERING)
		end_overcharge()

/// Poziomy mapy okrętu, na którym stoi konsola
/obj/machinery/pulsar_console/proc/ship_z_levels()
	. = list()
	var/obj/structure/overmap/ship = get_overmap()
	if(ship)
		for(var/datum/space_level/level as anything in ship.occupying_levels)
			. |= level.z_value
	if(!length(.))
		. += z

/obj/machinery/pulsar_console/proc/announce(message)
	var/obj/structure/overmap/ship = get_overmap()
	if(ship)
		ship.relay('sound/misc/notice1.ogg', "<span class='boldwarning'>[message]</span>")
	else
		radio.talk_into(src, message, RADIO_CHANNEL_ENGINEERING)

/obj/machinery/pulsar_console/proc/start_storm()
	if(storm_active)
		return
	storm_active = TRUE
	announce("Wysoki poziom promieniowania przy okręcie. Schrońcie się w osłoniętych tunelach technicznych.")
	SSweather.run_weather(/datum/weather/rad_storm/pulsar, ship_z_levels())

/obj/machinery/pulsar_console/proc/end_storm()
	storm_at = 0
	if(!storm_active)
		return
	storm_active = FALSE
	var/list/levels = ship_z_levels()
	for(var/datum/weather/rad_storm/pulsar/storm in SSweather.processing)
		if(length(storm.impacted_z_levels & levels))
			storm.wind_down()
	announce("Satelita pulsara opuścił wiązkę promieniowania. Kto czuje się źle, niech zgłosi się do ambulatorium.")

/obj/machinery/pulsar_console/proc/start_overcharge()
	if(overcharge_active)
		return
	overcharge_active = TRUE
	announce("Satelita pulsara jest przeciążony. Nadmiar energii spływa na okręt.")
	spawn_rift_wave(rand(4, 6))
	bridge?.update_appearance()

/obj/machinery/pulsar_console/proc/end_overcharge()
	overcharge_at = 0
	if(!overcharge_active)
		return
	overcharge_active = FALSE
	QDEL_LIST(rifts)
	announce("Poziom energii satelity pulsara ustabilizowany.")
	bridge?.update_appearance()

/obj/machinery/pulsar_console/proc/spawn_rift_wave(amount)
	next_rift_wave = world.time + PULSAR_RIFT_WAVE
	var/list/areas = list()
	for(var/level in ship_z_levels())
		areas |= SSmapping.areas_in_z["[level]"]
	var/list/turfs = get_safe_random_station_turfs(areas, amount)
	if(isturf(turfs))
		turfs = list(turfs)
	for(var/turf/T as anything in turfs)
		rifts += new /obj/effect/pulsar_rift(T)
	if(length(turfs))
		announce("Kolejna fala energii pulsara spłynęła na okręt.")

/obj/machinery/pulsar_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PulsarConsole", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/pulsar_console/ui_data(mob/user)
	var/list/data = list()
	data["grid"] = PULSAR_GRID
	data["pulsar"] = pulsar_pos()
	data["sat_x"] = sat_x
	data["sat_y"] = sat_y
	data["power"] = produced_power()
	data["shield"] = shield_power
	data["shield_required"] = required_shielding()
	data["effective"] = effective_power()
	data["effective_mw"] = round(PULSAR_MAX_POWER * effective_power() / 100 / 1000000, 0.1)
	data["has_tank"] = !!tank
	data["fuel"] = tank ? round(tank.air_contents.total_moles()) : 0
	data["thrust_cost"] = thrust_cost()
	data["decay_minutes"] = max(0, round((next_decay - world.time) / (1 MINUTES), 0.1))
	data["connected"] = !!events_enabled()
	data["storm_eta"] = (storm_at && !storm_active) ? max(0, round((storm_at - world.time) / 10)) : null
	data["storm_active"] = storm_active
	data["overcharge_eta"] = (overcharge_at && !overcharge_active) ? max(0, round((overcharge_at - world.time) / 10)) : null
	data["overcharge_active"] = overcharge_active
	return data

/obj/machinery/pulsar_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Brak dostępu. Konsolą orbity steruje inżynieria.</span>")
		return
	switch(action)
		if("move")
			var/direction = text2num(params["dir"])
			if(!move_satellite(direction))
				to_chat(usr, "<span class='warning'>Za mało paliwa w zbiorniku satelity.</span>")
				return
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 30, FALSE)
			return TRUE
		if("set_shield")
			shield_power = clamp(round(text2num(params["value"])), 0, 99)
			check_events()
			return TRUE
		if("scan_tank")
			scan_for_tank()
			return TRUE

// ---------------------------------------------------------------- zbiornik paliwa

/obj/structure/pulsar_fuel_tank
	name = "zbiornik paliwa satelity"
	desc = "Wielki zbiornik paliwa dla dysz satelity pulsara. Napełnia się go przenośnymi butlami z gazem; najlepsza jest czysta plazma."
	icon = 'aquila/icons/obj/machinery/pulsar_machinery.dmi'
	icon_state = "pulsar_tank"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	var/datum/gas_mixture/air_contents
	var/volume = 700
	var/obj/machinery/pulsar_console/console

/obj/structure/pulsar_fuel_tank/Initialize(mapload)
	. = ..()
	air_contents = new(volume)
	air_contents.set_temperature(T20C)

/obj/structure/pulsar_fuel_tank/Destroy()
	if(console?.tank == src)
		console.tank = null
	console = null
	QDEL_NULL(air_contents)
	return ..()

/obj/structure/pulsar_fuel_tank/update_icon_state()
	. = ..()
	icon_state = round(air_contents.total_moles()) > 100 ? "pulsar_tank_burst" : "pulsar_tank"

/obj/structure/pulsar_fuel_tank/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Paliwo: [round(air_contents.total_moles())]/100 moli.</span>"
	if(round(air_contents.total_moles()) >= 100)
		. += "<span class='danger'>Wygląda, jakby miał zaraz pęknąć!</span>"

/obj/structure/pulsar_fuel_tank/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/tank))
		return ..()
	var/obj/item/tank/gas_tank = W
	var/datum/gas_mixture/removed = gas_tank.air_contents.remove_ratio(1)
	air_contents.merge(removed)
	to_chat(user, "<span class='notice'>Przepompowujesz zawartość [gas_tank] do [src].</span>")
	playsound(src, 'sound/effects/spray.ogg', 50, TRUE, -3)
	update_appearance()
	check_burst()
	return TRUE

/obj/structure/pulsar_fuel_tank/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	to_chat(user, "<span class='notice'>[src] napełnia się tylko przenośnymi butlami z gazem.</span>")

/// Przepełniony zbiornik pęka i wypuszcza gaz
/obj/structure/pulsar_fuel_tank/proc/check_burst()
	var/moles = round(air_contents.total_moles())
	if(moles >= 125)
		var/turf/T = get_turf(src)
		visible_message("<span class='danger'>[src] pęka z hukiem i cały gaz wylewa się na zewnątrz!</span>")
		playsound(src, 'sound/effects/smoke.ogg', 100, TRUE, -3)
		T?.assume_air(air_contents)
		T?.air_update_turf()
		qdel(src)
	else if(moles > 100)
		visible_message("<span class='danger'>[src] wygląda, jakby miał zaraz pęknąć!</span>")

/obj/structure/pulsar_fuel_tank/filled/Initialize(mapload)
	. = ..()
	air_contents.set_moles(GAS_PLASMA, 3 * ONE_ATMOSPHERE * volume / (R_IDEAL_GAS_EQUATION * T20C))
	update_appearance()

// ---------------------------------------------------------------- mostek mocy

/obj/machinery/power/pulsar_bridge
	name = "mostek mocy pulsara"
	desc = "Odbiera energię z satelity pulsara i oddaje ją do sieci okrętu. Rozłączenie zatrzymuje burze i przeciążenia, ale ponowne połączenie trwa."
	icon = 'aquila/icons/obj/machinery/pulsar_power_bridge.dmi'
	icon_state = "bridge"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	pixel_x = -8
	layer = ABOVE_MOB_LAYER
	circuit = /obj/item/circuitboard/machine/pulsar_bridge
	var/connected = TRUE
	var/disconnect_time = -PULSAR_RECONNECT_COOLDOWN
	var/obj/machinery/pulsar_console/console

/obj/machinery/power/pulsar_bridge/Initialize(mapload)
	. = ..()
	connect_to_network()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/power/pulsar_bridge/LateInitialize()
	. = ..()
	find_console()

/obj/machinery/power/pulsar_bridge/Destroy()
	if(console?.bridge == src)
		console.bridge = null
		console.check_events()
	console = null
	return ..()

/// Konsola orbity na tym samym okręcie
/obj/machinery/power/pulsar_bridge/proc/find_console()
	var/obj/structure/overmap/ship = get_overmap()
	for(var/obj/machinery/pulsar_console/candidate as anything in GLOB.pulsar_consoles)
		if(candidate.bridge && candidate.bridge != src)
			continue
		if(candidate.get_overmap() != ship)
			continue
		console = candidate
		candidate.bridge = src
		break
	update_appearance()
	return console

/obj/machinery/power/pulsar_bridge/proc/output_power()
	if(!connected || !console || (console.machine_stat & (BROKEN|NOPOWER)))
		return 0
	return PULSAR_MAX_POWER * console.effective_power() / 100

/obj/machinery/power/pulsar_bridge/process(delta_time)
	if(!console)
		find_console()
	var/output = output_power()
	if(powernet && output > 0)
		add_avail(output)
	update_appearance()

/obj/machinery/power/pulsar_bridge/update_icon_state()
	. = ..()
	if(machine_stat & BROKEN)
		icon_state = "bridge_broken"
	else if(!connected || !console)
		icon_state = "bridge"
	else if(console.overcharge_active)
		icon_state = "bridge_on_crit"
	else
		icon_state = "bridge_on[clamp(round(console.effective_power() / 10), 1, 6)]"

/obj/machinery/power/pulsar_bridge/proc/toggle_connection(mob/user)
	if(connected)
		connected = FALSE
		disconnect_time = world.time
	else
		if(world.time < disconnect_time + PULSAR_RECONNECT_COOLDOWN)
			return FALSE
		connected = TRUE
	console?.check_events()
	update_appearance()
	return TRUE

/obj/machinery/power/pulsar_bridge/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PulsarBridge", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/power/pulsar_bridge/ui_data(mob/user)
	var/list/data = list()
	data["connected"] = connected
	data["has_console"] = !!console
	data["percent"] = console ? console.effective_power() : 0
	data["output_mw"] = round(output_power() / 1000000, 0.1)
	data["reconnect_in"] = connected ? 0 : max(0, round((disconnect_time + PULSAR_RECONNECT_COOLDOWN - world.time) / 10))
	data["overcharge"] = console?.overcharge_active
	return data

/obj/machinery/power/pulsar_bridge/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "toggle")
		if(!toggle_connection(usr))
			to_chat(usr, "<span class='warning'>Mostek jeszcze nie może się ponownie połączyć.</span>")
			return
		log_game("[key_name(usr)] [connected ? "połączył" : "rozłączył"] mostek mocy pulsara w [AREACOORD(src)]")
		return TRUE

/obj/item/circuitboard/machine/pulsar_bridge
	name = "mostek mocy pulsara (płytka maszyny)"
	build_path = /obj/machinery/power/pulsar_bridge
	req_components = list(
		/obj/item/stock_parts/capacitor = 4,
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/plasteel = 5)

// ---------------------------------------------------------------- wydarzenia

/// Burza z pulsara trwa, dopóki satelita nie wyjdzie z wiązki (koniec woła konsola)
/datum/weather/rad_storm/pulsar
	name = "burza z pulsara"
	desc = "Wiązka promieniowania pulsara omiata okręt."
	telegraph_duration = 300
	weather_duration_lower = 1 HOURS
	weather_duration_upper = 1 HOURS
	probability = 0

/// Szczelina energii przy przeciążeniu: strzela wiązkami jak emiter
/obj/effect/pulsar_rift
	name = "szczelina energii pulsara"
	desc = "Rozdarcie w przestrzeni, przez które spływa nadmiar energii satelity. Lepiej nie stać na linii strzału."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	color = "#82C2D8"
	anchored = TRUE
	density = FALSE
	light_range = 3
	light_color = "#82C2D8"

/obj/effect/pulsar_rift/proc/discharge()
	if(!prob(50))
		return
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/obj/item/projectile/beam/emitter/beam = new(T)
	beam.firer = src
	beam.fired_from = src
	playsound(T, 'sound/weapons/emitter.ogg', 40, TRUE)
	beam.fire(rand(0, 359))

#undef PULSAR_GRID
#undef PULSAR_MAX_POWER
#undef PULSAR_EVENT_WARNING
#undef PULSAR_ORBIT_DECAY
#undef PULSAR_RECONNECT_COOLDOWN
#undef PULSAR_RIFT_WAVE
